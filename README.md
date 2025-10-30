# nimtest — The Only Testing Framework You'll Ever Need

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Nim Version](https://img.shields.io/badge/Nim-2.0+-blue.svg?style=flat-square)](https://nim-lang.org/)
[![Build Status](https://img.shields.io/github/actions/workflow/status/codenimja/nimtest/ci.yml?branch=main&style=flat-square)](https://github.com/codenimja/nimtest/actions)
[![Nimble](https://img.shields.io/endpoint?url=https://nimble.directory/pkg/nimtest/badge)](https://nimble.directory/pkg/nimtest)

nimtest is a comprehensive testing package for Nim projects, providing utilities for unit tests, integration tests, CLI testing, and performance benchmarks with automatic resource management and rich reporting.

## Install

```bash
nimble install nimtest
```

## Quick Example

```nim
import nimtest/api   # ← ONE IMPORT TO RULE THEM ALL

var ctx = createTestContext()
try:
  let dir = createTempTestDir(ctx, "demo")
  let f = createTestFile(ctx, dir, "hello.txt", "world")
  discard assertFileContains(f, "world")
finally:
  ctx.cleanup()
```

## Features

- Auto-cleanup via TestContext
- 4 report formats (including JUnit XML)
- 5 animated progress bars
- Full CLI testing
- Benchmarks with benchmark()
- nimble test ready

## Documentation

This documentation covers all aspects of the nimtest framework:

### Getting Started
- [Quick Start Guide](QUICKSTART.md) - Get up and running in 5 minutes
- [Configuration Guide](CONFIGURATION.md) - Complete setup and configuration
- [User Guide](USER_GUIDE.md) - Complete usage instructions

### Core Documentation
- [API Reference](API.md) - Complete API documentation
- [Architecture](ARCHITECTURE.md) - Framework design and architecture
- [Best Practices](BEST_PRACTICES.md) - Recommended patterns and practices

### Examples and Guides
- [Examples and Patterns](EXAMPLES.md) - Common testing scenarios

### Community
- [Contribution Guidelines](CONTRIBUTING.md) - How to contribute to the project
- [CI/CD Guide](CI_CD_GUIDE.md) - Integration with CI/CD systems

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
discard assertFileExists("path/to/file")
discard assertFileContains("path/to/file", "expected content")
discard assertDirExists("path/to/directory")
```

### Performance Testing

Built-in benchmarking and timing utilities:

```nim
# Time a code block
let duration = measureTime("operation"):
  proc() =
    # Your code here
    sleep(100)

# Run benchmarks
let results = benchmark("test operation", 1000):
  proc() =
    # Code to benchmark
    discard 1 + 1
```

### Progress Visualization

Five different animated progress bar styles:

```nim
let bar = newProgressBar(pbsGlobe, total = 100, message = "Processing...")
for i in 0..99:
  # Do work
  bar.update(i + 1)
bar.finish("Complete!")
```

### Reporting

Multiple output formats for different use cases:

```nim
var report = newTestSuiteReport("My Tests")
# ... add test results
generateConsoleReport(report)  # Human-readable output
saveReport(report, rfJunit, "junit.xml")  # CI/CD integration
saveReport(report, rfJson, "report.json")  # Programmatic access
```

## Framework Architecture

nimtest is organized into focused modules:

```
src/nimtest/
├── api.nim          # Public API facade - import this
├── core.nim         # TestContext, basic utilities
├── helpers.nim      # Advanced assertions, extended utilities
├── reporting.nim    # Test results, multiple output formats
├── progress.nim     # Progress bar implementations
└── config.nim       # Project configuration constants
```

## Contributing

We welcome contributions! See our [Contribution Guidelines](CONTRIBUTING.md) for details on how to get involved.

## License

MIT License - see [LICENSE](../LICENSE) for details.
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

Configure nimtest by editing `src/nimtest/config.nim` in your project:

```nim
const
  ProjectName* = "yourproject"          # Your project name
  ProjectDisplayName* = "Your Project"  # Human-readable name
  TempDirPrefix* = "nimtest_temp"       # Prefix for temporary directories
  TestSuiteVersion* = "0.1.0"           # Version for test reports
```

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
