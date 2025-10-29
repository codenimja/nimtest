## Advanced reporting utilities for nimtest
## Provides comprehensive test reporting and analytics

import std/[json, times, strformat, sequtils, strutils, tables, os]
import helpers, test_config

const TimeFormat = "yyyy-MM-dd HH:mm:ss"

type
  TestSuiteResult* = ref object
    name*: string
    passed*: bool
    duration*: float
    message*: string
    timestamp*: Time
    category*: string
    tags*: seq[string]

  TestSuiteReport* = ref object
    name*: string
    startTime*: Time
    endTime*: Time
    results*: seq[TestSuiteResult]
    config*: Table[string, string]

  ReportFormat* = enum
    rfConsole,    # Human-readable console output
    rfJson,       # JSON format
    rfJunit,      # JUnit XML format
    rfMarkdown    # Markdown format

  ProgressBarStyle* = enum
    pbsMinimal,      # Simple bar with percentage
    pbsGlobe,        # Globe-like rotating progress
    pbsPulse,        # Pulsing bar with subtle animation
    pbsDots,         # Animated dots
    pbsBlocks        # Unicode block characters

  ProgressBar* = ref object
    style*: ProgressBarStyle
    width*: int
    current*: int
    total*: int
    startTime*: Time
    lastUpdate*: Time
    message*: string
    showPercentage*: bool
    showTime*: bool

proc newProgressBar*(style: ProgressBarStyle = pbsMinimal, width: int = 40, total: int = 100, message: string = ""): ProgressBar =
  ## Create a new progress bar
  let now = getTime()
  result = ProgressBar(
    style: style,
    width: width,
    current: 0,
    total: total,
    startTime: now,
    lastUpdate: now,
    message: message,
    showPercentage: true,
    showTime: false
  )

proc updateProgress*(bar: ProgressBar, current: int, message: string = "") =
  ## Update progress bar with new current value
  bar.current = current
  if message.len > 0:
    bar.message = message
  bar.lastUpdate = getTime()

proc renderMinimalBar(bar: ProgressBar): string =
  ## Render a minimal progress bar
  let percentage = if bar.total > 0: (bar.current.float / bar.total.float) * 100.0 else: 0.0
  let filled = int((bar.current.float / bar.total.float) * bar.width.float)
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
  let filled = int((bar.current.float / bar.total.float) * bar.width.float)
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
  let filled = int((bar.current.float / bar.total.float) * bar.width.float)
  let pulseChar = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"][int(getTime().toUnixFloat * 10) mod 10]
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
  let dots = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  let dotIndex = int(getTime().toUnixFloat * 2) mod dots.len
  let dotChar = dots[dotIndex]
  let filled = int((bar.current.float / bar.total.float) * bar.width.float)
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
  let filled = int((bar.current.float / bar.total.float) * bar.width.float)
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
  ## Finish the progress bar
  bar.current = bar.total
  bar.message = message
  bar.display()
  echo ""  # New line

proc newTestResult*(name: string, passed: bool, duration: float, message: string = "", category: string = "general"): TestSuiteResult =
  ## Create a new test result
  result = TestSuiteResult(
    name: name,
    passed: passed,
    duration: duration,
    message: message,
    timestamp: getTime(),
    category: category,
    tags: @[]
  )

proc newTestSuiteReport*(name: string): TestSuiteReport =
  ## Create a new test suite report
  result = TestSuiteReport(
    name: name,
    startTime: getTime(),
    results: @[],
    config: initTable[string, string]()
  )
  result.config["PROJECT_NAME"] = PROJECT_NAME
  result.config["PROJECT_DISPLAY_NAME"] = PROJECT_DISPLAY_NAME
  result.config["TEST_SUITE_VERSION"] = TEST_SUITE_VERSION

proc addResult*(report: var TestSuiteReport, result: TestSuiteResult) =
  ## Add a test result to the report
  report.results.add(result)

proc addResults*(report: var TestSuiteReport, results: seq[TestSuiteResult]) =
  ## Add multiple test results to the report
  report.results.add(results)

