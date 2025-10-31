# Changelog

## [1.0.0] - 2025-10-31
### Added
- **TestContext**: Automatic resource management with `createTestContext()` and `ctx.cleanup()`
- **CLI Testing**: `runCliCommand()`, `assertExitCode()`, `assertOutputContains()` for testing command-line applications
- **File System Testing**: Comprehensive assertions (`assertFileExists`, `assertFileContains`, `assertFileHasSize`, etc.)
- **Performance Benchmarking**: `benchmark()` macro with statistical analysis and `measureTime()` utility
- **Progress Bars**: 5 lock-free animated styles (`pbsGlobe`, `pbsSpinner`, `pbsBar`, `pbsDots`, `pbsBlocks`)
- **Reporting**: Multiple output formats (Console, JSON, JUnit XML, Markdown) for CI/CD integration
- **Cross-Platform Support**: Works on Linux, macOS, and Windows
- **Zero Dependencies**: Pure Nim implementation
- **Public API**: Clean `import nimtest/api` interface
- **CI/CD Ready**: GitHub Actions integration with artifact uploads
- **Comprehensive Documentation**: Complete API reference, examples, and guides

### Changed
- Version bumped to 1.0.0 for production release

## [0.1.0] - 2025-10-30
### Added
- Initial PDD implementation
- Basic testing framework structure
- Core module architecture