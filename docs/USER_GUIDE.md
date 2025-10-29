# nimtest User Guide

Complete guide to using the nimtest testing framework effectively.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Writing Tests](#writing-tests)
- [Test Context Management](#test-context-management)
- [File System Operations](#file-system-operations)
- [CLI Testing](#cli-testing)
- [Performance Testing](#performance-testing)
- [Progress Bars](#progress-bars)
- [Component Testing](#component-testing)
- [Advanced Testing Techniques](#advanced-testing-techniques)
- [Reporting](#reporting)

## Overview

nimtest is a comprehensive testing framework designed for Nim projects that provides utilities for various types of testing including unit tests, integration tests, CLI command testing, and performance benchmarks. The framework emphasizes resource management, clean test isolation, and comprehensive reporting.

### Key Features

- **Resource Management**: Automatic cleanup of temporary files and directories
- **File System Assertions**: Comprehensive file and directory testing utilities
- **CLI Testing**: Built-in utilities for testing command-line applications
- **Performance Testing**: Timing and benchmarking utilities
- **Component Testing**: Support for testing component-based systems
- **Comprehensive Reporting**: Multiple report formats including console, JSON, JUnit, and Markdown
- **Cross-Platform**: Works on Linux, macOS, and Windows

## Installation

To use nimtest in your project:

1. Copy the `src/nimtest` directory to your project's source directory
2. Edit `src/nimtest/test_config.nim` to configure for your project
3. Import the necessary modules in your test files

### Project Configuration

Edit `src/nimtest/test_config.nim`:

```nim
# Project information
const
  PROJECT_NAME* = "yourproject"          # Your project name
  PROJECT_DISPLAY_NAME* = "YourProject"  # Human-readable name
  CLI_BINARY_PATH* = "./bin/yourproject" # Path to your CLI binary (if applicable)

# Feature flags
const
  HAS_CLI* = true                      # Does your project have a CLI?
  HAS_CORE_LIB* = true                 # Test against internal library modules?
  HAS_COMPONENT_SYSTEM* = false        # Component/plugin architecture?

# Directory paths
const
  SRC_DIR* = "src"                     # Source code directory
  TEST_DIR* = "tests"                  # Test directory
  TEMP_DIR_PREFIX* = "test_"           # Prefix for temporary test directories
```

## Basic Usage

### Creating Your First Test

```nim
import nimtest
import std/unittest

suite "My Basic Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic assertion":
    check true == true
    echo "Test passed!"
```

### Using Test Context

The `TestContext` manages temporary resources and ensures proper cleanup:

```nim
import nimtest
import std/unittest

suite "File System Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "create and check file":
    let testDir = ctx.createTempTestDir()
    let testFile = ctx.createTempTestDir() / "test.txt"
    writeFile(testFile, "Hello, World!")
    
    assertFileExists(testFile)
    assertFileContains(testFile, "Hello, World!")
```

## Writing Tests

### Test Structure

Each test follows this pattern:

```nim
suite "Test Suite Name":
  var ctx: TestContext  # Optional but recommended

  setup:
    # Initialization code runs before each test
    ctx = createTestContext()

  teardown:
    # Cleanup code runs after each test
    ctx.cleanup()

  test "test description":
    # Actual test code
    check someCondition == true
```

### Using Assertions

nimtest provides various assertion utilities:

```nim
# File system assertions
assertFileExists("path/to/file")
assertDirExists("path/to/directory")
assertFileContains("config.json", "setting")
assertOutputContains(output, "expected text")

# Advanced assertions
assertFileNotExists("deleted_file.txt")
assertFileDoesNotContain("config.json", "debug_mode")
assertFileHasSize("data.bin", 1024)
assertFileModifiedAfter("file.txt", startTime)
```

## Test Context Management

### Creating a Test Context

```nim
var ctx = createTestContext()
```

### Managing Temporary Resources

```nim
# Create temporary directory
let tempDir = ctx.createTempTestDir("mytest")
# Directory will be automatically cleaned up

# Create temporary file
let tempFile = createTestFile(ctx, tempDir, "temp.txt", "content")
# File will be automatically cleaned up
```

### Manual Cleanup

```nim
ctx.cleanup()  # Clean up all tracked resources
```

## File System Operations

### File System Assertions

```nim
# Basic assertions
assertFileExists("config.json")
assertDirExists("output/")
assertFileContains("log.txt", "SUCCESS")

# Advanced assertions
assertFileNotExists("deleted.txt")
assertFileDoesNotContain("config.json", "debug_mode")
assertFileHasSize("data.bin", 1024)
assertFileModifiedAfter("file.txt", startTime)
```

### Creating Test Files and Directories

```nim
# Create temporary directory
let testDir = ctx.createTempTestDir("mytest")

# Create test file with content
let testFile = createTestFile(ctx, testDir, "sample.txt", "Hello, World!")

# Create subdirectory
let subDir = createTestDir(ctx, testDir, "subdir")
```

## CLI Testing

### Running CLI Commands

```nim
# Execute command and get output and exit code
let (output, exitCode) = runCliCommand("--version")
check exitCode == 0
check "1.0.0" in output

# Execute command in specific directory
let (output, exitCode) = runCliCommandInDir(testDir, "init")
```

### CLI Test Example

```nim
suite "CLI Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "version command works":
    let (output, exitCode) = runCliCommand("--version")
    check exitCode == 0
    assertOutputContains(output, "1.0.0")

  test "init command creates files":
    let testDir = ctx.createTempTestDir()
    let (output, exitCode) = runCliCommandInDir(testDir, "init")
    
    check exitCode == 0
    assertDirExists(testDir / "src")
    assertFileExists(testDir / "config.json")
```

## Performance Testing

### Measuring Execution Time

```nim
# Simple time measurement
measureTime("database query"):
  database.executeQuery("SELECT * FROM users")
# Output: [PERF] database query: 45.123 ms
```

### Benchmarking

```nim
# Run code multiple times and get performance metrics
benchmark("string concatenation", 1000):
  var s = ""
  for i in 0..10:
    s &= "test"
# Output: [BENCH] string concatenation: ...
```

### Timeout Testing

```nim
# Run test with timeout constraint
let completed = runTestWithTimeout(proc() = 
  sleep(1000)  # Sleep for 1 second
, 5)  # 5 second timeout
check completed == true
```

## Progress Bars

### Creating Progress Bars

nimtest provides 5 different progress bar styles for visual feedback during long-running operations:

```nim
# Create different progress bar styles
let minimalBar = newProgressBar(pbsMinimal, width = 40, total = 100)
let globeBar = newProgressBar(pbsGlobe, width = 30, total = 50, message = "Processing...")
let pulseBar = newProgressBar(pbsPulse, total = 25)
let dotsBar = newProgressBar(pbsDots, total = 20)
let blocksBar = newProgressBar(pbsBlocks, width = 50, total = 75)
```

### Progress Bar Styles

- **`pbsMinimal`**: Simple bar with percentage display
- **`pbsGlobe`**: Globe-like rotating progress with 🌍 emoji
- **`pbsPulse`**: Pulsing bar with animated Unicode characters
- **`pbsDots`**: Animated dots progress indicator
- **`pbsBlocks`**: Unicode block characters for solid progress display

### Using Progress Bars

```nim
# Basic usage
let bar = newProgressBar(pbsGlobe, total = 100, message = "Running tests...")

for i in 0..100:
  # Update progress
  bar.updateProgress(i, &"Processing item {i}")
  
  # Display the progress bar
  bar.display()
  
  # Simulate work
  sleep(50)

# Complete the progress bar
bar.finish("All tests completed!")
```

### Running Tests with Progress Bars

```nim
# Define test procedures
proc runUnitTests() =
  suite "Unit Tests":
    test "basic math": check 2 + 2 == 4
    test "string ops": check "hello".len == 5

proc runIntegrationTests() =
  suite "Integration Tests":
    test "database": check connectToDB() == true

# Run with progress bar
let testSuites = @[
  ("Unit Tests", runUnitTests),
  ("Integration Tests", runIntegrationTests)
]

let report = runTestsWithProgress(testSuites, pbsBlocks)
generateConsoleReport(report)
```

### Progress Bar Configuration

```nim
let bar = newProgressBar(pbsMinimal, width = 60, total = 200)

# Configure display options
bar.showPercentage = true    # Show percentage (default: true)
bar.showTime = true         # Show elapsed time (default: false)
bar.message = "Custom message"

# Update and display
bar.updateProgress(50, "Halfway there...")
bar.display()
```

## Component Testing

### Component Metadata

```nim
# Create test component metadata
let component = createTestComponent("mycomponent", catUtility)

# Create test component file
let compFile = createTestComponentFile(ctx, testDir, "mycomponent")

# Create test metadata file
let metaFile = createTestMetadataFile(ctx, testDir, "mycomponent", "utility")
```

### Component Categories

```nim
type
  ModuleCategory* = enum
    catGeneral,    # General-purpose modules
    catCore,       # Core system modules
    catUtility,    # Utility modules
    catExtension,  # Extension modules
    catPlugin      # Plugin modules
```

## Advanced Testing Techniques

### Exception Testing

```nim
# Test that a procedure throws an exception
assertThrows(proc() = 
  raise newException(ValueError, "Test")
)
```

### Output Capture

```nim
# Capture output from a procedure
let (output, captured) = captureOutput(proc(): string = 
  echo "Hello, World!"
  return "result"
)
```

### Conditional Assertions

```nim
# Assertions with custom messages
assertFileExists("config.json", "Configuration file must exist after init")
assertDirExists(testDir / "logs", "Logs directory must be created")
```

## Reporting

### Creating Test Reports

```nim
# Create a test suite report
var report = newTestSuiteReport("My Test Suite")

# Add test results
let result = newTestResult("my test", true, 0.005, "Test passed", "core")
addResult(report, result)

# Finish and generate report
finish(report)
generateConsoleReport(report)
```

### Report Formats

```nim
# Generate different report formats
let jsonReport = generateJsonReport(report)
let junitReport = generateJunitReport(report)
let markdownReport = generateMarkdownReport(report)

# Save report to file
let filename = saveReport(report, rfJson, "my_report.json")
```

### Report Summary

```nim
# Print simple summary
printSummary(report)
# Output: Test Summary: 5/6 passed (83.3%) in 1.23s
```

### Complete Reporting Example

```nim
import nimtest
import std/unittest
import std/times

suite "Reporting Example":
  var ctx: TestContext
  var report: TestSuiteReport

  setup:
    ctx = createTestContext()
    report = newTestSuiteReport("Example Test Suite")

  teardown:
    finish(report)
    generateConsoleReport(report)
    let jsonFile = saveReport(report, rfJson, "example_report.json")
    echo "JSON report saved to: ", jsonFile
    ctx.cleanup()

  test "example test 1":
    let startTime = cpuTime()
    # Test code here
    let duration = cpuTime() - startTime
    let result = newTestResult("example test 1", true, duration)
    addResult(report, result)

  test "example test 2":
    let startTime = cpuTime()
    # Test code here
    let duration = cpuTime() - startTime
    let result = newTestResult("example test 2", true, duration)
    addResult(report, result)
```

## Best Practices

1. **Always use TestContext**: Create and clean up contexts properly
2. **Use setup/teardown**: Initialize resources in setup, clean up in teardown
3. **Use descriptive test names**: Make test names clear and specific
4. **Test one thing per test**: Keep tests focused on a single functionality
5. **Use meaningful assertions**: Provide clear messages for failed assertions
6. **Clean up resources**: Always ensure temporary files and directories are cleaned up
7. **Use performance utilities**: Measure and track performance of critical operations
8. **Generate reports**: Use reporting utilities to track test results over time

## Troubleshooting

### Common Issues

**Q: Tests fail with "file not found" errors**
A: Ensure you're using the correct paths and that files are created before checking them

**Q: Memory usage grows with each test**
A: Make sure to properly clean up resources in teardown sections

**Q: CLI commands return exit code 127**
A: Ensure your CLI binary is built and the path is configured correctly in test_config.nim

**Q: Tests work locally but fail in CI/CD**
A: Check that all paths are relative and platform-independent