import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/database/repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  group('Repository', () {
    setUpAll(() {
      databaseFactory = databaseFactoryFfi;
    });

    test('should migrate the database', () async {
      // Arrange
      final repository = Repository();

      // Act
      final result = await repository.migrate();

      // Assert
      expect(result, true);

      // Open the actual database to check if the tables were created
      final database = await Repository.writable();

      // Check if the tables were created
      final tables = await database.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
      final tableNames = tables.map((e) => e['name']).toList();

      expect(tableNames, contains(tableFeedGroupChunk));
      expect(tableNames, contains(tableFeedGroupPositionState));
      expect(tableNames, contains(tableSavedTweet));
      expect(tableNames, contains(tableSearchSubscription));
      expect(tableNames, contains(tableSearchSubscriptionGroupMember));
      expect(tableNames, contains(tableSubscription));
      expect(tableNames, contains(tableSubscriptionGroup));
      expect(tableNames, contains(tableSubscriptionGroupMember));
      expect(tableNames, contains(tableRateLimits));
      expect(tableNames, contains(tableTwitterToken));
      expect(tableNames, contains(tableTwitterProfile));

      await database.close();
    });
  });
}
