# nimtest.nimble
version       = "0.1.0"
author        = "codenimja"
description   = "Comprehensive testing framework for Nim"
license       = "MIT"
srcDir        = "src"
bin           = @[]

requires "nim >= 2.0.0"

task test, "Run all tests":
  exec "nim c -r tests/test_core.nim"
  exec "nim c -r tests/test_helpers.nim"
  exec "nim c -r tests/test_reporting.nim"
  exec "nim c -r tests/test_progress.nim"