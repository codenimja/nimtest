## Test helper utilities - Generic Nim Test Suite

import std/[os, osproc, strutils, json, times]
import test_config  # Import project configuration

# Use ModuleCategory from test_config instead of ComponentCategory
export ModuleCategory

# Alias for backward compatibility with existing tests
type
  ComponentCategory* = ModuleCategory

# Map old categories to new ones
const
  catUI* = catGeneral
  catLayout* = catCore
  catInput* = catUtility
  catDisplay* = catExtension
  catFeedback* = catPlugin

type
  ComponentProperty* = object
    name*: string
    typeName*: string
    defaultValue*: string
    description*: string

  ComponentMetadata* = object
    name*: string
    displayName*: string
    category*: ComponentCategory
    description*: string
    version*: string
    author*: string
    tags*: seq[string]
    dependencies*: seq[string]
    properties*: seq[ComponentProperty]
    variants*: seq[string]
    filePath*: string
    examplePath*: string
    previewImage*: string

type
  TestContext* = object
    ## Test context for managing test resources
    tempDirs*: seq[string]
    tempFiles*: seq[string]
    startTime*: Time

proc createTestContext*(): TestContext =
  ## Create a new test context
  result = TestContext(
    tempDirs: @[],
    tempFiles: @[],
    startTime: getTime()
  )

proc cleanup*(ctx: var TestContext) =
  ## Clean up all temporary test resources
  for file in ctx.tempFiles:
    if fileExists(file):
      removeFile(file)

  for dir in ctx.tempDirs:
    if dirExists(dir):
      removeDir(dir)

proc createTempTestDir*(ctx: var TestContext, prefix: string = ""): string =
  ## Create a temporary test directory and track it for cleanup
  let actualPrefix = if prefix == "": TEMP_DIR_PREFIX & PROJECT_NAME else: prefix
  result = getTempDir() / (actualPrefix & "_" & $epochTime().int)
  createDir(result)
  ctx.tempDirs.add(result)

proc removeTempTestDir*(path: string) =
  ## Remove a temporary test directory
  if dirExists(path):
    removeDir(path)

proc createTestComponent*(name: string, category: ComponentCategory = catUI): ComponentMetadata =
  ## Create a test component metadata object
  result = ComponentMetadata(
    name: name,
    displayName: name.capitalizeAscii(),
    category: category,
    description: "Test component: " & name,
    version: "1.0.0-test",
    author: "Test Suite",
    tags: @["test"],
    dependencies: @["nigui"],
    properties: @[],
    variants: @["default"],
    filePath: "test/" & name & ".nim",
    examplePath: "",
    previewImage: ""
  )

proc createTestMetadata*(name: string, category: string = "ui"): JsonNode =
  ## Create test metadata as JSON
  result = %* {
    "name": name,
    "displayName": name.capitalizeAscii(),
    "category": category,
    "description": "Test component: " & name,
    "version": "1.0.0-test",
    "author": "Test Suite",
    "tags": ["test"],
    "dependencies": ["nigui"],
    "properties": [],
    "variants": ["default"],
    "filePath": "test/" & name & ".nim",
    "examplePath": "",
    "previewImage": ""
  }

proc createTestComponentFile*(ctx: var TestContext, dir: string, name: string): string =
  ## Create a minimal test component .nim file
  let filePath = dir / name & ".nim"
  let content = """
import nigui

type
  $1* = ref object of LayoutContainer
    label: Label

proc new$1*(): $1 =
  result = new $1
  result.init()
  result.label = newLabel("Test: $1")
  result.add(result.label)

when isMainModule:
  app.init()
  var window = newWindow("Test")
  var comp = new$1()
  window.add(comp)
  window.show()
  app.run()
""" % [name.capitalizeAscii()]

  writeFile(filePath, content)
  ctx.tempFiles.add(filePath)
  result = filePath

proc createTestMetadataFile*(ctx: var TestContext, dir: string, name: string, category: string = "ui"): string =
  ## Create a test metadata JSON file
  let filePath = dir / name & ".test.json"
  let metadata = createTestMetadata(name, category)
  writeFile(filePath, $metadata)
  ctx.tempFiles.add(filePath)
  result = filePath

proc runCliCommand*(args: string): tuple[output: string, exitCode: int] =
  ## Execute a CLI command and return output
  let cmd = getCliCommand(args)
  let (output, exitCode) = execCmdEx(cmd)
  result = (output, exitCode)

proc runCliCommandInDir*(dir: string, args: string): tuple[output: string, exitCode: int] =
  ## Execute a CLI command in a specific directory
  let currentDir = getCurrentDir()
  setCurrentDir(dir)
  result = runCliCommand(args)
  setCurrentDir(currentDir)

# Backward compatibility aliases
proc runNyxCommand*(args: string): tuple[output: string, exitCode: int] =
  ## Legacy name - use runCliCommand instead
  runCliCommand(args)

proc runNyxCommandInDir*(dir: string, args: string): tuple[output: string, exitCode: int] =
  ## Legacy name - use runCliCommandInDir instead
  runCliCommandInDir(dir, args)

# Additional aliases for clarity
proc runProjectCommand*(args: string): tuple[output: string, exitCode: int] =
  ## Execute a project command and return output (alias for runCliCommand)
  runCliCommand(args)

proc runProjectCommandInDir*(dir: string, args: string): tuple[output: string, exitCode: int] =
  ## Execute a project command in a specific directory (alias for runCliCommandInDir)
  runCliCommandInDir(dir, args)

