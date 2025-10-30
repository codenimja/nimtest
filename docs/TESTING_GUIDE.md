# nimtest Testing Guide

Complete guide to using the nimtest framework for testing your Nim projects.

## Overview

nimtest is a comprehensive testing framework that provides utilities for unit tests, integration tests, CLI testing, and performance benchmarks with automatic resource management and comprehensive reporting.

## Getting Started with Testing

### Basic Test Structure

```nim
import nimtest
import std/unittest

suite "Your Test Suite":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "descriptive test name":
    # Test implementation using nimtest utilities
    let testDir = ctx.createTempTestDir("mytest")
    # Your test code here
    check someCondition == true
```

### Using Test Context for Resource Management

```nim
suite "Resource Management Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "file operations with automatic cleanup":
    let testDir = ctx.createTempTestDir("file_test")
    let testFile = testDir / "sample.txt"
    writeFile(testFile, "Hello, World!")
    
    # Verify with nimtest assertions
    assertFileExists(testFile)
    assertFileContains(testFile, "Hello, World!")
    
    # No need to manually delete - cleanup() handles it
```

## Core Testing Patterns

### File System Testing

```nim
test "configuration file creation":
  let testDir = ctx.createTempTestDir("config_test")
  # Run your application logic that creates config
  createConfigFile(testDir / "config.json")
  
  # Verify with assertions
  assertFileExists(testDir / "config.json")
  assertFileContains(testDir / "config.json", "version")
  assertFileContains(testDir / "config.json", "settings")
```

### File System Testing

```nim
test "Configuration file validation":
  let testDir = createTempTestDir(ctx, "config_test")
  let configFile = createTestFile(ctx, testDir, "config.json", """{"version": "1.0.0"}""")
  
  discard assertFileExists(configFile)
  discard assertFileContains(configFile, "version")
  discard assertFileContains(configFile, "1.0.0")

test "Directory structure validation":
  let testDir = createTempTestDir(ctx, "structure_test")
  let srcDir = createTestDir(ctx, testDir, "src")
  let testDirSub = createTestDir(ctx, testDir, "tests")
  
  discard assertDirExists(srcDir)
  discard assertDirExists(testDirSub)
  discard assertDirExists(testDir / "src")
```

### Performance Testing

```nim
test "search operation performance":
  measureTime("search operation"):
    let results = performSearch("query")
  
  # Verify performance requirements
  benchmark("search operation", 100):
    let results = performSearch("query")
  
  # Test with timeout
  let completed = runTestWithTimeout(proc() =
    performSlowOperation()
  , 5)  # 5 second timeout
  check completed == true
```

### Error Handling Testing

```nim
test "invalid input raises error":
  assertThrows(proc() =
    processInvalidInput("bad_data")
  )

test "file not found error":
  try:
    readFile("nonexistent_file.txt")
    check false  # Should not reach here
  except IOError:
    check true   # Expected exception
```

## Advanced Testing Techniques

### Using Multiple Assertion Types

```nim
test "comprehensive file validation":
  let testDir = ctx.createTempTestDir("validation_test")
  let testFile = createTestFile(ctx, testDir, "data.txt", "important content")
  
  # Basic assertions
  assertFileExists(testFile)
  assertFileContains(testFile, "important")
  
  # Advanced assertions
  assertFileHasSize(testFile, 17)  # "important content" = 17 chars
  let beforeTime = getTime()
  writeFile(testFile, "updated content")
  assertFileModifiedAfter(testFile, beforeTime)
  
  # Negative assertions
  assertFileDoesNotContain(testFile, "obsolete")
```

### Integration Testing

```nim
suite "Integration Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "complete workflow":
    let projectDir = ctx.createTempTestDir("workflow_test")
    
    # Step 1: Create directory structure
    let srcDir = createTestDir(ctx, projectDir, "src")
    check true  # Directory created successfully
    
    # Step 2: Create component file
    let buttonFile = createTestFile(ctx, srcDir, "button.nim", "echo \"Button component\"")
    discard assertFileExists(buttonFile)
    
    # Step 3: Verify component
    discard assertFileContains(buttonFile, "Button component")
    discard assertFileExists(buttonFile)
```

### Reporting Test Results

```nim
suite "Reporting Example":
  var report: TestSuiteReport

  setup:
    report = newTestSuiteReport("My Application Tests")

  test "tracked test example":
    let startTime = cpuTime()
    # Your test logic here
    let duration = cpuTime() - startTime
    
    let result = newTestResult("feature test", true, duration, "Test passed", "feature")
    addResult(report, result)

  teardown:
    finish(report)
    generateConsoleReport(report)
    let jsonReport = saveReport(report, rfJson, "test_results.json")
    echo "Report saved to: ", jsonReport
```

