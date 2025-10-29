## Quick script to fix test files to use proper registry API
import std/[os, strutils]

proc fixFile(path: string) =
  if not fileExists(path):
    return

  var content = readFile(path)
  let original = content

  # Fix .components.len to .getTotalComponentCount()
  content = content.replace("reg.components.len", "reg.getTotalComponentCount()")
  content = content.replace("registry.components.len", "registry.getTotalComponentCount()")

  # Fix direct table access patterns
  content = content.replace("check \"test_button\" in reg.components",
                           "try:\n      discard reg.getComponent(\"test_button\")\n      check true\n    except KeyError:\n      check false")

  # Fix category access from catLayouts to catLayout
  content = content.replace("catLayouts", "catLayout")

  # Fix getComponentsByCategory calls
  if "reg.getComponentsByCategory(catUI)" in content:
    content = content.replace("let uiComps = reg.getComponentsByCategory(catUI)",
                             "let allByCategory = reg.getComponentsByCategory()\n    let uiComps = allByCategory[catUI]")

  if content != original:
    writeFile(path, content)
    echo "Fixed: ", path

# Fix all test files
for file in walkFiles("tests/core/*.nim"):
  fixFile(file)

for file in walkFiles("tests/cli/*.nim"):
  fixFile(file)

echo "Done!"
