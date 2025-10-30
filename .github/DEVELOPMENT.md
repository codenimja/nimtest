# nimtest Development Guidelines

This document provides comprehensive guidelines and best practices for developers working on the nimtest testing framework. nimtest is a modular testing framework for Nim projects with automatic resource management and multiple reporting formats.

## Contributor Roles & Responsibilities

### 1. Test Developer
**Purpose**: Creates and maintains test suites using nimtest patterns

**Key Responsibilities**:
- Generate unit, integration, and CLI tests
- Implement TestContext patterns for resource management
- Create component metadata and file generation tests
- Follow nimtest conventions and anti-patterns

**Development Focus**:
- TestContext setup/teardown
- CLI command testing
- File system assertions
- Component metadata testing

**Guidelines**:
- Always use TestContext for temporary resources
- Never create files manually in tests
- Follow nimtest/test_config.nim settings
- Include both success and failure test cases

### 2. Framework Developer
**Purpose**: Extends nimtest with new utilities and features

**Key Responsibilities**:
- Add new assertion utilities
- Create specialized testing helpers
- Extend reporting formats
- Maintain backward compatibility

**Development Focus**:
- Core utility development
- Assertion library expansion
- Reporting system enhancements
- API design and maintenance

**Guidelines**:
- Maintain pure Nim stdlib dependencies
- Ensure cross-platform compatibility
- Follow existing code patterns
- Include comprehensive documentation

### 3. Documentation Specialist
**Purpose**: Maintains and improves nimtest documentation

**Key Responsibilities**:
- Update API documentation
- Create usage examples
- Maintain best practices guides
- Generate comprehensive READMEs

**Development Focus**:
- API documentation format
- Example code structure
- Cross-references to source
- Usage pattern documentation

**Guidelines**:
- Reference actual code examples
- Include working Nim code in all docs
- Maintain consistent formatting
- Update docs with new features

### 4. Quality Assurance Developer
**Purpose**: Ensures code quality and testing standards

**Key Responsibilities**:
- Review test coverage and effectiveness
- Validate framework patterns
- Check for anti-patterns
- Ensure cross-platform compatibility

**Development Focus**:
- Test coverage analysis
- Pattern validation
- Cross-platform testing
- Performance benchmarking

**Guidelines**:
- Enforce TestContext usage
- Validate resource cleanup
- Check CLI binary compatibility
- Maintain high test coverage standards

### 5. CI/CD Developer
**Purpose**: Manages automated testing and deployment pipelines

**Key Responsibilities**:
- Create and maintain GitHub Actions workflows
- Set up cross-platform testing
- Implement release automation
- Integrate security scanning

**Development Focus**:
- GitHub Actions workflow creation
- Cross-platform testing setup
- Release automation
- Security scanning integration

**Guidelines**:
- Must support Linux, macOS, Windows
- Include performance regression detection
- Implement security scanning
- Automate dependency updates

### 6. Security Developer
**Purpose**: Ensures nimtest and projects using it are secure

**Key Responsibilities**:
- Implement CodeQL security scanning
- Conduct dependency vulnerability assessments
- Establish secure coding practices
- Perform input validation testing

**Development Focus**:
- CodeQL integration
- Dependency vulnerability scanning
- Secure coding practices
- Input validation testing

**Guidelines**:
- Never expose secrets in test code
- Validate all external command execution
- Implement proper file permission handling
- Regular security audits

### 7. Performance Developer
**Purpose**: Optimizes nimtest performance and memory usage

**Key Responsibilities**:
- Create and analyze benchmarks
- Detect memory leaks
- Optimize resource cleanup
- Ensure cross-platform performance

**Development Focus**:
- Benchmark creation and analysis
- Memory leak detection
- Resource cleanup optimization
- Cross-platform performance testing

**Guidelines**:
- Minimize framework overhead
- Optimize temporary file operations
- Reduce memory footprint
- Maintain backward compatibility

## VS Code Development Tasks

Create `.vscode/tasks.json` with the following tasks for streamlined development:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "nimtest: analyze codebase",
      "type": "shell",
      "command": "find",
      "args": ["src", "examples", "-name", "*.nim", "-exec", "grep", "-l", "TestContext", "{}", ";"],
      "group": "build"
    },
    {
      "label": "nimtest: validate patterns",
      "type": "shell",
      "command": "nim",
      "args": ["c", "-r", "examples/core/test_registry_init.nim"],
      "group": "test"
    },
    {
      "label": "nimtest: check documentation",
      "type": "shell",
      "command": "find",
      "args": ["docs", "-name", "*.md", "-exec", "grep", "-l", "```nim", "{}", ";"],
      "group": "build"
    },
    {
      "label": "nimtest: performance baseline",
      "type": "shell",
      "command": "nim",
      "args": ["c", "-r", "examples/performance/test_performance_registry.nim"],
      "group": "test"
    }
  ]
}
```

## Code Snippets

Create `.vscode/nimtest.code-snippets` for common patterns:

```json
{
  "nimtest_suite": {
    "prefix": "nimtest_suite",
    "body": [
      "import nimtest",
      "import std/unittest",
      "",
      "suite \"${1:Feature} Tests\":",
      "  var ctx: TestContext",
      "",
      "  setup:",
      "    ctx = createTestContext()",
      "",
      "  teardown:",
      "    ctx.cleanup()",
      "",
      "  test \"${2:specific behavior}\":",
      "    ${0:# test logic}"
    ],
  }
}
```

## Progress Bars & Loading Indicators

nimtest includes subtle badass progress bars inspired by Omarchy's globe-loading aesthetic. Perfect for test execution feedback without stealing the show.

### Available Progress Bar Styles

- **`pbsMinimal`**: Clean bar with Unicode block characters
- **`pbsGlobe`**: Earth-like progress with ●/○ and 🌍 emoji (Omarchy-inspired)
- **`pbsPulse`**: Breathing animation with Braille characters
- **`pbsDots`**: Animated rotating dots
- **`pbsBlocks`**: Solid Unicode blocks

### Usage Example

```nim
import nimtest/reporting

