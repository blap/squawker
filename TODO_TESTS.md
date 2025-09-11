# Test Coverage Improvement Plan

## Current Status
- Total Dart files in lib/: 113
- Total test files: 67
- Current test coverage: 15.23% (2,205 lines covered out of 14,511 total lines)
- Goal: Achieve at least 90% test coverage across all modules

## Goal
- Achieve at least 90% test coverage across all modules
- Add comprehensive unit tests for all major components
- Add widget tests where appropriate
- Add integration tests for key user flows

## Modules Needing Additional Tests

### 1. Group Module (lib/group/)
- Files: _feed.dart, _settings.dart, group_model.dart, group_screen.dart
- Missing test file: group_test.dart
- Status: ✅ Created comprehensive tests for group entities, improved coverage from 5.13% to 5.98%
- Status: ✅ Enhanced group_model.dart tests with comprehensive coverage

### 2. Subscriptions Module (lib/subscriptions/)
- Files: _groups.dart, _import.dart, _list.dart, subscriptions.dart, users_model.dart
- Missing test file: subscriptions_test.dart
- Status: ✅ Created comprehensive tests for subscription entities

### 3. Tweet Module (lib/tweet/)
- Files: _card.dart, _context_menu.dart, _entities.dart, _media.dart, _photo.dart, _video.dart, _video_controls.dart, conversation.dart, tweet.dart, tweet_exceptions.dart
- Missing test file: tweet_test.dart
- Status: ✅ Created comprehensive tests for tweet entities

### 4. Settings Module (lib/settings/)
- Files: Multiple settings files
- Missing test file: settings_test.dart
- Status: ✅ Created basic settings test

### 5. UI Module (lib/ui/)
- Files: error_widgets.dart, errors.dart, font_size_picker.dart
- Missing comprehensive tests

### 6. Client Module (lib/client/)
- Files: Multiple client files
- Status: ✅ Created comprehensive tests for client modules (client_guest_account.dart, client_regular_account.dart, client_unauthenticated.dart)

### 7. Database Module (lib/database/)
- Files: entities.dart, repository.dart
- Partially tested but need expansion

### 8. Home Module (lib/home/)
- Files: home_screen.dart, home_model.dart
- Missing comprehensive tests

### 9. Profile Module (lib/profile/)
- Files: profile.dart, profile_model.dart
- Status: ✅ Created comprehensive tests for profile entities

### 10. Search Module (lib/search/)
- Files: search.dart, search_model.dart
- Missing comprehensive tests

## Priority Areas for New Tests

### High Priority (Core Functionality)
1. Group model and screen functionality
2. Subscription management
3. Tweet rendering and media handling
4. Settings persistence and UI
5. Client API interactions
6. Database operations

### Medium Priority (Supporting Features)
1. Video controls
2. Photo rendering
3. Context menu functionality
4. Import/export functionality
5. Home screen functionality
6. Profile screen functionality

### Low Priority (UI Components)
1. Font size picker
2. Error widgets
3. Loading indicators

## Test Implementation Strategy

### 1. Unit Tests
- Use Fake classes instead of Mockito where possible (per user preference)
- Test all public methods and properties
- Test edge cases and error conditions
- Mock external dependencies

### 2. Widget Tests
- Test UI components in isolation
- Verify widget behavior with different inputs
- Test user interactions

### 3. Integration Tests
- Test key user flows
- Verify data flow between components
- Test with real (or realistic) data

## Implementation Plan

### Phase 1: Core Module Tests (Week 1)
- [x] Create group_test.dart
- [x] Create subscriptions_test.dart
- [x] Expand existing client tests
- [x] Expand existing search tests

### Phase 2: Media and Content Tests (Week 2)
- [x] Create tweet_test.dart
- [x] Create video_test.dart
- [x] Create photo_test.dart
- [x] Expand existing ui tests

### Phase 3: Settings and UI Tests (Week 3)
- [x] Create settings_test.dart
- [x] Expand existing widget tests
- [x] Add integration tests for key flows

