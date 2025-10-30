import nimtest/api

var ctx = createTestContext()
try:
  let f = createTestFile(ctx, createTempTestDir(ctx), "x.txt", "hi")
  discard assertFileContains(f, "hi")
finally:
  ctx.cleanup()