# Create and display a globe-style progress bar
let bar = newProgressBar(pbsGlobe, width = 30, total = 100, message = "Running tests...")
bar.showTime = true

for i in 0..100:
  bar.updateProgress(i, &"Processing test {i}/100")
  bar.display()
  sleep(50)  # Simulate work

bar.finish("All tests completed!")
```

### Test Runner Integration

```nim
# Run test suites with progress display
let testSuites = @[
  ("Core Tests", proc() = runCoreTests()),
  ("CLI Tests", proc() = runCliTests()),
  ("Integration Tests", proc() = runIntegrationTests())
]

let report = runTestsWithProgress(testSuites, pbsGlobe)
generateConsoleReport(report)
```

See `examples/test_progress_demo.nim` for a complete working example of all progress bar styles.

## Testing Workflow Patterns

### Unit Test Workflow Pattern
**Purpose**: Standard unit test implementation with TestContext

**Steps**:
1. Import nimtest and std/unittest
2. Create TestContext in setup
3. Implement test logic with assertions
4. Cleanup resources in teardown

**Example**:
```nim
import nimtest
import std/unittest

suite "Calculator Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "addition works correctly":
    let tempFile = createTestFile(ctx, ctx.createTempTestDir("calc"), "input.txt", "2+2")
    # Test logic here
    assertFileContains(tempFile, "2+2")
```

### Integration Test Workflow Pattern
**Purpose**: End-to-end testing with external dependencies

**Steps**:
1. Set up test environment
2. Execute complete workflows
3. Validate final state
4. Clean up all resources

### CLI Test Workflow Pattern
**Purpose**: Command-line interface testing

**Steps**:
1. Configure CLI binary path in test_config.nim
2. Execute commands with runCliCommand()
3. Validate output and exit codes
4. Test both success and error scenarios

### Component Test Workflow Pattern
**Purpose**: UI component testing and validation

**Steps**:
1. Create component metadata
2. Generate test files
3. Validate file contents
4. Test component properties

## Quality Gates for Development

### Code Review Checklist
- [ ] TestContext usage validated
- [ ] Resource cleanup implemented
- [ ] Cross-platform compatibility checked
- [ ] Documentation updated
- [ ] Performance impact assessed

### Pre-commit Quality Gates
- [ ] All tests pass
- [ ] No linting errors
- [ ] Documentation builds
- [ ] Cross-platform validation

### Release Quality Gates
- [ ] Performance benchmarks pass
- [ ] Security scanning clean
- [ ] All examples functional
- [ ] Documentation complete

## Development Best Practices

### Code Quality Standards
- **Always use TestContext** for temporary resources
- **Validate both success and failure paths** in tests
- **Include cleanup verification** in teardown blocks
- **Use descriptive test names** that explain behavior
- **Test cross-platform compatibility** where applicable

### Documentation Standards
- **Include working code examples** in all documentation
- **Reference actual implementation files** in guides
- **Provide migration examples** for breaking changes
- **Document performance characteristics** of utilities

### Maintenance Practices
- **Regular dependency updates** via CI/CD
- **Security scanning** with automated tools
- **Performance regression testing** in CI pipeline
- **Cross-platform testing** on all major operating systems

## Communication Templates

### Issue Reporting Template
```
**Issue Type**: [Bug/Feature/Question]
**Component**: [core/cli/ui/docs]
**Description**:
**Expected Behavior**:
**Actual Behavior**:
**Steps to Reproduce**:
**Environment**: [OS, Nim version]
```

### Pull Request Template
```
**Type of Change**: [feature/bugfix/documentation/refactor]
**Components Affected**: [list]
**Description**:
**Testing Performed**:
**Breaking Changes**: [yes/no]
**Documentation Updated**: [yes/no]
```

## Development Workflow

### Feature Development Process
1. **Planning**: Create issue with detailed requirements
2. **Implementation**: Follow TestContext patterns
3. **Testing**: Comprehensive test coverage
4. **Documentation**: Update all relevant docs
5. **Review**: Code review and testing validation
6. **Merge**: Squash merge with descriptive commit

### Bug Fix Process
1. **Reproduction**: Create failing test case
2. **Root Cause**: Identify and fix the issue
3. **Regression Testing**: Ensure no new failures
4. **Documentation**: Update if behavior changed
5. **Verification**: All tests pass

## Quality Improvement Guidelines

### Continuous Learning
- **Stay updated** with Nim language developments
- **Review test failures** for pattern improvements
- **Share learnings** with other developers
- **Contribute back** to nimtest framework

### Performance Optimization
- **Profile before optimizing** - measure don't guess
- **Focus on bottlenecks** - 80/20 rule applies
- **Maintain backward compatibility** - no breaking changes
- **Document performance characteristics** - help users understand

### Security Considerations
- **Never expose secrets** in test code or examples
- **Validate all inputs** - especially file paths and commands
- **Use safe defaults** - fail securely by default
- **Regular security audits** - scheduled reviews
