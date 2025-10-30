# Configuration and Setup Guide

Complete guide to configuring and setting up the nimtest framework for your project.

## Installation

nimtest is distributed as a Nimble package, making setup simple:

```bash
nimble install nimtest
```

That's it! No additional configuration required.

## Project Structure

nimtest works with your existing project structure:

```
your-project/
├── src/
│   └── yourproject.nim
├── tests/                 # Your test files
│   ├── test_basic.nim
│   ├── test_advanced.nim
│   └── test_performance.nim
├── nimble.nimble
└── README.md
```

## Basic Usage

### Import the Framework

```nim
import nimtest/api
import std/unittest

suite "My Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "basic functionality":
    let tempDir = createTempTestDir(ctx, "test")
    let tempFile = createTestFile(ctx, tempDir, "test.txt", "content")
    discard assertFileExists(tempFile)
```

### Running Tests

Run all tests with nimble:

```bash
nimble test
```

Run individual test files:

```bash
nim c -r tests/test_basic.nim
```

## Configuration Options

nimtest has minimal configuration - it works out of the box. However, you can customize some behavior:

### Temporary Directory Prefix

By default, nimtest uses `"nimtest_temp"` as the prefix for temporary directories. This can be customized if needed.

### Report Formats

nimtest supports multiple report formats:
- Console (human-readable)
- JSON (machine-readable)
- JUnit XML (CI/CD integration)
- Markdown (documentation)

### Progress Bar Styles

Choose from 5 different progress bar styles:
- `pbsMinimal` - Simple bar with percentage
- `pbsGlobe` - Globe-like rotating progress
- `pbsPulse` - Pulsing bar with animation
- `pbsDots` - Animated dots
- `pbsBlocks` - Unicode block characters

## CI/CD Integration

### GitHub Actions

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Nim
        uses: jiro4989/setup-nim-action@v1
      - run: nimble install -y
      - run: nimble test
```

### Jenkins/GitLab CI

```yaml
test:
  script:
    - nimble install -y
    - nimble test
  artifacts:
    reports:
      junit: test_results.xml
```

### Generating CI Reports

```nim
# In your test file
test "generate CI reports":
  var report = newTestSuiteReport("CI Tests")
  # ... add test results ...
  finish(report)

  # Generate JUnit XML for CI systems
  let junitFile = saveReport(report, rfJunit, "test_results.xml")
```

## Platform-Specific Setup

nimtest works on Linux, macOS, and Windows without platform-specific configuration.

### Linux/macOS

No additional setup required.

### Windows

nimtest handles path separators automatically. Ensure your Nim installation is properly configured.

## Advanced Configuration

### Custom Test Runners

Create custom test runners for specific needs:

```nim
# custom_runner.nim
import nimtest/api
import std/unittest

# Custom setup
proc setupTestEnvironment() =
  # Your custom setup code
  discard

# Custom teardown
proc teardownTestEnvironment() =
  # Your custom cleanup code
  discard

# Run tests with custom environment
setupTestEnvironment()
try:
  # Your test suites here
  suite "Custom Tests":
    test "example":
      check true
finally:
  teardownTestEnvironment()
```

### Integration with Build Systems

nimtest integrates seamlessly with Nim's build system:

```nim
# In your nimble.nimble
task test, "Run all tests":
  exec "nim c -r tests/test_basic.nim"
  exec "nim c -r tests/test_advanced.nim"
  exec "nim c -r tests/test_performance.nim"

task testWithCoverage, "Run tests with coverage":
  exec "nim c --coverage -r tests/test_basic.nim"
  # Process coverage data...
```

## Troubleshooting

### Common Issues

**Import errors:**
- Ensure nimtest is installed: `nimble install nimtest`
- Check that you're importing `nimtest/api`

**Test cleanup issues:**
- Always call `ctx.cleanup()` in teardown blocks
- Ensure all temporary resources are created through TestContext

**Performance test inconsistencies:**
- Use higher iteration counts for stable results
- Run benchmarks multiple times

**CI/CD report issues:**
- Verify file paths for report output
- Check that the CI environment has write permissions

## Migration from Other Frameworks

### From Nim's unittest

nimtest is designed to work alongside Nim's standard unittest:

```nim
# You can use both together
import nimtest/api
import unittest

suite "Mixed Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "standard unittest test":
    check(1 + 1 == 2)

  test "nimtest enhanced test":
    let tempFile = createTestFile(ctx, createTempTestDir(ctx, "test"), "test.txt", "content")
    discard assertFileContains(tempFile, "content")
