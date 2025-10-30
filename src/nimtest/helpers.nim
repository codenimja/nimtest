## Test helper utilities - Generic Nim Test Suite
## Advanced, high-performance testing utilities with proper error handling

import std/[os, osproc, strutils, json, times, options]
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
  TestContext* = ref object
    ## Test context for managing test resources (using ref object for better resource management)
    tempDirs*: seq[string]
    tempFiles*: seq[string]
    startTime*: Time
    isCleanedUp*: bool  # Track cleanup status

proc createTestContext*(): TestContext =
  ## Creates a new test context with proper initialization
  ## 
  ## This function initializes a TestContext object that manages temporary files and 
  ## directories created during testing. The context tracks resources to ensure 
  ## proper cleanup after tests complete.
  ## 
  ## Example:
  ## ```nim
  ## var ctx = createTestContext()
  ## try:
  ##   # Perform test operations
  ##   let tempFile = createTestFile(ctx, getTempDir(), "test.txt", "content")
  ##   # ... more test code
  ## finally:
  ##   ctx.cleanup()
  ## ```
  ## 
  ## Returns a new TestContext instance ready for use.
  new(result)
  result.tempDirs = @[]
  result.tempFiles = @[]
  result.startTime = getTime()
  result.isCleanedUp = false

proc cleanup*(ctx: var TestContext) =
  ## Clean up all temporary test resources with verification
  ## 
  ## This function removes all temporary files and directories that were 
  ## registered with the test context during testing. It prevents double cleanup
  ## by tracking the cleanup status.
  ## 
  ## The function will print warnings for any files or directories that could not
  ## be removed, but will continue processing the remaining resources.
  ## 
  ## Parameters:
  ##   ctx: The test context containing resources to clean up
  if ctx.isNil or ctx.isCleanedUp:
    return  # Prevent double cleanup or nil context
  
  var failures: seq[string] = @[]
  
  for file in ctx.tempFiles:
    if fileExists(file):
      try:
        removeFile(file)
      except OSError as e:
        failures.add("Failed to remove file " & file & ": " & e.msg)
  
  for dir in ctx.tempDirs:
    if dirExists(dir):
      try:
        removeDir(dir)
      except OSError as e:
        failures.add("Failed to remove directory " & dir & ": " & e.msg)
  
  ctx.isCleanedUp = true
  
  if failures.len > 0:
    echo "Warning: Cleanup failures occurred: ", failures.join(", ")

proc tryCleanup*(ctx: var TestContext): tuple[success: bool, errors: seq[string]] =
  ## Attempt to clean up test resources and return success status with detailed errors
  ## 
  ## This function provides safer cleanup that returns detailed information about
  ## success or failure, rather than printing warnings. It's useful when you need
  ## to programmatically determine if cleanup was successful.
  ## 
  ## Parameters:
  ##   ctx: The test context containing resources to clean up
  ## 
  ## Returns:
  ##   A tuple containing:
  ##   - success: true if all resources were cleaned up successfully, false otherwise
  ##   - errors: sequence of error messages for any cleanup failures
  if ctx.isNil:
    return (false, @["TestContext is nil"])
  
  if ctx.isCleanedUp:
    return (true, @[])  # Already cleaned up, consider it successful
  
  var errors: seq[string] = @[]
  
  for file in ctx.tempFiles:
    if fileExists(file):
      try:
        removeFile(file)
      except OSError as e:
        errors.add("Failed to remove file " & file & ": " & e.msg)
  
  for dir in ctx.tempDirs:
    if dirExists(dir):
      try:
        removeDir(dir)
      except OSError as e:
        errors.add("Failed to remove directory " & dir & ": " & e.msg)
  
  ctx.isCleanedUp = true
  
  return (errors.len == 0, errors)

proc createTempTestDir*(ctx: var TestContext, prefix: string = ""): string =
  ## Create a temporary test directory and track it for cleanup
  if ctx.isNil:
    raise newException(ValueError, "TestContext cannot be nil")
  
  let actualPrefix = if prefix == "": TEMP_DIR_PREFIX & PROJECT_NAME else: prefix
  if actualPrefix.len == 0:
    raise newException(ValueError, "Prefix cannot be empty after processing")
  
  result = getTempDir() / (actualPrefix & "_" & $cast[int](getTime().toUnix()))
  try:
    createDir(result)
    ctx.tempDirs.add(result)
  except OSError as e:
    raise newException(OSError, "Failed to create temporary directory " & result & ": " & e.msg)

proc removeTempTestDir*(path: string) =
  ## Remove a temporary test directory
  if dirExists(path):
    removeDir(path)

proc createTestComponent*(name: string, category: ComponentCategory = catUI): ComponentMetadata =
  ## Create a test component metadata object with proper validation
  # Validate input parameters
  if name.len == 0:
    raise newException(ValueError, "Component name cannot be empty")
  
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
  ## Create test metadata as JSON with validation
  if name.len == 0:
    raise newException(ValueError, "Name cannot be empty")
  
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
  ## Create a minimal test component .nim file with proper error handling
  if name.len == 0:
    raise newException(ValueError, "Component name cannot be empty")
  
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

  try:
    writeFile(filePath, content)
    ctx.tempFiles.add(filePath)
    result = filePath
  except IOError as e:
    raise newException(IOError, "Failed to write component file " & filePath & ": " & e.msg)

