# nimtest Framework - AI Coding Agent Instructions

## Project Overview
nimtest is a comprehensive testing framework for Nim projects, providing utilities for unit tests, integration tests, CLI testing, and performance benchmarks with automatic resource management and multiple reporting formats.

## Architecture & Core Components

### Modular Design
- **`src/nimtest/helpers.nim`**: Core utilities, TestContext for resource management, file system assertions, CLI testing utilities
- **`src/nimtest/reporting.nim`**: Test result collection, analytics, and output format generation (console, JSON, JUnit XML, Markdown)
- **`src/nimtest/test_config.nim`**: Project-specific configuration constants and CLI command definitions

### Key Data Types
- **`TestContext`**: Manages temporary files/directories with automatic cleanup
- **`TestResult`**: Individual test outcome with metadata (name, success, duration, message)
- **`TestSuiteReport`**: Collection of test results with analytics
- **`ComponentMetadata`**: UI component metadata for component-based testing

## Essential Patterns & Conventions

### Test Structure Pattern
```nim
import nimtest
import std/unittest

suite "Feature Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "specific behavior":
    let tempDir = ctx.createTempTestDir("test_name")
    let tempFile = createTestFile(ctx, tempDir, "file.txt", "content")
    # ... test logic
```

### Resource Management
- **Always use TestContext** for temporary resources - never create files/dirs manually in tests
- **Track resources automatically** through `ctx.createTempTestDir()` and `createTestFile(ctx, ...)`
- **Cleanup happens automatically** via `ctx.cleanup()` in teardown

### CLI Testing Pattern
```nim
let (output, exitCode) = runCliCommand("--version")
check exitCode == 0
assertOutputContains(output, "1.0.0")
```

### File System Assertions
```nim
assertFileExists("config.json")
assertFileContains("output.txt", "expected content")
assertDirExists("temp/")
```

## Configuration & Setup

### Project Configuration (`src/nimtest/test_config.nim`)
- **Edit this file first** when setting up for a new project
- Configure `PROJECT_NAME`, `CLI_BINARY_PATH`, feature flags (`HAS_CLI`, `HAS_COMPONENT_SYSTEM`)
- Define CLI command constants (`CMD_INIT`, `CMD_LIST`, etc.)
- Set directory paths (`SRC_DIR`, `TEST_DIR`)

### Build & Run Commands
```bash
# Build and run tests
nimble test
nim c -r examples/test_all.nim

# Run specific test suites
nim c -r examples/core/test_registry_init.nim
nim c -r examples/cli/test_cli_create.nim

# Generate reports
nim c -r examples/test_reporting_demo.nim
```

## Component System (UI Testing)

### Component Metadata Pattern
```nim
let component = ComponentMetadata(
  name: "dropdown",
  category: catUI,
  properties: @[ComponentProperty(name: "width", typeName: "int", defaultValue: "200")],
  variants: @["default", "compact"]
)
```

### Test Component Creation
```nim
let testComponent = createTestComponent("dropdown", catUI)
let componentFile = createTestComponentFile(ctx, tempDir, "dropdown")
let metadataFile = createTestMetadataFile(ctx, tempDir, "dropdown", "ui")
```

## Reporting & Analytics

### Report Generation Pattern
```nim
var report = newTestSuiteReport("My Test Suite")
let result = newTestResult("test name", true, 0.005, "passed")
addResult(report, result)

# Generate outputs
generateConsoleReport(report)
saveReport(report, rfJson, "report.json")
saveReport(report, rfJunitXml, "junit.xml")
```

## Common Workflows

### Adding New Tests
1. Create test file in appropriate `examples/` subdirectory
2. Import `nimtest` and `std/unittest`
3. Use TestContext pattern with setup/teardown
4. Add to `examples/test_all.nim` if it's a new test suite

### CLI Feature Testing
1. Configure `CLI_BINARY_PATH` in `test_config.nim`
2. Use `runCliCommand()` for command execution
3. Assert on exit codes and output content
4. Test both success and error cases

