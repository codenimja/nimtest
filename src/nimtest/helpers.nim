## Additional test helper utilities - Nim Test Framework
## Extended helper functions beyond core functionality

import std/[os, strutils, times, osproc]
# Import statements for core and config are intentionally commented out
# as they're not currently used but kept for future extensibility

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

# =========================
# CLI Testing Utilities
# =========================

proc runCliCommand*(command: string, workingDir: string = ""): tuple[output: string, exitCode: int] =
  ## Execute a CLI command and return its output and exit code
  ## 
  ## Parameters:
  ##   command: The command to execute
  ##   workingDir: Optional working directory (defaults to current)
  ##
  ## Returns:
  ##   Tuple of (output: string, exitCode: int)
  if command.len == 0:
    raise newException(ValueError, "Command cannot be empty")
  
  let wd = if workingDir.len == 0: getCurrentDir() else: workingDir
  if not dirExists(wd):
    raise newException(OSError, "Working directory does not exist: " & wd)
  
  try:
    let (output, exitCode) = execCmdEx(command, workingDir = wd)
    result = (output: output, exitCode: exitCode)
  except OSError as e:
    raise newException(OSError, "Failed to execute command '" & command & "': " & e.msg)

proc assertExitCode*(exitCode: int, expected: int, msg: string = ""): bool =
  ## Assert that an exit code matches the expected value
  let matches = exitCode == expected
  let errorMsg = if msg == "": "Exit code mismatch. Expected: " & $expected & ", Got: " & $exitCode else: msg
  if not matches:
    raise newException(AssertionDefect, errorMsg)
  return matches

proc assertOutputContains*(output: string, expected: string, msg: string = ""): bool =
  ## Assert that command output contains specific text
  let contains = expected in output
  let errorMsg = if msg == "": "Output does not contain: " & expected else: msg
  if not contains:
    raise newException(AssertionDefect, errorMsg)
  return contains

# Export all public symbols
export
  assertFileNotExists,
  assertDirNotExists,
  assertFileDoesNotContain,
  assertOutputDoesNotContain,
  assertFileHasSize,
  assertFileModifiedAfter,
  runTestWithTimeout,
  assertThrows,
  benchmark,
  runCliCommand,
  assertExitCode,
  assertOutputContains