proc assertFileExists*(path: string, msg: string = "") =
  ## Assert that a file exists
  let errorMsg = if msg == "": "File does not exist: " & path else: msg
  doAssert fileExists(path), errorMsg

proc assertDirExists*(path: string, msg: string = "") =
  ## Assert that a directory exists
  let errorMsg = if msg == "": "Directory does not exist: " & path else: msg
  doAssert dirExists(path), errorMsg

proc assertFileContains*(path: string, content: string, msg: string = "") =
  ## Assert that a file contains specific content
  doAssert fileExists(path), "File does not exist: " & path
  let fileContent = readFile(path)
  let errorMsg = if msg == "": "File does not contain: " & content else: msg
  doAssert content in fileContent, errorMsg

proc assertOutputContains*(output: string, expected: string, msg: string = "") =
  ## Assert that command output contains expected text
  let errorMsg = if msg == "": "Output does not contain: " & expected else: msg
  doAssert expected in output, errorMsg

proc measureTime*(label: string, body: proc()) =
  ## Measure execution time of a code block
  let start = cpuTime()
  body()
  let duration = cpuTime() - start
  echo "[PERF] ", label, ": ", formatFloat(duration * 1000, ffDecimal, 3), " ms"

# =========================
# Advanced Testing Utilities
# =========================

proc assertFileNotExists*(path: string, msg: string = "") =
  ## Assert that a file does NOT exist
  let errorMsg = if msg == "": "File should not exist but does: " & path else: msg
  doAssert not fileExists(path), errorMsg

proc assertDirNotExists*(path: string, msg: string = "") =
  ## Assert that a directory does NOT exist
  let errorMsg = if msg == "": "Directory should not exist but does: " & path else: msg
  doAssert not dirExists(path), errorMsg

proc assertFileDoesNotContain*(path: string, content: string, msg: string = "") =
  ## Assert that a file does NOT contain specific content
  doAssert fileExists(path), "File does not exist: " & path
  let fileContent = readFile(path)
  let errorMsg = if msg == "": "File should not contain: " & content else: msg
  doAssert not (content in fileContent), errorMsg

proc assertOutputDoesNotContain*(output: string, unexpected: string, msg: string = "") =
  ## Assert that command output does NOT contain specific text
  let errorMsg = if msg == "": "Output should not contain: " & unexpected else: msg
  doAssert not (unexpected in output), errorMsg

proc assertFileHasSize*(path: string, expectedSize: int, msg: string = "") =
  ## Assert that a file has a specific size in bytes
  doAssert fileExists(path), "File does not exist: " & path
  let size = getFileSize(path)
  let errorMsg = if msg == "": "File size mismatch. Expected: " & $expectedSize & ", Got: " & $size else: msg
  doAssert size == expectedSize, errorMsg

proc assertFileModifiedAfter*(path: string, time: Time, msg: string = "") =
  ## Assert that a file was modified after a specific time
  doAssert fileExists(path), "File does not exist: " & path
  let modTime = getLastModificationTime(path)
  let errorMsg = if msg == "": "File was not modified after the expected time: " & path else: msg
  doAssert modTime > time, errorMsg

proc createTestFile*(ctx: var TestContext, dir: string, name: string, content: string = ""): string =
  ## Create a test file with specified content
  let filePath = dir / name
  writeFile(filePath, content)
  ctx.tempFiles.add(filePath)
  result = filePath

proc createTestDir*(ctx: var TestContext, parentDir: string, name: string): string =
  ## Create a test directory and track it for cleanup
  let dirPath = parentDir / name
  createDir(dirPath)
  ctx.tempDirs.add(dirPath)
  result = dirPath

proc captureOutput*(body: proc(): string): tuple[output: string, captured: string] =
  ## Capture output from a procedure while still displaying it
  var captured = ""
  # This is a simplified version - in a real implementation, we'd redirect stdout
  let output = body()
  result = (output: output, captured: output)

proc runTestWithTimeout*(body: proc(), timeoutSeconds: int): bool =
  ## Run a test with a timeout (returns true if completed within timeout)
  let startTime = cpuTime()
  body()
  let duration = cpuTime() - startTime
  result = duration < timeoutSeconds.float

proc assertThrows*(procToRun: proc(), exceptionType: typedesc[ref Exception] = ref Exception, msg: string = "") =
  ## Assert that a procedure throws an exception
  var caught = false
  try:
    procToRun()
  except Exception as e:
    if msg == "":
      caught = true
    else:
      caught = true
  doAssert caught, if msg == "": "Expected exception but none was thrown" else: msg

proc benchmark*(label: string, iterations: int, body: proc()) =
  ## Run a procedure multiple times and report average performance
  let startTime = cpuTime()
  var minTime = float.high
  var maxTime = 0.0

  for i in 0..<iterations:
    let iterStart = cpuTime()
    body()
    let iterTime = cpuTime() - iterStart
    if iterTime < minTime: minTime = iterTime
    if iterTime > maxTime: maxTime = iterTime

  let totalTime = cpuTime() - startTime
  let avgTime = totalTime / float(iterations)

  echo "[BENCH] ", label, ": "
  echo "  Total: ", formatFloat(totalTime * 1000, ffDecimal, 3), " ms"
  echo "  Average: ", formatFloat(avgTime * 1000, ffDecimal, 3), " ms"
  echo "  Min: ", formatFloat(minTime * 1000, ffDecimal, 3), " ms"
  echo "  Max: ", formatFloat(maxTime * 1000, ffDecimal, 3), " ms"
  echo "  Iterations: ", iterations
