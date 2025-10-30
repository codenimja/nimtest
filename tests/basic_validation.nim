## Basic validation test for nimtest framework
import ../src/nimtest
import std/os

echo "Testing nimtest import and basic functionality..."

# Test that we can create a TestContext
var ctx = createTestContext()
echo "✓ TestContext creation works"

# Test basic helper functions
let tempDir = createTempTestDir(ctx, "validation")
doAssert dirExists(tempDir)
echo "✓ Temporary directory creation works"

let testFile = createTestFile(ctx, tempDir, "test.txt", "validation content")
doAssert fileExists(testFile)
doAssert readFile(testFile) == "validation content"
echo "✓ File operations work"

# Test assertion functions
discard assertFileExists(testFile)
discard assertFileContains(testFile, "validation content")
discard assertFileDoesNotContain(testFile, "missing content")
echo "✓ Assertion functions work"

# Test advanced functionality
let duration = measureTime("Simple operation"):
  proc() = 
    sleep(10)  # Small delay to measure

echo "✓ Time measurement works (duration: ", duration, "s)"

# Test benchmark functionality
let benchResult = benchmark("Simple increment", 1000):
  proc() = 
    var x = 0
    inc(x)

echo "✓ Benchmark functionality works (avg: ", benchResult.avg, "s)"

# Clean up
cleanup(ctx)
echo "✓ Cleanup works"

echo "All basic nimtest functionality validated!"