## Basic nimtest example demonstrating core functionality
import nimtest
import std/unittest

suite "Basic nimtest Framework Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "TestContext resource management":
    let tempDir = ctx.createTempTestDir("basic_test")
    let tempFile = createTestFile(ctx, tempDir, "test.txt", "Hello, nimtest!")

    # Verify resources were created
    assertDirExists(tempDir)
    assertFileExists(tempFile)
    assertFileContains(tempFile, "Hello, nimtest!")

    # Resources will be automatically cleaned up in teardown

  test "File system assertions":
    let tempDir = ctx.createTempTestDir("assertion_test")
    let testFile = createTestFile(ctx, tempDir, "data.json", """{"test": true, "value": 42}""")

    # Test various assertions
    assertFileExists(testFile)
    assertFileContains(testFile, "test")
    assertFileContains(testFile, "42")
    assertFileHasSize(testFile, 25)  # Exact size of the JSON content

  test "Cross-platform path handling":
    let tempDir = ctx.createTempTestDir("path_test")
    let subDir = tempDir / "subdir" / "nested"
    let testFile = createTestFile(ctx, subDir, "path_test.txt", "Path test content")

    # Use forward slashes - nimtest handles platform conversion
    assertDirExists(subDir)
    assertFileExists(testFile)
    assertFileContains(testFile, "Path test content")

  test "Performance measurement":
    let tempDir = ctx.createTempTestDir("perf_test")
    let largeFile = createTestFile(ctx, tempDir, "large.txt", "x".repeat(10000))

    # Measure file processing time
    measureTime("file processing test"):
      let content = readFile(largeFile)
      let processed = content.toUpperAscii()
      let outputFile = largeFile & ".processed"
      writeFile(outputFile, processed)

    # Verify processing worked
    assertFileExists(largeFile & ".processed")
    assertFileContains(largeFile & ".processed", "XXXXXXXXXX")

when isMainModule:
  echo "Running basic nimtest examples..."
  runTests()