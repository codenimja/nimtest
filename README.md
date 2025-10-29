# nimtest - Comprehensive Testing Framework for Nim

A modular testing framework for Nim projects that provides utilities for unit tests, integration tests, CLI testing, and performance benchmarks with automatic resource management and comprehensive reporting.

## Project Status

This project is a work in progress and is currently in beta. While functional and ready for use, expect some rough edges and potential bugs. At this early stage, encountering bugs is actually a good sign - it means people are using Nim and testing the framework in real scenarios. Please report any issues you find to help improve the framework.

## Features

- **Comprehensive Testing**: Support for unit, integration, CLI, and performance tests
- **Resource Management**: Automatic cleanup of temporary files and directories
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

Copy the `src/nimtest` directory to your project's source directory and configure:

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
import std/unittest

suite "My Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic functionality":
    let testDir = ctx.createTempTestDir()
    let testFile = createTestFile(ctx, testDir, "test.txt", "Hello, World!")
    
    assertFileExists(testFile)
    assertFileContains(testFile, "Hello, World!")
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
suite "Resource Management":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()
```

### File System Utilities

Comprehensive utilities for file and directory testing:

```nim
# Basic assertions
assertFileExists("config.json")
assertDirExists("output/")
assertFileContains("log.txt", "SUCCESS")

# Advanced assertions  
assertFileNotExists("deleted.txt")
assertFileHasSize("data.bin", 1024)
assertFileModifiedAfter("file.txt", startTime)
```

### CLI Testing

Built-in utilities for testing command-line applications:

```nim
test "CLI version command":
  let (output, exitCode) = runCliCommand("--version")
  check exitCode == 0
  assertOutputContains(output, "1.0.0")
```

### Performance Testing

Timing and benchmarking utilities:

```nim
# Measure single operation
measureTime("database query"):
  database.executeQuery("SELECT * FROM users")

# Benchmark multiple iterations
benchmark("string operations", 1000):
  var s = ""
  for i in 0..100:
    s &= "test"
```

### Reporting

Comprehensive test reporting with multiple output formats:

```nim
var report = newTestSuiteReport("My Test Suite")

# Add test results
let result = newTestResult("my test", true, 0.005, "Test passed")
addResult(report, result)

# Generate reports
generateConsoleReport(report)
let jsonFile = saveReport(report, rfJson, "report.json")
```

### Progress Bars

Visual feedback for long-running test suites with 5 different styles:

```nim
# Create progress bar
let bar = newProgressBar(pbsGlobe, width = 40, total = 100, message = "Running tests...")

# Update progress during test execution
for i in 0..<100:
  # Test logic here
  bar.updateProgress(i + 1, fmt"Completed {i + 1}/100 tests")
  bar.display()

# Complete progress bar
bar.finish("All tests completed!")

# Or use the built-in progress runner
let testSuites = @[("Unit Tests", runUnitTests), ("Integration", runIntegrationTests)]
let report = runTestsWithProgress(testSuites, pbsBlocks)
```

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

### Basic Unit Test

```nim
import nimtest
import std/unittest

suite "Calculator Tests":
  test "addition works":
    check add(2, 3) == 5
    check add(-1, 1) == 0
```

### File System Test

```nim
import nimtest
import std/unittest

suite "File Operations":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "file creation and validation":
    let dir = ctx.createTempTestDir()
    let file = createTestFile(ctx, dir, "config.json", """{"debug": true}""")
    
    assertFileExists(file)
    assertFileContains(file, "debug")
    assertFileContains(file, "true")
```

### CLI Test

```nim
import nimtest
import std/unittest

suite "CLI Tests":
  test "help command works":
    let (output, exitCode) = runCliCommand("--help")
    check exitCode == 0
    assertOutputContains(output, "Usage:")
```

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Support

For support and questions, please open an issue in the repository or consult the comprehensive documentation in the `docs/` directory.