# Package

version       = "0.2.0"
author        = "Nim Testing Framework Contributors"
description   = "Professional, comprehensive test suite framework for Nim projects"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests", "examples", "docs"]

# Dependencies

requires "nim >= 1.6.0"

# Installation note: This package provides a testing framework template.
# After installation, you can either:
#   1. Use the helper modules in your own tests
#   2. Copy the example tests to your project and customize them

task test, "Run package tests":
  echo "Testing nimtest package..."
  exec "nim c src/nimtest.nim"
  echo "Package builds successfully!"

task examples, "List available examples":
  echo ""
  echo "Example test suites available in examples/:"
  echo "  • cli/                   - CLI command tests (5 files)"
  echo "  • core/                  - Core library tests (6 files)"
  echo "  • performance/           - Performance benchmarks (2 files)"
  echo "  • error_handling/        - Error handling tests (2 files)"
  echo "  • integration/           - Integration tests (1 file)"
  echo ""
  echo "To use examples:"
  echo "  1. Copy to your project: cp -r examples/* tests/"
  echo "  2. Edit src/nimtest/test_config.nim"
  echo "  3. Run: nimble test"
  echo ""

task run_all_tests, "Run comprehensive test suite":
  echo "Running comprehensive test suite..."
  exec "nim c -r examples/test_reporting_demo.nim"
  exec "nim c -r examples/test_error_reporting.nim"
  exec "nim c -r examples/test_runner.nim"

task test_reports, "Generate test reports":
  echo "Generating test reports..."
  exec "nim c -r examples/test_reporting_demo.nim"
  exec "nim c -r examples/test_error_reporting.nim"
  echo "Test reports generated in current directory"