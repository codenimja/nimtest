## Fix all test compilation errors
import std/[os, strutils]

proc fixFile(path: string) =
  if not fileExists(path):
    return

  var content = readFile(path)
  let original = content

  # Fix strformat import - add where missing
  if "import std/[unittest" in content and "strformat" notin content:
    content = content.replace(
      "import std/[unittest",
      "import std/[unittest, strformat"
    )

  # Fix null to newJNull()
  content = content.replace(": null,", ": newJNull(),")
  content = content.replace(": null", ": newJNull()")

  # Fix getComponentsByCategory calls - remove catUI parameter
  content = content.replace(
    "getComponentsByCategory(emptyReg, catUI)",
    "getComponentsByCategory(emptyReg)[catUI]"
  )
  content = content.replace(
    "getComponentsByCategory(reg, catUI)",
    "getComponentsByCategory(reg)[catUI]"
  )

  if content != original:
    writeFile(path, content)
    echo "Fixed: ", path

# Fix all test files
for file in walkDirRec("tests"):
  if file.endsWith(".nim") and "test_" in file:
    fixFile(file)

echo "Done!"
