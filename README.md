# nimtest - Comprehensive Testing Framework for Nim

A modular testing framework for Nim projects that provides utilities for unit tests, integration tests, CLI testing, and performance benchmarks with automatic resource management and comprehensive reporting.

## Project Status

This project is a work in progress and is currently in beta. While functional and ready for use, expect some rough edges and potential bugs. At this early stage, encountering bugs is actually a good sign - it means people are using Nim and testing the framework in real scenarios. Please report any issues you find to help improve the framework.

## Features

- **Comprehensive Testing Utilities**: File operations, assertions, CLI testing, performance benchmarking
- **Resource Management**: Automatic cleanup of temporary files and directories via TestContext
- **Rich Reporting**: Console, JSON, JUnit XML, and Markdown report formats
- **Progress Bars**: Subtle loading indicators (5 styles: minimal, globe, pulse, dots, blocks)
- **Performance Utilities**: Built-in timing and benchmarking tools
- **CLI Testing**: Specialized utilities for testing command-line applications
- **File System Testing**: Extensive file and directory assertion utilities
- **Cross-Platform**: Works on Linux, macOS, and Windows
- **Highly Configurable**: Easy to customize for your specific project needs
- **Well Documented**: Complete API documentation and usage guides

## Quick Start

### 1. Installation

Copy the `src/nimtest` directory to your project's source directory:

```bash
# Copy framework to your project
cp -r nim-test-suite/src/nimtest your-project/src/
```

### 2. Configuration

Edit `src/nimtest/test_config.nim` to match your project:

```nim
const
  PROJECT_NAME* = "yourproject"          # Your project name
  PROJECT_DISPLAY_NAME* = "YourProject"  # Display name
  CLI_BINARY_PATH* = "./bin/yourproject" # CLI binary path (if applicable)
```

### 3. Write Your First Test

```nim
import nimtest
import std/[os, times]

# Create and use test context for resource management
var ctx = createTestContext()
try:
  # Create temporary resources
  let testDir = createTempTestDir(ctx, "mytest")
  let testFile = createTestFile(ctx, testDir, "test.txt", "Hello, World!")
  
  # Use assertion utilities
  discard assertFileExists(testFile)
  discard assertFileContains(testFile, "Hello, World!")
  
  # Use performance utilities
  let duration = measureTime("Simple operation"):
    proc() = 
      sleep(10)  # Small delay to measure

  echo "Operation took: ", duration, " seconds"

finally:
  # Always cleanup resources
  ctx.cleanup()
```

### 4. Run Tests

```bash
nimble test
# or
nim c -r tests/my_test.nim
```

## Core Concepts

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

### CLI Testing

Built-in utilities for testing command-line applications:

```nim
# Test CLI commands
let (output, exitCode) = runCliCommand("--version")
if exitCode == 0:
  discard assertOutputContains(output, "1.0.0")
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

# Update progress during execution
for i in 0..<100:
  # Your operation here
  sleep(10)  # Simulate work
  bar.updateProgress(i + 1, &"Processing {i + 1}/100")
  bar.display()

# Complete progress bar
bar.finish("All tasks completed!")
```

## API Overview

### Helpers Module
- `createTestContext()` - Create a new test context for resource management
- `cleanup(ctx)` - Clean up all registered resources
- `tryCleanup(ctx)` - Attempt cleanup and return success status with errors
- File operations: `createTestFile()`, `createTestDir()`, `createTempTestDir()`
- Assertions: `assertFileExists()`, `assertFileContains()`, `assertDirExists()`, etc.
- CLI utilities: `runCliCommand()`, `runCliCommandInDir()`
- Performance: `measureTime()`, `benchmark()`, `runTestWithTimeout()`
- Advanced: `assertThrows()`, `createTestComponent()`, `createTestMetadata()`

### Reporting Module
- `newTestSuiteReport(name)` - Create a new test suite report
- `newTestResult()` - Create individual test result
- Report formats: `generateConsoleReport()`, `generateJsonReport()`, `generateJunitReport()`, `generateMarkdownReport()`
- `saveReport()` - Save reports to files in different formats
- `runTestsWithProgress()` - Run tests with visual progress feedback
- `getStatistics()`, `getFailedResults()`, `sortResults()` - Report analysis functions

## Documentation

Complete documentation is available in the `docs/` directory:

- [User Guide](docs/USER_GUIDE.md) - Complete usage instructions
- [API Reference](docs/API.md) - Detailed API documentation  
- [Best Practices](docs/BEST_PRACTICES.md) - Recommended patterns
- [Examples](docs/EXAMPLES.md) - Common testing scenarios
- [Configuration Guide](docs/CONFIGURATION.md) - Setup and configuration
- [Architecture](docs/ARCHITECTURE.md) - Framework design
- [Contribution Guide](docs/CONTRIBUTING.md) - How to contribute

## Project Structure

```
src/nimtest/                 # Framework source code
├── helpers.nim             # Core utilities and assertions
├── reporting.nim           # Reporting and analytics
└── test_config.nim         # Project configuration
docs/                       # Complete documentation
examples/                   # Example implementations
tests/                      # Framework tests
```

## Examples

### Basic File Operation Test

```nim
import nimtest
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

### CLI Testing Example

```nim
import nimtest

# Test a CLI command
let (output, exitCode) = runCliCommand("--help")
if exitCode == 0:
  if assertOutputContains(output, "Usage:"):
    echo "CLI help test passed!"
```

### Performance Benchmarking

```nim
import nimtest

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

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Support

For support and questions, please open an issue in the repository or consult the comprehensive documentation in the `docs/` directory.