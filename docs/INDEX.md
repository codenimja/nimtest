# nimtest Documentation

Comprehensive documentation for the nimtest testing framework.

## Overview

nimtest is a professional, lightweight test suite framework for Nim projects that provides utilities for various types of testing including unit tests, integration tests, and performance benchmarks. The framework emphasizes resource management, clean test isolation, and comprehensive reporting.

## Documentation Sections

### Getting Started
- [Quick Start Guide](QUICKSTART.md) - Get up and running in 5 minutes
- [Configuration Guide](CONFIGURATION.md) - Complete setup and configuration
- [User Guide](USER_GUIDE.md) - Complete usage instructions

### Core Documentation
- [API Reference](API.md) - Complete API documentation
- [Architecture](ARCHITECTURE.md) - Framework design and architecture
- [Best Practices](BEST_PRACTICES.md) - Recommended patterns and practices

### Examples and Guides
- [Examples and Patterns](EXAMPLES.md) - Common testing scenarios

### Community
- [Contribution Guidelines](CONTRIBUTING.md) - How to contribute to the project
- [CI/CD Guide](CI_CD_GUIDE.md) - Integration with CI/CD systems

## Framework Features

### Resource Management
- Automatic cleanup of temporary files and directories
- Test context management with proper setup/teardown
- Cross-platform path handling

### Testing Utilities
- Comprehensive file system assertions
- Performance measurement and benchmarking
- Visual progress bars for long-running operations

### Reporting
- Multiple output formats (console, JSON, JUnit, Markdown)
- Detailed analytics and metrics
- Customizable reporting categories

### Compatibility
- Works on Linux, macOS, and Windows
- Integrates with Nim's standard unittest framework
- CI/CD friendly with standardized output formats
- Nimble-installable for easy project integration

## Quick API Reference

### Core Types
- `TestContext` - Manages test resources and cleanup
- `TestResult` - Represents individual test results
- `TestSuiteReport` - Collects and reports test suite results

### Key Procedures
- `createTestContext()` - Create a new test context
- `createTempTestDir()` - Create temporary directory for tests
- `assertFileExists()` - Assert that a file exists
- `measureTime()` - Measure execution time of operations
- `newTestSuiteReport()` - Create test suite report
- `saveReport()` - Save report in various formats

For complete API documentation, see the [API Reference](API.md).

## Support

For support and questions:
- Check the [User Guide](USER_GUIDE.md) for usage instructions
- Review the [Examples](EXAMPLES.md) for common patterns
- Consult the [API Reference](API.md) for detailed procedure documentation
- See [Contribution Guidelines](CONTRIBUTING.md) if you'd like to contribute

## License

The nimtest framework is released under the MIT license. See the LICENSE file for details.