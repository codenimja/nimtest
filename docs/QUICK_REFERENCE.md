# nimtest Quick Reference

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nim](https://img.shields.io/badge/Nim-1.6+-blue.svg)](https://nim-lang.org/)

Quick reference guide for the nimtest testing framework.

## Install

```bash
nimble install nimtest
```

## Quick Example

```nim
import nimtest/api

suite "Quick Test":
  var ctx = createTestContext()
  try:
    let tempDir = ctx.createTempTestDir("demo")
    let tempFile = createTestFile(ctx, tempDir, "test.txt", "content")
    discard assertFileExists(tempFile)
  finally:
    ctx.cleanup()
```

## Framework Usage

### Basic Test Setup

```nim
import nimtest/api
import std/unittest

suite "Your Test Suite":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "your test description":
    # Test implementation
    check someCondition == true
```

### Resource Management

```nim
# Create test context for automatic cleanup
var ctx = createTestContext()
try:
  # ... test code ...
finally:
  ctx.cleanup()

# Create temporary directory and file
let testDir = createTempTestDir(ctx, "mytest")
let testFile = createTestFile(ctx, testDir, "test.txt", "content")
# Directory and file are automatically cleaned up after test
```

### File System Assertions

```nim
# Basic assertions
discard assertFileExists("path/to/file")
discard assertDirExists("path/to/directory")
discard assertFileContains("config.json", "expected_content")
discard assertOutputContains(output, "expected_text")

# Advanced assertions
discard assertFileNotExists("deleted_file.txt")
discard assertFileDoesNotContain("config.json", "unwanted_content")
discard assertFileHasSize("data.bin", 1024)
discard assertFileModifiedAfter("file.txt", startTime)
```

### Performance Testing

```nim
# Measure execution time
let duration = measureTime("operation name"):
  proc() = 
    performOperation()

# Benchmark code with multiple iterations
let results = benchmark("operation", 1000):
  proc() = 
    performOperation()

# Test with timeout
let completed = runTestWithTimeout(proc() = 
  slowOperation()
, 5)  # 5 second timeout
```

### Progress Bars

```nim
# Create progress bar (5 styles available)
let bar = newProgressBar(pbsGlobe, width = 40, total = 100, message = "Processing...")

# Update progress (optimized to update only every 50ms)
update(bar, 50, "Halfway done...")
display(bar)

# Complete progress bar
finish(bar, "All done!")

# Run tests with progress bar
let testSuites = @[("Unit Tests", runUnitTests), ("Integration", runIntegrationTests)]
let report = runTestsWithProgress(testSuites, pbsBlocks)
generateConsoleReport(report)
```

### Reporting

```nim
# Create test reports
var report = newTestSuiteReport("My Test Suite")
let result = newTestResult("test name", true, 0.005, "Passed", "category")
addResult(report, result)
finish(report)
generateConsoleReport(report)

# Save reports in various formats
let jsonFile = saveReport(report, rfJson, "report.json")
let junitFile = saveReport(report, rfJunit, "report.xml")
let markdownFile = saveReport(report, rfMarkdown, "report.md")
```

## Key Types

- `TestContext` - Manages test resources and cleanup
- `TestResult` - Represents individual test results  
- `TestSuiteReport` - Collects and reports test suite results

## Key Procedures

- `createTestContext()` - Create a new test context
- `createTempTestDir()` - Create temporary directory for tests
- `createTestFile()` - Create temporary file with content
- `assertFileExists()` - Assert that a file exists
- `measureTime()` - Measure execution time of operations
- `newTestSuiteReport()` - Create test suite report
- `saveReport()` - Save report in various formats

## Configuration

Configure nimtest by importing the config module:

```nim
import nimtest/config

# Initialize with defaults
initConfig()

# Customize settings (optional)
ProjectName = "myproject"
TempDirPrefix = "myapp_"
```

## Documentation

- [API.md](API.md) - Complete API reference
- [USER_GUIDE.md](USER_GUIDE.md) - Complete usage instructions
- [CONFIGURATION.md](CONFIGURATION.md) - Setup and configuration
- [EXAMPLES.md](EXAMPLES.md) - Common testing scenarios
- [BEST_PRACTICES.md](BEST_PRACTICES.md) - Recommended patterns
