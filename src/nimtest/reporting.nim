## Advanced reporting utilities for nimtest
## Provides comprehensive test reporting and analytics with proper error handling

import std/[json, times, strformat, strutils, tables, algorithm, xmltree]
import ./config, ./progress

const TimeFormat* = "yyyy-MM-dd HH:mm:ss"

type
  TestSuiteResult* = ref object
    ## Represents the result of a single test case
    ##
    ## Contains information about a test execution including its name,
    ## pass/fail status, execution duration, and any associated messages.
    name*: string          ## Name of the test
    passed*: bool          ## Whether the test passed
    duration*: float       ## Execution duration in seconds
    message*: string       ## Any message associated with the test result
    timestamp*: Time       ## When the test was executed
    category*: string      ## Category of the test
    tags*: seq[string]     ## Tags associated with this test

  TestSuiteReport* = ref object
    ## Represents a complete test suite report
    ##
    ## Contains summary information, individual test results, and configuration
    ## data for a complete test run.
    name*: string              ## Name of the test suite
    startTime*: Time           ## When testing started
    endTime*: Time             ## When testing ended  
    results*: seq[TestSuiteResult]  ## Individual test results
    config*: Table[string, string]  ## Configuration information

  ReportFormat* = enum
    ## Different output formats supported for test reports
    rfConsole,    ## Human-readable console output
    rfJson,       ## JSON format
    rfJunit,      ## JUnit XML format
    rfMarkdown    ## Markdown format





proc newTestResult*(name: string, passed: bool, duration: float, message: string = "", category: string = "general"): TestSuiteResult =
  ## Create a new test result with input validation
  if name.len == 0:
    raise newException(ValueError, "Test result name cannot be empty")
  
  new(result)
  result.name = name
  result.passed = passed
  result.duration = duration
  result.message = message
  result.timestamp = getTime()
  result.category = category
  result.tags = @[]

proc newTestSuiteReport*(name: string): TestSuiteReport =
  ## Creates a new test suite report with required configuration
  ##
  ## Initializes a TestSuiteReport object with the given name and populates
  ## it with default configuration values from the project configuration.
  ##
  ## Parameters:
  ##   name: The name of the test suite (must not be empty)
  ##
  ## Returns:
  ##   A new TestSuiteReport instance ready to collect test results
  ##
  ## Raises:
  ##   ValueError: if the name is empty
  if name.len == 0:
    raise newException(ValueError, "Test suite name cannot be empty")
  
  new(result)
  result.name = name
  result.startTime = getTime()
  result.results = @[]
  result.config = initTable[string, string]()
  result.config["PROJECT_NAME"] = ProjectName
  result.config["PROJECT_DISPLAY_NAME"] = ProjectName  # Using ProjectName since we removed the display name
  result.config["TEST_SUITE_VERSION"] = "1.0.0"  # Using default version

proc addResult*(report: var TestSuiteReport, result: TestSuiteResult) =
  ## Add a test result to the report with validation
  if result.isNil:
    raise newException(ValueError, "Test result cannot be nil")
  report.results.add(result)

proc addResults*(report: var TestSuiteReport, results: seq[TestSuiteResult]) =
  ## Add multiple test results to the report with validation
  for result in results:
    if result.isNil:
      raise newException(ValueError, "Test result cannot be nil")
  report.results.add(results)

proc finish*(report: var TestSuiteReport) =
  ## Mark the report as finished
  report.endTime = getTime()
  if report.config.len == 0:
    report.config = {
      "project": ProjectName,
      "version": "1.0.0",
      "generated": $getTime()
    }.toTable

proc getDuration*(report: TestSuiteReport): float =
  ## Get total duration of the test suite
  if report.startTime > report.endTime and report.endTime != Time():
    # If endTime is not set but startTime is, use current time
    result = (getTime() - report.startTime).inNanoseconds.float / 1_000_000_000.0
  else:
    result = (report.endTime - report.startTime).inNanoseconds.float / 1_000_000_000.0

proc getPassedCount*(report: TestSuiteReport): int =
  ## Get number of passed tests
  result = 0
  for r in report.results:
    if r.passed: inc(result)

proc getFailedCount*(report: TestSuiteReport): int =
  ## Get number of failed tests
  result = report.results.len - getPassedCount(report)

proc getPassRate*(report: TestSuiteReport): float =
  ## Get pass rate as percentage
  if report.results.len == 0: return 0.0
  result = (getPassedCount(report).float / report.results.len.float) * 100.0

