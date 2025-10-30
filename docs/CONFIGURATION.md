# Configuration and Setup Guide

Complete guide to configuring and setting up the nimtest framework for your project.

## Table of Contents

- [Project Setup](#project-setup)
- [Configuration File](#configuration-file)
- [Feature Configuration](#feature-configuration)
- [Directory Structure](#directory-structure)
- [CLI Integration](#cli-integration)
- [Testing Environment](#testing-environment)
- [Customization Options](#customization-options)
- [Platform-Specific Setup](#platform-specific-setup)

## Project Setup

### Initial Installation

To integrate nimtest into your project:

1. Copy the `src/nimtest` directory to your project's source directory
2. Ensure your project structure includes a `tests/` directory
3. Edit the configuration file to match your project
4. Create your first test file

### Basic Project Structure

```
your-project/
├── src/
│   └── yourproject.nim
├── nimble.nimble          # Install via: nimble install nimtest
├── tests/                 # Your test files
│   ├── unit/
│   ├── integration/
│   └── performance/
└── README.md
```

The nimtest framework is now installed via Nimble and automatically available. No need to copy source files.

### Setting Up Test Dependencies

Install nimtest via Nimble:

```bash
nimble install nimtest
# or add to your project's nimble file
```

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