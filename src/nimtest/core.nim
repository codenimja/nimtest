import std/[os, times, strutils, strformat]
import config

type
  TestContext* = ref object
    tempDirs*: seq[string]
    tempFiles*: seq[string]
    startTime*: Time
    isCleanedUp*: bool

proc createTestContext*(): TestContext =
  new(result)
  result.tempDirs = @[]
  result.tempFiles = @[]
  result.startTime = getTime()
  result.isCleanedUp = false

proc cleanup*(ctx: var TestContext) =
  if ctx.isNil:
    return
  
  if ctx.isCleanedUp:
    return
  defer: ctx.isCleanedUp = true

  for f in ctx.tempFiles:
    if fileExists(f):
      try: removeFile(f) except: discard
  for d in ctx.tempDirs:
    if dirExists(d):
      try: removeDir(d) except: discard

proc tryCleanup*(ctx: var TestContext): tuple[success: bool, errors: seq[string]] =
  var errors: seq[string] = @[]
  if ctx.isNil:
    errors.add("TestContext is nil")
    return (false, errors)
  
  if ctx.isCleanedUp:
    return (true, errors)
  
  defer: ctx.isCleanedUp = true

  for f in ctx.tempFiles:
    if fileExists(f):
      try: removeFile(f) except: errors.add("Failed to remove file: " & f)
  for d in ctx.tempDirs:
    if dirExists(d):
      try: removeDir(d) except: errors.add("Failed to remove directory: " & d)
  
  return (errors.len == 0, errors)

proc createTempTestDir*(ctx: var TestContext, prefix: string = ""): string =
  if ctx.isNil:
    raise newException(ValueError, "TestContext cannot be nil")
  
  let actualPrefix = if prefix == "": TempDirPrefix & "_" & ProjectName else: prefix
  result = getTempDir() / (actualPrefix & "_" & $cast[int](getTime().toUnix()))
  try:
    createDir(result)
    ctx.tempDirs.add(result)
  except OSError as e:
    raise newException(OSError, "Failed to create temporary directory " & result & ": " & e.msg)

proc createTestFile*(ctx: var TestContext, dir: string, name: string, content: string = ""): string =
  if ctx.isNil:
    raise newException(ValueError, "TestContext cannot be nil")
  if dir.len == 0:
    raise newException(ValueError, "Directory path cannot be empty")
  if name.len == 0:
    raise newException(ValueError, "File name cannot be empty")
  
  if not dirExists(dir):
    raise newException(OSError, "Directory does not exist: " & dir)
  
  let filePath = dir / name
  
  try:
    writeFile(filePath, content)
    ctx.tempFiles.add(filePath)
    result = filePath
  except IOError as e:
    raise newException(IOError, "Failed to create test file " & filePath & ": " & e.msg)

proc assertFileExists*(path: string, msg: string = ""): bool =
  let errorMsg = if msg == "": "File does not exist: " & path else: msg
  let exists = fileExists(path)
  if not exists:
    raise newException(AssertionDefect, errorMsg)
  return exists

proc assertDirExists*(path: string, msg: string = ""): bool =
  let errorMsg = if msg == "": "Directory does not exist: " & path else: msg
  let exists = dirExists(path)
  if not exists:
    raise newException(AssertionDefect, errorMsg)
  return exists

proc assertFileContains*(path: string, content: string, msg: string = ""): bool =
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  if content.len == 0:
    return true
  
  let fileContent = readFile(path)
  let hasContent = content in fileContent
  let errorMsg = if msg == "": "File does not contain: " & content else: msg
  if not hasContent:
    raise newException(AssertionDefect, errorMsg)
  return hasContent

proc assertFileContainsFast*(path: string, content: string, msg: string = ""): bool =
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  if content.len == 0:
    return true

  let fileContent = readFile(path)
  let contains = find(fileContent, content) >= 0
  let errorMsg = if msg == "": "File does not contain: " & content else: msg
  if not contains:
    raise newException(AssertionDefect, errorMsg)
  return contains

proc measureTime*(label: string, body: proc()): float =
  let start = cpuTime()
  body()
  let duration = cpuTime() - start
  let durationMs = duration * 1000
  echo fmt"[PERF] {label}: {durationMs:.3f} ms"
  return duration

# Export all public symbols
export
  TestContext,
  createTestContext,
  cleanup,
  tryCleanup,
  createTempTestDir,
  createTestFile,
  assertFileExists,
  assertDirExists,
  assertFileContains,
  assertFileContainsFast,
  measureTime