import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/notifiers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('CombinedChangeNotifier', () {
    late ChangeNotifier notifier1;
    late ChangeNotifier notifier2;
    late CombinedChangeNotifier combinedNotifier;
    late List<String> notifications;

    setUp(() {
      notifier1 = ChangeNotifier();
      notifier2 = ChangeNotifier();
      combinedNotifier = CombinedChangeNotifier(notifier1, notifier2);
      notifications = [];

      // Add listener to track notifications
      combinedNotifier.addListener(() {
        notifications.add('combined_notified');
      });
    });

    tearDown(() {
      try {
        combinedNotifier.dispose();
      } catch (e) {
        // Ignore disposal errors in tearDown since some tests dispose it explicitly
      }
    });

    group('Constructor and Initialization', () {
      test('should create CombinedChangeNotifier with two notifiers', () {
        final testNotifier1 = ChangeNotifier();
        final testNotifier2 = ChangeNotifier();
        final combined = CombinedChangeNotifier(testNotifier1, testNotifier2);

        expect(combined.one, equals(testNotifier1));
        expect(combined.two, equals(testNotifier2));

        combined.dispose();
        testNotifier1.dispose();
        testNotifier2.dispose();
      });

      test('should properly initialize listeners on both notifiers', () {
        // Verify that the combined notifier responds to changes from either notifier
        expect(notifications.length, equals(0));

        notifier1.notifyListeners();
        expect(notifications.length, equals(1));

        notifier2.notifyListeners();
        expect(notifications.length, equals(2));
      });
    });

    group('Notification Forwarding', () {
      test('should forward notifications from first notifier', () {
        expect(notifications.length, equals(0));

        notifier1.notifyListeners();

        expect(notifications.length, equals(1));
        expect(notifications.last, equals('combined_notified'));
      });

      test('should forward notifications from second notifier', () {
        expect(notifications.length, equals(0));

        notifier2.notifyListeners();

        expect(notifications.length, equals(1));
        expect(notifications.last, equals('combined_notified'));
      });

      test('should forward multiple notifications from both notifiers', () {
        expect(notifications.length, equals(0));

        notifier1.notifyListeners();
        notifier2.notifyListeners();
        notifier1.notifyListeners();
        notifier2.notifyListeners();

        expect(notifications.length, equals(4));
      });

      test('should forward notifications in the order they occur', () {
        final List<String> detailedNotifications = [];

        // Remove the existing listener and add a more detailed one
        combinedNotifier.removeListener(() {
          notifications.add('combined_notified');
        });

        combinedNotifier.addListener(() {
          detailedNotifications.add('notification_${detailedNotifications.length + 1}');
        });

        notifier1.notifyListeners(); // Should trigger notification_1
        notifier2.notifyListeners(); // Should trigger notification_2
        notifier1.notifyListeners(); // Should trigger notification_3

        expect(detailedNotifications, equals(['notification_1', 'notification_2', 'notification_3']));
      });

      test('should handle rapid successive notifications', () {
        expect(notifications.length, equals(0));

        // Fire multiple notifications quickly
        for (int i = 0; i < 10; i++) {
          if (i % 2 == 0) {
            notifier1.notifyListeners();
          } else {
            notifier2.notifyListeners();
          }
        }

        expect(notifications.length, equals(10));
      });
    });

    group('Multiple Listeners', () {
      test('should notify all listeners when either notifier changes', () {
        final List<String> listener1Notifications = [];
        final List<String> listener2Notifications = [];

        combinedNotifier.addListener(() {
          listener1Notifications.add('listener1');
        });

        combinedNotifier.addListener(() {
          listener2Notifications.add('listener2');
        });

        notifier1.notifyListeners();

        expect(listener1Notifications.length, equals(1));
        expect(listener2Notifications.length, equals(1));
        expect(notifications.length, equals(1)); // Original listener

        notifier2.notifyListeners();

        expect(listener1Notifications.length, equals(2));
        expect(listener2Notifications.length, equals(2));
        expect(notifications.length, equals(2)); // Original listener
      });

      test('should handle listener removal correctly', () {
        final List<String> tempNotifications = [];

        void tempListener() {
          tempNotifications.add('temp');
        }

        combinedNotifier.addListener(tempListener);

        notifier1.notifyListeners();
        expect(tempNotifications.length, equals(1));
        expect(notifications.length, equals(1));

        combinedNotifier.removeListener(tempListener);

        notifier2.notifyListeners();
        expect(tempNotifications.length, equals(1)); // Should not increase
        expect(notifications.length, equals(2)); // Original listener still active
      });
    });

    group('Dispose Functionality', () {
      test('should remove listeners from both notifiers when disposed', () {
        // Create a separate test to verify disposal
        final testNotifier1 = ChangeNotifier();
        final testNotifier2 = ChangeNotifier();
        final testCombined = CombinedChangeNotifier(testNotifier1, testNotifier2);

        final List<String> testNotifications = [];
        testCombined.addListener(() {
          testNotifications.add('test');
        });

        // Verify listeners are working
        testNotifier1.notifyListeners();
        expect(testNotifications.length, equals(1));

        // Dispose the combined notifier
        testCombined.dispose();

        // After disposal, notifications should not be forwarded
        testNotifier1.notifyListeners();
        testNotifier2.notifyListeners();
        expect(testNotifications.length, equals(1)); // Should remain the same

        // Clean up
        testNotifier1.dispose();
        testNotifier2.dispose();
      });

      test('should handle multiple disposal attempts gracefully', () {
        // First disposal should work normally
        expect(() => combinedNotifier.dispose(), returnsNormally);

        // Second disposal might throw in debug mode, but should be handled gracefully
        // In production, Flutter's ChangeNotifier allows multiple disposals
        try {
          combinedNotifier.dispose();
        } catch (e) {
          // In debug mode, Flutter throws when disposing already disposed notifiers
          expect(e, isA<FlutterError>());
        }
      });

      test('should handle disposal when original notifiers are also disposed', () {
        notifier1.dispose();
        notifier2.dispose();

        // In debug mode, this might throw since we're disposing notifiers that are already disposed
        try {
          combinedNotifier.dispose();
        } catch (e) {
          expect(e, isA<FlutterError>());
        }
      });
    });

    group('Edge Cases', () {
      test('should handle notifiers that are already disposed', () {
        final disposedNotifier1 = ChangeNotifier();
        final disposedNotifier2 = ChangeNotifier();

        disposedNotifier1.dispose();
        disposedNotifier2.dispose();

        // Creating with disposed notifiers might work, but disposal behavior varies in debug/release
        try {
          final combined = CombinedChangeNotifier(disposedNotifier1, disposedNotifier2);
          try {
            combined.dispose();
          } catch (e) {
            // Disposal might throw in debug mode
            expect(e, isA<FlutterError>());
          }
        } catch (e) {
          // Creating might also throw in debug mode
          expect(e, isA<FlutterError>());
        }
      });

      test('should handle the same notifier used for both parameters', () {
        final sameNotifier = ChangeNotifier();
        final combined = CombinedChangeNotifier(sameNotifier, sameNotifier);

        final List<String> testNotifications = [];
        combined.addListener(() {
          testNotifications.add('same_notifier');
        });

        // When the same notifier fires, it should trigger the combined notifier twice
        // (once for each listener it adds)
        sameNotifier.notifyListeners();

        expect(testNotifications.length, equals(2)); // Should be called twice

        combined.dispose();
        sameNotifier.dispose();
      });

      test('should handle notifiers with existing listeners', () {
        final preListenerNotifier1 = ChangeNotifier();
        final preListenerNotifier2 = ChangeNotifier();

        final List<String> preExistingNotifications = [];

        // Add listeners before creating combined notifier
        preListenerNotifier1.addListener(() {
          preExistingNotifications.add('pre1');
        });

        preListenerNotifier2.addListener(() {
          preExistingNotifications.add('pre2');
        });

        final combined = CombinedChangeNotifier(preListenerNotifier1, preListenerNotifier2);

        final List<String> combinedNotifications = [];
        combined.addListener(() {
          combinedNotifications.add('combined');
        });

        // Fire notifications - should trigger both pre-existing and combined listeners
        preListenerNotifier1.notifyListeners();

        expect(preExistingNotifications, contains('pre1'));
        expect(combinedNotifications, contains('combined'));

        preListenerNotifier2.notifyListeners();

        expect(preExistingNotifications, contains('pre2'));
        expect(combinedNotifications.length, equals(2));

        combined.dispose();
        preListenerNotifier1.dispose();
        preListenerNotifier2.dispose();
      });
    });

    group('Integration Tests', () {
      test('should work correctly in a typical Flutter use case scenario', () {
        // Simulate a typical Flutter scenario with ValueNotifiers
        final ValueNotifier<int> counter1 = ValueNotifier<int>(0);
        final ValueNotifier<String> text = ValueNotifier<String>('initial');

        final combined = CombinedChangeNotifier(counter1, text);

        final List<Map<String, dynamic>> stateChanges = [];

        combined.addListener(() {
          stateChanges.add({
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'counter': counter1.value,
            'text': text.value,
          });
        });

        // Simulate state changes
        counter1.value = 1;
        expect(stateChanges.length, equals(1));
        expect(stateChanges.last['counter'], equals(1));

        text.value = 'updated';
        expect(stateChanges.length, equals(2));
        expect(stateChanges.last['text'], equals('updated'));

        counter1.value = 2;
        text.value = 'final';
        expect(stateChanges.length, equals(4)); // This is incorrect - should be 4

        combined.dispose();
        counter1.dispose();
        text.dispose();
      });
    });
  });
}
