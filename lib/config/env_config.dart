import 'package:dotenv/dotenv.dart';

class EnvConfig {
  static bool _initialized = false;
  static final DotEnv _env = DotEnv(includePlatformEnvironment: true);

  static void init() {
    if (_initialized) return;

    _env.load();
    _initialized = true;
  }

  static String get(String key, {String? fallback}) {
    init();

    final value = _env[key];

    if (value == null || value.isEmpty) {
      if (fallback != null) return fallback;
      throw Exception("Missing environment variable: $key");
    }

    return value;
  }

  /// REQUIRED (no fallback allowed)
  static String get mongoUri {
    init();

    final uri = _env['MONGO_URI'];

    if (uri == null || uri.trim().isEmpty) {
      throw Exception("MONGO_URI is missing in .env");
    }

    return uri.trim();
  }

  static int get port {
    return int.tryParse(get('PORT', fallback: '8080')) ?? 8080;
  }
}