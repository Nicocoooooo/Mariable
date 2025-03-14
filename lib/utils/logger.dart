// Créez un nouveau fichier lib/utils/logger.dart

import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

   static void debug(String message) {
    print('[DEBUG] $message');
  }

  static void info(String message) {
    print('[INFO] $message');
  }

  static void warning(String message) {
    print('[WARNING] $message');
  }

  static void error(String message, [dynamic error]) {
    print('[ERROR] $message');
    if (error != null) {
      print('[ERROR DETAILS] $error');
    }
  }

  static void supabaseRequest(String method, String table, Map<String, dynamic>? params) {
    _logger.i('Supabase Request: $method on $table with params: $params');
  }

  static void supabaseResponse(String method, String table, dynamic response) {
    if (response is List) {
      _logger.i('Supabase Response: $method on $table returned ${response.length} items');
    } else {
      _logger.i('Supabase Response: $method on $table successful');
    }
  }

  static void supabaseError(String method, String table, dynamic error) {
    _logger.e('Supabase Error: $method on $table failed: $error');
  }
}