```

### From Other Testing Frameworks

nimtest provides similar functionality to other testing frameworks but with Nim-specific optimizations:

- Resource management replaces manual cleanup
- File system assertions replace custom file checking code
- Built-in benchmarking replaces external profiling tools
- Multiple report formats support various CI/CD systems

## Best Practices

### Project Organization

- Keep tests in a dedicated `tests/` directory
- Group related tests in suites
- Use descriptive test names
- Separate unit, integration, and performance tests

### Resource Management

- Always use TestContext for temporary resources
- Create resources in setup, clean up in teardown
- Use descriptive prefixes for temporary directories

### Performance Testing

- Use `benchmark()` for operations that need measurement
- Set appropriate iteration counts (100-10000 typically)
- Compare results against known baselines

### CI/CD Integration

- Generate JUnit XML reports for CI systems
- Use JSON reports for programmatic analysis
- Archive test artifacts for debugging failed builds

Add nimtest to your project's nimble file:

```nim
# In your_project.nimble
requires "nimtest"

task test, "Run all tests":
  exec "nimble test:unit && nimble test:integration"

task test:unit, "Run unit tests":
  exec "nim c -r tests/unit/test_all.nim"

task test:integration, "Run integration tests":
  exec "nim c -r tests/integration/test_all.nim"
```

## Configuration

### Basic Usage

The recommended way to use nimtest is through the API module:

```nim
import nimtest/api  # All functionality available through this import

# Use framework utilities directly
var ctx = createTestContext()
# ... use the framework
```

### Project Configuration

Project-specific configuration is available through the config module:

```nim
import nimtest/api

# Optionally customize project settings
ProjectName = "myproject"  # Override default project name
TempDirPrefix = "myapp_test"  # Customize temp directory prefix
```

### Optional Configuration

For more advanced configuration, you can directly import the config module:

```nim
import nimtest/config

# Configure project settings
initConfig()  # Initialize with defaults
ProjectName = "myapp"
TempDirPrefix = "myapp_"
```

## Feature Configuration

### Standard Configuration

The framework provides sensible defaults out of the box. Most users don't need additional configuration:

```nim
import nimtest/api

# Use directly without configuration
var ctx = createTestContext()
let tempDir = createTempTestDir(ctx, "my_test")
let result = assertFileExists("test.txt")
```

### Advanced Configuration

For projects requiring specific configuration:

```nim
import nimtest/api, nimtest/config

# Configure settings before using framework
ProjectName = "myproject"
# Now use the framework with custom settings
var ctx = createTestContext()
```

## Directory Structure

### Recommended Test Organization

Organize your tests in a logical directory structure:

```
tests/
├── unit/                    # Unit tests for individual functions/modules
│   ├── core/
│   ├── utils/
│   └── models/
├── integration/            # Integration tests for multiple components
│   ├── api/
│   ├── database/
│   └── workflows/
├── performance/            # Performance and benchmark tests
│   ├── load/
│   └── stress/
├── cli/                    # CLI command tests (if applicable)
├── fixtures/               # Test data and fixture files
│   ├── sample.json
│   └── test_data/
├── helpers.nim            # Shared test utilities specific to your project
└── test_all.nim           # Main test runner
```

### Creating Test Directories

Use the framework utilities to create test directories safely:

```nim
# In your test files
suite "My Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "create test directory":
    let testDir = ctx.createTempTestDir("my_test")
    # Directory is automatically cleaned up
```

## CLI Integration

### Building Your CLI

If your project has a CLI, ensure it's built before running tests:

```bash
# Build your project
nimble build

# Or compile directly
nim c -d:release src/yourproject.nim
```

### Configuring CLI Path

Update the CLI_BINARY_PATH in test_config.nim:

```nim
const
  CLI_BINARY_PATH* = "./bin/yourproject"  # Linux/Mac
  # or
  CLI_BINARY_PATH* = ".\\bin\\yourproject.exe"  # Windows
```

### Testing CLI Commands

Use the framework's CLI testing utilities:

```nim
import nimtest/api

suite "File System Tests":
  test "configuration file validation":
    var ctx = createTestContext()
    try:
      let testDir = createTempTestDir(ctx, "config_test")
      let configFile = createTestFile(ctx, testDir, "config.json", """{"version": "1.0.0"}""")
      
      discard assertFileExists(configFile)
      discard assertFileContains(configFile, "version")
      discard assertFileContains(configFile, "1.0.0")
    finally:
      ctx.cleanup()
