import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../storage/token_storage.dart';
import '../utils/env_config.dart';
import 'api_error_mapper.dart';
import 'api_exception.dart';

/// Centralized HTTP Client with Bearer token authentication, timeout handling,
/// and automated error mapping.
class ApiClient {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 30);

  /// Global callback triggered on any HTTP 401 Unauthorized response
  /// to enable automated session termination and redirection to login.
  static void Function()? onUnauthorized;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Builds request headers including JSON content type and Authorization token.
  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Resolves full URL from an endpoint path.
  Uri _resolveUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final base = EnvConfig.apiBaseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    var uri = Uri.parse('$base$cleanEndpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters
          .where((key, value) => value != null)
          .map((key, value) => MapEntry(key, value.toString()));
      uri = uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  /// Sends a POST request.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final uri = _resolveUri(endpoint);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('[ApiClient] SocketException on $uri: $e');
      throw const ApiException(
        statusCode: 0,
        rawMessage: 'SocketException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on TimeoutException catch (e) {
      debugPrint('[ApiClient] TimeoutException on $uri: $e');
      throw const ApiException(
        statusCode: 408,
        rawMessage: 'TimeoutException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiClient] Unexpected error on $uri: $e');
      throw const ApiException(
        statusCode: 500,
        rawMessage: 'Unexpected Client Error',
        userMessage: ApiErrorMapper.defaultErrorMessage,
      );
    }
  }

  /// Sends a PATCH request.
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = _resolveUri(endpoint);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('[ApiClient] SocketException on $uri: $e');
      throw const ApiException(
        statusCode: 0,
        rawMessage: 'SocketException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on TimeoutException catch (e) {
      debugPrint('[ApiClient] TimeoutException on $uri: $e');
      throw const ApiException(
        statusCode: 408,
        rawMessage: 'TimeoutException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiClient] Unexpected error on $uri: $e');
      throw const ApiException(
        statusCode: 500,
        rawMessage: 'Unexpected Client Error',
        userMessage: ApiErrorMapper.defaultErrorMessage,
      );
    }
  }

  /// Sends a PUT request.
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = _resolveUri(endpoint);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('[ApiClient] SocketException on $uri: $e');
      throw const ApiException(
        statusCode: 0,
        rawMessage: 'SocketException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on TimeoutException catch (e) {
      debugPrint('[ApiClient] TimeoutException on $uri: $e');
      throw const ApiException(
        statusCode: 408,
        rawMessage: 'TimeoutException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiClient] Unexpected error on $uri: $e');
      throw const ApiException(
        statusCode: 500,
        rawMessage: 'Unexpected Client Error',
        userMessage: ApiErrorMapper.defaultErrorMessage,
      );
    }
  }

  /// Sends a GET request.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final uri = _resolveUri(endpoint, queryParameters);
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await _client.get(uri, headers: headers).timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        rawMessage: 'SocketException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        rawMessage: 'TimeoutException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        statusCode: 500,
        rawMessage: 'Unexpected Client Error',
        userMessage: ApiErrorMapper.defaultErrorMessage,
      );
    }
  }

  /// Sends a multipart POST request (e.g. for photo or PDF document uploads).
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    required String fileField,
    required File file,
    MediaType? contentType,
    bool requiresAuth = true,
  }) async {
    final uri = _resolveUri(endpoint);
    try {
      final request = http.MultipartRequest('POST', uri);
      if (requiresAuth) {
        final token = await TokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }
      final ext = file.path.split('.').last.toLowerCase();
      final MediaType resolvedType;
      if (contentType != null) {
        resolvedType = contentType;
      } else if (ext == 'pdf') {
        resolvedType = MediaType('application', 'pdf');
      } else {
        final mimeSubtype = ext == 'png' ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
        resolvedType = MediaType('image', mimeSubtype);
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          file.path,
          contentType: resolvedType,
        ),
      );

      final streamedResponse = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('[ApiClient] SocketException on $uri: $e');
      throw const ApiException(
        statusCode: 0,
        rawMessage: 'SocketException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on TimeoutException catch (e) {
      debugPrint('[ApiClient] TimeoutException on $uri: $e');
      throw const ApiException(
        statusCode: 408,
        rawMessage: 'TimeoutException',
        userMessage: ApiErrorMapper.networkErrorMessage,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiClient] Unexpected error on $uri: $e');
      throw const ApiException(
        statusCode: 500,
        rawMessage: 'Unexpected Client Error',
        userMessage: ApiErrorMapper.defaultErrorMessage,
      );
    }
  }

  /// Handles response payload and parses status codes.
  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data = {};
    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      }
    } catch (_) {
      // Body not JSON
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final rawMessage = data['message'] as String? ?? 'HTTP ${response.statusCode}';
    final rawError = data['error'] as String?;
    final rawDetails = data['details'] as List<dynamic>?;

    final userMessage = ApiErrorMapper.mapStatusToUserMessage(
      statusCode: response.statusCode,
      rawMessage: rawMessage,
      details: rawDetails,
    );

    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }

    throw ApiException(
      statusCode: response.statusCode,
      rawMessage: rawMessage,
      userMessage: userMessage,
      error: rawError,
      details: rawDetails,
    );
  }
}

extension _MapFilterExtension<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K key, V value) test) {
    final result = <K, V>{};
    forEach((key, value) {
      if (test(key, value)) {
        result[key] = value;
      }
    });
    return result;
  }
}
