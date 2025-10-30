## Advanced reporting utilities for nimtest
## Provides comprehensive test reporting and analytics with proper error handling

import std/[json, times, strformat, strutils, tables, algorithm, xmltree]
import test_config

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

  ProgressBarStyle* = enum
    ## Different visual styles for progress bars
    pbsMinimal,      ## Simple bar with percentage
    pbsGlobe,        ## Globe-like rotating progress
    pbsPulse,        ## Pulsing bar with subtle animation
    pbsDots,         ## Animated dots
    pbsBlocks        ## Unicode block characters

  ProgressBar* = ref object
    ## Represents a progress bar visual element
    ##
    ## Provides a visual indicator of progress for long-running operations.
    style*: ProgressBarStyle
    width*: int           ## Width of the progress bar in characters
    current*: int         ## Current progress value
    total*: int           ## Total value representing 100% completion
    startTime*: Time      ## When progress tracking started
    lastUpdate*: Time     ## Last time the progress was updated
    message*: string      ## Message to display with the progress bar
    showPercentage*: bool ## Whether to show percentage completion
    showTime*: bool       ## Whether to show elapsed time
    maxValue*: int        ## Track the maximum value reached

proc newProgressBar*(style: ProgressBarStyle = pbsMinimal, width: int = 40, total: int = 100, message: string = ""): ProgressBar =
  ## Create a new progress bar with validation
  if width <= 0:
    raise newException(ValueError, "ProgressBar width must be positive")
  if total <= 0:
    raise newException(ValueError, "ProgressBar total must be positive")
  
  let now = getTime()
  new(result)
  result.style = style
  result.width = width
  result.current = 0
  result.total = total
  result.startTime = now
  result.lastUpdate = now
  result.message = message
  result.showPercentage = true
  result.showTime = false
  result.maxValue = 0

proc updateProgress*(bar: ProgressBar, current: int, message: string = "") =
  ## Update progress bar with new current value, ensuring it doesn't exceed total
  bar.current = min(current, bar.total)
  if bar.current > bar.maxValue:
    bar.maxValue = bar.current
  if message.len > 0:
    bar.message = message
  bar.lastUpdate = getTime()

proc renderMinimalBar(bar: ProgressBar): string =
  ## Render a minimal progress bar
  let percentage = if bar.total > 0: (bar.current.float / bar.total.float) * 100.0 else: 0.0
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
  let barStr = "█".repeat(filled) & "░".repeat(bar.width - filled)
  let percentStr = if bar.showPercentage: &" {percentage:.1f}%" else: ""
  let timeStr = if bar.showTime:
    let elapsed = (bar.lastUpdate - bar.startTime).inMilliseconds.float / 1000.0
    &" {elapsed:.1f}s"
  else: ""
  let msgStr = if bar.message.len > 0: &" {bar.message}" else: ""
  result = &"[{barStr}]{percentStr}{timeStr}{msgStr}"

proc renderGlobeBar(bar: ProgressBar): string =
  ## Render a globe-like rotating progress bar
  let percentage = if bar.total > 0: (bar.current.float / bar.total.float) * 100.0 else: 0.0
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
  let barStr = "●".repeat(filled) & "○".repeat(bar.width - filled)
  let percentStr = if bar.showPercentage: &" {percentage:.1f}%" else: ""
  let timeStr = if bar.showTime:
    let elapsed = (bar.lastUpdate - bar.startTime).inMilliseconds.float / 1000.0
    &" {elapsed:.1f}s"
  else: ""
  let msgStr = if bar.message.len > 0: &" 🌍 {bar.message}" else: " 🌍"
  result = &"[{barStr}]{percentStr}{timeStr}{msgStr}"

proc renderPulseBar(bar: ProgressBar): string =
  ## Render a pulsing progress bar
  let percentage = if bar.total > 0: (bar.current.float / bar.total.float) * 100.0 else: 0.0
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
  let pulseIndex = int(bar.lastUpdate.toUnix().int * 10) mod 10
  let pulseChar = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"][pulseIndex]
  let barStr = pulseChar.repeat(filled) & "░".repeat(bar.width - filled)
  let percentStr = if bar.showPercentage: &" {percentage:.1f}%" else: ""
  let timeStr = if bar.showTime:
    let elapsed = (bar.lastUpdate - bar.startTime).inMilliseconds.float / 1000.0
    &" {elapsed:.1f}s"
  else: ""
  let msgStr = if bar.message.len > 0: &" {bar.message}" else: ""
  result = &"[{barStr}]{percentStr}{timeStr}{msgStr}"

