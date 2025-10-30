# nimtest Framework

A comprehensive, modular testing framework for Nim projects.

## Overview

nimtest is a professional testing framework that provides utilities for unit tests, integration tests, and performance benchmarks with automatic resource management and comprehensive reporting:
- Resource management (with `TestContext` for automatic cleanup)
- File system assertions (file and directory validation utilities)
- Performance testing (timing and benchmarking utilities)
- Progress visualization (5 different progress bar styles)
- Comprehensive reporting (console, JSON, JUnit, Markdown formats)

## Framework Structure

The nimtest framework consists of:

```
src/nimtest/
├── helpers.nim        # Core utilities, assertions, resource management
├── reporting.nim      # Test reporting, analytics, and output formats
└── test_config.nim    # Project configuration and constants
```

## Installation

To use nimtest in your project:

1. Copy the `src/nimtest` directory to your project's source directory
2. Edit `src/nimtest/test_config.nim` to configure for your project
3. Import the framework in your test files

## Basic Usage

### Writing Your First Test

```nim
import nimtest
import std/unittest

suite "Basic Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic example":
    # Use nimtest utilities in your tests
    let testDir = ctx.createTempTestDir("basic_test")
    let testFile = testDir / "sample.txt"
    writeFile(testFile, "Hello, nimtest!")

    # Verify with assertions
    assertFileExists(testFile)
    assertFileContains(testFile, "Hello, nimtest!")

    # Test passes if no assertion fails
    check true == true
```

### Key Framework Components

#### Resource Management
```nim
# Create test context for automatic cleanup
var ctx = createTestContext()
defer: ctx.cleanup()

# Create temporary resources
let testDir = ctx.createTempTestDir("my_test")
```

#### File System Assertions
```nim
assertFileExists("path/to/file")
assertDirExists("path/to/directory")
assertFileContains("config.json", "expected_content")
assertOutputContains(output, "expected_text")
```

#### CLI Testing
```nim
# Example usage with command output stored in a variable
let output = "Version: 1.0.0\nBuild Date: 2025-01-01"
discard assertOutputContains(output, "1.0.0")
```

#### Performance Testing
```nim
measureTime("operation name"):
  performOperation()

benchmark("operation", 1000):
  performOperation()
```

#### Progress Bars
```nim
# Create progress bar with different styles
let bar = newProgressBar(pbsGlobe, width = 40, total = 100, message = "Processing...")

# Update progress
bar.updateProgress(50, "Halfway done...")
bar.display()

# Complete progress bar
bar.finish("All done!")
```

## Configuration

Configure nimtest by editing `src/nimtest/test_config.nim` in your project:

```nim
const
  PROJECT_NAME* = "yourproject"          # Your project name
  PROJECT_DISPLAY_NAME* = "YourProject"  # Human-readable name
  CLI_BINARY_PATH* = "./bin/yourproject" # Path to your CLI binary (if applicable)

  # Features to enable/disable
  HAS_CLI* = true                        # Enable CLI testing utilities
  HAS_CORE_LIB* = false                  # Enable core library testing (if applicable)
  HAS_COMPONENT_SYSTEM* = false          # Enable component system features (if applicable)

  # Directory paths (relative to project root)
  SRC_DIR* = "src"                       # Source code directory
  TEST_DIR* = "tests"                    # Test directory
  TEMP_DIR_PREFIX* = "test_"             # Prefix for temporary test directories
```

## Framework Utilities

The nimtest framework provides these key utilities:

### Core Utilities
- `createTestContext()` - Create test resource manager
- `createTempTestDir()` - Create temporary directory for test with automatic cleanup
- `createTestFile()` - Create test file with content tracking
- `createTestDir()` - Create test directory with tracking

### File System Assertions
- `assertFileExists()` - Assert file existence
- `assertDirExists()` - Assert directory existence
- `assertFileContains()` - Assert file contains specific content
- `assertOutputContains()` - Assert command output contains text
- `assertFileNotExists()` - Assert file does NOT exist
- `assertFileDoesNotContain()` - Assert file does NOT contain content
- `assertFileHasSize()` - Assert file has specific size
- `assertFileModifiedAfter()` - Assert file was modified after specific time

### CLI Testing Utilities
(Note: CLI testing utilities have been removed to keep the framework lightweight and focused on core testing functionality)

### Performance Utilities
- `measureTime()` - Measure execution time of operations with formatted output
- `benchmark()` - Run operations multiple times and report performance metrics
- `runTestWithTimeout()` - Run test with timeout constraint

### Error Handling
- `assertThrows()` - Assert that a procedure throws an exception

### Reporting Utilities
- `newTestResult()` - Create individual test result with metadata
- `newTestSuiteReport()` - Create test suite report
- `addResult()` - Add test result to report
- `generateConsoleReport()` - Generate human-readable console report
- `generateJsonReport()` - Generate JSON-formatted report
- `generateJunitReport()` - Generate JUnit XML report
- `generateMarkdownReport()` - Generate Markdown report
- `saveReport()` - Save report to file in specified format

## Test Organization

Organize your tests in a logical directory structure:

```
tests/
├── unit/                    # Unit tests for individual functions/modules
├── integration/             # Integration tests for multiple components
├── performance/             # Performance and benchmark tests
├── cli/                     # CLI command tests (if applicable)
├── fixtures/                # Test data and fixture files
├── helpers.nim              # Shared test utilities specific to your project
└── test_all.nim             # Main test runner
```

## CI/CD Integration

nimtest is designed to work well in CI/CD environments:

- Compatible with GitHub Actions, GitLab CI, and other systems
- Cross-platform support (Linux, Windows, macOS)
- Multiple report formats (JSON, JUnit XML) for CI integration
- Console output formatted for CI logs

## Best Practices

1. **Always use TestContext**: Create and clean up contexts properly for resource management
2. **Use setup/teardown**: Initialize resources in setup, clean up in teardown
3. **Use descriptive test names**: Make test names clear and specific
4. **Test one thing per test**: Keep tests focused on a single functionality
5. **Use meaningful assertions**: Provide clear messages for failed assertions
6. **Clean up resources**: Always ensure temporary files and directories are cleaned up
7. **Use performance utilities**: Measure and track performance of critical operations
8. **Generate reports**: Use reporting utilities to track test results over time

## Dependencies

- `nim >= 2.0.0`
- `std/unittest` (built-in)
- `std/os` (built-in)
- `std/osproc` (built-in)
- `std/json` (built-in)
- `std/parseutils` (built-in)

## License

MIT License - See LICENSE file for details