### Using Progress Bars for Test Feedback

For long-running test suites, use progress bars to provide visual feedback:

```nim
suite "Progress Bar Example":
  test "long running test with progress":
    let bar = newProgressBar(pbsGlobe, width = 40, total = 100, message = "Running tests...")
    
    for i in 0..<100:
      # Simulate test work
      sleep(10)  # Replace with actual test logic
      bar.updateProgress(i + 1, fmt"Completed {i + 1}/100 operations")
      bar.display()
    
    bar.finish("All tests completed successfully!")
```

### Running Test Suites with Progress Visualization

Use the built-in progress runner for comprehensive test suites:

```nim
# In your test runner file
let testSuites = @[
  ("Core Tests", runCoreTests),
  ("CLI Tests", runCliTests),
  ("Integration Tests", runIntegrationTests)
]

let report = runTestsWithProgress(testSuites, pbsBlocks)
generateConsoleReport(report)
```

## Best Practices

### DO:
- Always use `TestContext` for resource management
- Use setup/teardown for initialization and cleanup
- Use descriptive test names that explain the expected behavior
- Use appropriate assertion utilities for different checks
- Test both success and failure scenarios
- Use performance utilities to track critical operations
- Generate reports to track test metrics over time
- Keep tests independent and focused

### DON'T:
- Forget to call `ctx.cleanup()` in teardown
- Hard-code absolute paths in tests
- Test multiple unrelated things in one test
- Ignore error conditions in your tests
- Create temporary files/directories without tracking them
- Make tests dependent on execution order

## Testing Strategies

### Unit Testing
Focus on testing individual functions or procedures:

```nim
test "add function works correctly":
  check add(2, 3) == 5
  check add(-1, 1) == 0
  check add(0, 0) == 0
```

### Integration Testing
Test how multiple components work together:

```nim
test "database and API integration":
  let db = connectToTestDatabase()
  let api = newApiHandler(db)
  
  let response = api.handleRequest("GET", "/users/123")
  check response.status == 200
  assertOutputContains(response.body, "user123")
```

### Performance Testing
Verify that operations meet performance requirements:

```nim
test "database query performs within limits":
  let startTime = cpuTime()
  let results = database.query("SELECT * FROM users LIMIT 100")
  let duration = cpuTime() - startTime
  
  check results.len == 100
  check duration < 0.1  # Must complete in under 100ms
```

## Debugging Tests

### Common Debugging Approaches

```nim
# Add debug output temporarily
test "debugging example":
  echo "Debug: Starting test"
  let testDir = ctx.createTempTestDir("debug_test")
  echo "Debug: Created dir: ", testDir
  # More test code
  echo "Debug: Test completed"
```

### Isolating Test Failures

```nim
# Run individual test files for isolation
# nim c -r tests/unit/test_specific_feature.nim
```

## Configuration for Different Test Types

### For CLI Applications

Enable CLI testing features in `src/nimtest/test_config.nim`:

```nim
const
  HAS_CLI* = true                      # Enable CLI testing utilities
  CLI_BINARY_PATH* = "./bin/myapp"     # Path to your CLI binary
```

### For Library Testing

Disable CLI features if your project is a library:

```nim
const
  HAS_CLI* = false                     # Disable CLI testing
  HAS_CORE_LIB* = true                 # Enable core library testing
```

## Running Tests

### Compile and Run Individual Tests

```bash
nim c -r tests/test_my_feature.nim
```

### With Release Flags for Performance Tests

```bash
nim c -r -d:release tests/test_performance.nim
```

## Troubleshooting Common Issues

### Resource Cleanup Issues

```nim
# Make sure to always use TestContext
suite "Proper Resource Management":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()  # Always call cleanup!
```

### Path Issues

```nim
# Use relative paths and nimtest utilities
let testDir = ctx.createTempTestDir("my_test")
let filePath = testDir / "file.txt"  # Use / for cross-platform paths
```

### CLI Command Issues

```nim
# Verify your CLI binary exists and is configured correctly
# Check src/nimtest/test_config.nim CLI_BINARY_PATH setting
```

## Support

For questions about using the nimtest framework:
- Review the [API.md](API.md) for complete API documentation
- Check [EXAMPLES.md](EXAMPLES.md) for usage patterns
- Look at [USER_GUIDE.md](USER_GUIDE.md) for comprehensive usage instructions
- See [BEST_PRACTICES.md](BEST_PRACTICES.md) for recommended patterns

---

**Framework Version**: 0.2.0
**Last Updated**: 2025-10-27
**Status**: Production Ready
