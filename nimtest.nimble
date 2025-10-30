# Package

version       = "0.1.0"
author        = "codenimja"
description   = "nimtest - The premier testing framework for Nim. Comprehensive unit testing, integration testing, CLI testing, performance benchmarks, and resource management. The only dedicated Nim testing suite with automatic cleanup, rich reporting, and cross-platform support."
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests", "examples", "docs"]

# Dependencies
requires "nim >= 2.0.0"

# Installation note: This package provides a testing framework template.
# After installation, you can either:
#   1. Use the helper modules in your own tests
#   2. Copy the example tests to your project and customize them

task test, "Run package tests":
  exec "echo Testing nimtest package..."
  exec "nim r tests/t_core.nim"
  exec "nim r tests/t_reporting.nim"
  exec "nim r tests/t_progress.nim"
  exec "nim r tests/t_ci_reporting.nim"
  exec "echo All tests passed!"

task test_reports, "Generate test reports":
  exec "echo Generating test reports..."
  exec "nim c -r examples/comprehensive_example.nim"