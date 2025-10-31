# Run all nimtest examples
# This file demonstrates the complete nimtest framework

echo "Running all nimtest examples..."
echo "================================"

import ../src/nimtest/api
import std/os

# Example 1: Basic functionality
echo "\n1. Basic TestContext and file operations"
var ctx = createTestContext()
try:
  let tempDir = createTempTestDir(ctx, "test_all")
  let testFile = createTestFile(ctx, tempDir, "test.txt", "nimtest works!")
  discard assertFileExists(testFile)
  discard assertFileContains(testFile, "nimtest")
  echo "   ✓ Basic operations passed"
finally:
  ctx.cleanup()

# Example 2: CLI testing
echo "\n2. CLI Testing"
let (output, exitCode) = runCliCommand("echo 'hello world'")
discard assertExitCode(exitCode, 0)
discard assertOutputContains(output, "hello world")
echo "   ✓ CLI testing passed"

# Example 3: Performance testing
echo "\n3. Performance Testing"
discard benchmark("simple benchmark", 100):
  proc() =
    var x = 0
    for i in 0..10:
      inc(x)
echo "   ✓ Performance testing passed"

# Example 4: Reporting
echo "\n4. Test Reporting"
var report = newTestSuiteReport("All Examples Test Suite")
addResult(report, newTestResult("basic operations", true, 0.001))
addResult(report, newTestResult("cli testing", true, 0.002))
addResult(report, newTestResult("performance", true, 0.003))
finish(report)

# Generate reports
let jsonReport = saveReport(report, rfJson, "test_all_report.json")
let junitReport = saveReport(report, rfJunit, "test_all_report.xml")
let mdReport = saveReport(report, rfMarkdown, "test_all_report.md")

echo "   ✓ Reports generated: ", jsonReport, ", ", junitReport, ", ", mdReport

# Clean up reports
if fileExists("test_all_report.json"): removeFile("test_all_report.json")
if fileExists("test_all_report.xml"): removeFile("test_all_report.xml")
if fileExists("test_all_report.md"): removeFile("test_all_report.md")

echo "\n🎉 All nimtest examples completed successfully!"
echo "The framework is ready for production use."