# Flutter Triple 3.0.0 Migration Guide

## ⚠️ WARNING ⚠️

**DO NOT ATTEMPT TO UPDATE flutter_triple TO VERSION 3.0.0 WITHOUT EXTENSIVE REFACTORING**

Updating to flutter_triple 3.0.0 will require significant changes to the codebase due to architectural changes from RxNotifier to ASP (Atomic State Pattern). 

Attempting to upgrade without proper refactoring will result in compilation errors including:
- `RxValueListenable` type not found
- `Atom` constructor not found

See the full migration details below if you plan to proceed with the upgrade.

---

## Overview

This document outlines the issues encountered when attempting to migrate from flutter_triple 2.2.0 to 3.0.0 in the Squawker project, and the steps taken to address them.

## Issues Encountered

### 1. Missing Dependencies

When upgrading to flutter_triple 3.0.0, we encountered compilation errors related to missing types:

- `RxValueListenable` type not found
- `Atom` constructor not found

These errors occurred because flutter_triple 3.0.0 migrated from RxNotifier to ASP (Atomic State Pattern).

### 2. Breaking Changes

According to the changelog, flutter_triple 3.0.0 introduced the following breaking changes:

- **BREAKING CHANGE**: Changed from RxNotifier to ASP Package
- This affects the underlying architecture and requires code changes

### 3. Dependency Requirements

flutter_triple 3.0.0 requires additional dependencies that were not automatically resolved:
- `asp` package
- `hook_state` package
- Potentially `atomlib` package (though this didn't fully resolve the issues)

## Attempted Solutions

### 1. Adding Missing Dependencies

We attempted to resolve the missing types by adding the following dependencies:
- `rx_notifier: ^2.3.0`
- `asp: ^2.0.3`
- `atomlib: ^0.0.7`

However, these additions did not resolve the compilation errors.

### 2. Code Changes Required

Based on the changelog, the following code changes would be required:
- Update Store implementations to be compatible with the new ASP-based architecture
- Replace any direct usage of RxNotifier features with ASP equivalents
- Update widget usage if any TripleConsumer, TripleListener, ScopedConsumer, or ScopedListener widgets are used

## Recommendation

### Current Status

We have reverted to flutter_triple 2.2.0 to maintain stability in the project. The single test failure that remains is unrelated to the flutter_triple version.

### Future Migration Path

To successfully migrate to flutter_triple 3.0.0, the following steps are recommended:

1. **Research ASP Package**: Understand the ASP (Atomic State Pattern) and how it differs from the previous RxNotifier-based approach.

2. **Update Store Implementations**: Review all Store classes in the project and update them to be compatible with the new architecture:
   - `lib/client/client_account.dart`
   - `lib/group/group_model.dart`
   - `lib/home/home_model.dart`
   - `lib/profile/profile_model.dart`
   - `lib/saved/saved_tweet_model.dart`
   - `lib/search/search_model.dart`
   - `lib/subscriptions/users_model.dart`
   - `lib/trends/trends_model.dart`

3. **Update Widget Usage**: If the project uses TripleConsumer, TripleListener, ScopedConsumer, or ScopedListener widgets, these may need updates.

4. **Testing**: Thoroughly test all functionality after the migration to ensure no regressions.

5. **Documentation**: Refer to the ASP package documentation and examples for proper usage patterns.

## Dependencies

Current working configuration:
```yaml
dependencies:
  flutter_triple: ^2.2.0
```

## Conclusion

While flutter_triple 3.0.0 offers new features and improvements, the migration requires significant changes to the codebase that are not straightforward. For now, we recommend staying on version 2.2.0 until a more comprehensive migration plan can be implemented.

If you decide to proceed with the migration, make sure to:
1. Create a backup of the current working code
2. Thoroughly test all functionality after the migration
3. Update all Store implementations according to the new ASP-based architecture
4. Check for any widget usage that might need updates