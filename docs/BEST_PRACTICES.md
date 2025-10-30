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

### Group Related Tests

Organize tests by functionality, not by file structure:

```
tests/
├── cli/
│   ├── test_init.nim
│   ├── test_list.nim
│   └── test_export.nim
├── core/
│   ├── test_registry.nim
│   ├── test_metadata.nim
│   └── test_exporter.nim
├── integration/
│   └── test_workflow.nim
└── performance/
    ├── test_search.nim
    └── test_load.nim
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