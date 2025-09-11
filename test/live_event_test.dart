import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/live_event/live_event.dart';

void main() {
  group('LiveEventScreenArguments', () {
    test('should be able to import LiveEventScreenArguments', () {
      // This test simply verifies that the module can be imported without errors
      expect(LiveEventScreenArguments, isNotNull);
    });

    test('should have required constructor parameters', () {
      // Verify that the class can be instantiated with required parameters
      expect(LiveEventScreenArguments, isNotNull);
      expect(
        () => LiveEventScreenArguments(url: 'https://example.com/live', title: 'Test Live Event'),
        returnsNormally,
      );
    });
  });

  group('BroadcastScreenArguments', () {
    test('should be able to import BroadcastScreenArguments', () {
      // This test simply verifies that the module can be imported without errors
      expect(BroadcastScreenArguments, isNotNull);
    });

    test('should have required constructor parameters', () {
      // Verify that the class can be instantiated with required parameters
      expect(BroadcastScreenArguments, isNotNull);
      expect(
        () => BroadcastScreenArguments(url: 'https://example.com/broadcast', title: 'Test Broadcast'),
        returnsNormally,
      );
    });
  });
}
