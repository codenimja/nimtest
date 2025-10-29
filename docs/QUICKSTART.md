# Quick Start Guide - Getting Started with nimtest!

Get your Nim project testing with nimtest in 5 minutes.

---

## Step 1: Install nimtest (1 minute)

Copy the `src/nimtest` directory to your project's source directory. The structure should look like this:

```
your-project/
├── src/
│   ├── yourproject.nim
│   └── nimtest/          # nimtest framework
│       ├── helpers.nim
│       ├── reporting.nim
│       └── test_config.nim
├── tests/                # Your test files
└── nimble.nimble
```

---

## Step 2: Configure (2 minutes)

Edit **`src/nimtest/test_config.nim`** to match your project settings:


```nim
const PROJECT_NAME* = "yourproject"        # ← Your project name here
const PROJECT_DISPLAY_NAME* = "YourProject" # ← Display name here
const CLI_BINARY_PATH* = "./bin/yourproject" # ← Path to your binary (if applicable)
```

Other configuration options (customize as needed):

```nim
const
  # Features to enable/disable
  HAS_CLI* = true                      # Enable CLI testing utilities if your project has a CLI
  HAS_CORE_LIB* = false                # Enable core library testing if applicable
  HAS_COMPONENT_SYSTEM* = false        # Enable component system features if applicable

  # Directory paths (relative to project root)
  SRC_DIR* = "src"                     # Source code directory
  TEST_DIR* = "tests"                  # Test directory
  TEMP_DIR_PREFIX* = "test_"           # Prefix for temporary test directories
```

That's it for basic configuration!

---

## Step 3: Write Your First Test (2 minutes)

Create a test file in your `tests/` directory (e.g., `tests/test_basic.nim`):

```nim
import nimtest
import std/unittest

suite "Basic Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic example":
    # Use nimtest utilities in your tests
    let testDir = ctx.createTempTestDir("basic_test")
    let testFile = testDir / "sample.txt"
    writeFile(testFile, "Hello, nimtest!")

    # Verify with assertions
    assertFileExists(testFile)
    assertFileContains(testFile, "Hello, nimtest!")

    # Test passes if no assertion fails
    check true == true
```

Run your test with: `nim c -r tests/test_basic.nim`

---

## ✅ Done!

You now have:
- ✅ nimtest installed in your project
- ✅ Configured for your project
- ✅ A basic test running successfully
- ✅ Ready to write more tests using nimtest utilities

---

## Common First-Time Usage

### For CLI Testing

If your project has a CLI, you can test it like this:


```nim
test "CLI version command works":
  let (output, exitCode) = runCliCommand("--version")
  check exitCode == 0
  assertOutputContains(output, "1.0.0")  # Replace with your expected version
```

### For File System Testing

```nim
test "configuration file is created":
  let testDir = ctx.createTempTestDir("config_test")
  # Run your project's init command or function
  runCliCommandInDir(testDir, "init")
  
  # Verify expected files were created
  assertFileExists(testDir / "config.json")
  assertDirExists(testDir / "src")
```

### For Performance Testing

```nim
test "operation completes quickly":
  measureTime("critical operation"):
    performCriticalOperation()
```

---

## Need More Help?

- **Full docs**: [USER_GUIDE.md](USER_GUIDE.md)
- **API Reference**: [API.md](API.md)
- **Configuration**: [CONFIGURATION.md](CONFIGURATION.md)
- **Examples**: [EXAMPLES.md](EXAMPLES.md)

Happy testing with nimtest! 🚀
