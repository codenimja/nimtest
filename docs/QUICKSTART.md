# Quick Start Guide - Getting Started with nimtest!

Get your Nim project testing with nimtest in 5 minutes.

---

## Step 1: Install nimtest (1 minute)

Install via Nimble:

```bash
nimble install nimtest
```

Your project structure should look like this:
```
your-project/
├── src/
│   └── yourproject.nim
├── tests/                # Your test files
├── nimble.nimble
└── README.md
```

The framework is now installed and available via Nimble.

---

## Step 2: Basic Usage (2 minutes)

There's no configuration needed to get started! Just import the API:

```nim
import nimtest/api
import std/unittest

suite "Basic Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic example":
    # Use nimtest utilities in your tests
    let testDir = createTempTestDir(ctx, "basic_test")
    let testFile = createTestFile(ctx, testDir, "sample.txt", "Hello, nimtest!")

    # Verify with assertions
    discard assertFileExists(testFile)
    discard assertFileContains(testFile, "Hello, nimtest!")

    # Test passes if no assertion fails
    check true == true
```

Run your test with: `nim c -r tests/test_basic.nim`

---

## Done!

You now have:
- nimtest installed via Nimble
- A basic test running successfully
- Ready to write more tests using nimtest utilities

---

## Common First-Time Usage

### For File System Testing

```nim
test "configuration file is created":
  var ctx = createTestContext()
  try:
    let testDir = createTempTestDir(ctx, "config_test")
    # Run your project's init command or function
    
    # Verify expected files were created
    discard assertFileExists(testDir / "config.json")
    discard assertDirExists(testDir / "src")
  finally:
    ctx.cleanup()
```

### For Performance Testing

```nim
test "operation completes quickly":
  let duration = measureTime("critical operation"):
    proc() = 
      performCriticalOperation()
  # Duration is automatically printed: [PERF] critical operation: X.XXX ms
```

### For Rich Reporting

```nim
test "generate comprehensive report":
  var report = newTestSuiteReport("My Test Suite")
  let result = newTestResult("my test", true, 0.005, "Test passed")
  addResult(report, result)
  finish(report)
  
  # Output in different formats
  generateConsoleReport(report)
  let jsonFile = saveReport(report, rfJson, "report.json")
  let junitFile = saveReport(report, rfJunit, "report.xml")
```

---

## Need More Help?

- **Full docs**: [USER_GUIDE.md](USER_GUIDE.md)
- **API Reference**: [API.md](API.md)
- **Configuration**: [CONFIGURATION.md](CONFIGURATION.md)
- **Examples**: [EXAMPLES.md](EXAMPLES.md)

Happy testing with nimtest!
