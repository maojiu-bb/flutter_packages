import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tencent_cos/src/config/cos_config.dart';
import 'package:tencentcloud_cos_sdk_plugin/fetch_credentials.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

/// Exception thrown when STS credential fetch fails (network, invalid response, or non-OK status).
class CosCredentialsException implements Exception {
  CosCredentialsException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'CosCredentialsException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Fetches STS session (temporary) credentials from [CosConfig.STS_URL].
/// Expects JSON: { credentials: { tmpSecretId, tmpSecretKey, sessionToken }, startTime, expiredTime }.
class FetchCredentials implements IFetchCredentials {
  @override
  Future<SessionQCloudCredentials> fetchSessionCredentials() async {
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(Uri.parse(CosConfig.STS_URL));
      final response = await request.close();
      final json = await response.transform(utf8.decoder).join();
      if (kDebugMode) {
        print('[COS] STS response: $json');
      }
      if (response.statusCode != HttpStatus.OK) {
        throw CosCredentialsException(
          'STS request failed: ${response.statusCode}',
        );
      }
      final data = jsonDecode(json) as Map<String, dynamic>;
      final creds = data['credentials'] as Map<String, dynamic>?;
      if (creds == null) {
        throw CosCredentialsException('STS response missing credentials');
      }
      return SessionQCloudCredentials(
        secretId: creds['tmpSecretId'] as String,
        secretKey: creds['tmpSecretKey'] as String,
        token: creds['sessionToken'] as String,
        startTime: data['startTime'] as int,
        expiredTime: data['expiredTime'] as int,
      );
    } catch (e) {
      if (e is CosCredentialsException) rethrow;
      if (kDebugMode) {
        print('[COS] STS fetch error: $e');
      }
      throw CosCredentialsException('Failed to fetch STS credentials', e);
    } finally {
      httpClient.close(force: true);
    }
  }
}

/// Fetches scope-limited STS credentials from [CosConfig.STS_SCOPE_LIMIT_URL].
class FetchScopeLimitCredentials implements IFetchScopeLimitCredentials {
  @override
  Future<SessionQCloudCredentials> fetchScopeLimitCredentials(
    List<STSCredentialScope?> stsCredentialScopes,
  ) async {
    final httpClient = HttpClient();
    try {
      final request = await httpClient.postUrl(
        Uri.parse(CosConfig.STS_SCOPE_LIMIT_URL),
      );
      request.headers.contentType = ContentType.json;
      final body = _jsonifyScopes(stsCredentialScopes);
      if (kDebugMode) {
        print('[COS] STS scope limit request body: $body');
      }
      request.write(body);

      final response = await request.close();
      final json = await response.transform(utf8.decoder).join();
      if (kDebugMode) {
        print('[COS] STS scope limit response: $json');
      }
      if (response.statusCode != HttpStatus.OK) {
        throw CosCredentialsException(
          'STS scope limit request failed: ${response.statusCode}',
        );
      }
      final data = jsonDecode(json) as Map<String, dynamic>;
      final creds = data['credentials'] as Map<String, dynamic>?;
      if (creds == null) {
        throw CosCredentialsException('STS response missing credentials');
      }
      return SessionQCloudCredentials(
        secretId: creds['tmpSecretId'] as String,
        secretKey: creds['tmpSecretKey'] as String,
        token: creds['sessionToken'] as String,
        startTime: data['startTime'] as int,
        expiredTime: data['expiredTime'] as int,
      );
    } catch (e) {
      if (e is CosCredentialsException) rethrow;
      if (kDebugMode) {
        print('[COS] STS scope limit fetch error: $e');
      }
      throw CosCredentialsException(
        'Failed to fetch scope-limited STS credentials',
        e,
      );
    } finally {
      httpClient.close(force: true);
    }
  }

  static String _jsonifyScopes(List<STSCredentialScope?> scopes) {
    final scopeList = <Map<String, String?>>[];
    for (final scope in scopes) {
      if (scope != null) {
        scopeList.add({
          'action': scope.action,
          'bucket': scope.bucket,
          'prefix': scope.prefix,
          'region': scope.region,
        });
      }
    }
    return jsonEncode(scopeList);
  }
}