proc finish*(report: var TestSuiteReport) =
  ## Mark the report as finished
  report.endTime = getTime()

proc getDuration*(report: TestSuiteReport): float =
  ## Get total duration of the test suite
  result = (report.endTime - report.startTime).inNanoseconds.float / 1_000_000_000.0

proc getPassedCount*(report: TestSuiteReport): int =
  ## Get number of passed tests
  result = report.results.filterIt(it.passed).len

proc getFailedCount*(report: TestSuiteReport): int =
  ## Get number of failed tests
  result = report.results.len - getPassedCount(report)

proc getPassRate*(report: TestSuiteReport): float =
  ## Get pass rate as percentage
  if report.results.len == 0: return 0.0
  result = (getPassedCount(report).float / report.results.len.float) * 100.0

proc generateConsoleReport*(report: TestSuiteReport) =
  ## Generate human-readable console report
  echo ""
  echo "┌─────────────────────────────────────────────────────────┐"
  echo "│                    TEST SUITE REPORT                    │"
  echo "├─────────────────────────────────────────────────────────┤"
  
  # Calculate consistent widths for proper alignment
  let contentWidth = 57  # Total width minus borders (59 - 2)
  let suiteWidth = contentWidth - 7  # "Suite: " is 7 chars
  let projectWidth = contentWidth - 9  # "Project: " is 9 chars
  let startedWidth = contentWidth - 9  # "Started: " is 9 chars
  let durationWidth = contentWidth - 10  # "Duration: " is 10 chars
  let resultsWidth = contentWidth - 9  # "Results: " is 9 chars
  let passRateWidth = contentWidth - 11  # "Pass Rate: " is 11 chars
  let statusWidth = contentWidth - 7  # "✓ PASS " is 7 chars
  let reasonWidth = contentWidth - 10  # "   Reason: " is 10 chars
  
  # Format each line with consistent width using string concatenation
  let suiteLine = "│ Suite: " & alignLeft(report.name, suiteWidth) & " │"
  echo suiteLine
  
  let projectLine = "│ Project: " & alignLeft(PROJECT_DISPLAY_NAME, projectWidth) & " │"
  echo projectLine
  
  let startedLine = "│ Started: " & alignLeft(report.startTime.format(TimeFormat), startedWidth) & " │"
  echo startedLine
  
  let durationStr = formatFloat(report.getDuration(), ffDecimal, 2) & "s"
  let durationLine = "│ Duration: " & alignLeft(durationStr, durationWidth) & " │"
  echo durationLine
  
  echo "├─────────────────────────────────────────────────────────┤"
  
  let passed = getPassedCount(report)
  let failed = getFailedCount(report)
  let total = report.results.len
  let passRate = getPassRate(report)
  
  let resultsStr = &"{passed} passed, {failed} failed, {total} total"
  let resultsLine = "│ Results: " & alignLeft(resultsStr, resultsWidth) & " │"
  echo resultsLine
  
  let passRateStr = formatFloat(passRate, ffDecimal, 1) & "%"
  let passRateLine = "│ Pass Rate: " & alignLeft(passRateStr, passRateWidth) & " │"
  echo passRateLine
  
  echo "├─────────────────────────────────────────────────────────┤"
  
  for result in report.results:
    let status = if result.passed: "✓ PASS" else: "✗ FAIL"
    let statusLine = "│ " & status & " " & alignLeft(result.name, statusWidth) & " │"
    echo statusLine
    if not result.passed and result.message.len > 0:
      let reasonLine = "│   Reason: " & alignLeft(result.message, reasonWidth) & " │"
      echo reasonLine
  
  echo "└─────────────────────────────────────────────────────────┘"
  echo ""

proc generateJsonReport*(report: TestSuiteReport): string =
  ## Generate JSON report
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
      "passed": getPassedCount(report),
      "failed": getFailedCount(report),
      "passRate": getPassRate(report)
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
      "category": result.category
    }
    reportJson{"results"}.add(resultJson)

  result = $reportJson

