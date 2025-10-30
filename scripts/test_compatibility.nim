#!/usr/bin/env nim
## Nim Compatibility Testing Script
##
## This script tests nimtest against multiple Nim versions to ensure
## compatibility and catch breaking changes early.
##
## Usage:
##   nim c -r scripts/test_compatibility.nim
##
## Requirements:
##   - Multiple Nim versions installed via choosenim
##   - nimble available in PATH

import os, strutils, sequtils, strformat, times

const
  nimVersions = ["1.6.0", "1.6.2", "1.6.4", "1.6.6", "1.6.8", "1.6.10", "1.6.12", "1.6.14", "2.0.0", "2.0.2", "devel"]
  testCommand = "nimble install -y && nimble test"

type
  TestResult = object
    version: string
    success: bool
    output: string
    duration: float

proc runCompatibilityTest(): seq[TestResult] =
  ## Run compatibility tests against all configured Nim versions
  result = @[]

  echo "🧪 Starting Nim Compatibility Tests"
  echo "=================================="
  echo fmt"Testing against {nimVersions.len} Nim versions"
  echo ""

  for version in nimVersions:
    echo fmt"Testing Nim {version}..."
    let startTime = epochTime()

    # Switch to specific Nim version
    let switchCmd = fmt"choosenim {version}"
    let switchResult = execShellCmd(switchCmd)

    var testResult: TestResult
    testResult.version = version

    if switchResult != 0:
      testResult.success = false
      testResult.output = fmt"Failed to switch to Nim {version}"
      testResult.duration = epochTime() - startTime
      result.add(testResult)
      echo fmt"❌ Failed to switch to Nim {version}"
      continue

    # Run the test suite
    let exitCode = execShellCmd(testCommand)
    testResult.success = exitCode == 0
    testResult.duration = epochTime() - startTime

    if testResult.success:
      echo fmt"✅ Nim {version}: PASSED ({testResult.duration:.2f}s)"
      testResult.output = "All tests passed"
    else:
      echo fmt"❌ Nim {version}: FAILED ({testResult.duration:.2f}s)"
      testResult.output = "Test suite failed - check logs above"

    result.add(testResult)

  echo ""
  echo "📊 Compatibility Test Results"
  echo "============================"

  let passed = result.filterIt(it.success).len
  let failed = result.len - passed

  echo fmt"Total versions tested: {result.len}"
  echo fmt"Passed: {passed}"
  echo fmt"Failed: {failed}"

  if failed > 0:
    echo ""
    echo "❌ Failed versions:"
    for res in result:
      if not res.success:
        echo fmt"  - Nim {res.version}: {res.output}"

  echo ""
  if failed == 0:
    echo "🎉 All compatibility tests passed!"
  else:
    echo "⚠️  Some compatibility issues detected. Review failed versions above."

proc saveResults(results: seq[TestResult]) =
  ## Save test results to a JSON file for CI/CD integration
  let jsonFile = "compatibility_results.json"

  var jsonContent = "{\n"
  jsonContent &= fmt"""  "timestamp": "{now()}",\n"""
  jsonContent &= fmt"""  "total_versions": {results.len},\n"""
  jsonContent &= fmt"""  "passed": {results.filterIt(it.success).len},\n"""
  jsonContent &= fmt"""  "failed": {results.len - results.filterIt(it.success).len},\n"""
  jsonContent &= """  "results": [\n"""

  for i, result in results:
    jsonContent &= "    {\n"
    jsonContent &= &"      \"version\": \"{result.version}\",\n"
    jsonContent &= &"      \"success\": {result.success},\n"
    jsonContent &= &"      \"duration\": {result.duration:.2f},\n"
    jsonContent &= &"      \"output\": \"{result.output}\"\n"
    jsonContent &= "    }"
    if i < results.high:
      jsonContent &= ","
    jsonContent &= "\n"

  jsonContent &= "  ]\n"
  jsonContent &= "}\n"

  writeFile(jsonFile, jsonContent)
  echo fmt"📄 Results saved to {jsonFile}"

when isMainModule:
  let results = runCompatibilityTest()
  saveResults(results)

  # Exit with error code if any tests failed
  let failedCount = results.filterIt(not it.success).len
  if failedCount > 0:
    quit(1)