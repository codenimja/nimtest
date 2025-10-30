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
- `api.nim`: Public API facade (recommended import)
- `core.nim`: Core functionality (TestContext, basic assertions)
- `reporting.nim`: Test reporting and analytics
- `config.nim`: Project configuration
- `progress.nim`: Progress bar utilities
- `helpers.nim`: Extended helper functions

### 4. Extensibility

The framework is designed to be extended with project-specific utilities while maintaining compatibility with standard Nim testing practices.

### 5. Performance Consciousness

The framework includes performance measurement utilities and is designed to minimize overhead during test execution.

## Module Architecture

### Core Modules

```
src/nimtest/
├── api.nim          # Public API facade (recommended import)
├── core.nim         # Core functionality (TestContext, basic assertions)
├── reporting.nim    # Test reporting, analytics, and output formats
├── config.nim       # Optional configuration
├── progress.nim     # Progress bar utilities
└── helpers.nim      # Extended helper functions
```

### api.nim - Public API

This module serves as the main entry point:

- **Unified Import**: Imports and re-exports all other modules
- **Clean Interface**: Provides single import point for all functionality
- **Recommended Usage**: `import nimtest/api` is the preferred way to use the framework

### core.nim - Core Utilities

This module contains the essential testing utilities:

- **Resource Management**: `TestContext` for managing temporary files/directories
- **Basic Assertions**: Core assertion functions like `assertFileExists`, `assertFileContains`
- **Performance Utilities**: Timing and basic benchmarking tools

### reporting.nim - Reporting System

This module handles test result collection and reporting:

- **Test Result Tracking**: `TestResult` and `TestSuiteReport` types
- **Multiple Output Formats**: Console, JSON, JUnit XML, Markdown
- **Analytics**: Pass rates, durations, failure analysis
- **Export Capabilities**: Save reports to files
- **Progress Integration**: `runTestsWithProgress` functionality

### config.nim - Configuration

This module contains optional configuration:

- **Project Metadata**: ProjectName, TempDirPrefix
- **Initialization**: `initConfig()` for setting up defaults
- **Thread Safety**: Uses `.threadvar` for thread-safe configuration

### progress.nim - Progress Utilities

This module handles visual progress indicators:

- **Progress Bar Types**: Multiple visual styles (minimal, globe, pulse, dots, blocks)
- **Optimization**: Updates only every 50ms to avoid spam
- **Integration**: Used by reporting module's `runTestsWithProgress`

### helpers.nim - Extended Utilities

This module contains additional helper functions:

- **Advanced Assertions**: `assertFileNotExists`, `assertFileDoesNotContain`, etc.
- **File Operations**: Extended file system utilities
- **Performance Tools**: Advanced benchmarking utilities

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

The CLI testing utilities have been removed from nimtest to keep the framework lightweight and focused on core testing functionality. For CLI testing, consider using other Nim libraries such as `unittest` with `osproc` for executing external commands.

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

Additional configuration options can be customized through the `config` module:

```nim
import nimtest/config

# Initialize with defaults (optional)
initConfig()

# Customize settings (optional)
ProjectName = "myproject"
TempDirPrefix = "myapp_"
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