import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/crypto_util.dart';

void main() {
  group('Crypto Utilities', () {
    test('should have OAuth constants defined', () {
      expect(oauthConsumerKey, isNotEmpty);
      expect(oauthConsumerSecret, isNotEmpty);
      expect(oauthConsumerKey, '3nVuSoBZnx6U4vzUxf5w');
      expect(oauthConsumerSecret, 'Bcs59EFbbsdF6Sl9Ng71smgStWEGwXXKSjYvPVt7qys');
    });

    group('nonce', () {
      test('should generate a random nonce', () {
        final nonce1 = nonce();
        final nonce2 = nonce();

        expect(nonce1, isA<String>());
        expect(nonce2, isA<String>());
        expect(nonce1, isNot(equals(nonce2))); // Should be different
      });

      test('should generate nonce without special characters', () {
        final result = nonce();

        expect(result, isNotEmpty);
        expect(result.contains('='), false);
        expect(result.contains('/'), false);
        expect(result.contains('+'), false);
      });

      test('should generate nonce of reasonable length', () {
        final result = nonce();

        expect(result.length, greaterThan(10));
        expect(result.length, lessThan(100));
      });
    });

    group('hmacSHA1', () {
      test('should compute HMAC-SHA1', () async {
        final result = await hmacSHA1('key', 'message');

        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should produce consistent results', () async {
        final result1 = await hmacSHA1('testkey', 'testmessage');
        final result2 = await hmacSHA1('testkey', 'testmessage');

        expect(result1, equals(result2));
      });

      test('should produce different results for different inputs', () async {
        final result1 = await hmacSHA1('key1', 'message');
        final result2 = await hmacSHA1('key2', 'message');
        final result3 = await hmacSHA1('key1', 'different');

        expect(result1, isNot(equals(result2)));
        expect(result1, isNot(equals(result3)));
      });

      test('should handle minimal strings', () async {
        final result = await hmacSHA1('k', 'm');

        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });
    });

    group('aesGcm256Encrypt and aesGcm256Decrypt', () {
      test('should encrypt and decrypt text correctly', () async {
        const key = 'testkey123';
        const plaintext = 'Hello, World!';

        final encrypted = await aesGcm256Encrypt(key, plaintext);
        final decrypted = await aesGcm256Decrypt(key, encrypted);

        expect(encrypted, isA<String>());
        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(plaintext)));
        expect(decrypted, equals(plaintext));
      });

      test('should produce different encrypted output each time', () async {
        const key = 'testkey123';
        const plaintext = 'Hello, World!';

        final encrypted1 = await aesGcm256Encrypt(key, plaintext);
        final encrypted2 = await aesGcm256Encrypt(key, plaintext);

        expect(encrypted1, isNot(equals(encrypted2))); // Due to random nonce
      });

      test('should handle empty text', () async {
        const key = 'testkey123';
        const plaintext = '';

        final encrypted = await aesGcm256Encrypt(key, plaintext);
        final decrypted = await aesGcm256Decrypt(key, encrypted);

        expect(decrypted, equals(plaintext));
      });

      test('should handle long text', () async {
        const key = 'testkey123';
        final plaintext = 'A' * 1000; // 1000 character string

        final encrypted = await aesGcm256Encrypt(key, plaintext);
        final decrypted = await aesGcm256Decrypt(key, encrypted);

        expect(decrypted, equals(plaintext));
      });

      test('should handle special characters', () async {
        const key = 'testkey123';
        const plaintext = 'Hello 世界! 🌍 @#\$%^&*()';

        final encrypted = await aesGcm256Encrypt(key, plaintext);
        final decrypted = await aesGcm256Decrypt(key, encrypted);

        expect(decrypted, equals(plaintext));
      });
    });

    group('sha1Hash', () {
      test('should compute SHA1 hash', () async {
        final result = await sha1Hash('hello');

        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result.length, equals(40)); // SHA1 hex string length
      });

      test('should produce consistent results', () async {
        final result1 = await sha1Hash('test');
        final result2 = await sha1Hash('test');

        expect(result1, equals(result2));
      });

      test('should produce different hashes for different inputs', () async {
        final result1 = await sha1Hash('test1');
        final result2 = await sha1Hash('test2');

        expect(result1, isNot(equals(result2)));
      });

      test('should handle empty string', () async {
        final result = await sha1Hash('');

        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result.length, equals(40));
      });

      test('should produce hex output', () async {
        final result = await sha1Hash('test');

        expect(RegExp(r'^[0-9a-f]{40}$').hasMatch(result), true);
      });
    });
  });
}
