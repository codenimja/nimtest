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

    # Assertions return bool and throw exceptions on failure
    discard assertFileExists(testFile)
    discard assertFileContains(testFile, "Hello, nimtest!")
```

That's it! Your test will automatically clean up temporary files and directories.

---

## Step 3: Advanced Features (2 minutes)

### Performance Testing

```nim
test "performance benchmark":
  let result = benchmark("string concatenation", 1000):
    proc() =
      var s = ""
      for i in 0..100:
        s &= "test"
  check result.avg > 0
```

### Progress Bars

```nim
test "progress visualization":
  let bar = newProgressBar(pbsGlobe, total = 10, message = "Processing...")
  for i in 0..9:
    # Simulate work
    bar.update(i + 1)
  bar.finish("All done!")
```

### Test Reporting

```nim
test "generate reports":
  var report = newTestSuiteReport("My Test Suite")
  addResult(report, newTestResult("sample test", true, 0.001, "passed"))
  finish(report)

  # Generate different output formats
  generateConsoleReport(report)
  let junitFile = saveReport(report, rfJunit, "test_results.xml")
  let jsonFile = saveReport(report, rfJson, "test_results.json")
```

---

## Step 4: Run Your Tests (30 seconds)

Run your tests with nimble:

```bash
nimble test
```

Or run individual test files:

```bash
nim c -r tests/your_test.nim
```

---

## Next Steps

- Read the [User Guide](USER_GUIDE.md) for comprehensive usage instructions
- Check out [Examples](EXAMPLES.md) for common testing patterns
- Review [Best Practices](BEST_PRACTICES.md) for optimal test writing
- See the [API Reference](API.md) for complete function documentation

Happy testing with nimtest! 🚀
