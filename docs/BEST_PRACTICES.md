# nimtest Best Practices

Recommended patterns and practices for effective testing with the nimtest framework.

## Table of Contents

- [Test Organization](#test-organization)
- [Resource Management](#resource-management)
- [Test Design Patterns](#test-design-patterns)
- [Assertion Best Practices](#assertion-best-practices)
- [Performance Testing](#performance-testing)
- [Error Handling](#error-handling)
- [Reporting and Analytics](#reporting-and-analytics)
- [CI/CD Integration](#cicd-integration)
- [Maintainability](#maintainability)
- [Code Quality](#code-quality)

## Test Organization

# nimtest Best Practices

Recommended patterns and practices for effective testing with the nimtest framework.

## Install

```bash
nimble install nimtest
```

## Quick Example

```nim
import nimtest/api

var ctx = createTestContext()
try:
  let dir = createTempTestDir(ctx, "demo")
  let f = createTestFile(ctx, dir, "hello.txt", "world")
  discard assertFileContains(f, "world")
finally:
  ctx.cleanup()
```

## Test Organization

### Group Related Tests

Organize tests by functionality:

```
tests/
├── test_core.nim        # Core functionality
├── test_helpers.nim     # Advanced utilities
├── test_reporting.nim   # Report generation
├── test_progress.nim    # Progress bars
└── test_integration.nim # Full workflows
```

### Use Descriptive Test Names

```nim
# Good
test "creates config file with correct structure":
test "handles missing input gracefully":
test "performance regression check":

# Avoid
test "test1":
test "check":
test "perf":
```

## Resource Management

### Always Use TestContext

```nim
suite "My Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()  # Always cleanup!

  test "file operations":
    let tempDir = createTempTestDir(ctx, "test")
    let tempFile = createTestFile(ctx, tempDir, "test.txt", "content")
    # ... test logic ...
```

### Use Descriptive Prefixes

```nim
# Good
let tempDir = createTempTestDir(ctx, "config_files")
let tempFile = createTestFile(ctx, tempDir, "app_config.json", "{}")

# Avoid
let tempDir = createTempTestDir(ctx, "tmp")
let tempFile = createTestFile(ctx, tempDir, "f.txt", "{}")
```

## Assertion Best Practices

### Use Specific Assertions

```nim
# Good - specific and clear
discard assertFileExists(configFile)
discard assertFileContains(configFile, "debug")
discard assertFileHasSize(dataFile, 1024)

# Avoid - generic and unclear
check(fileExists(configFile))
check(readFile(configFile).contains("debug"))
```

### Test Both Success and Failure Cases

```nim
test "validates input correctly":
  # Test valid input
  check validateInput("good input") == true

  # Test invalid input
  expect ValueError:
    discard validateInput("bad input")
```

### Check Error Messages When Relevant

```nim
test "provides helpful error messages":
  try:
    discard assertFileExists("nonexistent.txt")
  except AssertionDefect as e:
    check "File does not exist" in e.msg
```

## Performance Testing

### Use Appropriate Benchmark Parameters

```nim
# Good - stable results
let results = benchmark("operation", 1000):
  proc() = performOperation()

# Avoid - too few iterations
let results = benchmark("operation", 10):
  proc() = performOperation()
```

### Compare Against Baselines

```nim
test "performance regression check":
  let results = benchmark("critical path", 10000):
    proc() = criticalOperation()

  # Ensure performance hasn't regressed
  check results.avg < 0.001  # Less than 1ms average
  check results.max < 0.010  # Less than 10ms worst case
```

### Isolate Performance Tests

```nim
# Run performance tests separately from unit tests
when defined(performance):
  test "performance critical operation":
    # Performance test code here
else:
  skip("Performance tests disabled")
```

## Progress Bars

### Choose Appropriate Styles

```nim
# For CI/CD - minimal output
let bar = newProgressBar(pbsMinimal, total = 100)

# For interactive use - visual feedback
let bar = newProgressBar(pbsGlobe, total = 100, message = "Processing...")
```

### Update Progress Efficiently

```nim
let bar = newProgressBar(pbsGlobe, total = 1000)

for i in 0..999:
  # Do work
  performStep(i)

  # Update progress (rate-limited internally)
  bar.update(i + 1, &"Step {i + 1}/1000")

bar.finish("All steps completed!")
```

## Reporting

### Generate Multiple Formats

```nim
test "comprehensive testing":
  var report = newTestSuiteReport("Full Test Suite")
  # ... run tests and add results ...

  finish(report)

  # Human-readable for developers
  generateConsoleReport(report)

  # Machine-readable for CI/CD
  let junitFile = saveReport(report, rfJunit, "results.xml")
  let jsonFile = saveReport(report, rfJson, "results.json")
```

### Use JUnit for CI Integration

```nim
# CI systems typically expect JUnit XML
let junitReport = saveReport(report, rfJunit, "test_results.xml")
# This file can be consumed by Jenkins, GitLab CI, etc.
```

## Error Handling

### Test Error Conditions

```nim
test "handles invalid input":
  var ctx = createTestContext()
  try:
    # Test that invalid operations fail appropriately
    expect IOError:
      writeFile("/invalid/path/file.txt", "content")

    # Test custom error handling
    expect ValueError:
      processInvalidData("bad data")

  finally:
    ctx.cleanup()
```

### Avoid Silent Failures

```nim
# Good - explicit assertions
discard assertFileExists(requiredFile)

# Avoid - silent failures
if not fileExists(requiredFile):
  # Test continues without failing
  discard
```

## CI/CD Integration

### Configure Appropriate Timeouts

```yaml
# .github/workflows/ci.yml
test:
  timeout-minutes: 10
  steps:
    - run: nimble test
```

### Archive Test Artifacts

```yaml
# GitHub Actions
- uses: actions/upload-artifact@v3
  with:
    name: test-results
    path: |
      test_results.xml
      test_results.json
```

### Use Parallel Testing When Possible

```nim
# nimble.nimble
task testParallel, "Run tests in parallel":
  exec "nim c -r tests/test_core.nim &"
  exec "nim c -r tests/test_helpers.nim &"
  exec "nim c -r tests/test_reporting.nim &"
  exec "nim c -r tests/test_progress.nim &"
  exec "wait"
```

## Maintainability

### Keep Tests Focused

```nim
# Good - one responsibility
test "validates configuration file":
  # Only tests config validation

test "saves configuration to disk":
  # Only tests config saving

# Avoid - multiple responsibilities
test "configuration management":
  # Tests validation, saving, loading, etc.
```

### Use Helper Procedures

```nim
proc createTestUser(ctx: TestContext): string =
  let userDir = createTempTestDir(ctx, "user")
  let configFile = createTestFile(ctx, userDir, "config.json", "{}")
  return userDir

test "user operations":
  var ctx = createTestContext()
  try:
    let userDir = createTestUser(ctx)
    # Test user operations
  finally:
    ctx.cleanup()
```

### Document Complex Tests

```nim
test "complex workflow integration":
  ## Tests the complete user registration to activation workflow
  ## including email verification and database persistence
  var ctx = createTestContext()
  try:
    # Setup test data
    # Execute workflow
    # Verify results
  finally:
    ctx.cleanup()
```

## Code Quality

### Follow Nim Conventions

```nim
# Good
proc createTestContext*(): TestContext
proc cleanup*(ctx: var TestContext)

# Avoid
proc create_test_context(): TestContext
proc Cleanup(ctx: var TestContext)
```

### Use Meaningful Variable Names

```nim
# Good
let tempConfigDir = createTempTestDir(ctx, "config_test")
let userProfileFile = createTestFile(ctx, tempConfigDir, "profile.json", "{}")

# Avoid
let d = createTempTestDir(ctx, "test")
let f = createTestFile(ctx, d, "f.json", "{}")
```

### Handle Edge Cases

```nim
test "handles empty input":
  check processInput("") == defaultResult

test "handles large input":
  let largeInput = "x".repeat(1000000)
  check processInput(largeInput).len > 0

test "handles special characters":
  check processInput("!@#$%^&*()") == expectedResult
```

## Debugging Tests

### Use Temporary File Inspection

```nim
test "debug failing test":
  var ctx = createTestContext()
  try:
    let tempDir = createTempTestDir(ctx, "debug")
    let tempFile = createTestFile(ctx, tempDir, "debug.txt", "content")

    # Inspect file during debugging
    echo "Temp file: ", tempFile
    echo "Content: ", readFile(tempFile)

    # Your test assertions
    discard assertFileContains(tempFile, "content")

  finally:
    # Comment out cleanup during debugging
    # ctx.cleanup()
    ctx.cleanup()
```

### Add Debug Output

```nim
test "complex logic":
  let input = "test data"
  let result = complexFunction(input)

  # Debug output
  echo "Input: ", input
  echo "Result: ", result

  check result.isValid
```

## Migration Best Practices

### Gradual Migration

```nim
# Phase 1: Add nimtest alongside existing tests
import nimtest/api
import unittest

# Phase 2: Migrate one test suite at a time
suite "Migrated Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "migrated test":
    # Use nimtest utilities
    let tempFile = createTestFile(ctx, createTempTestDir(ctx, "test"), "test.txt", "content")
    discard assertFileContains(tempFile, "content")

# Phase 3: Remove old test framework
```

### Maintain Backward Compatibility

```nim
# Keep old APIs working during migration
when not defined(nimtest_only):
  # Old test code
  import unittest
else:
  # New nimtest code
  import nimtest/api
```

## Performance Optimization

### Minimize Test Setup

```nim
# Good - shared setup
suite "Optimized Tests":
  var ctx: TestContext
  var testDir: string

  setup:
    ctx = createTestContext()
    testDir = createTempTestDir(ctx, "shared")

  teardown:
    ctx.cleanup()

  test "test 1":
    let file1 = createTestFile(ctx, testDir, "file1.txt", "content1")
    # Test file1

  test "test 2":
    let file2 = createTestFile(ctx, testDir, "file2.txt", "content2")
    # Test file2
```

### Use Fast Assertions

```nim
# Use fast versions when appropriate
discard assertFileContainsFast(largeFile, "search_term")
```

### Profile Test Performance

```nim
test "test performance profiling":
  let testTime = measureTime("entire test suite"):
    proc() =
      # Run all tests
      runAllTests()

  echo &"Test suite took {testTime:.3f} seconds"
  check testTime < 30.0  # Should complete within 30 seconds
```

### Use Descriptive Test Names

Write test names that clearly describe what is being tested:

```nim
# Good
test "init command creates required files and directories":

test "registry returns component when searched by exact name":

test "exporter generates valid JSON output":

# Avoid
test "test 1":

test "function works":

test "check export":
```

### Organize Test Suites Logically

Group related functionality in test suites:

```nim
suite "Configuration Management Tests":
  # All config-related tests

suite "User Authentication Tests":
  # All auth-related tests

suite "File Processing Tests":
  # All file processing tests
```

## Resource Management

### Always Use TestContext

Use TestContext for all temporary resources to ensure proper cleanup:

```nim
suite "File Operations Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()
```

### Create Temporary Resources Safely

Use framework utilities to create temporary files and directories:

```nim
# Good
let tempDir = ctx.createTempTestDir("mytest")
let tempFile = createTestFile(ctx, tempDir, "test.txt", "content")

# Avoid
let tempDir = getTempDir() / "mytest"
createDir(tempDir)
# (Missing cleanup tracking)
```

### Clean Up Properly

Always ensure resources are cleaned up even if tests fail:

```nim
suite "Resource Management Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()  # This runs even if tests fail
```

## Test Design Patterns

### Arrange-Act-Assert Pattern

Structure tests with clear phases:

```nim
test "calculator adds numbers correctly":
  # Arrange
  let calc = newCalculator()
  
  # Act
  let result = calc.add(2, 3)
  
  # Assert
  check result == 5
```

### Given-When-Then Pattern

For more complex scenarios:

```nim
test "user cannot login with invalid credentials":
  # Given
  let authService = newAuthService()
  let invalidUser = User(email: "nonexistent@example.com", password: "wrong")
  
  # When
  let loginResult = authService.login(invalidUser)
  
  # Then
  check loginResult.success == false
  check loginResult.error == "Invalid credentials"
```

### Parameterized Testing

For multiple similar test cases:

```nim
suite "Input Validation Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "validates different input types":
    let testCases = [
      ("valid@email.com", true),
      ("invalid-email", false),
      ("another@valid.com", true),
      ("", false)
    ]
    
    for (input, expected) in testCases:
      let result = validateEmail(input)
      check result == expected
```

## Assertion Best Practices

### Use Specific Assertions

Use the most specific assertion for your needs:

```nim
# Good - specific file assertions
assertFileExists("config.json")
assertFileContains("log.txt", "SUCCESS")

# Avoid - generic assertion
check fileExists("config.json")
```

### Provide Meaningful Messages

Add custom messages to clarify assertion purposes:

```nim
# Good
assertFileExists("config.json", "Configuration file must exist after initialization")
assertDirExists(testDir / "logs", "Logs directory must be created by logger")

# Avoid
assertFileExists("config.json")
```

### Test Expected Failures

Test that errors occur when they should:

```nim
test "function raises error for invalid input":
  assertThrows(proc() = 
    processFile("invalid_path.txt")
  )
```

### Verify Both Success and Failure Cases

Test both positive and negative scenarios:

```nim
test "validator accepts valid input":
  check validateInput("valid_data") == true

test "validator rejects invalid input":
  check validateInput("invalid_data") == false
```

## Performance Testing

### Measure Critical Operations

Focus performance tests on critical user paths:

```nim
test "search returns results within performance threshold":
  measureTime("search operation"):
    let results = searchComponents("button")
  # Verify time is within acceptable limits
```

### Use Benchmarking for Performance Tracking

Track performance over time with benchmarks:

```nim
test "string operations performance":
  benchmark("string concatenation", 10000):
    var s = ""
    for i in 0..100:
      s &= "test"
```

### Set Performance Targets

Document and test against performance requirements:

```nim
test "registry initialization performance":
  let startTime = cpuTime()
  let registry = newRegistry()
  let duration = cpuTime() - startTime
  
  check duration < 0.1  # Must initialize in under 100ms
```

### Test Under Load

Test performance with realistic data volumes:

```nim
test "large dataset processing":
  let largeDataset = createLargeTestDataset(10000)  # 10k items
  measureTime("process large dataset"):
    processDataset(largeDataset)
```

## Error Handling

### Test Error Conditions

Ensure your code handles errors gracefully:

```nim
test "handles file not found gracefully":
  let result = processFile("nonexistent.txt")
  check result.isError == true
  check result.errorMessage.contains("not found")
```

### Verify Error Messages

Test that error messages are helpful and consistent:

```nim
test "validation error messages are descriptive":
  let result = validateEmail("invalid")
  check result.errorMessage == "Email format is invalid"
```

### Test Recovery Scenarios

Test that your application can recover from errors:

```nim
test "recovers from temporary network failure":
  # Simulate network failure
  let result = unreliableOperation()
  # Verify retry logic works
  check result.success == true
```

## Reporting and Analytics

### Track Test Results Over Time

Use reporting utilities to monitor test health:

```nim
suite "Reporting Example":
  var report: TestSuiteReport

  setup:
    report = newTestSuiteReport("My Test Suite")

  teardown:
    finish(report)
    let filename = saveReport(report, rfJson, "test_report.json")
    echo "Report saved to: ", filename

  test "tracked test":
    let startTime = cpuTime()
    # Test logic here
    let duration = cpuTime() - startTime
    let result = newTestResult("tracked test", true, duration)
    addResult(report, result)
```

### Categorize Tests Appropriately

Use categories to organize and analyze test results:

```nim
let coreResult = newTestResult("core functionality", true, 0.005, "", "core")
let uiResult = newTestResult("UI component", true, 0.010, "", "ui")
```

### Monitor Test Metrics

Track important metrics like pass rate and execution time:

```nim
test "performance metrics":
  let report = getTestReport()
  let passRate = getPassRate(report)
  check passRate >= 95.0  # Maintain 95%+ pass rate
```

### Use Progress Bars for Long-Running Tests

Provide visual feedback during extended test execution:

```nim
suite "Long Running Test Suite":
  test "progress bar example":
    let bar = newProgressBar(pbsBlocks, width = 50, total = 100, message = "Running tests...")

    for i in 0..<100:
      # Simulate test work
      sleep(10)
      bar.updateProgress(i + 1, fmt"Completed {i + 1}/100 tests")
      bar.display()

    bar.finish("All tests completed!")
```

### Run Test Suites with Progress Visualization

For comprehensive test suites, use the built-in progress runner:

```nim
let testSuites = @[
  ("Unit Tests", runUnitTests),
  ("Integration Tests", runIntegrationTests),
  ("Performance Tests", runPerformanceTests)
]

let report = runTestsWithProgress(testSuites, pbsGlobe)
check report.totalTests > 0
```

## CI/CD Integration

### Make Tests Deterministic

Ensure tests produce consistent results in CI/CD:

```nim
# Avoid time-dependent tests
test "operation completes within time limit":
  let startTime = cpuTime()
  performOperation()
  let duration = cpuTime() - startTime
  check duration < 1.0  # 1 second limit
```

### Handle Environment Differences

Make tests work across different environments:

```nim
# Use relative paths and environment variables
let testDataDir = getEnv("TEST_DATA_DIR", "fixtures")
let testFile = testDataDir / "sample.json"
```

### Parallel Test Execution

Design tests to run in parallel safely:

```nim
# Each test uses its own context and temporary directories
suite "Parallel Safe Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()  # Each test gets unique temp directories

  teardown:
    ctx.cleanup()  # Cleanup is isolated per test
```

## Maintainability

### Keep Tests Readable

Write tests that are easy to understand and maintain:

```nim
# Good - clear and readable
test "user can update profile information":
  let user = createUser("test@example.com")
  let updatedProfile = Profile(
    firstName: "John",
    lastName: "Doe",
    email: "john@example.com"
  )
  
  let result = user.updateProfile(updatedProfile)
  
  check result.success == true
  check user.email == "john@example.com"

# Avoid - hard to understand
test "profile update":
  let u = createUser("t@e.c")
  let p = Profile(fN: "J", lN: "D", e: "j@e.c")
  let r = u.upd(p)
  check r.s == true
  check u.e == "j@e.c"
```

### Minimize Test Dependencies

Keep tests independent and focused:

```nim
# Good - independent test
test "email validator works":
  check validateEmail("test@example.com") == true
  check validateEmail("invalid") == false

# Avoid - depends on other functionality
test "user creation validates email":
  # This tests both user creation AND email validation
  let user = createUser("invalid_email")  # This might fail for other reasons
```

### Use Test Fixtures Appropriately

Create reusable test data structures:

```nim
# Define common test data
const
  VALID_USER = User(
    email: "valid@example.com",
    name: "Test User",
    active: true
  )
  
  INVALID_USER = User(
    email: "invalid",
    name: "",
    active: false
  )

test "valid user passes validation":
  check validateUser(VALID_USER) == true

test "invalid user fails validation":
  check validateUser(INVALID_USER) == false
```

## Code Quality

### Follow Consistent Naming

Use consistent naming conventions:

```nim
# Good
suite "User Authentication Tests":
  test "valid user can login":

# Consistent with your project's style
suite "UserAuthenticationTests":
  test "ValidUserCanLogin":
```

### Document Complex Tests

Add comments for complex test logic:

```nim
test "complex workflow with multiple steps":
  # Step 1: Create user account
  let user = createUser("test@example.com")
  
  # Step 2: Verify account activation
  activateUser(user.id)
  check user.isActive == true
  
  # Step 3: Perform authenticated action
  let result = performAction(user.token)
  check result.success == true
```

### Avoid Test Duplication

Use helper functions for common test patterns:

```nim
proc createTestUser(ctx: var TestContext, email: string): User =
  let user = createUser(email)
  # Track for cleanup if needed
  return user

test "user creation works":
  let user = createTestUser(ctx, "test@example.com")
  check user.email == "test@example.com"
```

### Test Only What You Own

Don't test third-party library behavior:

```nim
# Good - test your code's interaction
test "my code handles API response correctly":
  let mockResponse = """{"status": "success", "data": []}"""
  let result = processApiResponse(mockResponse)
  check result.success == true

# Avoid - testing JSON library
test "JSON parsing works":  # This tests the JSON library, not your code
  let json = parseJson("""{"key": "value"}""")
  check json["key"].str == "value"
```

## Performance Considerations

### Optimize Test Execution Time

Run fast tests first, slow tests last:

```nim
# Fast unit tests first
test "simple validation":

test "basic calculation":

# Integration/performance tests last
test "full workflow integration":

test "performance benchmark":
```

### Use Mocks Appropriately

Use mocks for external dependencies but test real integrations too:

```nim
# Test with real dependencies occasionally
test "real database connection":

# Use mocks for most tests to keep them fast
test "business logic with mocked database":
```

By following these best practices, you'll create robust, maintainable, and effective tests that provide confidence in your code while remaining efficient to run and maintain.