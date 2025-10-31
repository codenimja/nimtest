# nimtest Roadmap 2026: From Testing Framework to Testing Empire

> **Pragmatic, Nim-idiomatic roadmap for 2026 domination. Prioritized by impact: what ships fast, delights users, and crushes competitors.**

## Vision

Make nimtest the drop-in upgrade for unittest users, while stealing Testament's thunder for advanced folks. Stars will explode. Again.

**Goal**: 500+ stars, 50+ contributors, stdlib consideration by Araq.

---

## Milestone 1: Foundations (Q1 2026) — "Polish the Blade"

**Focus**: Usability spikes. Get devs hooked with zero-friction wins.  
**Timeline**: 4-6 weeks (crowdsource via Nim forum)  
**Target**: v1.1 release, 100+ stars

### 🔥 High Priority Features

#### Macro DSL for Tests
**Description**: `suite "Files": test "exists": check fileExists(tempFile)` — auto-discovery, nesting, setup/teardown hooks. Integrates with existing TestContext.

**Why It Slaps**: Unittest2's "collect" mode proves two-phase discovery cuts boilerplate by 50%; Reddit threads scream for it over manual reports. Nim's macros make this elegant, not clunky.

**Implementation Notes**:
- Use Nim's macro system for compile-time test collection
- Maintain compatibility with existing `nimtest/api` imports
- Auto-generate test runners with `suite` and `test` macros

