# nimtest Framework - AI Coding Agent Instructions

## Project Overview
nimtest is a comprehensive testing framework for Nim projects, providing utilities for unit tests, integration tests, CLI testing, and performance benchmarks with automatic resource management and multiple reporting formats.

## Architecture & Core Components

### Modular Design
- **`src/nimtest/helpers.nim`**: Core utilities, TestContext for resource management, file system assertions, CLI testing utilities
- **`src/nimtest/reporting.nim`**: Test result collection, analytics, and output format generation (console, JSON, JUnit XML, Markdown)
- **`src/nimtest/test_config.nim`**: Project-specific configuration constants and CLI command definitions (NEEDS TO BE CREATED)

### Key Data Types
- **`TestContext`**: Manages temporary files/directories with automatic cleanup
- **`TestSuiteResult`**: Individual test outcome with metadata (name, success, duration, message)
- **`TestSuiteReport`**: Collection of test results with analytics
- **`ComponentMetadata`**: UI component metadata for component-based testing
- **`ProgressBar`**: Visual progress indicators with multiple styles (minimal, globe, pulse, dots, blocks)

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
- **Use forward slashes** for paths - nimtest handles platform conversion

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
assertFileHasSize("data.bin", 1024)
assertFileModifiedAfter("file.txt", startTime)
```

## Configuration & Setup

### Project Configuration (`src/nimtest/test_config.nim`)
⚠️ **CRITICAL**: This file does not exist yet and must be created first when setting up for a new project.

**Create this file with:**
```nim
import helpers

const
  PROJECT_NAME* = "yourproject"          # Your project name
  PROJECT_DISPLAY_NAME* = "YourProject"  # Display name
  CLI_BINARY_PATH* = "./bin/yourproject" # CLI binary path (if applicable)
  HAS_CLI* = true                       # Enable CLI testing features
  HAS_COMPONENT_SYSTEM* = false          # Enable component testing features

  # Directory paths
  SRC_DIR* = "src"
  TEST_DIR* = "tests"

  # CLI command constants
  CMD_INIT* = "init"
  CMD_LIST* = "list"
  CMD_CREATE* = "create"
  CMD_EXPORT* = "export"

  # Temporary directory prefix
  TEMP_DIR_PREFIX* = "nimtest_"

# Module categories for component testing
type
  ModuleCategory* = enum
    catGeneral = "general"
    catCore = "core"
    catUtility = "utility"
    catExtension = "extension"
    catPlugin = "plugin"
```

### Build & Run Commands
```bash
# Build the framework
nim c src/nimtest.nim

# Run framework tests (when examples exist)
nimble test

# Run specific test files
nim c -r examples/test_file.nim

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

### Progress Bars
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

### Performance Testing
```nim
test "performance regression check":
  let testData = createTestFile(ctx, tempDir, "large.txt", "x".repeat(1000000))

  measureTime("file processing"):
    let content = readFile(testData)
    let processed = content.toUpperAscii()
    writeFile(testData & ".processed", processed)

  assertFileExists(testData & ".processed")
```

### Benchmarking
```nim
benchmark("string operations", 1000):
  var s = ""
  for i in 0..100:
    s &= "test"
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

## Current Project State & Gaps

### Missing Critical Components
- **`src/nimtest/test_config.nim`**: Must be created for the framework to be usable
- **Example test files**: No actual working examples exist yet
- **Integration tests**: Framework needs real-world usage examples

### Immediate Action Items for AI Agents
1. **Create `test_config.nim`** with proper constants and types
2. **Generate example test files** in `examples/` directory
3. **Create `examples/test_all.nim`** to run all examples
4. **Add working CLI test examples** using `runCliCommand()`
5. **Implement component testing examples** for UI frameworks

### Framework Usage Pattern
This framework is designed to be **copied into other Nim projects**, not used as a dependency. When setting up for a new project:

1. Copy `src/nimtest/` directory to your project's `src/`
2. Create and configure `test_config.nim`
3. Write tests using the patterns above
4. Run with `nim c -r your_test.nim`