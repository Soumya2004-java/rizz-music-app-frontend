import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

@immutable
class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  UserAccount copyWith({String? name, String? email, String? password}) {
    return UserAccount(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class AuthStore {
  AuthStore._();

  static const String _loginPath = String.fromEnvironment(
    'AUTH_LOGIN_PATH',
    defaultValue: '/auth/login',
  );
  static const String _registerPath = String.fromEnvironment(
    'AUTH_REGISTER_PATH',
    defaultValue: '/auth/register',
  );
  static const String _changePasswordPath = String.fromEnvironment(
    'AUTH_CHANGE_PASSWORD_PATH',
    defaultValue: '/auth/change-password',
  );

  static final Map<String, UserAccount> _accountsByEmail = {
    'demo@rizz.app': const UserAccount(
      name: 'Demo User',
      email: 'demo@rizz.app',
      password: '123456',
    ),
  };

  static final ValueNotifier<UserAccount?> currentUser =
      ValueNotifier<UserAccount?>(null);

  static bool get isSignedIn => currentUser.value != null;

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final response = await _post(
      _registerPath,
      body: {
        'name': name.trim(),
        'email': normalizedEmail,
        'password': password,
      },
    );
    if (response.errorMessage != null) {
      return response.errorMessage;
    }

    final account = _accountFromResponse(
      response.json,
      fallbackName: name.trim(),
      fallbackEmail: normalizedEmail,
      fallbackPassword: password,
    );

    _accountsByEmail[normalizedEmail] = account;
    currentUser.value = account;
    return null;
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final response = await _post(
      _loginPath,
      body: {'email': normalizedEmail, 'password': password},
    );
    if (response.errorMessage != null) {
      return response.errorMessage;
    }

    final cached = _accountsByEmail[normalizedEmail];
    final account = _accountFromResponse(
      response.json,
      fallbackName: cached?.name ?? normalizedEmail.split('@').first,
      fallbackEmail: normalizedEmail,
      fallbackPassword: password,
    );

    _accountsByEmail[normalizedEmail] = account;
    currentUser.value = account;
    return null;
  }

  static Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final signedInUser = currentUser.value;
    if (signedInUser == null) return 'No active account found.';

    final response = await _put(
      _changePasswordPath,
      body: {
        'email': signedInUser.email,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    if (response.errorMessage != null) {
      return response.errorMessage;
    }

    final updated = signedInUser.copyWith(password: newPassword);
    _accountsByEmail[updated.email] = updated;
    currentUser.value = updated;
    return null;
  }

  static void signOut() {
    currentUser.value = null;
  }

  static Future<_ApiResponse> _post(
    String path, {
    required Map<String, dynamic> body,
  }) {
    return _send('POST', path, body);
  }

  static Future<_ApiResponse> _put(
    String path, {
    required Map<String, dynamic> body,
  }) {
    return _send('PUT', path, body);
  }

  static Future<_ApiResponse> _send(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = ApiConfig.uri(path);
      final headers = {'Content-Type': 'application/json'};
      late final http.Response response;
      if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      } else {
        response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      }

      Map<String, dynamic>? json;
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _ApiResponse(json: json);
      }

      return _ApiResponse(
        json: json,
        errorMessage:
            _extractMessage(json) ??
            'Request failed (${response.statusCode}) on $path.',
      );
    } catch (e) {
      final details = kDebugMode ? ' (${e.toString()})' : '';
      return _ApiResponse(
        errorMessage:
            'Could not connect to backend API. Verify API_BASE_URL and server status.$details',
      );
    }
  }

  static UserAccount _accountFromResponse(
    Map<String, dynamic>? json, {
    required String fallbackName,
    required String fallbackEmail,
    required String fallbackPassword,
  }) {
    final data = _extractDataMap(json);
    final name = _readString(data, const ['name', 'fullName']) ?? fallbackName;
    final email =
        _readString(data, const ['email', 'username']) ?? fallbackEmail;

    return UserAccount(name: name, email: email, password: fallbackPassword);
  }

  static Map<String, dynamic>? _extractDataMap(Map<String, dynamic>? json) {
    if (json == null) return null;
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static String? _extractMessage(Map<String, dynamic>? json) {
    if (json == null) return null;
    return _readString(json, const [
      'message',
      'error',
      'detail',
      'description',
    ]);
  }

  static String? _readString(Map<String, dynamic>? json, List<String> keys) {
    if (json == null) return null;
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

@immutable
class _ApiResponse {
  const _ApiResponse({this.json, this.errorMessage});

  final Map<String, dynamic>? json;
  final String? errorMessage;
}
