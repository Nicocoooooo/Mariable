import 'package:logger/logger.dart';

/// Classe utilitaire pour la journalisation dans l'application
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

  /// Journalisation de niveau debug
  static void debug(String message) {
    print('[DEBUG] $message');
    _logger.d(message);
  }

  /// Journalisation de niveau info
  static void info(String message) {
    print('[INFO] $message');
    _logger.i(message);
  }

  /// Journalisation de niveau avertissement
  static void warning(String message) {
    print('[WARNING] $message');
    _logger.w(message);
  }

  /// Journalisation de niveau erreur
  static void error(String message, [Object? err]) {
    print('[ERROR] $message');
    if (err != null) {
      print('[ERROR DETAILS] $err');
    }
   
    // Correction : vérifier si err est null avant de l'utiliser
    if (err != null) {
      // Utiliser error comme paramètre nommé
      _logger.e(message, error: err);
    } else {
      _logger.e(message);
    }
  }

  /// Journalisation de requêtes Supabase
  static void supabaseRequest(String method, String table, Map<String, dynamic>? params) {
    _logger.i('Supabase Request: $method on $table with params: $params');
  }

  /// Journalisation de réponses Supabase
  static void supabaseResponse(String method, String table, dynamic response) {
    if (response is List) {
      _logger.i('Supabase Response: $method on $table returned ${response.length} items');
    } else {
      _logger.i('Supabase Response: $method on $table successful');
    }
  }

  /// Journalisation d'erreurs Supabase
  static void supabaseError(String method, String table, Object? err) {
    String errorMessage = 'Supabase Error: $method on $table failed: $err';
    print(errorMessage);
   
    // Correction : utiliser error comme paramètre nommé
    if (err != null) {
      _logger.e(errorMessage, error: err);
    } else {
      _logger.e(errorMessage);
    }
  }
}