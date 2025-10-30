import ../src/nimtest/api
import std/[unittest, os]

suite "nimtest core":
  test "temp dir cleanup":
    var ctx = createTestContext()
    let dir = createTempTestDir(ctx, "test")
    check dirExists(dir)
    cleanup(ctx)
    check not dirExists(dir)

  test "create and verify test file":
    var ctx = createTestContext()
    try:
      let testDir = createTempTestDir(ctx, "file_test")
      let testFile = createTestFile(ctx, testDir, "hello.txt", "Hello, Nimtest!")
      
      check fileExists(testFile)
      check assertFileContains(testFile, "Hello, Nimtest!")
    finally:
      cleanup(ctx)

  test "assert file contains functionality":
    var ctx = createTestContext()
    try:
      let testDir = createTempTestDir(ctx, "assert_test")
      let testFile = createTestFile(ctx, testDir, "content.txt", "This is a test content")
      
      check assertFileContains(testFile, "test content")
      check assertFileContainsFast(testFile, "This is a")
    finally:
      cleanup(ctx)