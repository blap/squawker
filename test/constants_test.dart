import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/constants.dart';

void main() {
  group('Constants', () {
    test('wizard and setup options should be defined', () {
      expect(optionWizardCompleted, 'option.wizard_completed');
      expect(optionDisableScreenshots, 'disable_screenshots');
      expect(optionErrorsEnabled, 'errors._enabled');
      expect(optionHelloLastBuild, 'hello.last_build');
    });

    test('home and navigation options should be defined', () {
      expect(optionHomePages, 'home.pages');
      expect(optionHomeInitialTab, 'home.initial_tab');
      expect(optionNavigationAnimations, 'home.navigation_animations');
      expect(optionHomeShowTabLabels, 'home.show_tab_labels');
    });

    test('media options should be defined', () {
      expect(optionMediaSize, 'media.size');
      expect(optionMediaDefaultMute, 'media.mute');
      expect(optionMediaAllowBackgroundPlay, 'media.allow_background_play');
      expect(optionMediaAllowBackgroundPlayOtherApps, 'media.allow_background_play.other_apps');
    });

    test('download options should be defined', () {
      expect(optionDownloadType, 'download.type');
      expect(optionDownloadPath, 'download.path');
      expect(optionDownloadBestVideoQuality, 'download_best_video_quality');
      expect(optionDownloadTypeDirectory, 'directory');
      expect(optionDownloadTypeAsk, 'ask');
    });

    test('locale options should be defined', () {
      expect(optionLocale, 'locale');
      expect(optionLocaleDefault, 'system');
    });

    test('network and sharing options should be defined', () {
      expect(optionShouldCheckForUpdates, 'should_check_for_updates');
      expect(optionShareBaseUrl, 'share_base_url');
      expect(optionProxy, 'proxy');
    });

    test('subscription options should be defined', () {
      expect(optionSubscriptionGroupsOrderByAscending, 'subscription_groups.order_by.ascending');
      expect(optionSubscriptionGroupsOrderByField, 'subscription_groups.order_by.field');
      expect(optionSubscriptionOrderByAscending, 'subscription.order_by.ascending');
      expect(optionSubscriptionOrderCustom, 'subscription.order_by.custom');
      expect(optionSubscriptionOrderByField, 'subscription.order_by.field');
      expect(optionSubscriptionInitialTab, 'subscription.initial_tab');
    });

    test('theme options should be defined', () {
      expect(optionThemeMode, 'theme.mode');
      expect(optionThemeTrueBlack, 'theme.true_black');
      expect(optionThemeColorScheme, 'theme.color_scheme');
    });

    test('user interface options should be defined', () {
      expect(optionTranslators, 'translators');
      expect(optionTweetsHideSensitive, 'tweets.hide_sensitive');
      expect(optionUserTrendsLocations, 'trends.locations');
      expect(optionNonConfirmationBiasMode, 'other.improve_non_confirmation_bias');
    });

    test('feed and display options should be defined', () {
      expect(optionKeepFeedOffset, 'keep_feed_offset');
      expect(optionLeanerFeeds, 'leaner_feeds');
      expect(optionExclusionsFeed, 'exclusions_feed');
      expect(optionEnhancedFeeds, 'enhanced_feeds');
      expect(optionEnhancedSearches, 'enhanced_searches');
      expect(optionEnhancedProfile, 'enhanced_profile');
      expect(optionConfirmClose, 'confirm_close');
      expect(optionTweetFontSize, 'tweet_font_size');
    });

    test('twitter account options should be defined', () {
      expect(optionTwitterAccountTypes, 'twitter_account_types');
      expect(twitterAccountTypesPriorityToRegular, 'twitter_account_types_priority_to_regular');
      expect(twitterAccountTypesBoth, 'twitter_account_types_both');
      expect(twitterAccountTypesOnlyRegular, 'twitter_account_types_only_regular');
    });

    test('route constants should be defined', () {
      expect(routeHome, '/');
      expect(routeGroup, '/group');
      expect(routeProfile, '/profile');
      expect(routeSearch, '/search');
      expect(routeSettings, '/settings');
      expect(routeSettingsExport, '/settings/export');
      expect(routeSettingsHome, '/settings/home');
      expect(routeStatus, '/status');
      expect(routeSubscriptionsImport, '/subscriptions/import');
    });

    test('all constants should be non-empty strings', () {
      const allConstants = [
        optionWizardCompleted,
        optionDisableScreenshots,
        optionErrorsEnabled,
        optionHelloLastBuild,
        optionHomePages,
        optionHomeInitialTab,
        optionNavigationAnimations,
        optionHomeShowTabLabels,
        optionMediaSize,
        optionMediaDefaultMute,
        optionMediaAllowBackgroundPlay,
        optionMediaAllowBackgroundPlayOtherApps,
        optionDownloadType,
        optionDownloadPath,
        optionDownloadBestVideoQuality,
        optionDownloadTypeDirectory,
        optionDownloadTypeAsk,
        optionLocale,
        optionLocaleDefault,
        optionShouldCheckForUpdates,
        optionShareBaseUrl,
        optionProxy,
        optionSubscriptionGroupsOrderByAscending,
        optionSubscriptionGroupsOrderByField,
        optionSubscriptionOrderByAscending,
        optionSubscriptionOrderCustom,
        optionSubscriptionOrderByField,
        optionSubscriptionInitialTab,
        optionThemeMode,
        optionThemeTrueBlack,
        optionThemeColorScheme,
        optionTranslators,
        optionTweetsHideSensitive,
        optionUserTrendsLocations,
        optionNonConfirmationBiasMode,
        optionKeepFeedOffset,
        optionLeanerFeeds,
        optionExclusionsFeed,
        optionEnhancedFeeds,
        optionEnhancedSearches,
        optionEnhancedProfile,
        optionConfirmClose,
        optionTweetFontSize,
        optionTwitterAccountTypes,
        twitterAccountTypesPriorityToRegular,
        twitterAccountTypesBoth,
        twitterAccountTypesOnlyRegular,
        routeHome,
        routeGroup,
        routeProfile,
        routeSearch,
        routeSettings,
        routeSettingsExport,
        routeSettingsHome,
        routeStatus,
        routeSubscriptionsImport,
      ];

      for (String constant in allConstants) {
        expect(constant.isNotEmpty, true, reason: 'Constant "$constant" should not be empty');
      }
    });
  });
}