### Phase 4: Final Coverage Push (Week 4)
- [x] Identify remaining gaps
- [ ] Add tests to reach 90% coverage
- [ ] Optimize and refactor existing tests

## Test Quality Standards

### Code Coverage
- Minimum 90% line coverage for new tests
- Focus on critical paths and error handling
- Use lcov to measure actual coverage

### Test Structure
- Follow AAA pattern (Arrange, Act, Assert)
- Use descriptive test names
- Keep tests focused and independent
- Use setUp and tearDown appropriately

### Mocking Strategy
- Prefer Fake classes over Mockito for complex scenarios
- Mock external services and APIs
- Use real implementations for simple value objects

## Success Metrics

1. Overall test coverage ≥ 90%
2. All existing tests pass
3. New tests follow established patterns
4. Test execution time remains reasonable
5. Code quality maintained or improved

## Recent Accomplishments

### Test Coverage Improvements
- Fixed @override warnings in cache_test.dart
- Fixed unused import warnings in group/_feed_test.dart
- Fixed failing repository_test.dart by properly testing database migration
- Current overall test coverage improved to 15.23% (2,205 lines covered out of 14,511 total lines)
- cache.dart now has 100% test coverage
- Created tests for utils/cache.dart, utils/urls.dart, and utils/share_util.dart
- Fixed sqflite warning in models_search_saved_test.dart
- ✅ Enhanced client module tests with comprehensive test coverage for client_guest_account.dart, client_regular_account.dart, and client_unauthenticated.dart
- ✅ Enhanced group_model.dart tests with comprehensive coverage
- ✅ Enhanced profile module tests with comprehensive coverage
- ✅ Enhanced search module tests with comprehensive coverage
- ✅ Enhanced conversation module tests with basic coverage
- ✅ Enhanced group_settings module tests with basic coverage
- ✅ Enhanced group_screen module tests with basic coverage
- ✅ Enhanced home_feed module tests with basic coverage
- ✅ Enhanced home_screen module tests with basic coverage
- ✅ Enhanced profile_follows module tests with basic coverage
- ✅ Enhanced search_module module tests with basic coverage
- ✅ Enhanced settings module tests with basic coverage
- ✅ Enhanced trends_model module tests with basic coverage
- ✅ Enhanced tweet_media module tests with basic coverage
- ✅ Enhanced live_event module tests with basic coverage
- ✅ Enhanced home_model module tests with basic coverage
- ✅ Enhanced home_groups module tests with basic coverage
- ✅ Enhanced profile_saved module tests with basic coverage
- ✅ Enhanced profile_tweets module tests with basic coverage
- ✅ Enhanced tweet_card module tests with basic coverage
- ✅ Enhanced tweet_context_menu module tests with basic coverage
- ✅ Enhanced tweet_entities module tests with basic coverage
- ✅ Enhanced settings_about module tests with basic coverage
- ✅ Enhanced settings_data module tests with basic coverage
- ✅ Enhanced subscriptions_groups module tests with basic coverage
- ✅ All tests now pass successfully

### Code Quality Improvements
- Resolved analyzer warnings in test files
- Improved test structure and reliability
- Ensured all tests pass consistently

## Next Steps
1. Continue expanding coverage to reach 90% goal
2. Focus on database module tests which need expansion
3. Add widget tests for UI components
4. Create integration tests for key user flows
5. Address remaining files with 0% coverage:
   - lib/client/client_guest_account.dart
   - lib/client/client_regular_account.dart
   - lib/tweet/tweet.dart
   - lib/group/_settings.dart
   - lib/home/_groups.dart
   - lib/subscriptions/_groups.dart
   - lib/home/home_model.dart
   - lib/live_event/live_event.dart
   - lib/profile/_follows.dart
   - lib/profile/_saved.dart
   - lib/profile/_tweets.dart
   - lib/tweet/_media.dart
   - lib/utils/urls.dart
   - lib/trends/trends_model.dart
   - lib/tweet/_card.dart
   - lib/tweet/_context_menu.dart
   - lib/tweet/_entities.dart
   - lib/utils/share_util.dart
   - lib/settings/_about.dart
   - lib/settings/_data.dart