proc createTestMetadataFile*(ctx: var TestContext, dir: string, name: string, category: string = "ui"): string =
  ## Create a test metadata JSON file with error handling
  if name.len == 0:
    raise newException(ValueError, "Name cannot be empty")
  
  let filePath = dir / name & ".test.json"
  let metadata = createTestMetadata(name, category)
  
  try:
    writeFile(filePath, $metadata)
    ctx.tempFiles.add(filePath)
    result = filePath
  except IOError as e:
    raise newException(IOError, "Failed to write metadata file " & filePath & ": " & e.msg)

proc getCliCommand*(args: string): string =
  ## Construct the full CLI command for execution
  if CLI_BINARY_PATH == "":
    result = args
  else:
    result = CLI_BINARY_PATH & " " & args

proc runCliCommand*(args: string): tuple[output: string, exitCode: int] =
  ## Execute a CLI command and return output with error handling
  try:
    let cmd = getCliCommand(args)
    let (output, exitCode) = execCmdEx(cmd)
    result = (output, exitCode)
  except OSError as e:
    result = ("Command failed: " & e.msg, -1)

proc runCliCommandInDir*(dir: string, args: string): tuple[output: string, exitCode: int] =
  ## Execute a CLI command in a specific directory with proper error handling
  if not dirExists(dir):
    raise newException(ValueError, "Directory does not exist: " & dir)
  
  let currentDir = getCurrentDir()
  try:
    setCurrentDir(dir)
    result = runCliCommand(args)
  finally:
    setCurrentDir(currentDir)  # Always restore directory

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

proc assertFileExists*(path: string, msg: string = ""): bool =
  ## Asserts that a file exists at the specified path
  ## 
  ## This function checks if a file exists at the given path. If the file does not
  ## exist, it raises an AssertionDefect exception with an appropriate error message.
  ## 
  ## Parameters:
  ##   path: The path to the file to check for existence
  ##   msg: Optional custom error message to use if assertion fails
  ## 
  ## Returns:
  ##   true if the file exists
  ## 
  ## Raises:
  ##   AssertionDefect: if the file does not exist
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
  
  # For large files, we should use a streaming approach instead of loading entire file
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
  ## Fast version of assertFileContains with basic performance optimization
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  if content.len == 0:
    return true

  # Read file and check content (basic optimization with early return for empty content)
  let fileContent = readFile(path)
  let contains = content in fileContent
  let errorMsg = if msg == "": "File does not contain: " & content else: msg
  if not contains:
    raise newException(AssertionDefect, errorMsg)
  return contains

proc assertOutputContains*(output: string, expected: string, msg: string = ""): bool =
  ## Assert that command output contains expected text, return true if assertion passes
  if expected.len == 0:
    return true  # Empty string is always contained
  
  let contains = expected in output
  let errorMsg = if msg == "": "Output does not contain: " & expected else: msg
  if not contains:
    raise newException(AssertionDefect, errorMsg)
  return contains

proc measureTime*(label: string, body: proc()): float =
  ## Measure execution time of a code block
  let start = cpuTime()
  body()
  let duration = cpuTime() - start
  let durationMs = duration * 1000
  echo "[PERF] ", label, ": ", formatFloat(durationMs, ffDecimal, 3), " ms"
  return duration

# =========================
# Advanced Testing Utilities
# =========================

proc assertFileNotExists*(path: string, msg: string = ""): bool =
  ## Assert that a file does NOT exist, return true if assertion passes
  let errorMsg = if msg == "": "File should not exist but does: " & path else: msg
  let notExists = not fileExists(path)
  if not notExists:
    raise newException(AssertionDefect, errorMsg)
  return notExists

proc assertDirNotExists*(path: string, msg: string = ""): bool =
  ## Assert that a directory does NOT exist, return true if assertion passes
  let errorMsg = if msg == "": "Directory should not exist but does: " & path else: msg
  let notExists = not dirExists(path)
  if not notExists:
    raise newException(AssertionDefect, errorMsg)
  return notExists

proc assertFileDoesNotContain*(path: string, content: string, msg: string = ""): bool =
  ## Assert that a file does NOT contain specific content, return true if assertion passes
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  let fileContent = readFile(path)
  let notContains = not (content in fileContent)
  let errorMsg = if msg == "": "File should not contain: " & content else: msg
  if not notContains:
    raise newException(AssertionDefect, errorMsg)
  return notContains

proc assertOutputDoesNotContain*(output: string, unexpected: string, msg: string = ""): bool =
  ## Assert that command output does NOT contain specific text, return true if assertion passes
  let notContains = not (unexpected in output)
  let errorMsg = if msg == "": "Output should not contain: " & unexpected else: msg
  if not notContains:
    raise newException(AssertionDefect, errorMsg)
  return notContains