proc getStatistics*(report: TestSuiteReport): tuple[passed: int, failed: int, total: int, passRate: float, duration: float] =
  ## Get comprehensive statistics for the report
  let passed = getPassedCount(report)
  let total = report.results.len
  let failed = total - passed
  let passRate = if total > 0: (passed.float / total.float) * 100.0 else: 0.0
  let duration = getDuration(report)
  result = (passed: passed, failed: failed, total: total, passRate: passRate, duration: duration)

type
  SortCriteria* = enum
    srName, srDuration, srStatus

proc sortResults*(report: var TestSuiteReport, sortBy: SortCriteria = srStatus) =
  ## Sort test results by specified criteria
  case sortBy:
    of srName:
      report.results.sort(proc(a, b: TestSuiteResult): int = cmp(a.name, b.name))
    of srDuration:
      report.results.sort(proc(a, b: TestSuiteResult): int = 
        if a.duration > b.duration: -1
        elif a.duration < b.duration: 1
        else: 0)
    of srStatus:
      report.results.sort(proc(a, b: TestSuiteResult): int = 
        if a.passed and not b.passed: -1
        elif not a.passed and b.passed: 1
        else: 0)

proc getResultsByCategory*(report: TestSuiteReport, category: string): seq[TestSuiteResult] =
  ## Get test results filtered by category
  result = @[]
  for r in report.results:
    if r.category == category:
      result.add(r)

proc getFailedResults*(report: TestSuiteReport): seq[TestSuiteResult] =
  ## Get only failed test results
  result = @[]
  for r in report.results:
    if not r.passed:
      result.add(r)

proc generateConsoleReport*(report: TestSuiteReport) =
  ## Generate human-readable console report with proper formatting
  var outputLines: seq[string] = @[]
  outputLines.add("")
  outputLines.add("┌─────────────────────────────────────────────────────────┐")
  outputLines.add("│                    TEST SUITE REPORT                    │")
  outputLines.add("├─────────────────────────────────────────────────────────┤")
  
  # Calculate consistent widths for proper alignment
  const contentWidth = 57  # Total width minus borders (59 - 2)
  const suiteWidth = contentWidth - 7  # "Suite: " is 7 chars
  const projectWidth = contentWidth - 9  # "Project: " is 9 chars
  const startedWidth = contentWidth - 9  # "Started: " is 9 chars
  const durationWidth = contentWidth - 10  # "Duration: " is 10 chars
  const resultsWidth = contentWidth - 9  # "Results: " is 9 chars
  const passRateWidth = contentWidth - 11  # "Pass Rate: " is 11 chars
  const statusWidth = contentWidth - 7  # "✓ PASS " is 7 chars
  const reasonWidth = contentWidth - 10  # "   Reason: " is 10 chars
  
  # Format each line with consistent width using string concatenation
  outputLines.add("│ Suite: " & alignLeft(report.name, suiteWidth) & " │")
  outputLines.add("│ Project: " & alignLeft(ProjectName, projectWidth) & " │")
  outputLines.add("│ Started: " & alignLeft(report.startTime.format(TimeFormat), startedWidth) & " │")
  
  let stats = getStatistics(report)
  let durationStr = formatFloat(stats.duration, ffDecimal, 2) & "s"
  outputLines.add("│ Duration: " & alignLeft(durationStr, durationWidth) & " │")
  outputLines.add("├─────────────────────────────────────────────────────────┤")
  
  let resultsStr = &"{stats.passed} passed, {stats.failed} failed, {stats.total} total"
  outputLines.add("│ Results: " & alignLeft(resultsStr, resultsWidth) & " │")
  let passRateStr = formatFloat(stats.passRate, ffDecimal, 1) & "%"
  outputLines.add("│ Pass Rate: " & alignLeft(passRateStr, passRateWidth) & " │")
  outputLines.add("├─────────────────────────────────────────────────────────┤")
  
  # Sort results for better display: pass first, then fail, then by name
  var sortedResults = report.results
  sortedResults.sort(proc(a, b: TestSuiteResult): int =
    if a.passed and not b.passed: -1  # Passes first
    elif not a.passed and b.passed: 1  # Failures last
    else: cmp(a.name, b.name))  # Then by name
  
  for result in sortedResults:
    let status = if result.passed: "✓ PASS" else: "✗ FAIL"
    outputLines.add("│ " & status & " " & alignLeft(result.name, statusWidth) & " │")
    if not result.passed and result.message.len > 0:
      outputLines.add("│   Reason: " & alignLeft(result.message, reasonWidth) & " │")
  
  outputLines.add("└─────────────────────────────────────────────────────────┘")
  outputLines.add("")
  
  # Output all at once to reduce system calls
  for line in outputLines:
    echo line

