# nimtest User Guide

Complete guide to using the nimtest testing framework effectively.

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

## Writing Tests

### Basic Test Structure

```nim
import nimtest/api
import std/unittest

suite "My Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic functionality":
    let tempDir = createTempTestDir(ctx, "test")
    let tempFile = createTestFile(ctx, tempDir, "test.txt", "content")

    # Assertions
    discard assertFileExists(tempFile)
    discard assertFileContains(tempFile, "content")
```

### Test Context Management

The `TestContext` is the core of nimtest's resource management:

```nim
# Create context
var ctx = createTestContext()

try:
  # Create temporary resources
  let tempDir = createTempTestDir(ctx, "my_test")
  let tempFile = createTestFile(ctx, tempDir, "data.txt", "test data")

  # Use resources in tests
  check fileExists(tempFile)

finally:
  # Automatic cleanup
  ctx.cleanup()
```

### File System Operations

nimtest provides comprehensive file system testing utilities:

```nim
# Basic assertions
discard assertFileExists("path/to/file")
discard assertDirExists("path/to/directory")
discard assertFileContains("file.txt", "expected content")
discard assertFileHasSize("file.bin", 1024)

# Negative assertions
discard assertFileNotExists("should/not/exist")
discard assertFileDoesNotContain("file.txt", "forbidden text")
```

### Performance Testing

Built-in benchmarking and timing utilities:

```nim
# Simple timing
let duration = measureTime("database query"):
  proc() =
    # Your code to time
    sleep(100)

# Benchmarking with statistics
let results = benchmark("string operation", 1000):
  proc() =
    var s = ""
    for i in 0..100:
      s &= "test"

echo &"Average: {results.avg:.3f}ms, Min: {results.min:.3f}ms, Max: {results.max:.3f}ms"
```

### Progress Bars

Five animated progress bar styles for visual feedback:

```nim
# Create progress bar
let bar = newProgressBar(pbsGlobe, total = 100, message = "Processing...")

# Update progress
for i in 0..99:
  # Do work here
  bar.update(i + 1, &"Completed {i + 1}/100")

# Finish
bar.finish("All tasks completed!")
```

### Test Reporting

Generate comprehensive reports in multiple formats:

```nim
# Create report
var report = newTestSuiteReport("My Test Suite")

# Add results
addResult(report, newTestResult("test 1", true, 0.001, "passed"))
addResult(report, newTestResult("test 2", false, 0.002, "failed"))

# Finish and generate reports
finish(report)

# Console output (human-readable)
generateConsoleReport(report)

# Save to files
let junitFile = saveReport(report, rfJunit, "results.xml")
let jsonFile = saveReport(report, rfJson, "results.json")
let mdFile = saveReport(report, rfMarkdown, "results.md")
```

### CLI Testing (Planned)

CLI testing utilities are planned for future releases:

```nim
# Future API (not yet implemented)
let (output, exitCode) = runCliCommand("--version")
check exitCode == 0
assertOutputContains(output, "1.0.0")
```

## Advanced Usage

### Custom Assertions

Create custom assertions using the framework:

```nim
proc assertJsonFileContains*(path: string, key: string, expectedValue: string) =
  discard assertFileExists(path)
  let content = readFile(path)
  let json = parseJson(content)
  if json[key].getStr() != expectedValue:
    raise newException(AssertionDefect, &"JSON key '{key}' has value '{json[key].getStr()}', expected '{expectedValue}'")
```

### Integration Testing

Use nimtest for integration tests:

```nim
test "full workflow":
  var ctx = createTestContext()
  try:
    # Setup test environment
    let projectDir = createTempTestDir(ctx, "integration")

    # Simulate project creation
    let configFile = createTestFile(ctx, projectDir, "config.json", """{"debug": true}""")

    # Test your application logic
    # ... application code ...

    # Verify results
    discard assertFileExists(projectDir / "output.txt")
    discard assertFileContains(projectDir / "output.txt", "success")

  finally:
    ctx.cleanup()
```

### CI/CD Integration

nimtest works seamlessly with CI/CD systems:

```bash
# Run tests
nimble test

# Generate JUnit reports for CI
nim c -r tests/my_tests.nim --junit-report=test_results.xml

# Generate JSON reports for analysis
nim c -r tests/my_tests.nim --json-report=test_results.json
```

