import ../src/nimtest/api
import std/[unittest, os, strutils]

suite "nimtest CI-ready reporting":
  test "generate JUnit XML for CI":
    var report = newTestSuiteReport("CI Test Suite")
    
    # Add some passing tests
    addResult(report, newTestResult("test_addition", true, 0.001, "Addition works correctly"))
    addResult(report, newTestResult("test_subtraction", true, 0.002, "Subtraction works correctly"))
    
    # Add a failing test
    addResult(report, newTestResult("test_failing_example", false, 0.005, "Expected failure for testing"))
    
    finish(report)
    
    # Generate JUnit XML report
    let junitXml = generateJunitReport(report)
    check junitXml.len > 0
    check find(junitXml, "testsuite") >= 0
    check find(junitXml, "testcase") >= 0
    check find(junitXml, "failure") >= 0  # Should contain the failing test
    
    # Also test creation of target directory if needed
    let targetDir = "test-reports"
    if not dirExists(targetDir):
      createDir(targetDir)
    
    # Save to file for CI systems
    let filename = saveReport(report, rfJunit, "test-reports/junit.xml")
    check fileExists(filename)
    
    # Clean up test file
    if fileExists(filename):
      removeFile(filename)
    
    let junitFile = saveReport(report, rfJunit, "test-reports/ci_report.xml")
    check fileExists(junitFile)
    
    # Clean up
    if dirExists(targetDir):
      removeDir(targetDir)