proc generateJsonReport*(report: TestSuiteReport): string =
  ## Generate JSON report with detailed information
  let stats = getStatistics(report)
  var reportJson = %* {
    "suite": {
      "name": report.name,
      "project": ProjectName,
      "version": "1.0.0",
      "startTime": $report.startTime,
      "endTime": $report.endTime,
      "duration": report.getDuration()
    },
    "summary": {
      "total": report.results.len,
      "passed": stats.passed,
      "failed": stats.failed,
      "passRate": stats.passRate
    },
    "statistics": {
      "duration": stats.duration,
      "passRate": stats.passRate
    },
    "results": %[]
  }

  for result in report.results:
    let resultJson = %* {
      "name": result.name,
      "passed": result.passed,
      "duration": result.duration,
      "message": result.message,
      "timestamp": $result.timestamp,
      "category": result.category,
      "tags": result.tags
    }
    reportJson{"results"}.add(resultJson)

  result = $reportJson

proc generateJunitReport*(report: TestSuiteReport): string =
  ## Generate JUnit XML report compliant with standard format
  var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  let stats = getStatistics(report)
  xml &= &"<testsuite name=\"{xmltree.escape(report.name)}\" tests=\"{stats.total}\" failures=\"{stats.failed}\" time=\"{stats.duration:.3f}\">\n"
  
  for testResult in report.results:
    xml &= &"  <testcase name=\"{xmltree.escape(testResult.name)}\" time=\"{testResult.duration:.3f}\">\n"
    if not testResult.passed:
      xml &= &"    <failure message=\"{xmltree.escape(testResult.message)}\">FAILED</failure>\n"
    xml &= "  </testcase>\n"
  
  xml &= "</testsuite>\n"
  result = xml

proc generateMarkdownReport*(report: TestSuiteReport): string =
  ## Generate Markdown report with enhanced formatting
  let stats = getStatistics(report)
  
  result = "# Test Suite Report\n\n"
  result &= &"## Suite: {report.name}\n\n"
  result &= &"**Project:** {ProjectName}\n\n"
  result &= &"**Version:** 1.0.0\n\n"
  result &= &"**Started:** {report.startTime.format(TimeFormat)}\n\n"
  result &= &"**Duration:** {formatFloat(stats.duration, ffDecimal, 2)} seconds\n\n"
  
  result &= "## Summary\n\n"
  result &= &"- **Total Tests:** {stats.total}\n"
  result &= &"- **Passed:** {stats.passed}\n"
  result &= &"- **Failed:** {stats.failed}\n"
  result &= &"- **Pass Rate:** {formatFloat(stats.passRate, ffDecimal, 1)}%\n\n"
  
  if stats.failed > 0:
    result &= "## Failed Tests\n\n"
    result &= "| Test Name | Duration (s) | Message |\n"
    result &= "|-----------|--------------|---------|\n"
    
    for resultItem in getFailedResults(report):
      let duration = formatFloat(resultItem.duration, ffDecimal, 4)
      let message = if resultItem.message.len > 0: resultItem.message else: "Failed without message"
      result &= &"| {resultItem.name} | {duration} | {message} |\n"
    
    result &= "\n"
  
  result &= "## All Test Results\n\n"
  result &= "| Status | Test Name | Duration (s) | Category | Message |\n"
  result &= "|--------|-----------|--------------|----------|---------|\n"
  
  for resultItem in report.results:
    let status = if resultItem.passed: "✅" else: "❌"
    let duration = formatFloat(resultItem.duration, ffDecimal, 4)
    let message = if resultItem.message.len > 0: resultItem.message else: "Success"
    result &= &"| {status} | {resultItem.name} | {duration} | {resultItem.category} | {message} |\n"

