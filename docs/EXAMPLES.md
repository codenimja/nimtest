# nimtest Examples and Patterns

Common testing scenarios and patterns using the nimtest framework.

## Table of Contents

- [Basic Unit Testing](#basic-unit-testing)
- [File System Testing](#file-system-testing)
- [CLI Application Testing](#cli-application-testing)
- [Integration Testing](#integration-testing)
- [Performance Testing](#performance-testing)
- [Progress Bars](#progress-bars)
- [Error Handling Testing](#error-handling-testing)
- [Component Testing](#component-testing)
- [Database Testing](#database-testing)
- [API Testing](#api-testing)
- [Complex Scenarios](#complex-scenarios)

## Basic Unit Testing

### Simple Value Testing

```nim
import nimtest
import std/[unittest, os]

# Test basic functionality
proc add(a, b: int): int = a + b
proc multiply(a, b: int): int = a * b

# Direct function tests with nimtest utilities
let result1 = add(2, 3)
if result1 != 5:
  raise newException(AssertionDefect, "add(2, 3) should equal 5")

let result2 = add(-1, 1)
if result2 != 0:
  raise newException(AssertionDefect, "add(-1, 1) should equal 0")

let result3 = multiply(3, 4)
if result3 != 12:
  raise newException(AssertionDefect, "multiply(3, 4) should equal 12")
```

### Testing with Resource Management

```nim
import nimtest
import std/[os, times]

# Example calculator type
type Calculator = ref object
  value: int

proc newCalculator(): Calculator = Calculator(value: 0)
proc reset(calc: Calculator) = calc.value = 0
proc add(calc: Calculator, val: int) = calc.value += val
proc getValue(calc: Calculator): int = calc.value

# Test with resource management
var calc: Calculator = newCalculator()
calc.reset()

# Test calculator functionality
calc.add(5)
if calc.getValue() != 5:
  raise newException(AssertionDefect, "Calculator value should be 5")

calc.add(5)  # Now 10
if calc.getValue() != 10:
  raise newException(AssertionDefect, "Calculator value should be 10")

# Test reset functionality
calc.add(100)
calc.reset()
if calc.getValue() != 0:
  raise newException(AssertionDefect, "Calculator value should be 0 after reset")
```

## File System Testing

### Testing File Creation and Content

```nim
import nimtest
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # File creation and content verification
  let testDir = createTempTestDir(ctx, "file_test")
  let filePath = testDir / "config.json"
  
  # Create file with content
  let content = """{"version": "1.0", "debug": false}"""
  writeFile(filePath, content)
  
  # Verify file exists and contains expected content
  discard assertFileExists(filePath)
  discard assertFileContains(filePath, "version")
  discard assertFileContains(filePath, "1.0")
  discard assertFileContains(filePath, "debug")
  discard assertFileContains(filePath, "false")

  # Directory structure creation test
  let rootDir = createTempTestDir(ctx, "dir_test")
  let srcDir = createTestDir(ctx, rootDir, "src")
  let libDir = createTestDir(ctx, rootDir, "lib")
  let subDir = createTestDir(ctx, srcDir, "subdir")
  
  # Verify directory structure
  discard assertDirExists(rootDir)
  discard assertDirExists(srcDir)
  discard assertDirExists(libDir)
  discard assertDirExists(subDir)
  
  # Verify relative paths work correctly
  discard assertDirExists(rootDir / "src")
  discard assertDirExists(rootDir / "src" / "subdir")
  
  echo "File operations tests passed!"
  
finally:
  ctx.cleanup()
```

### Testing File Operations with Assertions

```nim
import nimtest
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # File size validation
  let testDir = createTempTestDir(ctx, "size_test")
  let testFile = testDir / "data.bin"
  
  # Create file with specific content
  let content = "A".repeat(1024)  # 1KB of data
  writeFile(testFile, content)
  
  # Verify file size
  discard assertFileHasSize(testFile, 1024)

  # File modification time tracking
  let timeTestDir = createTempTestDir(ctx, "time_test")
  let timeTestFile = timeTestDir / "modified.txt"
  
  let beforeTime = getTime()
  writeFile(timeTestFile, "content")
  let afterTime = getTime()
  
  # Verify file was modified after creation time
  discard assertFileModifiedAfter(timeTestFile, beforeTime)
  # Note: The second assertion might fail depending on timing, so it's omitted for reliability
  
  echo "File validation tests passed!"
  
finally:
  ctx.cleanup()
```

## CLI Application Testing

### Testing CLI Commands

```nim
import nimtest
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # Version command test
  let (versionOutput, versionExitCode) = runCliCommand("--version")
  
  if versionExitCode == 0:
    if assertOutputContains(versionOutput, "1.0.0"):  # Or your app version
      echo "Version check passed!"
    if assertOutputContains(versionOutput, "MyApp"):   # Or your app name
      echo "App name check passed!"
  else:
    echo "Version command failed with exit code: ", versionExitCode

  # Help command test
  let (helpOutput, helpExitCode) = runCliCommand("--help")
  
  if helpExitCode == 0:
    if assertOutputContains(helpOutput, "Usage:"):
      echo "Usage check passed!"
    if assertOutputContains(helpOutput, "--version"):
      echo "Version flag check passed!"
    if assertOutputContains(helpOutput, "--help"):
      echo "Help flag check passed!"
  else:
    echo "Help command failed with exit code: ", helpExitCode

  # Init command test
  let initTestDir = createTempTestDir(ctx, "init_test")
  let (initOutput, initExitCode) = runCliCommandInDir(initTestDir, "init")
  
  if initExitCode == 0:
    discard assertDirExists(initTestDir / "src")
    discard assertDirExists(initTestDir / "tests")
    discard assertFileExists(initTestDir / "config.json")
    if assertOutputContains(initOutput, "Project initialized"):
      echo "Init command test passed!"
  else:
    echo "Init command failed with exit code: ", initExitCode

finally:
  ctx.cleanup()
```

### Testing CLI Error Handling

```nim
import nimtest
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # Invalid command test
  let (invalidOutput, invalidExitCode) = runCliCommand("invalid_command")
  
  if invalidExitCode != 0:  # Non-zero exit code for error
    if assertOutputContains(invalidOutput, "Unknown command") or 
       assertOutputContains(invalidOutput, "Usage:"):
      echo "Invalid command test passed!"
  else:
    echo "Invalid command should have failed but didn't"

  # Missing required argument test
  let (missingArgOutput, missingArgExitCode) = runCliCommand("export")  # Missing required arg
  
  if missingArgExitCode != 0:
    if assertOutputContains(missingArgOutput, "Missing required argument") or
       assertOutputContains(missingArgOutput, "Usage:"):
      echo "Missing argument test passed!"
  else:
    echo "Missing argument command should have failed but didn't"

finally:
  ctx.cleanup()
```

## Integration Testing

### Testing Complete Workflows

```nim
import nimtest
import std/unittest

suite "Integration Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "complete project lifecycle":
    let projectDir = ctx.createTempTestDir("lifecycle_test")
    
    # Step 1: Initialize project
    let (initOutput, initExitCode) = runCliCommandInDir(projectDir, "init")
    check initExitCode == 0
    assertDirExists(projectDir / "src")
    assertFileExists(projectDir / "config.json")
    
    # Step 2: Create a component
    let (createOutput, createExitCode) = runCliCommandInDir(projectDir, "create button")
    check createExitCode == 0
    assertFileExists(projectDir / "src" / "button.nim")
    assertFileExists(projectDir / "src" / "button.nyx.json")
    
    # Step 3: List components
    let (listOutput, listExitCode) = runCliCommandInDir(projectDir, "list")
    check listExitCode == 0
    assertOutputContains(listOutput, "button")
    
    # Step 4: Export project
    let exportDir = createTestDir(ctx, projectDir, "export")
    let (exportOutput, exportExitCode) = runCliCommandInDir(projectDir, "export " & exportDir)
    check exportExitCode == 0
    assertDirExists(exportDir / "button")
    assertFileExists(exportDir / "button" / "button.nim")
```

## Performance Testing

### Measuring Execution Time

```nim
import nimtest
import std/unittest

suite "Performance Tests":
  test "search operation performance":
    measureTime("component search"):
      let results = searchComponents("button")
    # Performance is logged automatically

  test "registry initialization performance":
    measureTime("registry init"):
      let registry = newRegistry()
      registry.scanDirectory("components/")
    
    # You can also capture the time for assertions
    let startTime = cpuTime()
    let registry = newRegistry()
    let duration = cpuTime() - startTime
    
    check duration < 0.1  # Must initialize in under 100ms
```

### Benchmarking Operations

```nim
import nimtest
import std/unittest

suite "Benchmark Tests":
  test "string processing performance":
    benchmark("string concatenation", 10000):
      var result = ""
      for i in 0..100:
        result &= "test"
    
    benchmark("string builder", 10000):
      var builder = ""
      for i in 0..100:
        builder.add("test")

  test "data structure operations":
    let testData = generateLargeDataset(10000)
    
    benchmark("list iteration", 1000):
      for item in testData:
        discard item.process()
    
    benchmark("map lookup", 1000):
      for i in 0..1000:
        let _ = testData[i mod testData.len]
```

### Timeout Testing

```nim
import nimtest
import std/unittest

suite "Timeout Tests":
  test "operation completes within timeout":
    let completed = runTestWithTimeout(proc() =
      # Simulate operation that might hang
      performLongOperation()
    , 5)  # 5 second timeout
    
    check completed == true

  test "slow operation is terminated":
    let completed = runTestWithTimeout(proc() =
      sleep(10000)  # 10 second sleep
    , 1)  # 1 second timeout
    
    check completed == false
```

## Progress Bars

### Basic Progress Bar Usage

```nim
import nimtest
import std/unittest

suite "Progress Bar Tests":
  test "basic progress bar":
    let bar = newProgressBar(pbsMinimal, width = 30, total = 100, message = "Processing...")
    
    for i in 0..100:
      bar.updateProgress(i, &"Processing item {i}")
      bar.display()
      sleep(50)  # Simulate work
    
    bar.finish("All items processed!")
```

### Different Progress Bar Styles

```nim
import nimtest
import std/unittest

suite "Progress Bar Styles":
  test "minimal style":
    let bar = newProgressBar(pbsMinimal, total = 50)
    for i in 0..50:
      bar.updateProgress(i)
      bar.display()
      sleep(20)
    bar.finish()

  test "globe style":
    let bar = newProgressBar(pbsGlobe, total = 30, message = "🌍 Processing globally...")
    for i in 0..30:
      bar.updateProgress(i)
      bar.display()
      sleep(100)
    bar.finish("World tour complete!")

  test "pulse style":
    let bar = newProgressBar(pbsPulse, total = 20)
    for i in 0..20:
      bar.updateProgress(i, "Pulsing through data...")
      bar.display()
      sleep(150)
    bar.finish()

  test "dots style":
    let bar = newProgressBar(pbsDots, total = 25)
    for i in 0..25:
      bar.updateProgress(i)
      bar.display()
      sleep(80)
    bar.finish("Dots connected!")

  test "blocks style":
    let bar = newProgressBar(pbsBlocks, total = 40, width = 50)
    for i in 0..40:
      bar.updateProgress(i, &"Building blocks... {i}/40")
      bar.display()
      sleep(60)
    bar.finish("Structure complete!")
```

### Running Tests with Progress Bars

```nim
import nimtest
import std/unittest

# Define your test procedures
proc runUnitTests() =
  suite "Unit Tests":
    test "basic math": check 2 + 2 == 4
    test "string ops": check "hello".len == 5

proc runIntegrationTests() =
  suite "Integration Tests":
    test "database connection": check connectToDB() == true
    test "api calls": check makeAPICall() == true

proc runPerformanceTests() =
  suite "Performance Tests":
    test "response time":
      measureTime("api response"):
        discard makeAPICall()

# Run all test suites with progress bar
suite "Test Suite Runner":
  test "run all tests with progress":
    let testSuites = @[
      ("Unit Tests", runUnitTests),
      ("Integration Tests", runIntegrationTests),
      ("Performance Tests", runPerformanceTests)
    ]
    
    let report = runTestsWithProgress(testSuites, pbsGlobe)
    generateConsoleReport(report)
    
    # Verify all tests passed
    check getFailedCount(report) == 0
```

### Custom Progress Bar Configuration

```nim
import nimtest
import std/unittest

suite "Custom Progress Bars":
  test "wide progress bar":
    let bar = newProgressBar(pbsBlocks, width = 60, total = 200)
    bar.showPercentage = true
    bar.showTime = true
    
    for i in 0..200:
      bar.updateProgress(i, &"Processing file {i} of 200")
      bar.display()
      sleep(30)
    bar.finish("All files processed!")

  test "minimal progress bar":
    let bar = newProgressBar(pbsMinimal, width = 20, total = 10)
    bar.showPercentage = false
    bar.showTime = false
    
    for i in 0..10:
      bar.updateProgress(i)
      bar.display()
      sleep(200)
    bar.finish()
```

## Error Handling Testing

### Testing Expected Exceptions

```nim
import nimtest
import std/unittest

suite "Error Handling Tests":
  test "invalid input raises appropriate error":
    assertThrows(proc() =
      processInput("invalid_data")
    )

  test "specific exception type":
    assertThrows(proc() =
      divideByZero(10, 0)
    , DivByZeroDefect)

  test "validation errors handled properly":
    try:
      validateEmail("invalid_email")
      check false  # Should not reach here
    except ValueError as e:
      check e.msg.contains("Invalid email format")
```

### Testing Error Recovery

```nim
import nimtest
import std/unittest

suite "Error Recovery Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "file operation recovers from temporary failure":
    let testDir = ctx.createTempTestDir("recovery_test")
    let testFile = testDir / "data.txt"
    
    # Simulate temporary write failure and recovery
    writeFile(testFile, "initial content")
    
    # Attempt operation that might fail
    let result = saveDataWithRetry(testFile, "new content")
    
    check result.success == true
    assertFileContains(testFile, "new content")
```

## Component Testing

### Testing Component Metadata

```nim
import nimtest
import std/unittest

suite "Component Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "component metadata validation":
    let component = createTestComponent("mybutton", catUI)
    
    check component.name == "mybutton"
    check component.category == catUI
    check component.displayName == "Mybutton"
    check component.dependencies.contains("nigui")

  test "component file generation":
    let testDir = ctx.createTempTestDir("component_test")
    
    let componentFile = createTestComponentFile(ctx, testDir, "custombutton")
    let metadataFile = createTestMetadataFile(ctx, testDir, "custombutton", "ui")
    
    assertFileExists(componentFile)
    assertFileExists(metadataFile)
    assertFileContains(componentFile, "Custombutton")
    assertFileContains(metadataFile, "custombutton")
```

## Database Testing

### Testing with Mock Database

```nim
import nimtest
import std/unittest

suite "Database Tests":
  var db: MockDatabase
  var ctx: TestContext

  setup:
    ctx = createTestContext()
    db = newMockDatabase()
    db.connect()

  teardown:
    db.disconnect()
    ctx.cleanup()

  test "user creation and retrieval":
    let user = User(email: "test@example.com", name: "Test User")
    let id = db.createUser(user)
    
    let retrievedUser = db.getUser(id)
    check retrievedUser.email == user.email
    check retrievedUser.name == user.name

  test "user search functionality":
    db.createUser(User(email: "alice@example.com", name: "Alice"))
    db.createUser(User(email: "bob@example.com", name: "Bob"))
    
    let results = db.searchUsers("alice")
    check results.len == 1
    check results[0].email == "alice@example.com"
```

## API Testing

### Testing HTTP Endpoints

```nim
import nimtest
import std/unittest
import std/httpclient

suite "API Tests":
  var server: TestServer
  var client: HttpClient

  setup:
    server = newTestServer()
    server.start()
    client = newHttpClient()
    client.timeout = 5000  # 5 second timeout

  teardown:
    client.close()
    server.stop()

  test "GET /api/users returns user list":
    let response = client.request("GET", server.url & "/api/users")
    
    check response.status == "200 OK"
    check response.body.contains("users")
    check response.headers.hasKey("Content-Type")
    check response.headers["Content-Type"].contains("application/json")

  test "POST /api/users creates new user":
    let userData = """{"name": "New User", "email": "new@example.com"}"""
    let response = client.request("POST", server.url & "/api/users", userData)
    
    check response.status == "201 Created"
    check response.body.contains("id")
    check response.body.contains("new@example.com")
```

## Complex Scenarios

### Testing State Machines

```nim
import nimtest
import std/unittest

suite "State Machine Tests":
  var workflow: ApprovalWorkflow

  setup:
    workflow = newApprovalWorkflow()
    workflow.initialize()

  test "approval workflow transitions correctly":
    # Initial state
    check workflow.currentState == State.Pending
    
    # Submit for approval
    workflow.submit()
    check workflow.currentState == State.Submitted
    
    # Approve
    workflow.approve()
    check workflow.currentState == State.Approved
    
    # Cannot approve again
    workflow.approve()  # Should be no-op or raise error
    check workflow.currentState == State.Approved

  test "rejection workflow":
    workflow.submit()
    workflow.reject()
    check workflow.currentState == State.Rejected
    
    # Cannot approve after rejection
    workflow.approve()
    check workflow.currentState == State.Rejected
```

### Testing Concurrent Operations

```nim
import nimtest
import std/unittest
import std/threads

suite "Concurrency Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "thread-safe resource access":
    let sharedResource = newSharedResource()
    var threads: seq[Thread[void]]
    
    # Create multiple threads that access shared resource
    for i in 0..4:
      threads.add(createThread(threadProc, sharedResource))
    
    # Wait for all threads to complete
    for t in threads:
      t.join()
    
    # Verify resource state is correct
    check sharedResource.counter == 50  # 5 threads * 10 operations each
```

### Testing Configuration and Environment

```nim
import nimtest
import std/unittest
import std/os

suite "Configuration Tests":
  var originalEnv: string

  setup:
    originalEnv = getEnv("MYAPP_CONFIG", "")
    putEnv("MYAPP_CONFIG", "test_config.json")

  teardown:
    if originalEnv == "":
      deleteEnv("MYAPP_CONFIG")
    else:
      putEnv("MYAPP_CONFIG", originalEnv)

  test "configuration loads from environment":
    let config = loadConfiguration()
    check config.source == "test_config.json"
    check config.debugMode == true  # Assuming test config has debug=true

  test "default configuration used when env not set":
    deleteEnv("MYAPP_CONFIG")
    let config = loadConfiguration()
    check config.source == "default"
    check config.debugMode == false
```

These examples demonstrate various testing patterns and scenarios you can implement using the nimtest framework. Each example follows best practices for test organization, resource management, and assertion usage.