proc generateJunitReport*(report: TestSuiteReport): string =
  ## Generate JUnit XML report
  var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  xml &= &"<testsuite name=\"{report.name}\" tests=\"{report.results.len}\" failures=\"{getFailedCount(report)}\" time=\"{report.getDuration()}\">\n"
  
  for testResult in report.results:
    xml &= &"  <testcase name=\"{testResult.name}\" time=\"{testResult.duration}\">\n"
    if not testResult.passed:
      xml &= &"    <failure message=\"{testResult.message}\">FAILED</failure>\n"
    xml &= "  </testcase>\n"
  
  xml &= "</testsuite>\n"
  result = xml

proc generateMarkdownReport*(report: TestSuiteReport): string =
  ## Generate Markdown report
  result = "# Test Suite Report\n\n"
  result &= &"**Suite:** {report.name}\n\n"
  result &= &"**Project:** {PROJECT_DISPLAY_NAME}\n\n"
  result &= &"**Version:** {TEST_SUITE_VERSION}\n\n"
  result &= &"**Started:** {report.startTime.format(TimeFormat)}\n\n"
  result &= &"**Duration:** {formatFloat(report.getDuration(), ffDecimal, 2)} seconds\n\n"
  
  let passed = getPassedCount(report)
  let failed = getFailedCount(report)
  let total = report.results.len
  let passRate = getPassRate(report)
  
  result &= "## Summary\n\n"
  result &= &"- Total Tests: {total}\n"
  result &= &"- Passed: {passed}\n"
  result &= &"- Failed: {failed}\n"
  result &= &"- Pass Rate: {formatFloat(passRate, ffDecimal, 1)}%\n\n"
  
  result &= "## Test Results\n\n"
  result &= "| Status | Test Name | Duration (s) | Message |\n"
  result &= "|--------|-----------|--------------|---------|\n"
  
  for resultItem in report.results:
    let status = if resultItem.passed: "✓" else: "✗"
    let duration = formatFloat(resultItem.duration, ffDecimal, 4)
    let message = if resultItem.message.len > 0: resultItem.message else: "Success"
    result &= &"| {status} | {resultItem.name} | {duration} | {message} |\n"

proc saveReport*(report: TestSuiteReport, format: ReportFormat, filename: string = ""): string =
  ## Save report in specified format to file
  let reportContent = case format:
    of rfConsole: generateConsoleReport(report); ""
    of rfJson: generateJsonReport(report)
    of rfJunit: generateJunitReport(report)
    of rfMarkdown: generateMarkdownReport(report)
  
  let actualFilename = if filename == "":
    case format:
      of rfJson: "test_report.json"
      of rfJunit: "test_report.xml"
      of rfMarkdown: "test_report.md"
      else: "test_report.txt"
  else:
    filename
  
  writeFile(actualFilename, reportContent)
  return actualFilename

proc printSummary*(report: TestSuiteReport) =
  ## Print a simple summary to console
  let passed = getPassedCount(report)
  let failed = getFailedCount(report)
  let total = report.results.len
  let passRate = getPassRate(report)
  let duration = formatFloat(report.getDuration(), ffDecimal, 2)
  
  echo &"\nTest Summary: {passed}/{total} passed ({passRate:.1f}%) in {duration}s"
  if failed > 0:
    echo &"Failed tests: {failed}"

proc runTestsWithProgress*(testSuites: seq[tuple[name: string, testProc: proc()]], style: ProgressBarStyle = pbsGlobe): TestSuiteReport =
  ## Run test suites with progress bar display
  let report = newTestSuiteReport("Progress Test Suite")
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
    
    let duration = (getTime() - startTime).inMilliseconds.float / 1000.0
    let result = newTestResult(suiteName, passed, duration, message, "suite")
    report.results.add(result)
    
    # Small delay for visual effect
    sleep(100)
  
  progressBar.finish("All tests completed!")
  report.endTime = getTime()
  
  return report