proc renderDotsBar(bar: ProgressBar): string =
  ## Render animated dots progress bar
  let percentage = if bar.total > 0: (bar.current.float / bar.total.float) * 100.0 else: 0.0
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
  let dots = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  let dotIndex = int(bar.lastUpdate.toUnix().int * 2) mod dots.len
  let dotChar = dots[dotIndex]
  let barStr = dotChar.repeat(filled) & "·".repeat(bar.width - filled)
  let percentStr = if bar.showPercentage: &" {percentage:.1f}%" else: ""
  let timeStr = if bar.showTime:
    let elapsed = (bar.lastUpdate - bar.startTime).inMilliseconds.float / 1000.0
    &" {elapsed:.1f}s"
  else: ""
  let msgStr = if bar.message.len > 0: &" {bar.message}" else: ""
  result = &"[{barStr}]{percentStr}{timeStr}{msgStr}"

proc renderBlocksBar(bar: ProgressBar): string =
  ## Render Unicode block characters progress bar
  let percentage = if bar.total > 0: (bar.current.float / bar.total.float) * 100.0 else: 0.0
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
  var barStr = ""
  for i in 0..<bar.width:
    if i < filled:
      barStr &= "█"
    else:
      barStr &= "░"
  let percentStr = if bar.showPercentage: &" {percentage:.1f}%" else: ""
  let timeStr = if bar.showTime:
    let elapsed = (bar.lastUpdate - bar.startTime).inMilliseconds.float / 1000.0
    &" {elapsed:.1f}s"
  else: ""
  let msgStr = if bar.message.len > 0: &" {bar.message}" else: ""
  result = &"[{barStr}]{percentStr}{timeStr}{msgStr}"

proc render*(bar: ProgressBar): string =
  ## Render the progress bar based on its style
  case bar.style:
    of pbsMinimal: renderMinimalBar(bar)
    of pbsGlobe: renderGlobeBar(bar)
    of pbsPulse: renderPulseBar(bar)
    of pbsDots: renderDotsBar(bar)
    of pbsBlocks: renderBlocksBar(bar)

proc display*(bar: ProgressBar) =
  ## Display the progress bar (clears line and prints)
  stdout.write("\r" & bar.render())
  stdout.flushFile()

proc finish*(bar: ProgressBar, message: string = "Complete!") =
  ## Finish the progress bar by setting to 100% and displaying
  bar.current = bar.total
  bar.message = message
  bar.display()
  echo ""  # New line

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
  result.config["PROJECT_NAME"] = PROJECT_NAME
  result.config["PROJECT_DISPLAY_NAME"] = PROJECT_DISPLAY_NAME
  result.config["TEST_SUITE_VERSION"] = TEST_SUITE_VERSION

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
  outputLines.add("│ Project: " & alignLeft(PROJECT_DISPLAY_NAME, projectWidth) & " │")
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
      "project": PROJECT_DISPLAY_NAME,
      "version": TEST_SUITE_VERSION,
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
  result &= &"**Project:** {PROJECT_DISPLAY_NAME}\n\n"
  result &= &"**Version:** {TEST_SUITE_VERSION}\n\n"
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

proc runTestsWithProgress*(testSuites: seq[tuple[name: string, testProc: proc()]], style: ProgressBarStyle = pbsGlobe): TestSuiteReport =
  ## Run test suites with progress bar display and proper error handling
  var report = newTestSuiteReport("Progress Test Suite")
  if testSuites.len == 0:
    echo "No tests to run"
    return report
  
  let progressBar = newProgressBar(style, total = testSuites.len, message = "Running tests...")
  
  echo "🚀 Starting test execution..."
  echo ""
  
  for i, (suiteName, testProc) in testSuites:
    progressBar.updateProgress(i, &"Running {suiteName}...")
    progressBar.display()
    
    let startTime = getTime()
    var passed = true
    var message = ""
    
    try:
      testProc()
    except Exception as e:
      passed = false
      message = e.msg
    except:
      passed = false
      message = "Unknown error occurred"
    
    let duration = (getTime() - startTime).inMilliseconds.float / 1000.0
    let testResult = newTestResult(suiteName, passed, duration, message, "suite")
    addResult(report, testResult)
    
    # Small delay for visual effect (only during debugging, remove in production)
    # sleep(100)
  
  progressBar.finish("All tests completed!")
  finish(report)
  
  return report

# Export all public symbols
export
  TestSuiteResult,
  TestSuiteReport,
  ReportFormat,
  ProgressBarStyle,
  SortCriteria,
  TimeFormat,
  newProgressBar,
  updateProgress,
  render,
  display,
  finish,
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