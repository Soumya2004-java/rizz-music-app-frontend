import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // Override with:
  // flutter run --dart-define=API_BASE_URL=http://<your-host>:<port>
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) return configured;

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8080';
    }
  }

  static Uri uri(String path, {Map<String, String>? queryParameters}) {
    final base = Uri.parse(baseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(
      path: '${base.path}$normalizedPath'.replaceAll('//', '/'),
      queryParameters: queryParameters,
    );
  }
}
