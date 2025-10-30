## Nim Test Framework
## A professional, high-performance testing framework for Nim projects
##
## This module provides utilities and helpers for building comprehensive test suites
## with proper error handling, resource management, and detailed reporting.
##
## Core components:
## - helpers.nim: File operations, assertions, CLI testing, performance utilities
## - reporting.nim: Test reporting with multiple output formats and progress bars
## - test_config.nim: Project configuration constants and types
##
## Basic usage:
## ```nim
## import nimtest
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
## ```

import nimtest/test_config
import nimtest/helpers
import nimtest/reporting

export test_config, helpers, reporting
