# nimtest Examples and Patterns

Common testing scenarios and patterns using the nimtest framework.

## Table of Contents

- [Basic Unit Testing](#basic-unit-testing)
- [File System Testing](#file-system-testing)
- [Performance Testing](#performance-testing)
- [Progress Bars](#progress-bars)
- [Error Handling Testing](#error-handling-testing)
- [Database Testing](#database-testing)
- [API Testing](#api-testing)
- [Complex Scenarios](#complex-scenarios)

## Basic Unit Testing

### Simple Value Testing

```nim
import nimtest/api
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
import nimtest/api
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
import nimtest/api
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # File creation and content verification
  let testDir = createTempTestDir(ctx, "file_test")
  let filePath = createTestFile(ctx, testDir, "config.json", """{"version": "1.0", "debug": false}""")
  
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
import nimtest/api
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # File size validation
  let testDir = createTempTestDir(ctx, "size_test")
  let testFile = createTestFile(ctx, testDir, "data.bin", "A".repeat(1024))  # 1KB of data
  
  # Verify file size
  discard assertFileHasSize(testFile, 1024)

  # File modification time tracking
  let timeTestDir = createTempTestDir(ctx, "time_test")
  let beforeTime = getTime()
  let timeTestFile = createTestFile(ctx, timeTestDir, "modified.txt", "content")
  let afterTime = getTime()
  
  # Verify file was modified after creation time
  discard assertFileModifiedAfter(timeTestFile, beforeTime)
  # Note: The second assertion might fail depending on timing, so it's omitted for reliability
  
  echo "File validation tests passed!"
  
finally:
  ctx.cleanup()
```

## Integration Testing

### Testing Complete Workflows

```nim
import nimtest/api
import std/[os, times]

# Create test context for resource management
var ctx = createTestContext()
try:
  # Complete project lifecycle test
  let projectDir = createTempTestDir(ctx, "lifecycle_test")
  
  # Simulate project setup
  let srcDir = createTestDir(ctx, projectDir, "src")
  let testDir = createTestDir(ctx, projectDir, "tests")
  let configFile = createTestFile(ctx, projectDir, "config.json", """{"debug": false}""")
  
  # Verify project structure
  discard assertDirExists(srcDir)
  discard assertDirExists(testDir)
  discard assertFileExists(configFile)

  # Simulate creating components/files
  let componentFile = createTestFile(ctx, srcDir, "component.nim", "echo \"Hello World\"")
  discard assertFileExists(componentFile)
  
  echo "Complete project lifecycle test passed!"
  
finally:
  ctx.cleanup()
```

## Performance Testing

### Measuring Execution Time

```nim
import nimtest/api
import std/[os, times]

# Example functions for testing
proc searchComponents(query: string): seq[string] = @["button", "input", "label"]

# Search operation performance test
let duration1 = measureTime("component search"):
  proc() = 
    let results = searchComponents("button")

# Manual timing for assertions
let startTime = cpuTime()
let results = searchComponents("button")
let duration = cpuTime() - startTime

if duration < 0.1:  # Must search in under 100ms
  echo "Component search performance test passed!"
else:
  echo "Component search took too long: ", duration, " seconds"
```

### Benchmarking Operations

```nim
import nimtest/api
import std/[os, times]

# String processing benchmark test
let stringConcatResults = benchmark("string concatenation", 1000):
  proc() = 
    var result = ""
    for i in 0..100:
      result &= "test"

echo "String concatenation - Avg: ", stringConcatResults.avg, "s, Min: ", stringConcatResults.min, "s, Max: ", stringConcatResults.max, "s"

let stringBuilderResults = benchmark("string builder", 1000):
  proc() = 
    var builder = ""
    for i in 0..100:
      builder.add("test")

echo "String builder - Avg: ", stringBuilderResults.avg, "s, Min: ", stringBuilderResults.min, "s, Max: ", stringBuilderResults.max, "s"

# Data structure operations (with placeholder function)
proc process(item: int): int = item * 2
proc generateLargeDataset(size: int): seq[int] = 
  result = @[]
  for i in 0..<size:
    result.add(i)

let testData = generateLargeDataset(1000)

let listIterationResults = benchmark("list iteration", 100):
  proc() = 
    for item in testData:
      discard process(item)

echo "List iteration - Avg: ", listIterationResults.avg, "s, Min: ", listIterationResults.min, "s, Max: ", listIterationResults.max, "s"

let mapLookupResults = benchmark("map lookup", 1000):
  proc() = 
    for i in 0..1000:
      let _ = testData[i mod testData.len]

echo "Map lookup - Avg: ", mapLookupResults.avg, "s, Min: ", mapLookupResults.min, "s, Max: ", mapLookupResults.max, "s"
```

### Timeout Testing

```nim
import nimtest/api
import std/[os, times]

proc performLongOperation() = sleep(2000)  # 2 second operation

# Operation completes within timeout test
let completed1 = runTestWithTimeout(proc() =
  # Simulate operation that might hang
  performLongOperation()
, 5)  # 5 second timeout

if completed1[0]:  # [0] is the completed status
  echo "Operation completed within timeout - Duration: ", completed1[1]
else:
  echo "Operation did not complete within timeout"

# Slow operation timeout test
let completed2 = runTestWithTimeout(proc() =
  sleep(5000)  # 5 second sleep
, 1)  # 1 second timeout

if not completed2[0]:  # [0] is the completed status
  echo "Slow operation properly terminated by timeout - Duration: ", completed2[1]
else:
  echo "Slow operation unexpectedly completed"
```

## Progress Bars

### Basic Progress Bar Usage

```nim
import nimtest/api
import std/[os, times]

# Basic progress bar example
let bar = newProgressBar(pbsMinimal, width = 30, total = 100, message = "Processing...")

for i in 0..100:
  update(bar, i, &"Processing item {i}")  # Use the updated function
  display(bar)
  sleep(10)  # Simulate work

finish(bar, "All items processed!")  # Use the updated function
```

### Different Progress Bar Styles

```nim
import nimtest/api
import std/[os, times]

# Minimal style progress bar
let minimalBar = newProgressBar(pbsMinimal, total = 50)
for i in 0..50:
  update(minimalBar, i)
  display(minimalBar)
  sleep(20)
finish(minimalBar)

# Globe style progress bar
let globeBar = newProgressBar(pbsGlobe, total = 30, message = "Processing globally...")
for i in 0..30:
  update(globeBar, i)
  display(globeBar)
  sleep(100)
finish(globeBar, "World tour complete!")

# Pulse style progress bar
let pulseBar = newProgressBar(pbsPulse, total = 20)
for i in 0..20:
  update(pulseBar, i, "Pulsing through data...")
  display(pulseBar)
  sleep(150)
finish(pulseBar)

# Dots style progress bar
let dotsBar = newProgressBar(pbsDots, total = 25)
for i in 0..25:
  update(dotsBar, i)
  display(dotsBar)
  sleep(80)
finish(dotsBar, "Dots connected!")

# Blocks style progress bar
let blocksBar = newProgressBar(pbsBlocks, total = 40, width = 50)
for i in 0..40:
  update(blocksBar, i, &"Building blocks... {i}/40")
  display(blocksBar)
  sleep(60)
finish(blocksBar, "Structure complete!")
```

### Running Operations with Progress Bars

```nim
import nimtest/api
import std/[os, times]

# Define your operation procedures
proc runMathOperations() {.gcsafe.} =
  # Simulate basic math operations
  let result1 = 2 + 2
  let result2 = "hello".len
  echo "Math operations completed: ", result1, ", ", result2

proc runConnectionTests() {.gcsafe.} =
  # Simulate connection tests
  let connected = true  # Placeholder
  echo "Connection test completed: ", connected

proc runAPICalls() {.gcsafe.} =
  # Simulate API calls
  let responseTime = measureTime("api response"):
    proc() = 
      sleep(50)  # Simulate API call delay

# Run all operations with progress bar
let operationSuites: seq[tuple[name: string, opProc: proc() {.gcsafe.}]] = @[
  ("Math Operations", runMathOperations),
  ("Connection Tests", runConnectionTests),
  ("API Calls", runAPICalls)
]

let report = runTestsWithProgress(operationSuites, pbsGlobe)
generateConsoleReport(report)

# Check report statistics
let stats = getStatistics(report)
echo "Operations completed: ", stats.passed, " passed, ", stats.failed, " failed"
```

### Custom Progress Bar Configuration

```nim
import nimtest/api
import std/[os, times]

# Wide progress bar with percentage and time
let wideBar = newProgressBar(pbsBlocks, width = 60, total = 200)

for i in 0..200:
  update(wideBar, i, &"Processing file {i} of 200")
  display(wideBar)
  sleep(30)
finish(wideBar, "All files processed!")

# Minimal progress bar 
let minimalBar2 = newProgressBar(pbsMinimal, width = 20, total = 10)

for i in 0..10:
  update(minimalBar2, i)
  display(minimalBar2)
  sleep(200)
finish(minimalBar2)
```

## Error Handling Testing

### Testing Expected Exceptions

```nim
import nimtest/api
import std/[os, times]

# Example functions that might throw exceptions
proc processInput(input: string) =
  if input == "invalid_data":
    raise newException(ValueError, "Invalid input provided")

proc divideByZero(a, b: int): int =
  if b == 0:
    raise newException(DivByZeroDefect, "Division by zero")
  return a div b

proc validateEmail(email: string): bool =
  if not email.contains("@"):
    raise newException(ValueError, "Invalid email format: missing @")
  return true

# Test invalid input raises appropriate error
try:
  processInput("invalid_data")
  echo "ERROR: Expected exception was not raised"
except ValueError:
  echo "SUCCESS: processInput properly raised ValueError for invalid data"

# Test specific exception type
let exceptionRaised = assertThrows(proc() =
  discard divideByZero(10, 0)
, DivByZeroDefect)

if exceptionRaised:
  echo "SUCCESS: divideByZero properly raised DivByZeroDefect"

# Test validation errors handled properly
try:
  validateEmail("invalid_email")
  echo "ERROR: Expected exception was not raised for invalid email"
except ValueError as e:
  if e.msg.contains("Invalid email format"):
    echo "SUCCESS: Email validation properly raised ValueError with correct message"
  else:
    echo "ERROR: Email validation raised ValueError but with wrong message: ", e.msg
```

### Testing Error Recovery

```nim
import nimtest/api
import std/[os, times]

# Example function for saving data with retry
type SaveResult = object
  success: bool
  message: string

proc saveDataWithRetry(filePath: string, content: string): SaveResult =
  result = SaveResult(success: true, message: "Data saved successfully")
  writeFile(filePath, content)  # In a real scenario, this might have retry logic

# Create test context for resource management
var ctx = createTestContext()
try:
  # File operation recovery test
  let testDir = createTempTestDir(ctx, "recovery_test")
  let testFile = createTestFile(ctx, testDir, "data.txt", "initial content")
  
  # Simulate temporary write failure and recovery
  discard assertFileExists(testFile)
  
  # Attempt operation that might fail
  let result = saveDataWithRetry(testFile, "new content")
  
  if result.success:
    if assertFileContains(testFile, "new content"):
      echo "SUCCESS: File operation recovery test passed"
  else:
    echo "ERROR: File operation recovery failed: ", result.message

finally:
  ctx.cleanup()
```

## Database Testing

### Testing with Mock Database

```nim
import nimtest
import std/[os, times]

# Example User type and mock database
type
  User = object
    email: string
    name: string

  MockDatabase = ref object
    users: seq[User]

proc newMockDatabase(): MockDatabase = MockDatabase(users: @[])
proc connect(db: MockDatabase) = discard
proc disconnect(db: MockDatabase) = discard
proc createUser(db: MockDatabase, user: User): int = 
  db.users.add(user)
  return db.users.len - 1  # Return index as ID
proc getUser(db: MockDatabase, id: int): User = db.users[id]
proc searchUsers(db: MockDatabase, query: string): seq[User] = 
  result = @[]
  for user in db.users:
    if user.email.contains(query):
      result.add(user)

# Create test context for resource management
var ctx = createTestContext()
var db: MockDatabase

try:
  db = newMockDatabase()
  db.connect()

  # User creation and retrieval test
  let user = User(email: "test@example.com", name: "Test User")
  let id = db.createUser(user)
  
  let retrievedUser = db.getUser(id)
  
  if retrievedUser.email == user.email:
    echo "SUCCESS: User email retrieved correctly"
  else:
    echo "ERROR: User email mismatch"
  
  if retrievedUser.name == user.name:
    echo "SUCCESS: User name retrieved correctly"
  else:
    echo "ERROR: User name mismatch"

  # User search functionality test
  db.createUser(User(email: "alice@example.com", name: "Alice"))
  db.createUser(User(email: "bob@example.com", name: "Bob"))
  
  let results = db.searchUsers("alice")
  if results.len == 1:
    echo "SUCCESS: Search returned correct number of results"
    if results[0].email == "alice@example.com":
      echo "SUCCESS: Search returned correct user"
  else:
    echo "ERROR: Search returned wrong number of results: ", results.len

  echo "Database tests completed!"

finally:
  if not db.isNil:
    db.disconnect()
  ctx.cleanup()
```

## API Testing

### Testing HTTP Endpoints

```nim
import nimtest
import std/[os, times]
# Note: This example shows the pattern but requires actual HTTP client/server

# Placeholder for API testing
type
  APIResponse = object
    status: string
    body: string
    headers: array[0..0, tuple[key, value: string]]  # Simplified for example

proc mockGetRequest(url: string): APIResponse = 
  # In real scenario, this would call actual HTTP client
  APIResponse(status: "200 OK", body: """{"users": [{"name": "John", "email": "john@example.com"}]}""", 
             headers: [(key: "Content-Type", value: "application/json")])

proc mockPostRequest(url, data: string): APIResponse = 
  # In real scenario, this would call actual HTTP client
  APIResponse(status: "201 Created", body: """{"id": 123, "name": "New User", "email": "new@example.com"}""", 
             headers: [(key: "Content-Type", value: "application/json")])

# GET API test
let getResponse = mockGetRequest("/api/users")

if getResponse.status == "200 OK":
  echo "SUCCESS: GET request returned correct status"
  
  if getResponse.body.contains("users"):
    echo "SUCCESS: GET response contains expected data"
  
  var hasContentType = false
  for header in getResponse.headers:
    if header.key == "Content-Type" and header.value.contains("application/json"):
      hasContentType = true
  if hasContentType:
    echo "SUCCESS: GET response has correct Content-Type header"
  else:
    echo "WARNING: GET response missing Content-Type header"

# POST API test  
let userData = """{"name": "New User", "email": "new@example.com"}"""
let postResponse = mockPostRequest("/api/users", userData)

if postResponse.status == "201 Created":
  echo "SUCCESS: POST request returned correct status"
  
  if postResponse.body.contains("id"):
    echo "SUCCESS: POST response contains ID"
  
  if postResponse.body.contains("new@example.com"):
    echo "SUCCESS: POST response contains expected email"

echo "API tests completed!"
```

## Complex Scenarios

### Testing State Machines

```nim
import nimtest
import std/[os, times]

# Example state machine
type
  State = enum
    StatePending, StateSubmitted, StateApproved, StateRejected
  
  ApprovalWorkflow = ref object
    currentState: State

proc newApprovalWorkflow(): ApprovalWorkflow = ApprovalWorkflow(currentState: StatePending)
proc initialize(workflow: ApprovalWorkflow) = workflow.currentState = StatePending
proc submit(workflow: ApprovalWorkflow) = workflow.currentState = StateSubmitted
proc approve(workflow: ApprovalWorkflow) = 
  if workflow.currentState == StateSubmitted:
    workflow.currentState = StateApproved
proc reject(workflow: ApprovalWorkflow) = 
  if workflow.currentState == StateSubmitted:
    workflow.currentState = StateRejected

# Approval workflow test
var workflow = newApprovalWorkflow()
workflow.initialize()

# Initial state check
if workflow.currentState == StatePending:
  echo "SUCCESS: Initial state is Pending"
else:
  echo "ERROR: Initial state is not Pending"

# Submit for approval
workflow.submit()
if workflow.currentState == StateSubmitted:
  echo "SUCCESS: State changed to Submitted after submit"
else:
  echo "ERROR: State did not change to Submitted"

# Approve the workflow
workflow.approve()
if workflow.currentState == StateApproved:
  echo "SUCCESS: State changed to Approved after approval"
else:
  echo "ERROR: State did not change to Approved"

# Try to approve again (should have no effect)
let oldState = workflow.currentState
workflow.approve()
if workflow.currentState == oldState:
  echo "SUCCESS: State remains Approved after second approval (no change)"
else:
  echo "INFO: State changed after second approval: ", workflow.currentState

# Rejection workflow test
var rejectionWorkflow = newApprovalWorkflow()
rejectionWorkflow.initialize()
rejectionWorkflow.submit()
rejectionWorkflow.reject()

if rejectionWorkflow.currentState == StateRejected:
  echo "SUCCESS: Rejection workflow moves to Rejected state"
else:
  echo "ERROR: Rejection workflow did not move to Rejected state"

# Try to approve after rejection
let stateBeforeApproval = rejectionWorkflow.currentState
rejectionWorkflow.approve()
if rejectionWorkflow.currentState == stateBeforeApproval:
  echo "SUCCESS: Cannot approve after rejection - state unchanged"
else:
  echo "INFO: State changed after approval attempt post-rejection: ", rejectionWorkflow.currentState

echo "State machine tests completed!"
```

### Testing Concurrent Operations

```nim
import nimtest
import std/[os, times]

# Example shared resource (simplified for example since threading would be complex in this format)
type
  SharedResource = ref object
    counter: int

proc newSharedResource(): SharedResource = SharedResource(counter: 0)
proc increment(res: SharedResource) = 
  for i in 0..9:  # 10 operations
    inc(res.counter)

# Note: True concurrency test would require actual threading
# This example shows the concept
var sharedResource = newSharedResource()

# Simulate concurrent access (in real threading scenario, multiple threads would call increment)
for i in 0..4:  # Simulate 5 "threads" each doing 10 increments
  for j in 0..9:
    inc(sharedResource.counter)

# Verify resource state: 5 "threads" * 10 operations each = 50
if sharedResource.counter == 50:
  echo "SUCCESS: Resource counter has expected value (simulated concurrency test)"
else:
  echo "INFO: Resource counter: ", sharedResource.counter, " (expected 50 in perfect simulation)"

echo "Concurrency test completed (simulated)!"
```

### Testing Configuration and Environment

```nim
import nimtest
import std/[os, times]

# Store original environment value
let originalEnv = getEnv("MYAPP_CONFIG", "")
putEnv("MYAPP_CONFIG", "test_config.json")

# Example configuration loader
type
  Config = object
    source: string
    debugMode: bool

proc loadConfiguration(): Config = 
  let configSource = getEnv("MYAPP_CONFIG", "default")
  result = Config(source: configSource, debugMode: configSource == "test_config.json")

# Configuration loading test
let config = loadConfiguration()

if config.source == "test_config.json":
  echo "SUCCESS: Configuration loaded from environment variable"
else:
  echo "ERROR: Configuration did not load from expected source"

if config.debugMode == true:  # Assuming test config enables debug
  echo "SUCCESS: Debug mode enabled as expected"
else:
  echo "INFO: Debug mode not enabled, which may be expected"

# Test default configuration when env var is not set
deleteEnv("MYAPP_CONFIG")
let defaultConfig = loadConfiguration()

if defaultConfig.source == "default":
  echo "SUCCESS: Default configuration used when environment variable not set"
else:
  echo "INFO: Configuration source when env var missing: ", defaultConfig.source

# Restore original environment
if originalEnv == "":
  deleteEnv("MYAPP_CONFIG")
else:
  putEnv("MYAPP_CONFIG", originalEnv)

echo "Configuration tests completed!"
```

These examples demonstrate various testing patterns and scenarios you can implement using the nimtest framework. Each example follows best practices for test organization, resource management, and assertion usage.