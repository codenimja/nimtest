# nimtest v1.0 Documentation

> **The only Nim test framework that ships with lock-free progress bars, JUnit reports, and a soul.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Nim Version](https://img.shields.io/badge/Nim-2.0+-blue.svg?style=flat-square)](https://nim-lang.org/)
[![Build Status](https://img.shields.io/github/actions/workflow/status/codenimja/nimtest/ci.yml?branch=main&style=flat-square)](https://github.com/codenimja/nimtest/actions)
[![Nimble Package](https://img.shields.io/badge/nimble-package-blue.svg?style=flat-square)](https://github.com/nim-lang/packages)
[![nimble](https://img.shields.io/endpoint?url=https://nimble.directory/api/package-badge/nimtest)](https://nimble.directory/package/nimtest)
[![CI](https://github.com/codenimja/nimtest/actions/workflows/ci.yml/badge.svg)](https://github.com/codenimja/nimtest/actions)
[![nimpkgs](https://img.shields.io/endpoint?url=https://nimpkgs.ci/badge/nimtest)](https://nimpkgs.ci)
[![Docs](https://img.shields.io/badge/docs-latest-blue)](https://codenimja.github.io/nimtest/)

**Install**: `nimble install nimtest`

**Import**: `import nimtest/api`

**Zero runtime dependencies • Cross-platform: Linux, macOS, Windows • CI/CD Ready**

## Table of Contents

- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
  - [TestContext](#testcontext)
  - [File System Testing](#file-system-testing)
  - [CLI Testing](#cli-testing)
  - [Performance Benchmarking](#performance-benchmarking)
  - [Progress Bars](#progress-bars)
  - [Reporting](#reporting)
- [API Reference](#api-reference)
- [Examples](#examples)
- [CI/CD Integration](#cicd-integration)
- [Best Practices](#best-practices)
- [Roadmap](#roadmap)
- [FAQ](#faq)
- [Contributing](#contributing)
- [Support](#support)

## Quick Start

Get started with nimtest in under 5 minutes:

```bash
nimble install nimtest
```

```nim
import nimtest/api

# Create a test context for automatic cleanup
var ctx = createTestContext()
try:
  # Create temporary resources
  let tempDir = createTempTestDir(ctx, "demo")
  let testFile = createTestFile(ctx, tempDir, "hello.txt", "world")

  # Test file operations
  discard assertFileExists(testFile)
  discard assertFileContains(testFile, "world")

  echo "All tests passed!"
finally:
  # Automatic cleanup of all temp files/dirs
  ctx.cleanup()
```

Run with: `nim c -r your_test.nim`

## Core Concepts

### TestContext

TestContext manages temporary files and directories with automatic cleanup, preventing test isolation issues.

```nim
var ctx = createTestContext()
try:
  let tempDir = createTempTestDir(ctx, "my_test")
  let tempFile = createTestFile(ctx, tempDir, "data.txt", "content")
  # ... your tests
finally:
  ctx.cleanup()  # Deletes all registered temp resources
```

**Gotchas**: Always call `ctx.cleanup()` in a `finally` block. Temp resources are tracked automatically.

### File System Testing

Comprehensive assertions for file and directory operations.

```nim
discard assertFileExists("path/to/file")
discard assertFileNotExists("path/to/missing")
discard assertDirExists("path/to/dir")
discard assertFileContains("file.txt", "expected content")
discard assertFileHasSize("file.bin", 1024)
discard assertFileModifiedAfter("file.txt", getTime() - 1.hours)
```

**Gotchas**: All assertions throw `AssertionDefect` on failure. Use `discard` to ignore return values.

### CLI Testing

Test command-line applications and scripts.

```nim
let (output, exitCode) = runCliCommand("nim --version")
discard assertExitCode(exitCode, 0)
discard assertOutputContains(output, "Nim Compiler")
```

**Gotchas**: Commands run in current directory unless `cwd` specified. Timeout defaults to 5000ms.

### Performance Benchmarking

Measure execution time with statistical analysis.

```nim
let result = benchmark("string concat", 1000):
  proc() =
    var s = ""
    for i in 0..100:
      s &= "test"

echo &"Avg: {result.avg:.3f}ms, Min: {result.min:.3f}ms, Max: {result.max:.3f}ms"
```

**Gotchas**: Iterations must be positive. Results include statistical analysis.

### Progress Bars

Lock-free animated progress indicators for long-running tests.

```nim
let bar = newProgressBar(pbsGlobe, total = 100, message = "Running tests...")
for i in 0..100:
  # ... test logic
  bar.updateProgress(i, &"Completed {i}/100")
bar.finish("All tests completed!")
```

**Gotchas**: Styles: `pbsGlobe`, `pbsPulse`, `pbsDots`, `pbsBar`, `pbsSpinner`. Lock-free for concurrent use.

### Reporting

Generate test reports in multiple formats for CI/CD integration.

```nim
var report = newTestSuiteReport("My Test Suite")
let result = newTestResult("test name", true, 0.015, "passed")
addResult(report, result)

# Generate reports
generateConsoleReport(report)
let jsonPath = saveReport(report, rfJson, "report.json")
let junitPath = saveReport(report, rfJunit, "junit.xml")
```

**Gotchas**: Formats: `rfConsole`, `rfJson`, `rfJunit`, `rfMarkdown`. `saveReport` returns the file path.

## API Reference

### TestContext

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `createTestContext` | - | `TestContext` | Creates a new test context |
| `cleanup` | `ctx: var TestContext` | `void` | Cleans up all registered resources |
| `createTempTestDir` | `ctx: var TestContext, prefix: string = ""` | `string` | Creates temporary directory |
| `createTestFile` | `ctx: var TestContext, dir: string, name: string, content: string = ""` | `string` | Creates temporary file |

### File System Assertions

| Function | Parameters | Returns | Exceptions |
|----------|------------|---------|------------|
| `assertFileExists` | `path: string, msg: string = ""` | `bool` | `AssertionDefect` |
| `assertFileNotExists` | `path: string, msg: string = ""` | `bool` | `AssertionDefect` |
| `assertDirExists` | `path: string, msg: string = ""` | `bool` | `AssertionDefect` |
| `assertFileContains` | `path: string, content: string, msg: string = ""` | `bool` | `AssertionDefect` |
| `assertFileHasSize` | `path: string, expectedSize: int, msg: string = ""` | `bool` | `AssertionDefect` |
| `assertFileModifiedAfter` | `path: string, time: Time, msg: string = ""` | `bool` | `AssertionDefect` |

### CLI Testing

| Function | Parameters | Returns | Exceptions |
|----------|------------|---------|------------|
| `runCliCommand` | `cmd: string, cwd: string = "", env: seq[(string,string)] = @[], timeoutMs: int = 5000` | `(string, int)` | `OSError` |
| `assertExitCode` | `code: int, expected: int, msg: string = ""` | `bool` | `AssertionDefect` |
| `assertOutputContains` | `output: string, expected: string, msg: string = ""` | `bool` | `AssertionDefect` |

### Performance Benchmarking

| Function | Parameters | Returns | Exceptions |
|----------|------------|---------|------------|
| `benchmark` | `name: string, iterations: int, body: proc()` | `BenchResult` | `ValueError` |

**BenchResult fields**: `avg: float`, `min: float`, `max: float`, `stddev: float`, `total: float`, `iterations: int`

### Progress Bars

| Function | Parameters | Returns | Exceptions |
|----------|------------|---------|------------|
| `newProgressBar` | `style: ProgressBarStyle, width: int = 40, total: int, message: string = ""` | `ProgressBar` | `ValueError` |
| `updateProgress` | `bar: var ProgressBar, current: int, msg: string = ""` | `void` | - |
| `finish` | `bar: var ProgressBar, finalMsg: string = ""` | `void` | - |

**ProgressBarStyle**: `pbsGlobe`, `pbsPulse`, `pbsDots`, `pbsBar`, `pbsSpinner`

### Reporting

| Function | Parameters | Returns | Exceptions |
|----------|------------|---------|------------|
| `newTestSuiteReport` | `name: string` | `TestSuiteReport` | `ValueError` |
| `newTestResult` | `name: string, passed: bool, duration: float, message: string = ""` | `TestResult` | `ValueError` |
| `addResult` | `report: var TestSuiteReport, result: TestResult` | `void` | `ValueError` |
| `generateConsoleReport` | `report: TestSuiteReport` | `void` | - |
| `saveReport` | `report: TestSuiteReport, format: ReportFormat, path: string` | `string` | `IOError` |

**ReportFormat**: `rfConsole`, `rfJson`, `rfJunit`, `rfMarkdown`

## Examples

### File System Testing

```nim
import nimtest/api

var ctx = createTestContext()
try:
  let tempDir = createTempTestDir(ctx, "file_test")
  let configFile = createTestFile(ctx, tempDir, "config.json", """{"debug": true}""")
  let logFile = createTestFile(ctx, tempDir, "app.log", "INFO: Started\nERROR: Failed\n")

  # Test file existence and content
  discard assertFileExists(configFile)
  discard assertFileContains(configFile, "debug")
  discard assertFileHasSize(configFile, 15)

  # Test log parsing
  discard assertFileContains(logFile, "ERROR")

  echo "File system tests passed!"
finally:
  ctx.cleanup()
```

### CLI Testing

```nim
import nimtest/api

# Test nim compiler version
let (output, exitCode) = runCliCommand("nim --version")
discard assertExitCode(exitCode, 0)
discard assertOutputContains(output, "Nim Compiler")

# Test with custom working directory
let tempDir = createTempTestDir(createTestContext(), "cli_test")
let (lsOutput, lsCode) = runCliCommand("ls -la", cwd = tempDir)
discard assertExitCode(lsCode, 0)

echo "CLI tests passed!"
```

### Benchmarking with Progress

```nim
import nimtest/api

# Benchmark string operations
let benchResult = benchmark("string concatenation", 1000):
  proc() =
    var s = ""
    for i in 0..100:
      s &= "test"

echo &"Benchmark results: {benchResult.avg:.3f}ms avg"

# Progress bar for long-running tests
let bar = newProgressBar(pbsGlobe, total = 100, message = "Running benchmarks...")
for i in 0..100:
  # Simulate work
  let result = benchmark("iteration " & $i, 10):
    proc() = discard
  bar.updateProgress(i, &"Completed {i}/100 benchmarks")
bar.finish("All benchmarks completed!")
```

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
      - uses: jiro4989/setup-nim-action@v2
      - run: nimble install nimtest
      - run: nim c -r tests/test_all.nim
      - uses: actions/upload-artifact@v3
        with:
          name: junit-report
          path: test-results.xml
```

### JUnit XML Upload

```yaml
- name: Generate JUnit Report
  run: |
    var report = newTestSuiteReport("CI Tests")
    # ... add test results
    discard saveReport(report, rfJunit, "test-results.xml")

- uses: actions/upload-artifact@v3
  with:
    name: test-results
    path: test-results.xml
```

## Best Practices

- **Always use TestContext** for temporary resources to ensure cleanup
- **Call `ctx.cleanup()` in `finally` blocks** for exception safety
- **Use progress bars** for tests taking >5 seconds to provide user feedback
- **Generate JUnit reports** for CI/CD integration
- **Benchmark with sufficient iterations** (1000+) for accurate results
- **Test CLI commands** with both success and failure cases
- **Use descriptive names** for benchmarks and test results

## Roadmap

nimtest has an ambitious roadmap for 2026 focused on usability, performance, and observability. See [ROADMAP.md](../ROADMAP.md) for the complete strategic plan including:

- **Q1 2026 (v1.1)**: Macro DSL for tests, CLI runner binary, enhanced assertions
- **Q2 2026 (v1.2)**: Parallel execution, async/await support, E2E integration lanes
- **Q3 2026 (v1.3)**: Interactive HTML reports, coverage integration, fuzzing hooks
- **Q4 2026+**: Wild cards including AI-assisted test generation and compile-time fuzzing

**Contribute**: Help shape the future by participating in roadmap discussions on the [Nim Forum](https://forum.nim-lang.org/) or [GitHub Discussions](https://github.com/codenimja/nimtest/discussions).

## FAQ

**Q: Why not just use unittest?**  
A: unittest is great for basics, but nimtest provides automatic resource cleanup, CLI testing, progress visualization, and CI-ready reporting.

**Q: Are progress bars thread-safe?**  
A: Yes, they are lock-free and safe for concurrent use.

**Q: Can I use nimtest with existing unittest code?**  
A: Yes, nimtest complements unittest - use both in the same project.

**Q: What happens if cleanup fails?**  
A: Cleanup failures are logged but don't throw exceptions to avoid masking test failures.

**Q: How do I customize progress bar appearance?**  
A: Choose from 5 built-in styles: `pbsGlobe`, `pbsPulse`, `pbsDots`, `pbsBar`, `pbsSpinner`.

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure `nimble test` passes
5. Submit a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/codenimja/nimtest/issues)
- **Discussions**: [GitHub Discussions](https://github.com/codenimja/nimtest/discussions)
- **Forum**: [Nim Forum](https://forum.nim-lang.org/)

---

**nimtest v1.0.0** - MIT License - [GitHub](https://github.com/codenimja/nimtest)