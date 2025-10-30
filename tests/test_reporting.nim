import ../src/nimtest/api
import std/[unittest, strutils]

suite "nimtest reporting":
  test "create and finish test report":
    var report = newTestSuiteReport("Test Suite")
    let result = newTestResult("sample test", true, 0.005, "Test passed")
    addResult(report, result)
    finish(report)
    
    check report.results.len == 1
    check report.results[0].passed == true

  test "get report statistics":
    var report = newTestSuiteReport("Stats Test")
    addResult(report, newTestResult("passing test", true, 0.001, ""))
    addResult(report, newTestResult("failing test", false, 0.002, "Failed"))
    
    let stats = getStatistics(report)
    check stats.passed == 1
    check stats.failed == 1
    check stats.total == 2
    check stats.passRate == 50.0

  test "get failed results":
    var report = newTestSuiteReport("Failed Results Test")
    addResult(report, newTestResult("passing test", true, 0.001, ""))
    addResult(report, newTestResult("failing test 1", false, 0.002, "Error 1"))
    addResult(report, newTestResult("failing test 2", false, 0.003, "Error 2"))
    
    let failed = getFailedResults(report)
    check failed.len == 2
    check failed[0].message == "Error 1"
    check failed[1].message == "Error 2"

  test "generate different report formats":
    var report = newTestSuiteReport("Format Test")
    addResult(report, newTestResult("sample test", true, 0.005, "Success"))
    finish(report)
    
    # Test JSON generation
    let jsonReport = generateJsonReport(report)
    check jsonReport.len > 0
    check find(jsonReport, "suite") >= 0
    
    # Test JUnit generation
    let junitReport = generateJunitReport(report)
    check junitReport.len > 0
    check "<?xml" in junitReport
    
    # Test Markdown generation
    let markdownReport = generateMarkdownReport(report)
    check markdownReport.len > 0
    check "# Test Suite Report" in markdownReport