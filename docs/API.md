# nimtest API Reference

Complete API documentation for the nimtest framework.

## Table of Contents

- [Getting Started](#getting-started)
- [TestContext](#testcontext)
- [File System Assertions](#file-system-assertions)
- [Performance Utilities](#performance-utilities)
- [Progress Bars](#progress-bars)
- [Advanced Testing Utilities](#advanced-testing-utilities)
- [Reporting Utilities](#reporting-utilities)
- [Configuration](#configuration)

## Getting Started

### Installation

Install via Nimble:
```bash
nimble install nimtest
```

### Basic Usage

Import the API module:
```nim
import nimtest/api

# All framework functionality is now available
var ctx = createTestContext()
# ... use the framework
```

## TestContext

The `TestContext` type manages test resources and ensures proper cleanup.

### Type Definition

```nim
type
  TestContext* = ref object
    tempDirs*: seq[string]
    tempFiles*: seq[string]
    startTime*: Time
    isCleanedUp*: bool
```

### Procedures

#### createTestContext

```nim
proc createTestContext*(): TestContext
```

Creates a new test context for managing test resources.

**Returns:** A new `TestContext` instance

**Example:**

```nim
import nimtest/api

var ctx = createTestContext()
```

#### cleanup

```nim
proc cleanup*(ctx: var TestContext)
```

Cleans up all temporary files and directories tracked by the context. Prevents double cleanup by tracking cleanup status.

**Parameters:**
- `ctx`: The test context to clean up

**Example:**

```nim
import nimtest/api

var ctx = createTestContext()
try:
  # ... test code ...
finally:
  ctx.cleanup()
```

#### tryCleanup

```nim
proc tryCleanup*(ctx: var TestContext): tuple[success: bool, errors: seq[string]]
```

Safely attempts to clean up all temporary files and directories tracked by the context, returning detailed status information.

**Parameters:**
- `ctx`: The test context to clean up

**Returns:** A tuple containing:
- `success`: true if all resources were cleaned up successfully, false otherwise
- `errors`: sequence of error messages for any cleanup failures

**Example:**

```nim
import nimtest/api

var ctx = createTestContext()
let (success, errors) = tryCleanup(ctx)
if not success:
  echo "Cleanup completed with errors: ", errors
```

#### createTempTestDir

```nim
proc createTempTestDir*(ctx: var TestContext, prefix: string = ""): string
```

Creates a temporary test directory and tracks it for cleanup.

**Parameters:**
- `ctx`: The test context
- `prefix`: Optional prefix for the directory name (defaults to configured project name)

**Returns:** Path to the created directory

**Example:**

```nim
import nimtest/api

var ctx = createTestContext()
let testDir = createTempTestDir(ctx, "mytest")
# Directory is automatically cleaned up when ctx.cleanup() is called
```

#### removeTempTestDir

```nim
proc removeTempTestDir*(path: string)
```

Removes a temporary test directory immediately.

**Parameters:**
- `path`: Path to the directory to remove

## CLI Utilities

The CLI testing utilities have been removed from nimtest to keep the framework lightweight and focused on core testing functionality. For CLI testing, consider using other Nim libraries such as `unittest` with `osproc` for executing external commands.

## File System Assertions

Assertion utilities for file and directory testing.

### assertFileExists

```nim
proc assertFileExists*(path: string, msg: string = "")
```

Asserts that a file exists at the given path.

**Parameters:**
- `path`: File path to check
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if file does not exist

**Example:**

```nim
assertFileExists("config.json")
assertFileExists("data.txt", "Configuration file must exist")
```

### assertDirExists

```nim
proc assertDirExists*(path: string, msg: string = "")
```

Asserts that a directory exists at the given path.

**Parameters:**
- `path`: Directory path to check
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if directory does not exist

**Example:**

```nim
assertDirExists("output/")
assertDirExists(testDir / "logs", "Logs directory must be created")
```

### assertFileContains

```nim
proc assertFileContains*(path: string, content: string, msg: string = "")
```

Asserts that a file contains specific content.

**Parameters:**
- `path`: File path to check
- `content`: Content that must be present in the file
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if file doesn't exist or doesn't contain the content

**Example:**

```nim
assertFileContains("log.txt", "SUCCESS")
assertFileContains("config.json", "\"version\"")
```

### assertFileContainsFast

```nim
proc assertFileContainsFast*(path: string, content: string, msg: string = "")
```

A performance-optimized version of `assertFileContains` that uses memory-efficient techniques for large files.

**Parameters:**
- `path`: File path to check
- `content`: Content that must be present in the file
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if file doesn't exist or doesn't contain the content

**Example:**

```nim
assertFileContainsFast("large_log.txt", "SUCCESS")  # Better for large files
```

### assertOutputContains

```nim
proc assertOutputContains*(output: string, expected: string, msg: string = "")
```

Asserts that command output contains expected text.

**Parameters:**
- `output`: Output string to check
- `expected`: Text that must be present
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if output doesn't contain expected text

**Example:**

```nim
# Example usage with command output stored in a variable
let output = "Usage: myapp [options]\nOptions:\n  --help    Show help\n  --version Show version"
assertOutputContains(output, "Usage:")
```

## Performance Utilities

Utilities for measuring and reporting performance.

### measureTime

```nim
proc measureTime*(label: string, body: proc())
```

Measures and reports the execution time of a code block.

**Parameters:**
- `label`: Description of the operation being measured
- `body`: Procedure to execute and measure

**Output:** Prints execution time to stdout in format: `[PERF] label: X.XXX ms`

**Example:**

```nim
measureTime("database query"):
  database.executeQuery("SELECT * FROM users")

# Output: [PERF] database query: 45.123 ms
```

### benchmark

```nim
proc benchmark*(label: string, iterations: int, body: proc())
```

Runs a procedure multiple times and reports average performance metrics including min, max, and average execution times.

**Parameters:**
- `label`: Description of the operation being benchmarked
- `iterations`: Number of times to execute the procedure
- `body`: Procedure to execute and measure

**Output:** Prints detailed performance metrics to stdout including total, average, min, and max times

**Example:**

```nim
benchmark("string concatenation", 1000):
  var s = ""
  for i in 0..10:
    s &= "test"
```

## Progress Bars

Visual progress indicators for test execution and long-running operations.

### Types

#### ProgressBarStyle

```nim
type
  ProgressBarStyle* = enum
    pbsMinimal,      # Simple bar with percentage
    pbsGlobe,        # Globe-like rotating progress
    pbsPulse,        # Pulsing bar with subtle animation
    pbsDots,         # Animated dots
    pbsBlocks        # Unicode block characters
```

Available progress bar styles for different visual preferences.

#### ProgressBar

```nim
type
  ProgressBar* = ref object
    style*: ProgressBarStyle
    width*: int
    current*: int
    total*: int
    startTime*: Time
    lastUpdate*: Time
    message*: string
    showPercentage*: bool
    showTime*: bool
```

Represents a progress bar with configurable style and display options.

### Procedures

#### newProgressBar

```nim
proc newProgressBar*(style: ProgressBarStyle = pbsMinimal, width: int = 40, total: int = 100, message: string = ""): ProgressBar
```

Creates a new progress bar with the specified style and configuration.

**Parameters:**
- `style`: Visual style of the progress bar (defaults to `pbsMinimal`)
- `width`: Width of the progress bar in characters (defaults to 40)
- `total`: Total number of steps/items to complete (defaults to 100)
- `message`: Optional message to display with the progress bar

**Returns:** New `ProgressBar` instance

**Example:**

```nim
let bar = newProgressBar(pbsGlobe, width = 30, total = 100, message = "Running tests...")
```

#### updateProgress

```nim
proc updateProgress*(bar: ProgressBar, current: int, message: string = "")
```

Updates the progress bar with a new current value and optional message.

**Parameters:**
- `bar`: The progress bar to update
- `current`: New current progress value
- `message`: Optional new message to display

**Example:**

```nim
bar.updateProgress(50, "Halfway done...")
```

#### render

```nim
proc render*(bar: ProgressBar): string
```

Renders the progress bar as a string for display.

**Parameters:**
- `bar`: The progress bar to render

**Returns:** String representation of the progress bar

**Example:**

```nim
let display = bar.render()
echo display
```

#### display

```nim
proc display*(bar: ProgressBar)
```

Displays the progress bar on the current line, clearing any previous output.

**Parameters:**
- `bar`: The progress bar to display

**Example:**

```nim
bar.display()
```

#### finish

```nim
proc finish*(bar: ProgressBar, message: string = "Complete!")
```

Completes the progress bar and displays a final message.

**Parameters:**
- `bar`: The progress bar to finish
- `message`: Final message to display (defaults to "Complete!")

**Example:**

```nim
bar.finish("All tests passed!")
```

#### runTestsWithProgress

```nim
proc runTestsWithProgress*(testSuites: seq[tuple[name: string, testProc: proc()]], style: ProgressBarStyle = pbsGlobe): TestSuiteReport
```

Runs multiple test suites with progress bar display and returns a comprehensive report.

**Parameters:**
- `testSuites`: Sequence of tuples containing test suite names and test procedures
- `style`: Progress bar style to use (defaults to `pbsGlobe`)

**Returns:** Complete `TestSuiteReport` with all test results

**Example:**

```nim
let testSuites = @[
  ("Unit Tests", unitTests),
  ("Integration Tests", integrationTests),
  ("Performance Tests", performanceTests)
]

let report = runTestsWithProgress(testSuites, pbsBlocks)
generateConsoleReport(report)
```

## Component Metadata

The component metadata utilities have been removed from nimtest to keep the framework lightweight and focused on core testing functionality. For component-based testing, consider using dedicated frameworks or implementing custom solutions that match your specific architecture.

## Advanced Testing Utilities

Additional utilities for more comprehensive testing scenarios.

### assertFileNotExists

```nim
proc assertFileNotExists*(path: string, msg: string = "")
```

Asserts that a file does NOT exist at the given path.

**Parameters:**
- `path`: File path to check
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if file exists

**Example:**

```nim
assertFileNotExists("deleted_file.txt")
```

### assertDirNotExists

```nim
proc assertDirNotExists*(path: string, msg: string = "")
```

Asserts that a directory does NOT exist at the given path.

**Parameters:**
- `path`: Directory path to check
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if directory exists

**Example:**

```nim
assertDirNotExists("removed_directory/")
```

### assertFileDoesNotContain

```nim
proc assertFileDoesNotContain*(path: string, content: string, msg: string = "")
```

Asserts that a file does NOT contain specific content.

**Parameters:**
- `path`: File path to check
- `content`: Content that must NOT be present in the file
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if file doesn't exist or contains the content

**Example:**

```nim
assertFileDoesNotContain("config.json", "debug_mode")
```

### assertOutputDoesNotContain

```nim
proc assertOutputDoesNotContain*(output: string, unexpected: string, msg: string = "")
```

Asserts that command output does NOT contain specific text.

**Parameters:**
- `output`: Output string to check
- `unexpected`: Text that must NOT be present
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if output contains the unexpected text

**Example:**

```nim
# Example usage with command output stored in a variable
let output = "Usage: myapp [options]\nOptions:\n  --help    Show help\n  --version Show version"
assertOutputDoesNotContain(output, "ERROR")
```

### assertFileHasSize

```nim
proc assertFileHasSize*(path: string, expectedSize: int, msg: string = "")
```

Asserts that a file has a specific size in bytes.

**Parameters:**
- `path`: File path to check
- `expectedSize`: Expected file size in bytes
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if file doesn't exist or has different size

**Example:**

```nim
assertFileHasSize("data.bin", 1024)  # 1KB file
```

### assertFileModifiedAfter

```nim
proc assertFileModifiedAfter*(path: string, time: Time, msg: string = "")
```

Asserts that a file was modified after a specific time.

**Parameters:**
- `path`: File path to check
- `time`: Time reference to compare against
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if file doesn't exist or was not modified after the specified time

**Example:**

```nim
let startTime = getTime()
writeFile("test.txt", "content")
assertFileModifiedAfter("test.txt", startTime)
```

### createTestFile

```nim
proc createTestFile*(ctx: var TestContext, dir: string, name: string, content: string = ""): string
```

Creates a test file with specified content and tracks it for cleanup.

**Parameters:**
- `ctx`: Test context
- `dir`: Directory to create file in
- `name`: File name
- `content`: Initial file content (defaults to empty string)

**Returns:** Path to created file

**Example:**

```nim
let testFile = createTestFile(ctx, testDir, "sample.txt", "Hello, World!")
```

### createTestDir

```nim
proc createTestDir*(ctx: var TestContext, parentDir: string, name: string): string
```

Creates a test directory and tracks it for cleanup.

**Parameters:**
- `ctx`: Test context
- `parentDir`: Parent directory
- `name`: Directory name

**Returns:** Path to created directory

**Example:**

```nim
let testSubDir = createTestDir(ctx, testDir, "subdir")
```

### runTestWithTimeout

```nim
proc runTestWithTimeout*(body: proc(), timeoutSeconds: int): bool
```

Runs a procedure with a timeout constraint.

**Parameters:**
- `body`: Procedure to execute
- `timeoutSeconds`: Maximum time in seconds to allow execution

**Returns:** True if the procedure completed within the timeout, false otherwise

**Example:**

```nim
let completed = runTestWithTimeout(proc() = 
  sleep(1000)  # Sleep for 1 second
, 5)  # 5 second timeout
```

### assertThrows

```nim
proc assertThrows*(procToRun: proc(), exceptionType: typedesc[ref Exception] = ref Exception, msg: string = "")
```

Asserts that a procedure throws an exception when executed.

**Parameters:**
- `procToRun`: Procedure to execute
- `exceptionType`: Expected exception type (defaults to any Exception)
- `msg`: Optional custom error message

**Raises:** `AssertionDefect` if no exception is thrown

**Example:**

```nim
assertThrows(proc() = raise newException(ValueError, "Test"))
```

## Reporting Utilities

Advanced reporting capabilities for comprehensive test analytics and reporting.

### Types

#### TestSuiteResult

```nim
type
  TestSuiteResult* = ref object
    name*: string
    passed*: bool
    duration*: float
    message*: string
    timestamp*: Time
    category*: string
    tags*: seq[string]
```

Represents the result of a single test execution with metadata and metrics.

#### TestSuiteReport

```nim
type
  TestSuiteReport* = ref object
    name*: string
    startTime*: Time
    endTime*: Time
    results*: seq[TestSuiteResult]
    config*: Table[string, string]
```

Represents a complete test suite report with results and configuration information.

#### ReportFormat

```nim
type
  ReportFormat* = enum
    rfConsole,    # Human-readable console output
    rfJson,       # JSON format
    rfJunit,      # JUnit XML format
    rfMarkdown    # Markdown format
```

Available output formats for test reports.

#### SortCriteria

```nim
type
  SortCriteria* = enum
    srName,       # Sort by test name
    srDuration,   # Sort by execution duration
    srStatus      # Sort by pass/fail status
```

Criteria for sorting test results in reports.

### Procedures

#### newTestResult

```nim
proc newTestResult*(name: string, passed: bool, duration: float, message: string = "", category: string = "general"): TestResult
```

Creates a new test result object with metadata and timing information.

**Parameters:**
- `name`: Name of the test
- `passed`: Whether the test passed or failed
- `duration`: Execution time in seconds
- `message`: Optional message or error details
- `category`: Test category (defaults to "general")

**Returns:** New `TestResult` instance

**Example:**

```nim
let result = newTestResult("my test", true, 0.005, "Test passed")
```

#### newTestSuiteReport

```nim
proc newTestSuiteReport*(name: string): TestSuiteReport
```

Creates a new test suite report object with initial configuration data.

**Parameters:**
- `name`: Name of the test suite

**Returns:** New `TestSuiteReport` instance

**Example:**

```nim
var report = newTestSuiteReport("My Test Suite")
```

#### addResult

```nim
proc addResult*(report: var TestSuiteReport, result: TestResult)
```

Adds a single test result to the test suite report.

**Parameters:**
- `report`: The test suite report to add to
- `result`: The test result to add

**Example:**

```nim
let result = newTestResult("my test", true, 0.005)
addResult(report, result)
```

#### addResults

```nim
proc addResults*(report: var TestSuiteReport, results: seq[TestResult])
```

Adds multiple test results to the test suite report at once.

**Parameters:**
- `report`: The test suite report to add to
- `results`: Sequence of test results to add

**Example:**

```nim
var results: seq[TestResult] = @[]
# ... populate results
addResults(report, results)
```

#### finish

```nim
proc finish*(report: var TestSuiteReport)
```

Marks the test suite report as finished by setting the end time.

**Parameters:**
- `report`: The test suite report to finish

**Example:**

```nim
finish(report)
```

#### getDuration

```nim
proc getDuration*(report: TestSuiteReport): float
```

Gets the total duration of the test suite execution in seconds.

**Parameters:**
- `report`: The test suite report to query

**Returns:** Total duration in seconds

**Example:**

```nim
let duration = getDuration(report)
```

#### getPassedCount

```nim
proc getPassedCount*(report: TestSuiteReport): int
```

Gets the number of passed tests in the test suite report.

**Parameters:**
- `report`: The test suite report to query

**Returns:** Number of passed tests

**Example:**

```nim
let passed = getPassedCount(report)
```

#### getFailedCount

```nim
proc getFailedCount*(report: TestSuiteReport): int
```

Gets the number of failed tests in the test suite report.

**Parameters:**
- `report`: The test suite report to query

**Returns:** Number of failed tests

**Example:**

```nim
let failed = getFailedCount(report)
```

#### getPassRate

```nim
proc getPassRate*(report: TestSuiteReport): float
```

Gets the pass rate percentage for the test suite report.

**Parameters:**
- `report`: The test suite report to query

**Returns:** Pass rate as a percentage (0.0-100.0)

**Example:**

```nim
let passRate = getPassRate(report)
```

#### generateConsoleReport

```nim
proc generateConsoleReport*(report: TestSuiteReport)
```

Generates and prints a human-readable console report with test results summary and details.

**Parameters:**
- `report`: The test suite report to generate

**Output:** Formatted console report with summary and test details

**Example:**

```nim
generateConsoleReport(report)
```

#### generateJsonReport

```nim
proc generateJsonReport*(report: TestSuiteReport): string
```

Generates a JSON-formatted test report string with complete test data and metadata.

**Parameters:**
- `report`: The test suite report to generate

**Returns:** JSON string representation of the report

**Example:**

```nim
let jsonReport = generateJsonReport(report)
```

#### generateJunitReport

```nim
proc generateJunitReport*(report: TestSuiteReport): string
```

Generates a JUnit XML-formatted test report string compatible with CI/CD systems and test runners.

**Parameters:**
- `report`: The test suite report to generate

**Returns:** JUnit XML string representation of the report

**Example:**

```nim
let junitReport = generateJunitReport(report)
```

#### generateMarkdownReport

```nim
proc generateMarkdownReport*(report: TestSuiteReport): string
```

Generates a Markdown-formatted test report string suitable for documentation and reports.

**Parameters:**
- `report`: The test suite report to generate

**Returns:** Markdown string representation of the report

**Example:**

```nim
let mdReport = generateMarkdownReport(report)
```

#### saveReport

```nim
proc saveReport*(report: TestSuiteReport, format: ReportFormat, filename: string = ""): string
```

Saves the test report in the specified format to a file and returns the filename used.

**Parameters:**
- `report`: The test suite report to save
- `format`: The format to save the report in
- `filename`: Optional filename (auto-generated if not provided)

**Returns:** Name of the saved file

**Example:**

```nim
let filename = saveReport(report, rfJson, "my_report.json")
```

#### trySaveReport

```nim
proc trySaveReport*(report: TestSuiteReport, format: ReportFormat, filename: string = ""): tuple[success: bool, filename: string, error: string]
```

Safely attempts to save the test report in the specified format to a file, returning detailed status information.

**Parameters:**
- `report`: The test suite report to save
- `format`: The format to save the report in
- `filename`: Optional filename

**Returns:** A tuple containing:
- `success`: true if the report was saved successfully, false otherwise
- `filename`: Name of the file that was saved (or attempted to save)
- `error`: Error message if save failed, empty string if successful

**Example:**

```nim
let (success, filename, error) = trySaveReport(report, rfJson, "my_report.json")
if success:
  echo "Report saved to: ", filename
else:
  echo "Report save failed: ", error
```

#### printSummary

```nim
proc printSummary*(report: TestSuiteReport)
```

Prints a simple summary of the test suite results to the console with key metrics.

**Parameters:**
- `report`: The test suite report to summarize

**Output:** Simple summary with pass/fail counts and pass rate

**Example:**

```nim
printSummary(report)
```

#### getStatistics

```nim
proc getStatistics*(report: TestSuiteReport): tuple[passed: int, failed: int, total: int, passRate: float, duration: float]
```

Gets comprehensive statistics for the test suite report.

**Parameters:**
- `report`: The test suite report to analyze

**Returns:** A tuple containing:
- `passed`: Number of passed tests
- `failed`: Number of failed tests
- `total`: Total number of tests
- `passRate`: Pass rate percentage
- `duration`: Total execution duration in seconds

**Example:**

```nim
let stats = getStatistics(report)
echo "Passed: ", stats.passed, " Failed: ", stats.failed
```

#### sortResults

```nim
proc sortResults*(report: var TestSuiteReport, sortBy: SortCriteria = srStatus)
```

Sorts test results within the report by the specified criteria.

**Parameters:**
- `report`: The test suite report to sort
- `sortBy`: Criteria to sort by (defaults to srStatus)

**Example:**

```nim
sortResults(report, srDuration)  # Sort by duration
```

#### getResultsByCategory

```nim
proc getResultsByCategory*(report: TestSuiteReport, category: string): seq[TestSuiteResult]
```

Filters and returns test results by category.

**Parameters:**
- `report`: The test suite report to filter
- `category`: Category to filter by

**Returns:** Sequence of test results matching the category

**Example:**

```nim
let unitTests = getResultsByCategory(report, "unit")
```

#### getFailedResults

```nim
proc getFailedResults*(report: TestSuiteReport): seq[TestSuiteResult]
```

Returns only the failed test results from the report.

**Parameters:**
- `report`: The test suite report to filter

**Returns:** Sequence of failed test results

**Example:**

```nim
let failedTests = getFailedResults(report)
if failedTests.len > 0:
  echo "Failed tests: ", failedTests.len
```

## Configuration

The framework provides optional configuration through the `config` module.

### Project Configuration

```nim
import nimtest/config

# Initialize with defaults
initConfig()

# Customize settings (optional)
ProjectName = "myproject"
TempDirPrefix = "myapp_"
```

### Configuration Options

Available configuration options:

```nim
# Configurable values
var
  ProjectName* {.threadvar.}: string     # Name of your project (default: "unknown")
  TempDirPrefix* {.threadvar.}: string   # Prefix for temporary directories (default: "nimtest_temp")

# Constants
const
  DefaultProjectName* = "unknown"
  DefaultTempDirPrefix* = "nimtest_temp"
```

### Thread Safety

Configuration variables use `.threadvar` for thread safety:
```nim
# Each thread gets its own configuration values
ProjectName = "myproject"  # Only affects current thread
```

### Time Format

```nim
const
  TimeFormat* = "yyyy-MM-dd HH:mm:ss"
```

Standard time format used for reporting timestamps.

## Error Handling

All assertion procedures raise `AssertionDefect` on failure, which integrates with Nim's unittest framework. Command execution procedures return error information via exit codes rather than raising exceptions. The reporting system captures test results including failures and provides comprehensive analytics about test execution outcomes.

## Thread Safety

The current implementation is not thread-safe. Each test should use its own `TestContext` instance. Do not share contexts between concurrent tests. Reporting objects should be created and used within individual test suites to avoid conflicts in multi-threaded environments (though not currently supported).

## Platform Support

All utilities support Linux, macOS, and Windows. Path handling uses Nim's cross-platform `os` module. Temporary directories use the system temp directory. The reporting system generates platform-independent output formats that work across all supported platforms.
