# Contributing to nimtest

1. Fork & clone
2. `nimble test`
3. Open PR with clear title
4. Reference issues

# Install dependencies
nimble refresh
nimble install

# Build the framework
nim c src/nimtest.nim

# Run tests
nim c -r examples/test_all.nim
```

## Project Structure

```
nimtest/
├── src/nimtest/           # Core framework source
│   ├── api.nim           # Public API facade
│   ├── core.nim          # TestContext and basic utilities
│   ├── helpers.nim       # Advanced assertions and utilities
│   ├── reporting.nim     # Test reporting and analytics
│   ├── progress.nim      # Progress bar implementations
│   └── config.nim        # Configuration constants
├── examples/             # Example test implementations
│   ├── basic_test.nim    # Basic usage examples
│   ├── comprehensive_example.nim
│   └── test_basic.nim
├── docs/                # Documentation
├── tests/               # Framework tests
└── .github/            # GitHub configuration
```

## Development Workflow

### 1. Choose an Issue
- Check [GitHub Issues](https://github.com/yourusername/nimtest/issues) for open tasks
- Look for issues labeled `good first issue` or `help wanted`
- Comment on the issue to indicate you're working on it

### 2. Create a Branch
```bash
# Create and switch to a feature branch
git checkout -b feature/your-feature-name
# or for bug fixes
git checkout -b fix/issue-number-description
```

### 3. Make Changes
- Follow the [code style guidelines](#code-style)
- Write tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 4. Test Your Changes
```bash
# Run all tests
nim c -r examples/test_all.nim

# Run specific test suites
nim c -r examples/basic_test.nim
nim c -r examples/comprehensive_example.nim
```

### 5. Commit Your Changes
```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add new assertion function assertFileHasLineCount

- Add assertFileHasLineCount procedure to helpers.nim
- Include comprehensive tests in examples/
- Update API documentation
- Add usage examples in docs/EXAMPLES.md"
```

### 6. Push and Create Pull Request
```bash
# Push your branch
git push origin feature/your-feature-name

# Create a pull request on GitHub
# Fill out the PR template completely
```

## Testing Guidelines

### Test Organization
- **Unit Tests**: Test individual functions and procedures
- **Integration Tests**: Test component interactions
- **CLI Tests**: Test command-line interfaces
- **Performance Tests**: Benchmark and profile code

### Test Structure Pattern
```nim
import nimtest/api

suite "Feature Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "specific behavior":
    # Arrange
    let tempDir = ctx.createTempTestDir("test_name")
    let tempFile = createTestFile(ctx, tempDir, "file.txt", "content")

    # Act
    # ... perform operations

    # Assert
    discard assertFileExists(tempFile)
    discard assertFileContains(tempFile, "content")
```

### Test Coverage
- Aim for high test coverage of public APIs
- Test both success and failure scenarios
- Include edge cases and boundary conditions
- Test cross-platform compatibility

### Performance Testing
```nim
test "performance benchmark":
  let testData = createTestFile(ctx, tempDir, "large.txt", "x".repeat(100000))

  measureTime("data processing"):
    let content = readFile(testData)
    let processed = content.toUpperAscii()
    writeFile(testData & ".processed", processed)

  discard assertFileExists(testData & ".processed")
```

## Code Style

### Nim Style Guidelines
- Follow the [Nim Style Guide](https://nim-lang.org/docs/nep1.html)
- Use 2 spaces for indentation
- Use `camelCase` for variables and functions
- Use `PascalCase` for types
- Use `SCREAMING_CASE` for constants

### Naming Conventions
```nim
# Good
proc createTestContext(): TestContext
let tempFile = createTestFile(ctx, dir, "test.txt", "content")
const MAX_FILE_SIZE = 1024 * 1024

# Avoid
proc createtestcontext(): testcontext
let tempfile = createtestfile(ctx, dir, "test.txt", "content")
const maxfilesize = 1024 * 1024
```

### Code Organization
- Group related functionality together
- Use clear, descriptive names
- Add comments for complex logic
- Keep functions focused on single responsibilities

### Error Handling
- Use Nim's `doAssert` for test assertions
- Provide meaningful error messages
- Handle edge cases gracefully
- Document expected exceptions

## Documentation

### Documentation Standards
- All public APIs must be documented
- Include parameter descriptions and return values
- Provide usage examples
- Document limitations and edge cases

### API Documentation Example
```nim
## Creates a new test context for managing test resources
##
## This procedure initializes a TestContext that automatically tracks
## temporary files and directories for cleanup.
##
## Returns:
##   A new TestContext instance
##
## Example:
##   ```nim
##   var ctx = createTestContext()
##   defer: ctx.cleanup()
##   ```
proc createTestContext*(): TestContext
```

### Updating Documentation
- Update API docs when changing public interfaces
- Add examples for new features
- Keep cross-references current
- Test all code examples

## Submitting Changes

### Pull Request Guidelines
- Use the provided PR template
- Provide a clear description of changes
- Reference related issues
- Include before/after screenshots for UI changes
- Ensure CI checks pass

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

**Examples:**
```
feat: add assertFileHasLineCount assertion

Add a new assertion function to check file line counts.
Includes comprehensive tests and documentation updates.

Fixes #123
```

```
fix(core): handle empty file paths

Prevent crashes when file operations receive empty path arguments.
Add validation in assertFileExists procedure.
```

## Review Process

### What to Expect
1. **Automated Checks**: CI will run tests and linting
2. **Code Review**: Maintainers will review your code
3. **Feedback**: You may receive requests for changes
4. **Approval**: PR will be merged once approved

### Addressing Feedback
- Be responsive to review comments
- Explain your reasoning when disagreeing
- Make requested changes promptly
- Ask for clarification if needed

### Review Checklist
**For Reviewers:**
- [ ] Code follows style guidelines
- [ ] Tests are comprehensive and pass
- [ ] Documentation is updated
- [ ] No breaking changes without migration path
- [ ] Performance impact is acceptable

**For Contributors:**
- [ ] All CI checks pass
- [ ] Code is well-documented
- [ ] Tests cover new functionality
- [ ] No linting errors
- [ ] Commit messages are clear

## Community

### Getting Help
- **Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Discord/Slack**: For real-time chat (if available)

### Recognition
Contributors are recognized through:
- GitHub contributor statistics
- Mention in release notes
- Attribution in documentation

### Governance
- **Maintainers**: Oversee project direction and releases
- **Contributors**: Community members who contribute code
- **Users**: Community members who use and provide feedback

## Additional Resources

- [User Guide](USER_GUIDE.md) - Complete usage instructions
- [API Reference](API.md) - Detailed API documentation
- [Architecture](ARCHITECTURE.md) - Framework design principles
- [Best Practices](BEST_PRACTICES.md) - Recommended patterns

Thank you for contributing to nimtest! Your contributions help make testing in Nim better for everyone.