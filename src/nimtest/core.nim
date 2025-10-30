## Core testing utilities - Nim Test Framework
## Core components: TestContext, assertions, basic helpers

import std/[os, strutils, times]
import ./config

type
  TestContext* = ref object
    ## Test context for managing test resources (using ref object for better resource management)
    tempDirs*: seq[string]
    tempFiles*: seq[string]
    startTime*: Time
    isCleanedUp*: bool  # Track cleanup status

proc createTestContext*(): TestContext =
  ## Creates a new test context with proper initialization
  new(result)
  result.tempDirs = @[]
  result.tempFiles = @[]
  result.startTime = getTime()
  result.isCleanedUp = false

proc cleanup*(ctx: var TestContext) =
  ## Clean up all temporary test resources with verification
  if ctx.isNil:
    return  # Prevent nil context
  
  if ctx.isCleanedUp:
    return  # Prevent double cleanup
  defer: ctx.isCleanedUp = true

  for f in ctx.tempFiles:
    if fileExists(f):
      try: removeFile(f) except: discard
  for d in ctx.tempDirs:
    if dirExists(d):
      try: removeDir(d) except: discard

proc createTempTestDir*(ctx: var TestContext, prefix: string = ""): string =
  ## Create a temporary test directory and track it for cleanup
  if ctx.isNil:
    raise newException(ValueError, "TestContext cannot be nil")
  
  let actualPrefix = if prefix == "": TempDirPrefix & ProjectName else: prefix
  if actualPrefix.len == 0:
    raise newException(ValueError, "Prefix cannot be empty after processing")
  
  result = getTempDir() / (actualPrefix & "_" & $cast[int](getTime().toUnix()))
  try:
    createDir(result)
    ctx.tempDirs.add(result)
  except OSError as e:
    raise newException(OSError, "Failed to create temporary directory " & result & ": " & e.msg)

proc createTestFile*(ctx: var TestContext, dir: string, name: string, content: string = ""): string =
  ## Create a test file with specified content
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
  ## Asserts that a file exists at the specified path
  let errorMsg = if msg == "": "File does not exist: " & path else: msg
  let exists = fileExists(path)
  if not exists:
    raise newException(AssertionDefect, errorMsg)
  return exists

proc assertDirExists*(path: string, msg: string = ""): bool =
  ## Assert that a directory exists, return true if assertion passes
  let errorMsg = if msg == "": "Directory does not exist: " & path else: msg
  let exists = dirExists(path)
  if not exists:
    raise newException(AssertionDefect, errorMsg)
  return exists

proc assertFileContains*(path: string, content: string, msg: string = ""): bool =
  ## Assert that a file contains specific content, return true if assertion passes
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  if content.len == 0:
    # Empty content is always considered to be contained
    return true
  
  let fileContent = readFile(path)
  let contains = content in fileContent
  let errorMsg = if msg == "": "File does not contain: " & content else: msg
  if not contains:
    raise newException(AssertionDefect, errorMsg)
  return contains

proc assertFileContainsFast*(path: string, content: string, msg: string = ""): bool =
  ## Fast version of assertFileContains with performance optimization using memmem via strutils.find
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  if content.len == 0:
    return true

  # Using strutils.find for performance improvement (10x faster as mentioned in PDD)
  let fileContent = readFile(path)
  let contains = find(fileContent, content) >= 0
  let errorMsg = if msg == "": "File does not contain: " & content else: msg
  if not contains:
    raise newException(AssertionDefect, errorMsg)
  return contains

proc measureTime*(label: string, body: proc()): float =
  ## Measure execution time of a code block (using cpuTime as mentioned in PDD)
  let start = cpuTime()
  body()
  let duration = cpuTime() - start
  let durationMs = duration * 1000
  echo "[PERF] ", label, ": ", formatFloat(durationMs, ffDecimal, 3), " ms"
  return duration

# Export all public symbols
export
  TestContext,
  createTestContext,
  cleanup,
  createTempTestDir,
  createTestFile,
  assertFileExists,
  assertDirExists,
  assertFileContains,
  assertFileContainsFast,
  measureTime