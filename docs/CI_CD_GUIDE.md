# nimtest CI/CD Integration

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nim](https://img.shields.io/badge/Nim-1.6+-blue.svg)](https://nim-lang.org/)

Complete guide for integrating nimtest with CI/CD platforms for automated testing.

## Install

```bash
nimble install nimtest
```

## Quick Example

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: jiro4989/setup-nim-action@v2
    - run: nimble install
    - run: nim c -r examples/test_all.nim
```

## GitHub Actions

nimtest comes with comprehensive GitHub Actions workflows that follow Nim ecosystem standards. The workflows include:

### Main CI Workflow (`.github/workflows/ci.yml`)

The main CI workflow provides:
- **Matrix testing** across multiple OS (Ubuntu, Windows, macOS) and Nim versions (2.0.x, stable, devel)
- **Dependency caching** for faster builds
- **Comprehensive test execution** including progress bar demos
- **Linting and documentation generation**
- **Automated releases** and package publishing

```yaml
# Key features of the provided CI workflow:
- setup-nim-action@v2 (latest version)
- Nimble dependency caching
- Cross-platform testing (Linux, macOS, Windows)
- Multiple Nim versions (2.0.x, stable, devel)
- Progress bar integration testing
- Automated documentation generation
- Release automation with GitHub Releases
```

### Code Quality Workflow (`.github/workflows/code-quality.yml`)

Runs comprehensive code quality checks:
- **Security scanning** for potential vulnerabilities
- **Performance benchmarking**
- **Code coverage analysis** (when tools available)
- **Complexity analysis** and code metrics
- **Scheduled weekly runs** for ongoing quality monitoring

### Release Workflow (`.github/workflows/release.yml`)

Handles automated releases:
- **Tagged release creation** (v*.*.* tags)
- **GitHub Release generation** with release notes
- **Package publishing** to nimble registry
- **Release asset uploads** (tar.gz, zip)
- **Publication verification**

### Dependabot Configuration (`.github/dependabot.yml`)

Automated dependency management:
- **GitHub Actions updates** weekly
- **Security and feature updates**
- **Automated PR creation** for updates

## GitLab CI

For GitLab CI/CD, create `.gitlab-ci.yml`:

```yaml
stages:
  - test
  - quality
  - deploy

variables:
  NIM_VERSION: "stable"

cache:
  key: nimble
  paths:
    - ~/.nimble/

.test_template: &test_definition
  image: nimlang/nim:latest
  before_script:
    - nimble refresh
    - nimble install -y
  script:
    - nim c -r examples/test_all.nim
    - nim c -r examples/test_reporting_demo.nim
  artifacts:
    reports:
      junit: test-results.xml
    paths:
      - comprehensive_test_report.json
      - error_handling_report.json

test:nim_stable:
  <<: *test_definition
  stage: test
  variables:
    NIM_VERSION: "stable"

test:nim_2.0:
  <<: *test_definition
  stage: test
  image: nimlang/nim:2.0
  variables:
    NIM_VERSION: "2.0"

test:nim_devel:
  <<: *test_definition
  stage: test
  image: nimlang/nim:devel
  variables:
    NIM_VERSION: "devel"
  allow_failure: true

quality_check:
  stage: quality
  image: nimlang/nim:latest
  before_script:
    - nimble refresh
    - nimble install -y
  script:
    - nim c --warnings:on --hints:on src/nimtest.nim
    - nimble check
  artifacts:
    paths:
      - docs/generated/
    expire_in: 1 week

pages:
  stage: deploy
  image: nimlang/nim:latest
  before_script:
    - nimble refresh
    - nimble install -y
  script:
    - mkdir -p docs/generated
    - nim doc --out:docs/generated/ --project src/nimtest.nim
  artifacts:
    paths:
      - docs/generated/
  only:
    - main
```

## Jenkins Pipeline

For Jenkins CI, create a `Jenkinsfile`:

```groovy
pipeline {
    agent any

    stages {
        stage('Setup') {
            steps {
                sh 'curl https://nim-lang.org/choosenim/init.sh -sSf | sh'
                sh 'export PATH=$HOME/.nimble/bin:$PATH'
                sh 'nimble refresh'
                sh 'nimble install -y'
            }
        }

        stage('Test') {
            steps {
                sh 'nim c -r examples/test_all.nim'
                sh 'nim c -r examples/test_reporting_demo.nim'
            }
            post {
                always {
                    junit 'test-results.xml'
                    archiveArtifacts artifacts: '*.json', fingerprint: true
                }
            }
        }

        stage('Quality') {
            steps {
                sh 'nim c --warnings:on --hints:on src/nimtest.nim'
                sh 'nimble check'
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'nimble publish'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```

## Azure DevOps

For Azure Pipelines, create `azure-pipelines.yml`:

```yaml
trigger:
  branches:
    include:
    - main
    - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  nim.version: 'stable'

stages:
- stage: Test
  jobs:
  - job: TestMatrix
    strategy:
      matrix:
        nim_stable:
          nim.version: 'stable'
        nim_2_0:
          nim.version: '2.0'
    steps:
    - script: |
        curl https://nim-lang.org/choosenim/init.sh -sSf | sh
        export PATH=$HOME/.nimble/bin:$PATH
        nimble refresh
        nimble install -y
      displayName: 'Setup Nim'

    - script: |
        export PATH=$HOME/.nimble/bin:$PATH
        nim c -r examples/test_all.nim
        nim c -r examples/test_reporting_demo.nim
      displayName: 'Run Tests'

    - task: PublishTestResults@2
      condition: succeededOrFailed()
      inputs:
        testResultsFiles: 'test-results.xml'
        testRunTitle: 'nimtest Results'

    - task: PublishBuildArtifacts@1
      inputs:
        pathtoPublish: 'comprehensive_test_report.json'
        artifactName: 'test-reports'

- stage: Release
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - job: Publish
    steps:
    - script: |
        export PATH=$HOME/.nimble/bin:$PATH
        nimble publish
      displayName: 'Publish Package'
```

## Available Nimble Tasks

The nimtest package provides several nimble tasks for CI/CD workflows:

### `nimble test`
Runs basic package tests to verify the package builds correctly.

### `nimble run_all_tests`
Executes the comprehensive test suite, including all example tests with reporting.

### `nimble test_reports`
Generates detailed test reports in multiple formats (JSON, JUnit XML, Markdown).

## Report Formats

The reporting system generates reports in multiple formats:

- **JSON**: Detailed test results for programmatic analysis
- **JUnit XML**: Compatible with CI/CD systems and IDEs
- **Markdown**: Human-readable reports for documentation
- **Console**: Formatted output for terminal display

## Progress Visualization in CI

For long-running test suites in CI environments, use progress bars to provide visual feedback:

```yaml
# GitHub Actions with progress bars
- name: Run comprehensive tests with progress
  run: |
    nim c -r examples/test_all.nim
  env:
    NIMTEST_PROGRESS_STYLE: blocks  # or globe, pulse, dots, minimal
```

```yaml
# GitLab CI with progress visualization
test_with_progress:
  script:
    - export NIMTEST_PROGRESS_STYLE=globe
    - nim c -r examples/test_all.nim
```

## Configuration

All CI/CD behavior can be customized through the `src/nimtest/test_config.nim` file in your project. Adjust the configuration to match your project's specific requirements.

## Best Practices

### 1. Multi-Version Testing
Test against multiple Nim versions to ensure compatibility:
```yaml
strategy:
  matrix:
    nim-version: ['2.0.x', stable, devel]
```

### 2. Dependency Caching
Cache nimble dependencies to speed up builds:
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.nimble
    key: ${{ runner.os }}-nimble-${{ matrix.nim-version }}-${{ hashFiles('nimble.nimble') }}
```

### 3. Cross-Platform Testing
Test on multiple operating systems:
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
```

### 4. Path-Based Triggers
Avoid running CI on documentation-only changes:
```yaml
on:
  push:
    paths-ignore:
      - '*.md'
      - 'docs/**'
```

### 5. Artifact Management
Store test reports and build artifacts:
```yaml
- uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: '*.json'
    retention-days: 30
```

### 6. Security Considerations
- Store API keys as encrypted secrets
- Use read-only tokens where possible
- Regularly rotate credentials
- Audit third-party actions for security

### 7. Performance Optimization
- Use parallel jobs for faster execution
- Cache dependencies effectively
- Minimize artifact sizes
- Use incremental builds when possible

## Troubleshooting

### Common Issues

**Setup failures**: Ensure `setup-nim-action@v2` is used (not v1)

**Cache misses**: Verify cache keys include all relevant dependencies

**Permission errors**: Check token scopes for publishing operations

**Timeout issues**: Increase timeout for long-running tests

### Debug Mode
Enable verbose output for debugging:
```bash
nim c -r examples/test_all.nim --verbosity:2
```

### Log Analysis
Check CI logs for:
- Nim version compatibility issues
- Missing dependencies
- Path resolution problems
- Permission issues