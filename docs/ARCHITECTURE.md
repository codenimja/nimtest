# Architecture Documentation

Detailed overview of the nimtest framework architecture, design principles, and internal structure.

## Table of Contents

- [Overview](#overview)
- [Design Principles](#design-principles)
- [Module Architecture](#module-architecture)
- [Core Components](#core-components)
- [Data Flow](#data-flow)
- [Testing Patterns](#testing-patterns)
- [Extensibility](#extensibility)
- [Performance Considerations](#performance-considerations)
- [Security Aspects](#security-aspects)

## Overview

nimtest is a comprehensive testing framework designed for Nim projects that emphasizes resource management, clean test isolation, and comprehensive reporting. The framework is built around a modular architecture that allows for easy customization and extension while maintaining simplicity for basic use cases.

### Purpose and Goals

The primary goals of nimtest are:

1. **Simplicity**: Easy to set up and use for basic testing needs
2. **Resource Management**: Automatic cleanup of temporary resources
3. **Comprehensive Utilities**: Rich set of utilities for various testing scenarios
4. **Flexible Reporting**: Multiple output formats for test results
5. **Cross-Platform**: Consistent behavior across Linux, macOS, and Windows
6. **Extensibility**: Easy to customize for specific project needs

## Design Principles

### 1. Resource Management First

The framework prioritizes proper resource management through the `TestContext` system, ensuring that temporary files and directories are automatically cleaned up even if tests fail.

### 2. Convention Over Configuration

While configurable, the framework provides sensible defaults that work for most projects out of the box, requiring minimal setup for basic usage.

### 3. Modularity

The framework is organized into distinct modules, each handling specific functionality:
- `helpers.nim`: Core testing utilities and assertions
- `reporting.nim`: Test reporting and analytics
- `test_config.nim`: Project configuration

### 4. Extensibility

The framework is designed to be extended with project-specific utilities while maintaining compatibility with standard Nim testing practices.

### 5. Performance Consciousness

The framework includes performance measurement utilities and is designed to minimize overhead during test execution.

## Module Architecture

### Core Modules

```
src/nimtest/
├── helpers.nim      # Core utilities, assertions, resource management
├── reporting.nim    # Test reporting, analytics, and output formats
└── test_config.nim  # Project configuration and constants
```

### helpers.nim - Core Utilities

This module contains the essential testing utilities:

- **Resource Management**: `TestContext` for managing temporary files/directories
- **File System Operations**: Assertions and utilities for file/directory testing
- **CLI Testing**: Utilities for testing command-line applications
- **Performance Utilities**: Timing and benchmarking tools
- **Component Testing**: Utilities for component-based systems

### reporting.nim - Reporting System

This module handles test result collection and reporting:

- **Test Result Tracking**: `TestResult` and `TestSuiteReport` types
- **Multiple Output Formats**: Console, JSON, JUnit XML, Markdown
- **Analytics**: Pass rates, durations, failure analysis
- **Export Capabilities**: Save reports to files

### test_config.nim - Configuration

This module contains project-specific configuration:

- **Project Metadata**: Name, display name, version
- **Feature Flags**: Enable/disable specific functionality
- **Path Configuration**: Directories and binary locations
- **CLI Commands**: Command names for testing

## Core Components

### TestContext

The `TestContext` is the central resource management component:

```nim
type
  TestContext* = object
    tempDirs*: seq[string]    # Tracked temporary directories
    tempFiles*: seq[string]   # Tracked temporary files
    startTime*: Time          # Test start time
```

**Responsibilities:**
- Track temporary resources created during tests
- Provide automatic cleanup through `cleanup()` method
- Ensure test isolation by managing unique temporary spaces

### Assertion System

The framework provides various assertion utilities organized by category:

**File System Assertions:**
- `assertFileExists`
- `assertDirExists`
- `assertFileContains`
- `assertOutputContains`

**Advanced Assertions:**
- `assertFileNotExists`
- `assertFileDoesNotContain`
- `assertFileHasSize`
- `assertFileModifiedAfter`

### CLI Testing Utilities

Utilities for testing command-line applications:

- `runCliCommand`: Execute CLI commands and capture output
- `runCliCommandInDir`: Execute commands in specific directories
- Exit code and output validation

### Reporting System

The reporting system consists of:

- `TestResult`: Individual test result with metadata
- `TestSuiteReport`: Collection of test results
- Multiple output format generators
- File export capabilities

## Data Flow

### Test Execution Flow

```
Test Definition → Setup → Test Execution → Result Collection → Reporting
```

1. **Test Definition**: Tests are defined using Nim's unittest framework
2. **Setup**: `TestContext` is created and initialized
3. **Execution**: Test code runs with framework utilities
4. **Collection**: Results are gathered using reporting utilities
5. **Reporting**: Results are formatted and output

### Resource Management Flow

```
createTestContext → createTempTestDir/createTestFile → cleanup
```

1. **Context Creation**: `TestContext` is instantiated
2. **Resource Creation**: Temporary resources are created and tracked
3. **Cleanup**: All tracked resources are removed

### Reporting Flow

```
newTestSuiteReport → addResult → finish → generateOutput → saveReport
```

1. **Report Creation**: `TestSuiteReport` is initialized
2. **Result Addition**: Individual test results are added
3. **Finalization**: Report is marked as complete
4. **Generation**: Output format is generated
5. **Export**: Report is saved to file if requested

## Testing Patterns

### Test Isolation Pattern

Each test uses its own `TestContext` to ensure isolation:

```nim
suite "Isolated Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()
```

### Resource Tracking Pattern

Temporary resources are created through the context:

```nim
let tempDir = ctx.createTempTestDir("test_name")
let tempFile = createTestFile(ctx, tempDir, "file.txt", "content")
```

### Assertion Composition Pattern

Assertions are built using reusable utilities:

```nim
assertFileExists(filePath)
assertFileContains(filePath, expectedContent)
```

## Extensibility

### Custom Assertion Creation

New assertions can be created by extending the existing patterns:

```nim
proc assertFileMatchesPattern*(path: string, pattern: string) =
  ## Custom assertion for pattern matching in files
  doAssert fileExists(path), "File does not exist: " & path
  let content = readFile(path)
  doAssert matchesPattern(content, pattern), "File does not match pattern: " & path
```

### Reporting Extension

New report formats can be added by implementing the pattern:

```nim
proc generateCustomReport*(report: TestSuiteReport): string =
  ## Generate custom report format
  # Implementation here
```

### Configuration Extension

Additional configuration options can be added to `test_config.nim`:

```nim
const
  CUSTOM_OPTION* = "default_value"  # New configuration option
```

## Performance Considerations

### Resource Management Efficiency

The framework is designed to minimize resource overhead:

- Temporary files/directories are created only when needed
- Cleanup is batched and efficient
- Memory usage is kept minimal for large test suites

### Test Execution Speed

The framework minimizes overhead during test execution:

- Lightweight assertion utilities
- Efficient file system operations
- Optional performance tracking

### Memory Usage

The framework manages memory efficiently:

- Temporary resources are tracked in sequences
- Cleanup prevents memory leaks
- Report generation is optimized for large datasets

## Security Aspects

### File System Security

The framework ensures safe file system operations:

- Temporary files are created in system temp directories
- Cleanup removes all created resources
- Path validation prevents directory traversal attacks

### Command Execution Safety

CLI testing utilities execute commands safely:

- Commands are executed in controlled environments
- Output is captured and validated
- Timeout mechanisms prevent hanging processes

### Data Isolation

Tests maintain proper isolation:

- Each test gets unique temporary directories
- No shared state between tests
- Proper cleanup prevents data leakage

## Integration Points

### Nim Standard Library

The framework integrates with Nim's standard library:

- Uses `unittest` for test execution
- Leverages `os` and `osproc` for system operations
- Utilizes `json` for data handling
- Employs `times` for timing operations

### External Tools

The framework can integrate with external tools:

- JUnit XML output for CI/CD systems
- JSON output for analysis tools
- Markdown output for documentation

This architecture provides a solid foundation for comprehensive testing while maintaining simplicity and extensibility for diverse project needs.