import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/tweet/_video.dart';

void main() {
  group('Video Module', () {
    test('should have TweetVideo widget', () {
      expect(TweetVideo, isA<Type>());
    });

    test('should have TweetVideoUrls class', () {
      expect(TweetVideoUrls, isA<Type>());
    });

    test('should have TweetVideoMetadata class', () {
      expect(TweetVideoMetadata, isA<Type>());
    });

    test('should have VideoContextState class', () {
      expect(VideoContextState, isA<Type>());
    });

    group('TweetVideoUrls', () {
      test('should create TweetVideoUrls with streamUrl and downloadUrl', () {
        final urls = TweetVideoUrls('https://example.com/stream', 'https://example.com/download');

        expect(urls.streamUrl, equals('https://example.com/stream'));
        expect(urls.downloadUrl, equals('https://example.com/download'));
      });

      test('should create TweetVideoUrls with null downloadUrl', () {
        final urls = TweetVideoUrls('https://example.com/stream', null);

        expect(urls.streamUrl, equals('https://example.com/stream'));
        expect(urls.downloadUrl, isNull);
      });
    });

    group('VideoContextState', () {
      test('should create VideoContextState with initial mute state', () {
        final state = VideoContextState(true);

        expect(state.isMuted, isTrue);
      });

      test('should update mute state when setIsMuted is called', () {
        final state = VideoContextState(false);

        expect(state.isMuted, isFalse);

        state.setIsMuted(0.0);
        expect(state.isMuted, isTrue);

        state.setIsMuted(1.0);
        expect(state.isMuted, isFalse);
      });
    });
  });
}
