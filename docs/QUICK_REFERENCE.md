# nimtest Framework - Quick Reference

## Common Commands

```bash
# After installing nimtest in your project
nim c -r your_test_file.nim    # Run a single test file
nimble test                    # Run all tests (if configured in nimble file)
```

## Framework Usage

### Basic Test Setup

```nim
import nimtest
import std/unittest

suite "Your Test Suite":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "your test description":
    # Test implementation
    check someCondition == true
```

### Resource Management

```nim
# Create test context for automatic cleanup
var ctx = createTestContext()
defer: ctx.cleanup()

# Create temporary directory
let testDir = ctx.createTempTestDir("mytest")
# Directory is automatically cleaned up after test
```

### File System Assertions

```nim
# Basic assertions
assertFileExists("path/to/file")
assertDirExists("path/to/directory")
assertFileContains("config.json", "expected_content")
assertOutputContains(output, "expected_text")

# Advanced assertions
assertFileNotExists("deleted_file.txt")
assertFileDoesNotContain("config.json", "unwanted_content")
assertFileHasSize("data.bin", 1024)
assertFileModifiedAfter("file.txt", startTime)
```

### CLI Testing

```nim
# Run CLI commands and capture output
let (output, exitCode) = runCliCommand("--version")
check exitCode == 0
assertOutputContains(output, "1.0.0")

# Run CLI command in specific directory
let (output, exitCode) = runCliCommandInDir(testDir, "init")
```

### Performance Testing

```nim
# Measure execution time
measureTime("operation name"):
  performOperation()

# Benchmark code with multiple iterations
benchmark("operation", 1000):
  performOperation()

# Test with timeout
let completed = runTestWithTimeout(proc() = 
  slowOperation()
, 5)  # 5 second timeout
```

### Progress Bars

```nim
# Create progress bar (5 styles available)
let bar = newProgressBar(pbsGlobe, width = 40, total = 100, message = "Processing...")

# Update progress
bar.updateProgress(50, "Halfway done...")
bar.display()

# Complete progress bar
bar.finish("All done!")

# Run tests with progress bar
let testSuites = @[("Unit Tests", runUnitTests), ("Integration", runIntegrationTests)]
let report = runTestsWithProgress(testSuites, pbsBlocks)
```

### Reporting

```nim
# Create test reports
var report = newTestSuiteReport("My Test Suite")
let result = newTestResult("test name", true, 0.005, "Passed", "category")
addResult(report, result)
finish(report)
generateConsoleReport(report)
```

## Key Types

- `TestContext` - Manages test resources and cleanup
- `TestResult` - Represents individual test results  
- `TestSuiteReport` - Collects and reports test suite results

## Key Procedures

- `createTestContext()` - Create a new test context
- `createTempTestDir()` - Create temporary directory for tests
- `assertFileExists()` - Assert that a file exists
- `runCliCommand()` - Execute CLI commands in tests
- `measureTime()` - Measure execution time of operations
- `newTestSuiteReport()` - Create test suite report
- `saveReport()` - Save report in various formats

## Configuration

Configure nimtest by editing `src/nimtest/test_config.nim` in your project:

```nim
const
  PROJECT_NAME* = "yourproject"          # Your project name
  PROJECT_DISPLAY_NAME* = "YourProject"  # Human-readable name
  CLI_BINARY_PATH* = "./bin/yourproject" # Path to your CLI binary
  HAS_CLI* = true                        # Enable CLI testing utilities
```

## Documentation

- [API.md](API.md) - Complete API reference
- [USER_GUIDE.md](USER_GUIDE.md) - Complete usage instructions
- [CONFIGURATION.md](CONFIGURATION.md) - Setup and configuration
- [EXAMPLES.md](EXAMPLES.md) - Common testing scenarios
- [BEST_PRACTICES.md](BEST_PRACTICES.md) - Recommended patterns
