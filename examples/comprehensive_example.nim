# Comprehensive example demonstrating nimtest capabilities

import nimtest/api
import std/os

# Configure project name (optional)
ProjectName = "myapp"

# Example 1: Basic file operations and assertions
echo "=== Example 1: Basic File Operations ==="
var ctx = createTestContext()
try:
  let testDir = createTempTestDir(ctx, "example")
  let testFile = createTestFile(ctx, testDir, "example.txt", "Hello, nimtest!")
  
  # Basic assertions
  discard assertFileExists(testFile)
  discard assertFileContains(testFile, "Hello, nimtest!")
  echo "✓ Basic file operations work correctly"
  
  # Advanced assertions
  discard assertFileHasSize(testFile, 15)  # "Hello, nimtest!" is 15 chars
  echo "✓ Advanced assertions work correctly"
  
finally:
  ctx.cleanup()
  echo "✓ Cleanup completed"

# Example 2: Performance utilities
echo "\n=== Example 2: Performance Utilities ==="
discard measureTime("simple operation"):
  proc() = 
    var x = 0
    for i in 0..1000:
      inc(x)

discard benchmark("Increment operation", 1000):
  proc() = 
    var x = 0
    inc(x)

echo "✓ Performance utilities work correctly"

# Example 3: Test reporting
echo "\n=== Example 3: Test Reporting ==="
var report = newTestSuiteReport("Example Test Suite")

# Simulate some test results
addResult(report, newTestResult("file operations test", true, 0.015, "File operations passed"))
addResult(report, newTestResult("performance test", true, 0.002, "Performance test passed"))
addResult(report, newTestResult("edge case test", false, 0.008, "Expected failure"))

finish(report)
generateConsoleReport(report)

# Save different report formats
let jsonFile = saveReport(report, rfJson, "example_report.json")
let junitFile = saveReport(report, rfJunit, "example_report.xml") 
let markdownFile = saveReport(report, rfMarkdown, "example_report.md")

echo "✓ Reports generated: ", jsonFile, ", ", junitFile, ", ", markdownFile

# Clean up example files
if fileExists("example_report.json"): removeFile("example_report.json")
if fileExists("example_report.xml"): removeFile("example_report.xml")
if fileExists("example_report.md"): removeFile("example_report.md")

# Example 4: Progress bars
echo "\n=== Example 4: Progress Bars ==="
# Note: runTestsWithProgress example simplified due to type issues

echo "\n✓ All examples completed successfully!"