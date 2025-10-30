import ../src/nimtest/api
import std/unittest

suite "nimtest progress":
  test "create and update progress bar":
    var bar = newProgressBar(pbsMinimal, width = 20, total = 10)
    check bar.total == 10
    check bar.width == 20

    bar.current = 5  # Direct assignment for testing
    check bar.current == 5

  test "progress bar rendering":
    var bar = newProgressBar(pbsBlocks, width = 10, total = 10, message = "Loading")
    updateProgress(bar, 7)
    
    let rendered = render(bar)
    check rendered.len > 0

  # test "run tests with progress":
  #   proc quickTest() {.gcsafe.} = discard
  #   proc delayTest() {.gcsafe.} = discard
  #
  #   let report = runTestsWithProgress(@[
  #     ("quick test", quickTest),
  #     ("delay test", delayTest)
  #   ])
  #
  #   check report.results.len == 2
  #   check report.getPassedCount() == 2