## Best Practices

### Resource Management
- Always use `TestContext` for temporary resources
- Call `ctx.cleanup()` in teardown blocks
- Use descriptive prefixes for temp directories

### Test Organization
- Group related tests in suites
- Use descriptive test names
- Keep tests focused and atomic

### Performance Testing
- Use `benchmark()` for operations that should be measured
- Set appropriate iteration counts
- Compare results against baselines

### Error Handling
- Let assertions throw exceptions for test failures
- Use `try/except` blocks sparingly in tests
- Check error messages in assertions when needed

## Troubleshooting

### Common Issues

**Tests not cleaning up properly:**
- Ensure `ctx.cleanup()` is called in teardown
- Check that all resources are created through the context

**Performance tests showing inconsistent results:**
- Run benchmarks multiple times
- Use higher iteration counts for stable results
- Isolate performance tests from other operations

**File system assertions failing:**
- Verify file paths are correct
- Check file permissions
- Ensure files are created before assertions

## Migration Guide

### From unittest

If migrating from Nim's standard unittest:

```nim
# Old way
import unittest

suite "old tests":
  test "basic":
    check(1 + 1 == 2)

# New way with nimtest
import nimtest/api
import unittest

suite "new tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic":
    check(1 + 1 == 2)

  test "with resources":
    let tempFile = createTestFile(ctx, createTempTestDir(ctx, "test"), "test.txt", "content")
    discard assertFileContains(tempFile, "content")
```

## API Reference

See [API.md](API.md) for complete function documentation.
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
import nimtest/api
import std/unittest

suite "File System Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "create and check file":
    let testDir = ctx.createTempTestDir()
    let testFile = createTestFile(ctx, testDir, "test.txt", "Hello, World!")
    
    assertFileExists(testFile)
    assertFileContains(testFile, "Hello, World!")
```

## Writing Tests

### Test Structure

Each test follows this pattern:

```nim
import nimtest/api
import std/unittest

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

## Command Line Interface Testing

The nimtest framework previously included CLI testing utilities, but these have been removed to keep the framework lightweight and focused on core testing functionality. For CLI testing, consider using other Nim libraries such as `unittest` with `osproc` for executing external commands.
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
- **`pbsGlobe`**: Globe-like rotating progress
- **`pbsPulse`**: Pulsing bar with animated Unicode characters
- **`pbsDots`**: Animated dots progress indicator
- **`pbsBlocks`**: Unicode block characters for solid progress display

### Using Progress Bars

```nim
# Basic usage
let bar = newProgressBar(pbsGlobe, total = 100, message = "Running tests...")

for i in 0..100:
  # Update progress (optimized to avoid spam - only updates every 50ms)
  update(bar, i, &"Processing item {i}")
  
  # Display the progress bar
  display(bar)
  
  # Simulate work
  sleep(50)

# Complete the progress bar
finish(bar, "All tests completed!")
```

### Running Tests with Progress Bars

```nim
# Define test procedures
proc runUnitTests() {.gcsafe.} =
  suite "Unit Tests":
    test "basic math": check 2 + 2 == 4
    test "string ops": check "hello".len == 5

proc runIntegrationTests() {.gcsafe.} =
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

# Configuration happens during creation
# Update and display (optimized for performance)
update(bar, 50, "Halfway there...")
display(bar)
```

## Extensibility

### Creating Custom Assertions

You can create custom assertion functions that follow the same pattern as the built-in assertions:

```nim
proc assertFileMatchesPattern*(path: string, pattern: string): bool =
  ## Custom assertion to check if file content matches a pattern
  if not fileExists(path):
    let errorMsg = "File does not exist: " & path
    raise newException(AssertionDefect, errorMsg)
  
  let content = readFile(path)
  let matches = contains(content, pattern)
  if not matches:
    let errorMsg = "File does not match pattern: " & path
    raise newException(AssertionDefect, errorMsg)
  return matches
```

### Extending Functionality

The framework is designed to be easily extended with project-specific utilities that work alongside the built-in functions.
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
import nimtest/api

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
import nimtest/api
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

**Q: Tests work locally but fail in CI/CD**
A: Check that all paths are relative and platform-independent