### Component Testing
1. Create component metadata using `createTestComponent()`
2. Generate test files with `createTestComponentFile()` and `createTestMetadataFile()`
3. Test component properties and variants
4. Validate file generation and content

## Advanced Testing Patterns

### Component Testing with Metadata Validation
```nim
test "component metadata validation":
  let component = createTestComponent("dropdown", catUI)
  assert component.name == "dropdown"
  assert component.category == catUI
  assert component.version == "1.0.0-test"

  # Test file generation
  let componentFile = createTestComponentFile(ctx, tempDir, "dropdown")
  let metadataFile = createTestMetadataFile(ctx, tempDir, "dropdown", "ui")

  assertFileExists(componentFile)
  assertFileContains(componentFile, "import nigui")
  assertFileContains(metadataFile, "\"name\": \"dropdown\"")
```

### Cross-Platform Path Handling
```nim
test "cross-platform path operations":
  let testPath = tempDir / "subdir" / "file.txt"
  createTestFile(ctx, testPath, "test content")

  # Use forward slashes - nimtest handles platform conversion
  assertFileExists(testPath)
  assertFileContains(testPath, "test content")
```

### CLI Testing with Error Scenarios
```nim
test "CLI error handling":
  let (output, exitCode) = runCliCommand("--invalid-flag")
  check exitCode != 0  # Should fail
  assertOutputContains(output, "error") or
  assertOutputContains(output, "Error") or
  assertOutputContains(output, "ERROR")
```

## Framework Extension Guidelines

### Adding New Assertions
```nim
proc assertFileHasLineCount*(path: string, expectedLines: int, msg: string = "") =
  ## Assert that a file has a specific number of lines
  doAssert fileExists(path), "File does not exist: " & path
  let content = readFile(path)
  let lineCount = content.splitLines().len
  let errorMsg = if msg == "": fmt"Expected {expectedLines} lines, got {lineCount}" else: msg
  doAssert lineCount == expectedLines, errorMsg
```

### Adding New CLI Testing Utilities
```nim
proc runCliCommandWithTimeout*(args: string, timeoutSeconds: int = 30): tuple[output: string, exitCode: int, timedOut: bool] =
  ## Execute CLI command with timeout
  # Implementation using osproc with timeout handling
```

## Integration Testing Patterns

### End-to-End Workflow Testing
```nim
test "complete project workflow":
  let projectDir = ctx.createTempTestDir("project")

  # Simulate project creation
  let configFile = createTestFile(ctx, projectDir, "config.json", """{"debug": true}""")
  let (initOutput, initCode) = runCliCommandInDir(projectDir, "init")
  check initCode == 0

  # Verify project structure
  assertFileExists(projectDir / "config.json")
  assertDirExists(projectDir / "src")
  assertDirExists(projectDir / "tests")
```

## Performance Testing Integration

### Benchmark Integration
```nim
test "performance regression check":
  let testData = createTestFile(ctx, tempDir, "large.txt", "x".repeat(1000000))

  measureTime("file processing"):
    let content = readFile(testData)
    let processed = content.toUpperAscii()
    writeFile(testData & ".processed", processed)

  assertFileExists(testData & ".processed")
```

## Error Handling Patterns

### Graceful Test Failure Handling
```nim
test "handles missing files gracefully":
  let missingFile = tempDir / "does_not_exist.txt"

  # This should fail gracefully
  expect AssertionDefect:
    assertFileContains(missingFile, "content")

  # Test passes because we expect the assertion to fail
```

## Best Practices Summary

### Code Quality Standards
- **Always use TestContext** for any temporary resources
- **Validate both success and failure paths** in tests
- **Include cleanup verification** in teardown blocks
- **Use descriptive test names** that explain the behavior being tested
- **Test cross-platform compatibility** where applicable

### Documentation Standards
- **Include working code examples** in all documentation
- **Reference actual implementation files** in guides
- **Provide migration examples** for breaking changes
- **Document performance characteristics** of utilities

### Maintenance Practices
- **Regular dependency updates** via CI/CD
- **Security scanning** with automated tools
- **Performance regression testing** in CI pipeline
- **Cross-platform testing** on all major operating systems