## Nim Test Framework
## A professional, high-performance testing framework for Nim projects
##
## This module provides utilities and helpers for building comprehensive test suites
## with proper error handling, resource management, and detailed reporting.
##
## Core components:
## - api.nim: Main public API (recommended import)
## - core.nim: Core functionality (TestContext, basic assertions)
## - reporting.nim: Test reporting with multiple output formats and progress bars
## - config.nim: Optional configuration
## - progress.nim: Progress bar utilities
## - helpers.nim: Extended helper functions
##
## Basic usage:
## ```nim
## import nimtest/api
## import std/[os, times]
##
## # Create and use test context for resource management
## var ctx = createTestContext()
## try:
##   # Create temporary resources
##   let testDir = createTempTestDir(ctx, "mytest")
##   let testFile = createTestFile(ctx, testDir, "test.txt", "Hello, World!")
##   
##   # Use assertion utilities (return bool, throw exception on failure)
##   discard assertFileExists(testFile)
##   discard assertFileContains(testFile, "Hello, World!")
##   
##   # Use performance utilities
##   let duration = measureTime("operation"):
##     proc() = 
##       sleep(10)  # Example operation
##
##   echo "Operation took: ", duration, " seconds"
##
## finally:
##   # Always cleanup resources
##   ctx.cleanup()
## ```
##
## For comprehensive test reporting:
## ```nim
## var report = newTestSuiteReport("My Test Suite")
## let result = newTestResult("my test", true, 0.005, "Test passed")
## addResult(report, result)
## generateConsoleReport(report)
## let jsonFile = saveReport(report, rfJson, "report.json")
## 
## # For CI/CD systems, use JUnit XML format:
## let junitFile = saveReport(report, rfJunit, "junit.xml")
## ```

import nimtest/api

export api
