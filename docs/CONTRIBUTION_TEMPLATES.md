# Nimtest Contribution Response Templates

Use these templates when responding to pull requests and issues from the Nim community. Copy and customize as needed.

## Quick Acknowledgment (Within 24 hours)

### For Any PR
```
Thanks for your contribution to nimtest! 🙏

**Quick Assessment:**
- ✅ PR follows contribution guidelines
- 🔍 Code review in progress
- 🧪 CI tests running

I'll provide detailed feedback within [2-3 business days].
```

### For Nim Core Team PRs
```
Thanks @nim-lang/core-team-member for this important contribution!

**Priority:** High (Nim ecosystem compatibility)
**Review Timeline:** 24-48 hours

This looks like [brief description of what the PR addresses]. I'll coordinate with the team for thorough review.
```

## Detailed Review Responses

### Approval with Minor Suggestions
```
**Review Complete** ✅

Great work on this PR! The implementation looks solid and follows nimtest conventions well.

**Approved with minor suggestions:**
- [ ] Consider adding a test case for edge case X
- [ ] Update documentation example Y
- [ ] Add type hint for parameter Z

Once these are addressed, this is ready to merge. Thanks for the contribution!
```

### Request for Changes
```
**Review Complete** 🔄

Thanks for submitting this PR. I see the value in [what the PR aims to achieve], but there are a few issues that need to be addressed:

**Required Changes:**
1. **Breaking Change Documentation**: This introduces a breaking change that needs migration documentation
2. **Test Coverage**: Missing test cases for [specific scenarios]
3. **Performance Impact**: Need to verify performance implications

**Suggested Improvements:**
- [ ] Add integration tests
- [ ] Update API documentation
- [ ] Consider backward compatibility

Let me know if you need help with any of these changes!
```

### Nim Compatibility Issues
```
**Nim Compatibility Review** ⚠️

This PR addresses important Nim [version] compatibility, but I've identified some issues:

**Compatibility Status:**
- ✅ Nim 1.6.x: Working
- ❌ Nim 2.0.x: [Specific issue]
- ❓ Nim devel: Needs testing

**Action Required:**
Please test against Nim 2.0.x and update the PR with any necessary changes. The compatibility testing script in `scripts/test_compatibility.nim` can help.

**Breaking Changes:** [Yes/No - with details]
```

## Issue Response Templates

### Bug Report Acknowledgment
```
**Bug Report Received** 🐛

Thanks for reporting this issue! I've reproduced the problem and confirmed it's a valid bug.

**Initial Assessment:**
- **Severity:** [Low/Medium/High/Critical]
- **Affected Versions:** [Nim versions where this occurs]
- **Reproduction:** [Steps to reproduce]

**Next Steps:**
- [ ] Root cause analysis
- [ ] Fix implementation
- [ ] Test case addition
- [ ] Documentation update

I'll prioritize this for the next patch release.
```

### Feature Request Response
```
**Feature Request Review** 💡

Thanks for suggesting this feature! This aligns well with nimtest's goals of [relevant goal].

**Proposal Assessment:**
- **Use Case:** [How this would be used]
- **Implementation Complexity:** [Low/Medium/High]
- **Breaking Change:** [Yes/No]
- **Priority:** [Low/Medium/High]

**Implementation Plan:**
1. Design API surface
2. Add core functionality
3. Comprehensive testing
4. Documentation and examples

Would you be interested in contributing this feature? I can provide guidance on the implementation.
```

## Escalation Templates

### Security Issue
```
**Security Issue Alert** 🔒

This appears to be a security-related issue. For security concerns, please:

1. **DO NOT** discuss details in public issues/PRs
2. Email security@nimtest.dev with full details
3. Allow 24-48 hours for initial assessment

**Temporary Measures:**
- [Any immediate workarounds or patches]

The nimtest security team will coordinate with you directly.
```

### Critical Nim Ecosystem Impact
```
**Critical Ecosystem Impact** 🚨

This issue affects the broader Nim ecosystem. I'm escalating this to the Nim core team.

**Impact Assessment:**
- **Scope:** [How many projects affected]
- **Severity:** [Critical ecosystem breakage]
- **Timeline:** [When this needs to be addressed]

**Coordination:**
- @nim-lang/core-team - Requesting your input on this issue
- CC: @nimtest/maintainers

We'll work together to resolve this quickly.
```

## Release Communication Templates

### Breaking Change Announcement
```
**Breaking Change Notice** ⚠️

nimtest [version] includes breaking changes that may affect your code:

**Changes:**
- [List breaking changes with migration examples]

**Migration Guide:**
[Step-by-step migration instructions]

**Timeline:**
- Current version still supported until: [date]
- Migration period: [duration]

**Questions?** Open an issue or discussion - we're here to help!
```

### New Nim Version Support
```
**Nim Version Support Update** 🆕

nimtest [version] now supports Nim [new version]!

**What's New:**
- Full compatibility with Nim [version] features
- [Any new capabilities enabled by the version]
- Performance improvements from [version] optimizations

**Migration:**
- Automatic for most users
- [Any manual migration steps if needed]

**Testing:** All tests pass on Nim [version range].
```

## Community Coordination Templates

### Requesting Nim Core Team Input
```
@nim-lang/core-team - Requesting your expertise on this nimtest compatibility issue.

**Context:**
- nimtest [current version] compatibility with Nim [version]
- Issue: [brief description]
- Impact: [who this affects]

**Questions:**
1. Is this expected behavior in Nim [version]?
2. Recommended approach for compatibility?
3. Any upstream changes planned?

Your guidance will help ensure nimtest stays compatible with the Nim ecosystem.
```

### Coordinating with Library Authors
```
@library-author - nimtest is preparing for Nim [version] compatibility.

**Request:**
We're updating nimtest to support Nim [version] and want to ensure compatibility with [your library].

**Testing Needed:**
- [Specific integration points to test]
- [Any known compatibility issues]

**Timeline:** Targeting Nim [version] support in nimtest [upcoming version].

Can you help us validate compatibility?
```

## Customizing These Templates

### Personalization Tips
- Always use the contributor's name/handle
- Reference specific parts of their PR/issue
- Include concrete next steps
- Set realistic timelines
- Offer help and support

### Tone Guidelines
- **Professional**: Clear, direct, respectful
- **Appreciative**: Thank contributors for their time
- **Helpful**: Offer guidance and support
- **Collaborative**: Frame responses as working together
- **Transparent**: Be clear about timelines and processes

### When to Use Each Template
- **Quick Ack**: Any new PR/issue within 24 hours
- **Detailed Review**: After thorough code review
- **Changes Requested**: When PR needs modifications
- **Escalation**: Security issues or critical ecosystem impact
- **Release Comms**: Major version releases or breaking changes