#### CLI Runner Binary
**Description**: `nimtest --filter "bench*" --parallel --format junit` — auto-runs tests/*.nim, supports globs, skips, and Nimble integration.

**Why It Slaps**: Nimble's test is "fine," but devs want pytest-style discovery. Matches 2025 trends: fast, filterable runs under 2min.

**Implementation Notes**:
- Binary executable alongside library
- Pattern matching for test file discovery
- Command-line argument parsing with Nim's stdlib

### 🟡 Medium Priority Features

#### Enhanced Assertions
**Description**: Add `check eq(a, b)` with rich diffs, `notCompiles(expr)` for static checks, and `assertThrows(proc)` with type-safe expectations.

**Why It Slaps**: Stdlib unittest lacks compile-time tests; compiler suite uses `compiles` magic for this. Fixes "why did this fail?" rage—echoes einheit's diff magic.

**Implementation Notes**:
- Rich diff output for failed assertions
- Compile-time assertion macros
- Exception type checking in `assertThrows`

**Milestone Win**: v1.1 release. Promote via Nim Discord: "Ditch unittest boilerplate—try the DSL."

---

## Milestone 2: Power Tools (Q2 2026) — "Arm the Rebels"

**Focus**: Advanced flows for real-world pain (CLI, perf, isolation). Lean into Nim's async/threads for speed.  
**Timeline**: 8-10 weeks  
**Target**: v1.2 release, parallel execution blog post

### 🔥 High Priority Features

#### Parallel & Isolated Execution
**Description**: `--parallel` spawns threads/processes per test; full isolation like Testament (no shared state leaks).

**Why It Slaps**: Nim 2.2's threads are begging for this; unittest2 hints at "future parallel scheduling." Solves flaky shared-state hell in integration tests.

**Implementation Notes**:
- Thread/process spawning for test isolation
- Shared-nothing architecture
- Resource cleanup across parallel executions

### 🟡 Medium Priority Features

#### Async/Await Test Support
**Description**: `asyncTest "await dbQuery": await check dbResponds()` — hooks into Nim's asyncdispatch.

**Why It Slaps**: Nim's concurrency is a superpower (async/await since forever), but testing it? Crickets. Aligns with web/CLI growth in awesome-nim lists.

**Implementation Notes**:
- `asyncTest` macro for async test functions
- Integration with Nim's asyncdispatch
- Proper async cleanup and error handling

#### E2E/Integration Lanes
**Description**: Separate `--e2e` mode for async pipelines (non-blocking PRs); auto-randomize env vars for flakiness hunting.

**Why It Slaps**: Borrow from PlanetScale's wisdom: Unit for PRs, e2e on main for velocity. Nim's embedded bent (e.g., TinyML) needs robust integration.

**Implementation Notes**:
- Separate execution modes for unit vs integration
- Environment variable randomization
- Async pipeline support for E2E tests

**Milestone Win**: v1.2. Blog post: "Parallel nimtest: 5x faster suites, zero flakes." Eye stdlib merger—Araq's 2025 roadmap vibes with "rewrite in Nim."

---

## Milestone 3: Observability Overlords (Q3 2026) — "See All, Know All"

**Focus**: Reporting that doesn't suck. Visuals + analysis for the data-hoarding dev.  
**Timeline**: 10-12 weeks  
**Target**: v1.3 release, GitHub Action template

### 🔥 High Priority Features

#### Interactive HTML Reports
**Description**: Timelines, benchmark charts (via JS backend?), failure heatmaps. Export artifacts on flake.

**Why It Slaps**: Testament's HTML is gold; extend your Markdown/JUnit with Vitest-style workspaces for multi-test types. 2025 CI demands visuals—disk I/O bottlenecks scream for perf charts.

**Implementation Notes**:
- HTML report generation with interactive charts
- Timeline visualizations for test execution
- Failure analysis and heatmaps

### 🟡 Medium Priority Features

#### Coverage Integration
**Description**: Hooks for nimcov or built-in line tracing; flag untested branches in reports.

**Why It Slaps**: Awesome-nim gaps on coverage; stdlib lacks it natively. Ties into "runnableExamples" for docs.

**Implementation Notes**:
- Integration with nimcov tool
- Line-by-line coverage reporting
- Branch coverage analysis

### 🟢 Low Priority Features

#### Fuzzing Hooks
**Description**: `fuzzTest "parser": drchaosIntegration()` — property-based with generators.

**Why It Slaps**: Nim's drchaos is underrated; pair with benchmarks for "TinyML-proof" testing. Rebels love chaos.

**Implementation Notes**:
- Integration with drchaos fuzzing library
- Property-based test generation
- Fuzzing result integration into reports

**Milestone Win**: v1.3. GitHub Action template: "nimtest + coverage = your CI wet dream." Community poll: "What flakes you most?"

---

## Wild Cards: The Forbidden Tech (Q4 2026+) — "Because Why Not?"

**These are the "let's break Nim" ideas—high-reward, high-macro-fu. Pitch 'em on the forum for buy-in.**

### AI-Assisted Test Gen
**Hook into NVIDIA NIMs or local LLMs to auto-gen edge cases from code/docs.**  
*Why? DSPy-style optimization for prompts-as-tests. Nim's speed makes it feasible without cloud tax.*

### Compile-Time Fuzzing
**Macros that static fuzz at build-time—catch n>3 errors before runtime.**  
*Rebel move: "Testament for mortals."*

### Multi-Backend Magic
**JS/WASM test runs in-browser; cross-compile suites to C for embedded validation.**  
*Taps Nim's FFI superpowers.*

---

## Execution Blueprint: From Dream to Stars

### Timeline Strategy
- **Quarterly releases**: v1.1 (Q1), v1.2 (Q2), v1.3 (Q3)
- **NimConf 2026 demo**: Showcase parallel execution and HTML reports
- **GitHub Projects tracking**: Label issues "roadmap-q1", "roadmap-q2", etc.

### Community Fuel
- **Nim forum thread**: "nimtest v1.1: Vote your pains"
- **Reddit collation**: Gather "testing async is hell" complaints
- **Discord promotion**: "Ditch unittest boilerplate—try the DSL"

### Metrics of Glory
- **Stars**: 500+ target
- **Contributors**: 50+ target
- **Stdlib consideration**: If Araq emails back, pitch "nimtest as testutils"

### Risk Mitigation
- **Flaky e2e**: Mitigate with separate lanes and randomization
- **Over-scope**: Ship DSL first—it's 80% of the value
- **Community feedback**: Regular polls on forum for prioritization

### Success Criteria
- **v1.1**: 100+ stars, macro DSL adoption
- **v1.2**: Parallel execution blog post goes viral
- **v1.3**: HTML reports become the standard
- **2026 End**: Stdlib merger discussion with Araq

---

**nimtest 2026: From testing framework to testing empire. Let's make Nim's testing story unskippable.** 🚀</content>
<parameter name="filePath">/home/boonzy/dev/projects/contributing/nimtest/ROADMAP.md