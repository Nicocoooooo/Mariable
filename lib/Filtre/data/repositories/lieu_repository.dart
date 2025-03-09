import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lieu_type_model.dart';

/// Repository class for all lieu-related data operations
class LieuRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all lieu types from the database
  Future<List<LieuTypeModel>> getLieuTypes() async {
    try {
      final response = await _client
          .from('lieu_type')
          .select('id, name, description, image_url')
          .order('id', ascending: true);

      return (response as List)
          .map((item) => LieuTypeModel.fromMap(item))
          .toList();
    } catch (e) {
      // You might want to log the error or handle it differently based on your needs
      rethrow;
    }
  }

  /// Fetch lieux by type
  Future<List<Map<String, dynamic>>> getLieuxByType(int typeId) async {
    try {
      final response = await _client
          .from('lieux')
          .select('*')
          .eq('type_lieu', typeId)
          .eq('actif', true)
          .order('note_moyenne', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Search lieux by name and type
  Future<List<Map<String, dynamic>>> searchLieux({
    String? query,
    int? typeId,
    String? region,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      var request = _client.from('lieux').select('*').eq('actif', true);

      if (query != null && query.isNotEmpty) {
        request = request.ilike('nom', '%$query%');
      }

      if (typeId != null) {
        request = request.eq('type_lieu', typeId);
      }

      if (region != null && region.isNotEmpty) {
        request = request.eq('region', region);
      }

      if (minPrice != null) {
        request = request.gte('prix_base', minPrice);
      }

      if (maxPrice != null) {
        request = request.lte('prix_base', maxPrice);
      }

      final response = await request.order('note_moyenne', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}