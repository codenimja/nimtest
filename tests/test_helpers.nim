import ../src/nimtest/api
import std/[unittest, os]

suite "nimtest helpers":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "assert file not exists":
    let tempDir = ctx.createTempTestDir("helpers")
    let missingFile = tempDir / "does_not_exist.txt"
    check assertFileNotExists(missingFile)

  test "assert file has size":
    let tempDir = ctx.createTempTestDir("helpers")
    let testFile = ctx.createTestFile(tempDir, "size_test.txt", "12345")
    check assertFileHasSize(testFile, 5)

  test "benchmark functionality":
    let result = benchmark("test operation", 10):
      proc() = discard 1 + 1
    check result.avg > 0
    check result.total > 0