# nimtest

[![CI](https://github.com/codenimja/nimtest/workflows/CI/badge.svg)](https://github.com/codenimja/nimtest/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/codenimja/nimtest/releases)
[![Nim](https://img.shields.io/badge/nim-2.0+-blue.svg)](https://nim-lang.org/)

**The ultimate testing powerhouse for Nim** - featuring automatic resource management, blazing-fast performance benchmarking, 5 animated progress bars, and multi-format reporting that makes testing actually enjoyable.

## Features

- **Resource Management**: Automatic cleanup of temporary files and directories via `TestContext`
- **File System Testing**: Comprehensive assertions for files and directories
- **Performance Utilities**: Built-in benchmarking and timing functions
- **Reporting**: Generate reports in multiple formats (Console, JSON, JUnit XML, Markdown)
- **Progress Indicators**: 5 animated progress bar styles for visual feedback
- **Easy Integration**: Works seamlessly with `nimble test`

## Installation

```bash
nimble install nimtest
```

## Quick Start

```nim
import nimtest/api

var ctx = createTestContext()
try:
  let d = createTempTestDir(ctx, "demo")
  let f = createTestFile(ctx, d, "hello.txt", "world")
  discard assertFileContains(f, "world")
finally:
  ctx.cleanup()
```

## Core Concepts

### Public API

The recommended way to import nimtest is:

```nim
import nimtest/api
```

This provides access to all functionality in a clean namespace.

### Test Context

The `TestContext` manages temporary resources and ensures proper cleanup:

```nim
var ctx = createTestContext()
try:
  let tempDir = createTempTestDir(ctx, "test_prefix")
  # ... your test code
finally:
  ctx.cleanup()
```

### File System Utilities

Comprehensive utilities for file and directory testing:

```nim
# Basic assertions
discard assertFileExists("config.json")
discard assertDirExists("output/")
discard assertFileContains("log.txt", "SUCCESS")

# Advanced assertions
discard assertFileNotExists("deleted.txt")
discard assertFileHasSize("data.bin", 1024)
discard assertFileModifiedAfter("file.txt", getTime())
```

### Performance Testing

Timing and benchmarking utilities:

```nim
# Measure single operation
let duration = measureTime("database query"):
  proc() = 
    # database.executeQuery("SELECT * FROM users")

# Benchmark multiple iterations
let benchResults = benchmark("string operations", 1000):
  proc() = 
    var s = ""
    for i in 0..100:
      s &= "test"

echo "Average: ", benchResults.avg, "s, Min: ", benchResults.min, "s, Max: ", benchResults.max, "s"
```

### Reporting

Comprehensive test reporting with multiple output formats:

```nim
var report = newTestSuiteReport("My Test Suite")

let result = newTestResult("my test", true, 0.005, "Test passed")
addResult(report, result)

# Generate different report formats
generateConsoleReport(report)
let jsonFile = saveReport(report, rfJson, "report.json")
let junitFile = saveReport(report, rfJunit, "report.xml")
let markdownFile = saveReport(report, rfMarkdown, "report.md")
```

## Complete Examples

### Basic File Operation Test

```nim
import nimtest/api
import std/[os, times]

var ctx = createTestContext()
try:
  let testDir = createTempTestDir(ctx, "file_test")
  let testFile = createTestFile(ctx, testDir, "config.json", """{"debug": true}""")
  
  discard assertFileExists(testFile)
  discard assertFileContains(testFile, "debug")
  discard assertFileContains(testFile, "true")
  
  echo "File operations test passed!"
  
finally:
  ctx.cleanup()
```

### Performance Benchmarking

```nim
import nimtest/api

let results = benchmark("string operations", 10000):
  proc() = 
    var s = ""
    for i in 0..100:
      s &= "test"

echo "String operations benchmark completed"
echo "Average time: ", results.avg, " seconds"
echo "Min time: ", results.min, " seconds" 
echo "Max time: ", results.max, " seconds"
```

### CI-Ready Testing with JUnit Output

```nim
import nimtest/api

var report = newTestSuiteReport("CI Test Suite")

addResult(report, newTestResult("test_addition", true, 0.001, "Addition works correctly"))
addResult(report, newTestResult("test_failing_example", false, 0.005, "Expected failure"))

finish(report)

let junitFile = saveReport(report, rfJunit, "test-results.xml")
echo "JUnit report saved to: ", junitFile
```

## API Reference

For complete API documentation, see [docs/API.md](docs/API.md).

### Core Functions
- `createTestContext()` - Create a new test context for resource management
- `cleanup(ctx)` - Clean up all registered resources
- `createTempTestDir(ctx, prefix)` - Create temporary test directory
- `createTestFile(ctx, dir, name, content)` - Create test file
- `assertFileExists(path)` - Verify file exists
- `assertFileContains(path, content)` - Verify file contains content
- `measureTime(label, body)` - Measure execution time

### Reporting Functions
- `newTestSuiteReport(name)` - Create new test suite report
- `newTestResult(name, passed, duration, message)` - Create test result
- `saveReport(report, format, filename)` - Save report in specified format
- `generateConsoleReport(report)` - Generate console output
- `generateJsonReport(report)` - Generate JSON report
- `generateJunitReport(report)` - Generate JUnit XML report
- `generateMarkdownReport(report)` - Generate Markdown report

### Progress Bar Functions
- `newProgressBar(style, width, total, message)` - Create progress bar
- `update(bar, current, message)` - Update progress
- `finish(bar, message)` - Complete progress bar

## Project Structure

```
nimtest.nimble              # Package configuration
src/nimtest/                # Source code
├── api.nim                 # Public API import (recommended)
├── core.nim                # Core functionality
├── helpers.nim             # Extended helper functions
├── reporting.nim           # Test reporting
├── progress.nim            # Progress bar utilities
└── config.nim              # Configuration
docs/                       # Documentation
examples/                   # Example implementations
tests/                      # Test suite for the framework
```

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Support

For support and questions, please open an issue in the repository or consult the documentation in the `docs/` directory.