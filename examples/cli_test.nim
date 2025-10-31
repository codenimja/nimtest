# CLI Testing Example
import ../src/nimtest/api

echo "CLI Testing Example"
echo "=================="

var ctx = createTestContext()
try:
  # Test nim --version command
  let (output, exitCode) = runCliCommand("nim --version")
  discard assertExitCode(exitCode, 0)
  discard assertOutputContains(output, "Nim Compiler")

  echo "✓ CLI testing works!"
  echo "Output preview: ", output[0..100], "..."

finally:
  ctx.cleanup()