proc saveReport*(report: TestSuiteReport, format: ReportFormat, filename: string = ""): string =
  ## Saves report in specified format to file with error handling
  ##
  ## Creates a report in the specified format and writes it to a file.
  ## If no filename is provided, a default name based on the format is used.
  ## The function automatically adds appropriate file extensions if missing.
  ##
  ## Parameters:
  ##   report: The test suite report to save (cannot be nil)
  ##   format: The format to save the report in (JSON, JUnit, Markdown, or Console)
  ##   filename: Optional filename to use; if empty, a default is generated
  ##
  ## Returns:
  ##   The filename that was actually used for saving the report
  ##
  ## Raises:
  ##   ValueError: if report is nil or report content generation fails
  ##   IOError: if file writing fails
  if report.isNil:
    raise newException(ValueError, "Report cannot be nil")
  
  let reportContent = case format:
    of rfConsole:
      # For console format, we just print but return an empty string
      generateConsoleReport(report)
      ""
    of rfJson: generateJsonReport(report)
    of rfJunit: generateJunitReport(report)
    of rfMarkdown: generateMarkdownReport(report)
  
  if reportContent.len == 0 and format != rfConsole:
    raise newException(ValueError, "Failed to generate report content")
  
  let actualFilename = if filename == "":
    case format:
      of rfJson: "test_report.json"
      of rfJunit: "test_report.xml"
      of rfMarkdown: "test_report.md"
      else: "test_report.txt"
  else:
    # Validate filename has appropriate extension
    var finalFilename = filename
    if format == rfJson and not finalFilename.endsWith(".json"):
      finalFilename.add(".json")
    elif format == rfJunit and not finalFilename.endsWith(".xml"):
      finalFilename.add(".xml")
    elif format == rfMarkdown and not finalFilename.endsWith(".md"):
      finalFilename.add(".md")
    finalFilename
  
  try:
    writeFile(actualFilename, reportContent)
  except IOError as e:
    raise newException(IOError, "Failed to write report to " & actualFilename & ": " & e.msg)
  
  return actualFilename

proc trySaveReport*(report: TestSuiteReport, format: ReportFormat, filename: string = ""): tuple[success: bool, filename: string, error: string] =
  ## Attempt to save report and return success status with filename and error details
  try:
    let savedFilename = saveReport(report, format, filename)
    return (true, savedFilename, "")
  except Exception as e:
    return (false, "", e.msg)

proc printSummary*(report: TestSuiteReport) =
  ## Print a simple summary to console
  if report.isNil:
    echo "Error: Report is nil"
    return
  
  let stats = getStatistics(report)
  echo &"\nTest Summary: {stats.passed}/{stats.total} passed ({stats.passRate:.1f}%) in {formatFloat(stats.duration, ffDecimal, 2)}s"
  if stats.failed > 0:
    echo &"Failed tests: {stats.failed}"

proc runTestsWithProgress*(testSuites: seq[tuple[name: string, testProc: proc() {.gcsafe.}]], style: progress.ProgressBarStyle = progress.pbsGlobe): TestSuiteReport =
  ## Run test suites with progress bar display and proper error handling
  var report = newTestSuiteReport("Progress Test Suite")
  if testSuites.len == 0:
    echo "No tests to run"
    return report
  
  let progressBar = progress.newProgressBar(style, total = testSuites.len, message = "Running tests...")
  
  echo "🚀 Starting test execution..."
  echo ""
  
  for i, (suiteName, testProc) in testSuites:
    # Using the optimized update method that only updates every 50ms to avoid spam
    let msg = "Running " & suiteName & "..."
    progress.update(progressBar, i, msg)
    
    let startTime = getTime()
    var passed = true
    var msg2 = ""
    
    try:
      testProc()
    except Exception as e:
      passed = false
      msg2 = e.msg
    except:
      passed = false
      msg2 = "Unknown error occurred"
    
    let duration = (getTime() - startTime).inMilliseconds.float / 1000.0
    let testResult = newTestResult(suiteName, passed, duration, msg2, "suite")
    addResult(report, testResult)
    
    # Small delay for visual effect (only during debugging, remove in production)
    # sleep(100)
  
  progress.finish(progressBar, "All tests completed!")
  finish(report)
  
  return report

# Export all public symbols
export
  TestSuiteResult,
  TestSuiteReport,
  ReportFormat,
  SortCriteria,
  TimeFormat,
  newTestResult,
  newTestSuiteReport,
  addResult,
  addResults,
  getDuration,
  getPassedCount,
  getFailedCount,
  getPassRate,
  getStatistics,
  sortResults,
  getResultsByCategory,
  getFailedResults,
  generateConsoleReport,
  generateJsonReport,
  generateJunitReport,
  generateMarkdownReport,
  saveReport,
  trySaveReport,
  printSummary,
  runTestsWithProgress