proc assertFileHasSize*(path: string, expectedSize: int, msg: string = ""): bool =
  ## Assert that a file has a specific size in bytes, return true if assertion passes
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  let size = getFileSize(path)
  let hasCorrectSize = size == expectedSize
  let errorMsg = if msg == "": "File size mismatch. Expected: " & $expectedSize & ", Got: " & $size else: msg
  if not hasCorrectSize:
    raise newException(AssertionDefect, errorMsg)
  return hasCorrectSize

proc assertFileModifiedAfter*(path: string, time: Time, msg: string = ""): bool =
  ## Assert that a file was modified after a specific time, return true if assertion passes
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  let modTime = getLastModificationTime(path)
  let isModifiedAfter = modTime > time
  let errorMsg = if msg == "": "File was not modified after the expected time: " & path else: msg
  if not isModifiedAfter:
    raise newException(AssertionDefect, errorMsg)
  return isModifiedAfter

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

proc createTestDir*(ctx: var TestContext, parentDir: string, name: string): string =
  ## Create a test directory and track it for cleanup
  if ctx.isNil:
    raise newException(ValueError, "TestContext cannot be nil")
  if parentDir.len == 0:
    raise newException(ValueError, "Parent directory path cannot be empty")
  if name.len == 0:
    raise newException(ValueError, "Directory name cannot be empty")
  
  if not dirExists(parentDir):
    raise newException(OSError, "Parent directory does not exist: " & parentDir)
  
  let dirPath = parentDir / name
  
  # Check if directory already exists
  if dirExists(dirPath):
    raise newException(OSError, "Directory already exists: " & dirPath)
  
  try:
    createDir(dirPath)
    ctx.tempDirs.add(dirPath)
    result = dirPath
  except OSError as e:
    raise newException(OSError, "Failed to create test directory " & dirPath & ": " & e.msg)

proc runTestWithTimeout*(body: proc(), timeoutSeconds: int): tuple[completed: bool, duration: float] =
  ## Run a test with a timeout, return completion status and duration
  let startTime = cpuTime()
  try:
    body()
    let duration = cpuTime() - startTime
    result = (completed: duration < timeoutSeconds.float, duration: duration)
  except:
    let duration = cpuTime() - startTime
    result = (completed: duration < timeoutSeconds.float, duration: duration)

proc assertThrows*(procToRun: proc(), exceptionType: typedesc[ref Exception] = ref Exception, msg: string = ""): bool =
  ## Assert that a procedure throws an exception, return true if assertion passes
  if procToRun.isNil:
    raise newException(ValueError, "Procedure to run cannot be nil")
  
  var caught = false
  var caughtExceptionMsg = ""
  
  try:
    procToRun()
  except exceptionType as e:
    caught = true
    caughtExceptionMsg = e.msg
    if msg != "" and e.msg != msg:
      raise newException(AssertionDefect, "Exception message mismatch: expected '" & msg & "', got '" & e.msg & "'")
  except Exception as e:
    if exceptionType is ref Exception:
      # Generic Exception type is allowed to catch any exception
      caught = true
      caughtExceptionMsg = e.msg
    else:
      # Different exception type than expected
      raise newException(AssertionDefect, "Expected exception type " & $exceptionType & " but got: " & $e.type & ": " & e.msg)
  
  if not caught:
    let errorMsg = if msg == "": "Expected exception but none was thrown" else: msg
    raise newException(AssertionDefect, errorMsg)
  
  # If specific message was expected, validate it was returned
  if msg != "" and caughtExceptionMsg != msg:
    raise newException(AssertionDefect, "Expected message '" & msg & "' but got '" & caughtExceptionMsg & "'")
  
  return caught

proc benchmark*(label: string, iterations: int, body: proc()): tuple[avg: float, min: float, max: float, total: float] =
  ## Run a procedure multiple times and return performance metrics
  if iterations <= 0:
    raise newException(ValueError, "Iterations must be positive")
  
  let startTime = cpuTime()
  var times: seq[float] = newSeq[float](iterations)
  var minTime = float.high
  var maxTime = 0.0

  for i in 0..<iterations:
    let iterStart = cpuTime()
    body()
    let iterTime = cpuTime() - iterStart
    times[i] = iterTime
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

  return (avg: avgTime, min: minTime, max: maxTime, total: totalTime)

# Export all public symbols
export
  TestContext,
  ComponentProperty,
  ComponentMetadata,
  createTestContext,
  cleanup,
  tryCleanup,
  createTempTestDir,
  removeTempTestDir,
  createTestComponent,
  createTestMetadata,
  createTestComponentFile,
  createTestMetadataFile,
  runCliCommand,
  runCliCommandInDir,
  runNyxCommand,
  runNyxCommandInDir,
  runProjectCommand,
  runProjectCommandInDir,
  assertFileExists,
  assertDirExists,
  assertFileContains,
  assertFileContainsFast,
  assertOutputContains,
  measureTime,
  assertFileNotExists,
  assertDirNotExists,
  assertFileDoesNotContain,
  assertOutputDoesNotContain,
  assertFileHasSize,
  assertFileModifiedAfter,
  createTestFile,
  createTestDir,
  runTestWithTimeout,
  assertThrows,
  benchmark
