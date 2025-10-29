# Contribution Guidelines

Welcome to the nimtest project! This document outlines how to contribute to the framework and maintain its quality and consistency.

## Table of Contents

- [Getting Started](#getting-started)
- [Code of Conduct](#code-of-conduct)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)
- [Maintainer Responsibilities](#maintainer-responsibilities)

## Getting Started

### Prerequisites

Before contributing to nimtest, ensure you have:

- Nim compiler (version 1.6.0 or higher)
- Git for version control
- A text editor or IDE of your choice
- Basic knowledge of Nim programming language

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:

```bash
git clone https://github.com/yourusername/nim-test-suite.git
cd nim-test-suite
```

3. Set up the upstream remote:

```bash
git remote add upstream https://github.com/original/nim-test-suite.git
```

## Code of Conduct

This project adheres to the Nim community code of conduct. We expect all contributors to:

- Be respectful and inclusive in all interactions
- Provide constructive feedback
- Welcome questions and new contributors
- Focus on technical discussions and improvements
- Follow established coding standards

## Development Setup

### Environment Setup

1. Install Nim compiler (1.6.0 or higher)
2. Install dependencies:

```bash
nimble develop
```

3. Verify the setup by running existing tests:

```bash
nimble test
```

### Project Dependencies

The project has minimal dependencies to maintain simplicity:

- Nim standard library
- unittest module (built-in)
- json module (built-in)
- os/osproc modules (built-in)

## Project Structure

Understanding the project structure is important for making contributions:

```
nim-test-suite/
├── src/
│   └── nimtest/              # Main framework source
│       ├── helpers.nim       # Core testing utilities
│       ├── reporting.nim     # Reporting and analytics
│       └── test_config.nim   # Configuration module
├── tests/                    # Test files (currently empty in template)
├── examples/                 # Example implementations
├── docs/                     # Documentation files
├── .github/                  # GitHub configuration
├── nimble.nimble            # Project definition
└── README.md                # Main project documentation
```

### Key Files

- `src/nimtest/helpers.nim`: Core testing utilities and assertions
- `src/nimtest/reporting.nim`: Reporting and analytics functionality
- `src/nimtest/test_config.nim`: Configuration constants and types
- `docs/API.md`: Complete API reference
- `docs/USER_GUIDE.md`: User documentation

## Coding Standards

### Nim Coding Conventions

Follow standard Nim coding conventions:

1. Use `camelCase` for procedures and variables
2. Use `PascalCase` for types and constants
3. Use `snake_case` for module names
4. Follow Nim style guide for indentation and spacing

### Code Documentation

Document all public procedures, types, and constants:

```nim
proc myProcedure*(param: string): int =
  ## Brief description of what the procedure does.
  ##
  ## Detailed explanation of the procedure's behavior,
  ## parameters, and return value.
  ##
  ## Parameters:
  ##   param: Description of the parameter
  ##
  ## Returns:
  ##   Description of the return value
  result = 0
```

### Naming Conventions

- Public API procedures should end with `*`
- Test helper procedures should have descriptive names
- Constants should be in `UPPER_SNAKE_CASE`
- Types should be in `PascalCase`

### Error Handling

Use Nim's exception handling appropriately:

```nim
proc riskyOperation*(): bool =
  ## Performs an operation that might fail.
  ## 
  ## Returns: `true` if successful, `false` otherwise.
  try:
    # Operation code
    result = true
  except Exception:
    result = false
```

## Testing Guidelines

### Test Structure

Follow the standard Nim unittest structure:

```nim
import unittest
import nimtest

suite "Feature Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()

  test "feature works correctly":
    # Test implementation
    check someCondition == true
```

### Test Quality Standards

1. Each test should focus on a single functionality
2. Use descriptive test names that explain what is being tested
3. Include proper setup and teardown
4. Use appropriate assertions from the framework
5. Ensure tests are deterministic and repeatable

### Test Coverage

Aim for high test coverage, especially for:

- Core framework functionality
- Error handling paths
- Public API procedures
- Edge cases and boundary conditions

## Documentation Standards

### API Documentation

When adding new procedures or types:

1. Document all public procedures with complete Nimdoc
2. Include parameter descriptions
3. Include return value descriptions
4. Provide usage examples when helpful

### User Documentation

When updating user documentation:

1. Use clear, concise language
2. Provide practical examples
3. Follow consistent formatting
4. Include relevant code snippets
5. Organize content logically

### Example Documentation

```nim
# Good example documentation
test "calculator adds numbers correctly":
  # Arrange
  let calc = newCalculator()
  
  # Act
  let result = calc.add(2, 3)
  
  # Assert
  check result == 5
```

## Submitting Changes

### Branch Management

1. Create a feature branch for your changes:

```bash
git checkout -b feature/my-feature
# or
git checkout -b bugfix/issue-description
```

2. Make your changes in the feature branch
3. Follow the commit message guidelines below

### Commit Messages

Write clear, descriptive commit messages:

```
feat: Add new assertion for file size validation

- Implement assertFileHasSize procedure
- Add tests for the new procedure
- Update documentation
```

Use these prefixes:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `test:` for test additions
- `refactor:` for code restructuring
- `chore:` for maintenance tasks

### Pull Request Process

1. Ensure all tests pass before submitting
2. Update documentation as needed
3. Submit a pull request to the main repository
4. Fill out the pull request template
5. Link to any related issues
6. Wait for review and address feedback

## Review Process

### Code Review Criteria

Pull requests will be reviewed based on:

1. **Functionality**: Does the code work as intended?
2. **Code Quality**: Is the code well-structured and readable?
3. **Testing**: Are there adequate tests for the changes?
4. **Documentation**: Is the code properly documented?
5. **Standards**: Does the code follow project standards?
6. **Performance**: Are there any performance implications?

### Review Timeline

- Initial review: Within 48 hours
- Follow-up reviews: Within 24 hours of changes
- Final approval: After all feedback is addressed

### Common Review Feedback

Be prepared for feedback on:
- Code style and conventions
- Test coverage
- Documentation completeness
- Performance considerations
- API design decisions

## Maintainer Responsibilities

### Code Quality

Maintainers are responsible for:

- Ensuring all code meets project standards
- Maintaining backward compatibility when possible
- Reviewing and merging pull requests
- Managing project releases

### Documentation

Maintainers should:

- Keep documentation up-to-date
- Ensure examples remain functional
- Maintain API documentation
- Update contribution guidelines as needed

### Community Management

Maintainers should:

- Respond to issues and questions promptly
- Foster a welcoming community
- Handle code of conduct violations appropriately
- Recognize contributor contributions

## Getting Help

### Questions

For questions about contributing:

1. Check existing documentation
2. Search existing issues
3. Open a new issue if needed
4. Join the Nim community channels

### Support

If you're stuck on a contribution:

1. Describe your issue in detail
2. Include relevant code snippets
3. Explain what you've tried so far
4. Ask for specific guidance

Thank you for contributing to nimtest! Your efforts help improve the framework for all users.