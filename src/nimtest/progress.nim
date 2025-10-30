## Progress bar utilities - Nim Test Framework
## Module for progress bars with optimization

import std/[times, strformat, strutils]

type
  ProgressBarStyle* = enum
    ## Different visual styles for progress bars
    pbsMinimal,      ## Simple bar with percentage
    pbsGlobe,        ## Globe-like rotating progress
    pbsPulse,        ## Pulsing bar with subtle animation
    pbsDots,         ## Animated dots
    pbsBlocks        ## Unicode block characters

  ProgressBar* = ref object
    ## Represents a progress bar visual element
    style*: ProgressBarStyle
    width*: int           ## Width of the progress bar in characters
    current*: int         ## Current progress value
    total*: int           ## Total value representing 100% completion
    startTime*: Time      ## When progress tracking started
    lastUpdate*: Time     ## Last time the progress was updated (for optimization)
    message*: string      ## Message to display with the progress bar
    showPercentage*: bool ## Whether to show percentage completion
    showTime*: bool       ## Whether to show elapsed time
    maxValue*: int        ## Track the maximum value reached

proc newProgressBar*(style: ProgressBarStyle = pbsMinimal, width: int = 40, total: int = 100, message: string = ""): ProgressBar =
  ## Create a new progress bar with validation
  if width <= 0:
    raise newException(ValueError, "ProgressBar width must be positive")
  if total <= 0:
    raise newException(ValueError, "ProgressBar total must be positive")
  
  let now = getTime()
  new(result)
  result.style = style
  result.width = width
  result.current = 0
  result.total = total
  result.startTime = now
  result.lastUpdate = now
  result.message = message
  result.showPercentage = true
  result.showTime = false
  result.maxValue = 0

proc renderMinimalBar(bar: ProgressBar): string =
  ## Render a minimal progress bar
  let percentage = if bar.total > 0: (bar.current.float / bar.total.float) * 100.0 else: 0.0
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
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
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
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
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
  let pulseIndex = int(bar.lastUpdate.toUnix().int * 10) mod 10
  let pulseChar = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"][pulseIndex]
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
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
  let dots = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  let dotIndex = int(bar.lastUpdate.toUnix().int * 2) mod dots.len
  let dotChar = dots[dotIndex]
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
  let filled = if bar.total > 0: int((bar.current.float / bar.total.float) * bar.width.float) else: 0
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
  ## Display the progress bar (clears line and prints with optimization)
  stdout.write("\r" & render(bar))
  stdout.flushFile()

proc update*(bar: ProgressBar, current: int, msg = "") =
  ## Update progress bar with optimization to avoid spam - only update every 50ms
  let now = getTime()
  if (now - bar.lastUpdate).inMilliseconds > 50:  # Optimization from PDD
    bar.current = min(current, bar.total)
    if bar.current > bar.maxValue:
      bar.maxValue = bar.current
    if msg.len > 0:
      bar.message = msg
    bar.lastUpdate = now
    display(bar)

proc finish*(bar: ProgressBar, message: string = "Complete!") =
  ## Finish the progress bar by setting to 100% and displaying
  bar.current = bar.total
  bar.message = message
  display(bar)
  echo ""  # New line

# Export all public symbols
export
  ProgressBarStyle,
  ProgressBar,
  newProgressBar,
  update,
  render,
  display,
  finish