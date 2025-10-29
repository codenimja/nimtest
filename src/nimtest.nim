## Nim Test Framework
## A professional testing framework for Nim projects
##
## This module provides utilities and helpers for building comprehensive test suites.
##
## Basic usage:
## ```nim
## import nimtest
##
## # Configure your project
## # (Edit src/nimtest/test_config.nim or override in your tests)
##
## # Use helpers in your tests
## suite "My Tests":
##   var ctx: TestContext
##
##   setup:
##     ctx = createTestContext()
##
##   teardown:
##     ctx.cleanup()
##
##   test "something works":
##     let testDir = ctx.createTempTestDir()
##     # ... your test code
## ```

import nimtest/test_config
import nimtest/helpers
import nimtest/reporting

export test_config, helpers, reporting
