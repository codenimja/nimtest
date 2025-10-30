# src/nimtest/config.nim

const
  DefaultProjectName* = "unknown"
  DefaultTempPrefix* = "nimtest_temp"

var
  ProjectName* {.threadvar.}: string
  TempDirPrefix* {.threadvar.}: string

proc initConfig*() =
  ProjectName = DefaultProjectName
  TempDirPrefix = DefaultTempPrefix

initConfig()  # auto-init