# nimtest.nimble
version       = "0.1.0"
author        = "codenimja"
description   = "A batteries-included testing framework for Nim – TestContext, file-system assertions, CLI testing, benchmarks, JUnit/Markdown reports, animated progress bars."
license       = "MIT"
srcDir        = "src"

requires "nim >= 2.0.0"

# Optional but recommended for nimble.directory
keywords      = "testing, unittest, benchmark, junit, markdown, progress-bar, cli-testing"
homepage      = "https://github.com/codenimja/nimtest"

installMsg    = """
Quick start:
  import nimtest/api
  var ctx = createTestContext()
  # …write tests…
  ctx.cleanup()
"""

task test, "Run the complete nimtest test suite":
  exec "nim c -r tests/test_core.nim"
  exec "nim c -r tests/test_helpers.nim"
  exec "nim c -r tests/test_reporting.nim"
  exec "nim c -r tests/test_progress.nim"