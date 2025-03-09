import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/presta_type_model.dart';

/// Repository class for all prestataire-related data operations
class PrestaRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all prestataire types from the database
  Future<List<PrestaTypeModel>> getPrestaTypes() async {
    try {
      final response = await _client
          .from('presta_type')
          .select('id, name, description, image_url')
          .order('id', ascending: true);

      return (response as List)
          .map((item) => PrestaTypeModel.fromMap(item))
          .toList();
    } catch (e) {
      // You might want to log the error or handle it differently based on your needs
      rethrow;
    }
  }

  /// Fetch prestataires by type
  Future<List<Map<String, dynamic>>> getPrestairesByType(int typeId) async {
    try {
      final response = await _client
          .from('presta')
          .select('*')
          .eq('type_presta', typeId)
          .eq('actif', true)
          .order('note_moyenne', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Search prestataires by name and type
  Future<List<Map<String, dynamic>>> searchPrestataires({
    String? query,
    int? typeId,
    String? region,
  }) async {
    try {
      var request = _client.from('presta').select('*').eq('actif', true);

      if (query != null && query.isNotEmpty) {
        request = request.ilike('nom_entreprise', '%$query%');
      }

      if (typeId != null) {
        request = request.eq('type_presta', typeId);
      }

      if (region != null && region.isNotEmpty) {
        request = request.eq('region', region);
      }

      final response = await request.order('note_moyenne', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}