# nimtest — The Only Testing Framework You'll Ever Need

```nim
import nimtest/api   # ← ONE IMPORT TO RULE THEM ALL
```

## Install
```bash
nimble install nimtest
```

## Quick Start
```nim
var ctx = createTestContext()
try:
  let d = createTempTestDir(ctx, "demo")
  let f = createTestFile(ctx, d, "hello.txt", "world")
  discard assertFileContains(f, "world")
finally:
  ctx.cleanup()
```

## Features
- Auto-cleanup via `TestContext`
- 4 report formats (Console, JSON, JUnit XML, Markdown)
- 5 animated progress bars
- Full CLI testing
- Benchmarks with `benchmark()`
- `nimble test` ready
- Full docs in [`docs/`](./docs/)

## Links
- [Documentation](./docs/)
- [Changelog](./CHANGELOG.md)
- [Contributing](./docs/CONTRIBUTING.md)
- [Handling Nim Contributions](./docs/NIM_CONTRIBUTIONS.md)
```

## Features

- Automatic resource management with TestContext
- File system testing utilities
- CLI testing support
- Performance benchmarking
- Multiple report formats (console, JSON, JUnit XML, Markdown)
- Progress bars
- Cross-platform support

## Documentation

See [docs/](docs/) for comprehensive documentation, API reference, and examples.

## Core Concepts

### Public API

The recommended way to import nimtest is:

```nim
import nimtest/api
```

This provides access to all core functionality in a clean namespace.

### Test Context

The `TestContext` manages temporary resources and ensures proper cleanup:

```nim
# Create test context
var ctx = createTestContext()
try:
  # Create temporary files and directories
  let tempDir = createTempTestDir(ctx, "test_prefix")
  # ... your test code
finally:
  # Cleanup all registered resources
  ctx.cleanup()
```

### File System Utilities

Comprehensive utilities for file and directory testing:

```nim
# Basic assertions (return bool, throw exception on failure)
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
# Create test report
var report = newTestSuiteReport("My Test Suite")

# Add test results
let result = newTestResult("my test", true, 0.005, "Test passed")
addResult(report, result)

# Generate different report formats
generateConsoleReport(report)
let jsonFile = saveReport(report, rfJson, "report.json")
let junitFile = saveReport(report, rfJunit, "report.xml")
let markdownFile = saveReport(report, rfMarkdown, "report.md")
```

### Progress Bars

Visual feedback for long-running operations with 5 different styles:

```nim
# Create progress bar
let bar = newProgressBar(pbsGlobe, width = 40, total = 100, message = "Running...")

# Update progress during execution (optimized to avoid spam)
for i in 0..<100:
  # Your operation here
  sleep(10)  # Simulate work
  update(bar, i + 1, &"Processing {i + 1}/100")  # Using optimized update

# Complete progress bar
finish(bar, "All tasks completed!")
```

## API Overview

### Core Module
- `createTestContext()` - Create a new test context for resource management
- `cleanup(ctx)` - Clean up all registered resources
- File operations: `createTestFile()`, `createTestDir()`, `createTempTestDir()`
- Assertions: `assertFileExists()`, `assertFileContains()`, `assertDirExists()`, etc.
- Performance: `measureTime()`, etc.

### Helpers Module
- Advanced assertions: `assertFileNotExists()`, `assertFileHasSize()`, etc.
- File operations: `createTestFile()`, `createTestDir()`
- Performance: `benchmark()`, `runTestWithTimeout()`
- Advanced: `assertThrows()`

### Reporting Module
- `newTestSuiteReport(name)` - Create a new test suite report
- `newTestResult()` - Create individual test result
- Report formats: `generateConsoleReport()`, `generateJsonReport()`, `generateJunitReport()`, `generateMarkdownReport()`
- `saveReport()` - Save reports to files in different formats
- `runTestsWithProgress()` - Run tests with visual progress feedback
- `getStatistics()`, `getFailedResults()`, `sortResults()` - Report analysis functions

### Progress Module
- Progress bars with various styles: `newProgressBar()`, `update()`, `display()`, `finish()`

## Project Structure

```
nimtest.nimble              # Nimble package configuration
src/nimtest/                # Framework source code
├── api.nim                 # Public API facade (recommended import)
├── core.nim                # Core functionality (TestContext, basic assertions)
├── reporting.nim           # Test reporting with multiple output formats
├── config.nim              # Optional configuration
├── progress.nim            # Progress bar utilities
└── helpers.nim             # Extended helper functions
docs/                       # Complete documentation
examples/                   # Example implementations
tests/                      # Framework tests
```

## Examples

### Basic File Operation Test

```nim
import nimtest/api
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # Create temporary directory and file
  let testDir = createTempTestDir(ctx, "file_test")
  let testFile = createTestFile(ctx, testDir, "config.json", """{"debug": true}""")
  
  # Validate file operations
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

# Benchmark string concatenation
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

# Add some test results
addResult(report, newTestResult("test_addition", true, 0.001, "Addition works correctly"))
addResult(report, newTestResult("test_failing_example", false, 0.005, "Expected failure"))

finish(report)

# Generate JUnit XML for CI/CD systems
let junitFile = saveReport(report, rfJunit, "test-results.xml")
echo "JUnit report saved to: ", junitFile
```

## Configuration

The framework provides optional configuration through the config module:

```nim
import nimtest/api

# Optionally override default configuration
ProjectName = "myapp"
```

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Support

For support and questions, please open an issue in the repository or consult the comprehensive documentation in the `docs/` directory.