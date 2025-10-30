# nimtest Security Policy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nim](https://img.shields.io/badge/Nim-1.6+-blue.svg)](https://nim-lang.org/)

Security policy and guidelines for the nimtest testing framework.

## Install

```bash
nimble install nimtest
```

## Quick Example

```nim
import nimtest/api

# Secure test with proper resource cleanup
var ctx = createTestContext()
try:
  let tempDir = ctx.createTempTestDir("secure_test")
  let tempFile = createTestFile(ctx, tempDir, "sensitive.txt", "data")
  # Test operations...
finally:
  ctx.cleanup()  # Ensures no sensitive data remains
```

## Supported Versions

We take security seriously and actively maintain security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 0.3.x   | :white_check_mark: |
| 0.2.x   | :white_check_mark: |
| < 0.2.0 | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in nimtest, please help us by reporting it responsibly.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities by emailing:
- **Email**: security@nimtest.dev (create this email alias or use your personal email)
- **Subject**: `[SECURITY] Vulnerability Report - nimtest`

### What to Include

Please include the following information in your report:

1. **Description**: A clear description of the vulnerability
2. **Impact**: What an attacker could achieve by exploiting this vulnerability
3. **Steps to Reproduce**: Detailed steps to reproduce the issue
4. **Proof of Concept**: Code or commands demonstrating the vulnerability
5. **Affected Versions**: Which versions of nimtest are affected
6. **Environment**: Your operating system, Nim version, and any other relevant details
7. **Mitigation**: Any workarounds or temporary fixes you've identified

### Response Timeline

We will acknowledge your report within **48 hours** and provide a more detailed response within **7 days** indicating our next steps.

We will keep you informed about our progress throughout the process of fixing the vulnerability.

### Disclosure Policy

- We follow a **90-day disclosure timeline** from the initial report
- We will credit you (if desired) in our security advisory
- We will not disclose vulnerability details until a fix is available
- We may delay disclosure at your request if you need more time

## Security Considerations for Users

### Safe Usage Guidelines

When using nimtest in your projects, consider these security best practices:

#### 1. Test Environment Isolation
```nim
# Always use TestContext for resource management
suite "Secure Tests":
  var ctx: TestContext

  setup:
    ctx = createTestContext()

  teardown:
    ctx.cleanup()  # Ensures cleanup even on test failures
```

#### 2. CLI Command Safety
```nim
# Be cautious with dynamic command construction
# Note: CLI testing utilities have been removed from nimtest.
# For CLI testing, consider using other Nim libraries such as `unittest` with `osproc`.

# Example of secure command execution with other libraries:
# let (output, exitCode) = execCmdEx("some-command --version")
# Avoid: Dynamic command construction from untrusted input
# let dangerous = execCmdEx(userInput)  # DON'T DO THIS
```

#### 3. File System Security
```nim
# nimtest automatically handles temporary file creation safely
test "file operations":
  let tempDir = ctx.createTempTestDir("safe_test")
  let tempFile = createTestFile(ctx, tempDir, "test.txt", "content")

  # Framework ensures proper permissions and cleanup
  assertFileExists(tempFile)
```

### Known Security Considerations

#### Temporary File Handling
- nimtest creates temporary files in system temp directories
- Files are automatically cleaned up after tests
- No sensitive data should be written to test files

#### Command Execution
- CLI testing executes commands in controlled environments
- Commands run with the same permissions as the test process
- Be aware of command injection risks with dynamic arguments

#### Resource Management
- TestContext prevents resource leaks
- Automatic cleanup reduces risk of temporary file accumulation
- Cross-platform path handling prevents traversal attacks

## Security Updates

### How We Handle Security Updates

1. **Vulnerability Assessment**: All reported issues are assessed for severity and impact
2. **Fix Development**: Security fixes are developed with minimal changes
3. **Testing**: Comprehensive testing ensures fixes don't break functionality
4. **Release**: Security updates are released as patch versions
5. **Communication**: Users are notified through security advisories

### Security Advisory Format

```markdown
# Security Advisory: [TITLE]

## Summary
A brief description of the vulnerability and its impact.

## Affected Versions
- nimtest < [fixed version]

## Impact
Description of what an attacker could achieve.

## Mitigation
How to mitigate the vulnerability before upgrading.

## Fix
Details of the fix and upgrade instructions.
```

## Security Testing

### Automated Security Checks

nimtest includes several security-focused checks in CI/CD:

- **CodeQL Analysis**: Static analysis for common vulnerabilities
- **Dependency Scanning**: Automated checks for vulnerable dependencies
- **Permission Checks**: Validation of file system operations
- **Command Injection Prevention**: Tests for safe CLI execution

### Manual Security Review

For significant changes, we conduct manual security reviews focusing on:

- Input validation and sanitization
- File system operations
- Command execution safety
- Resource management
- Cross-platform security implications

## Third-Party Dependencies

nimtest has minimal dependencies and we regularly audit them for security issues:

- **Nim Standard Library**: Core language dependencies
- **No External Dependencies**: nimtest uses only Nim's standard library

## Compliance

### Security Standards
- **OWASP Guidelines**: Following web application security principles
- **Secure Coding Practices**: Adhering to Nim language security guidelines
- **Responsible Disclosure**: Following industry-standard disclosure practices

### Certifications
- **No Current Certifications**: We are working towards security certifications
- **Open Source Security**: Following OpenSSF best practices

## Contact

For security-related questions or concerns:
- **Security Issues**: Use the reporting process above
- **General Security Questions**: security@nimtest.dev
- **Public Discussions**: GitHub Discussions (for non-sensitive topics)

## Acknowledgments

We appreciate the security research community for their contributions to keeping open source software secure. Security researchers who responsibly disclose vulnerabilities will be acknowledged in our security advisories (unless they request anonymity).

## Changes to This Policy

This security policy may be updated as the project evolves. Significant changes will be announced through our release notes and security advisories.