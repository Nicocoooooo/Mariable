// Créez un nouveau fichier lib/utils/supabase_test.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseTest {
  static Future<bool> testConnection() async {
    try {
      AppLogger.info('Testing Supabase connection...');
      
      final client = Supabase.instance.client;
      
      // Test simple pour vérifier que nous pouvons nous connecter à Supabase
      final response = await client.from('presta_type').select('id').limit(1);
      
      AppLogger.info('Supabase connection successful: ${response != null}');
      return true;
    } catch (e) {
      AppLogger.error('Supabase connection test failed', e);
      return false;
    }
  }
  
  static Future<Map<String, bool>> testTables() async {
    final Map<String, bool> results = {};
    final List<String> tables = [
      'presta_type',
      'presta',
      'lieu_type',
      'lieux',
      'tarifs',
      'reservations',
      'avis'
    ];
    
    final client = Supabase.instance.client;
    
    for (var table in tables) {
      try {
        AppLogger.info('Testing table: $table');
        final response = await client.from(table).select('*').limit(1);
        results[table] = true;
        AppLogger.info('Table $table is accessible');
      } catch (e) {
        results[table] = false;
        AppLogger.error('Failed to access table: $table', e);
      }
    }
    
    return results;
  }
  
  static Future<void> logTableStructures() async {
    final List<String> tables = [
      'presta_type',
      'presta',
      'lieu_type',
      'lieux',
      'tarifs',
      'reservations',
      'avis'
    ];
    
    final client = Supabase.instance.client;
    
    for (var table in tables) {
      try {
        final response = await client.rpc('get_table_columns', params: {'table_name': table});
        AppLogger.info('Table structure for $table:');
        AppLogger.info(response.toString());
      } catch (e) {
        AppLogger.error('Failed to get structure for table: $table', e);
      }
    }
  }
}