```

## Testing Environment

### Environment Variables

Set environment variables for different test environments:

```bash
# Set test-specific environment variables
export MYAPP_ENV=test
export MYAPP_DATABASE_URL=sqlite://test.db
export MYAPP_DEBUG=true
```

### Test Data Setup

Create test fixtures in the `fixtures/` directory:

```
tests/fixtures/
├── sample_config.json
├── test_users.json
├── mock_responses/
│   ├── api_response.json
│   └── error_response.json
└── database/
    ├── initial_state.sql
    └── test_data.sql
```

### Database Configuration

For projects using databases in tests:

```nim
# Create test database configuration
const
  TEST_DB_URL* = "sqlite://test.db"     # For SQLite
  # or
  TEST_DB_URL* = "postgres://localhost/test_db"  # For PostgreSQL
```

## Customization Options

### Custom Assertion Messages

Provide meaningful error messages in your tests:

```nim
test "configuration loads correctly":
  let config = loadConfig("test_config.json")
  check config.isValid == true, "Configuration should be valid"
  assertFileExists(config.filePath, "Config file must exist at specified path")
```

### Custom Test Categories

Add custom categories for your test reporting:

```nim
# In your test files
let securityResult = newTestResult("security test", true, 0.005, "", "security")
let performanceResult = newTestResult("performance test", true, 0.010, "", "performance")
```

### Custom Helper Functions

Create project-specific test helpers:

```nim
# In tests/helpers.nim
import nimtest

proc createTestUser*(ctx: var TestContext, email: string): User =
  # Create a test user with default values
  result = User(
    id: generateId(),
    email: email,
    name: "Test User",
    createdAt: getTime()
  )
  # Track for cleanup if needed

proc createTestDataFile*(ctx: var TestContext, dir: string, filename: string): string =
  let content = """{"test": true, "data": []}"""
  result = createTestFile(ctx, dir, filename, content)
```

## Platform-Specific Setup

### Linux Setup

On Linux systems, ensure proper permissions and paths:

```bash
# Make sure your binary is executable
chmod +x ./bin/yourproject

# Set proper paths in test_config.nim
const CLI_BINARY_PATH* = "./bin/yourproject"
```

### Windows Setup

On Windows, adjust paths accordingly:

```nim
const
  CLI_BINARY_PATH* = ".\\bin\\yourproject.exe"
  # Use forward slashes for internal operations
  SRC_DIR* = "src"
```

### macOS Setup

macOS follows Unix conventions but check for specific requirements:

```bash
# Ensure codesigning if required
codesign --force --deep --sign - ./bin/yourproject
```

## Verification Steps

### Testing the Setup

After configuration, verify everything works:

1. Run a simple test:

```bash
nim c -r tests/test_all.nim
```

2. Verify basic functionality works:

```nim
test "sanity check":
  var ctx = createTestContext()
  try:
    let testDir = createTempTestDir(ctx, "sanity_test")
    let testFile = createTestFile(ctx, testDir, "test.txt", "hello")
    
    discard assertFileExists(testFile)
    discard assertFileContains(testFile, "hello")
    
    echo "Setup verified: Test context and file operations working"
  finally:
    ctx.cleanup()
```

### Common Setup Issues

**Issue**: "Command not found" errors
**Solution**: Verify CLI_BINARY_PATH is correct and binary exists

**Issue**: "Permission denied" errors
**Solution**: Check file permissions on your CLI binary

**Issue**: Tests can't find configuration files
**Solution**: Ensure relative paths are correct and files exist

**Issue**: Temporary directories not being cleaned up
**Solution**: Verify TestContext is properly created and cleanup() is called

## Updating Configuration

### Version Updates

When updating the test framework, check for new configuration options:

```nim
# New options might be added in future versions
const
  NEW_FEATURE_ENABLED* = true    # Check for new features
  BACKWARD_COMPATIBLE* = true    # Maintain compatibility
```

### Migration Steps

When migrating between versions:

1. Backup your current `test_config.nim`
2. Update the framework files
3. Compare and merge configuration changes
4. Update any deprecated settings
5. Run tests to verify everything works

By following this configuration guide, you'll have a properly set up testing environment that's customized for your specific project needs.