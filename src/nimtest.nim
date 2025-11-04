## nimtest binary - Test runner command
## Usage: nimtest [test_file.nim]
## If no file specified, runs examples/test_all.nim

import std/[os, strutils, osproc]

proc runTestFile(filePath: string): int =
  if not fileExists(filePath):
    echo "Error: Test file not found: ", filePath
    return 1

  echo "Running tests from: ", filePath
  echo "========================================"

  let (output, exitCode) = execCmdEx("nim c -r " & filePath)
  echo output

  if exitCode == 0:
    echo "\n✅ All tests passed!"
  else:
    echo "\n❌ Tests failed with exit code: ", exitCode

  return exitCode

proc discoverAndRunTests(): int =
  # Check if we're in the nimtest project directory
  let isNimtestProject = fileExists("nimtest.nimble") or dirExists("examples")
  
  if isNimtestProject:
    # In nimtest project, run the examples
    let defaultTestFile = "examples" / "test_all.nim"
    if fileExists(defaultTestFile):
      return runTestFile(defaultTestFile)
  
  # Look for user test files in current directory
  var testFiles: seq[string] = @[]
  for file in walkDirRec("."):
    if file.endsWith(".nim") and (file.extractFilename.startsWith("test_") or 
                                  file.extractFilename.startsWith("t_")):
      testFiles.add(file)
  
  if testFiles.len > 0:
    echo "Found ", testFiles.len, " test files. Running all..."
    for testFile in testFiles:
      let exitCode = runTestFile(testFile)
      if exitCode != 0:
        return exitCode
    return 0

  # No tests found - provide helpful guidance
  echo "No tests found in current directory."
  echo ""
  echo "To use nimtest:"
  echo "1. Create test files starting with 'test_' or 't_' (e.g., test_mylib.nim)"
  echo "2. Or specify a test file: nimtest path/to/your/test.nim"
  echo ""
  echo "Example test file:"
  echo "  import nimtest/api"
  echo "  "
  echo "  suite \"my tests\":"
  echo "    test \"basic\":"
  echo "      check 1 + 1 == 2"
  echo ""
  return 1

when isMainModule:
  let args = commandLineParams()
  if args.len > 0:
    quit(runTestFile(args[0]))
  else:
    quit(discoverAndRunTests())
