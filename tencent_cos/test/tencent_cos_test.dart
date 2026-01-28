import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_cos/tencent_cos.dart';

void main() {
  group('TencentCosConfig', () {
    test('creates config with required fields', () {
      final config = TencentCosConfig(
        appId: 'app1',
        bucketName: 'bucket1',
        region: 'ap-guangzhou',
      );
      expect(config.appId, 'app1');
      expect(config.bucketName, 'bucket1');
      expect(config.region, 'ap-guangzhou');
      expect(config.useSessionToken, true);
      expect(config.useScopeLimitToken, false);
      expect(config.isDebuggable, false);
    });

    test('creates config with optional fields', () {
      final config = TencentCosConfig(
        appId: 'app1',
        bucketName: 'bucket1',
        region: 'ap-guangzhou',
        useSessionToken: false,
        secretId: 'sid',
        secretKey: 'skey',
        isDebuggable: true,
      );
      expect(config.secretId, 'sid');
      expect(config.secretKey, 'skey');
      expect(config.isDebuggable, true);
    });

    test('creates config with custom folder prefixes', () {
      final config = TencentCosConfig(
        appId: 'app1',
        bucketName: 'bucket1',
        region: 'ap-guangzhou',
        imagesPrefix: 'avatars',
        videosPrefix: 'media',
      );
      expect(config.imagesPrefix, 'avatars');
      expect(config.videosPrefix, 'media');
    });

    test('default folder prefixes are images and videos', () {
      final config = TencentCosConfig(
        appId: 'app1',
        bucketName: 'bucket1',
        region: 'ap-guangzhou',
      );
      expect(config.imagesPrefix, 'images');
      expect(config.videosPrefix, 'videos');
    });
  });

  group('TencentCosClient', () {
    test('instance throws before initialize', () {
      expect(
        () => TencentCosClient.instance,
        throwsStateError,
      );
    });
  });

  group('CosCredentialsException', () {
    test('toString includes message', () {
      final e = CosCredentialsException('test message');
      expect(e.toString(), contains('CosCredentialsException'));
      expect(e.toString(), contains('test message'));
    });

    test('toString includes cause when provided', () {
      final e = CosCredentialsException('msg', ArgumentError('cause'));
      expect(e.toString(), contains('msg'));
      expect(e.toString(), contains('cause'));
    });
  });
}
