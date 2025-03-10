// Mise à jour de la classe PrestaRepository dans lib/Filtre/data/repositories/presta_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/presta_type_model.dart';
import 'package:logger/logger.dart';

class PrestaRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final Logger _logger = Logger();

  /// Fetch all prestataire types from the database
  Future<List<PrestaTypeModel>> getPrestaTypes() async {
    try {
      _logger.d('Fetching prestataire types');
      final response = await _client
          .from('presta_type')
          .select('id, name, description, image_url')
          .order('id', ascending: true);

      _logger.d('Received ${response.length} prestataire types');
      return (response as List)
          .map((item) => PrestaTypeModel.fromMap(item))
          .toList();
    } catch (e) {
      _logger.e('Error fetching prestataire types: $e');
      rethrow;
    }
  }

  /// Fetch prestataires by type
  Future<List<Map<String, dynamic>>> getPrestairesByType(int typeId) async {
    try {
      _logger.d('Fetching prestataires by type: $typeId');
      final response = await _client
          .from('presta')
          .select('*, tarifs(*)') // Sélectionne également les tarifs associés
          .eq('presta_type_id', typeId)
          .eq('actif', true)
          .order('note_moyenne', ascending: false);

      final List<Map<String, dynamic>> result = [];
      
      // Convertir la réponse en une liste de Map<String, dynamic>
      for (var item in response) {
        if (item is Map) {
          final Map<String, dynamic> prestataire = {};
          item.forEach((key, value) {
            prestataire[key.toString()] = value;
          });
          
          // Extraire le prix de base à partir des tarifs si disponible
          if (prestataire.containsKey('tarifs') && prestataire['tarifs'] is List && prestataire['tarifs'].isNotEmpty) {
            var lowestPrice = double.infinity;
            for (var tarif in prestataire['tarifs']) {
              if (tarif['prix_base'] != null && tarif['prix_base'] < lowestPrice) {
                lowestPrice = tarif['prix_base'];
              }
            }
            if (lowestPrice != double.infinity) {
              prestataire['prix_base'] = lowestPrice;
            }
          }
          
          result.add(prestataire);
        }
      }

      _logger.d('Received ${result.length} prestataires for type $typeId');
      return result;
    } catch (e) {
      _logger.e('Error fetching prestataires by type: $e');
      rethrow;
    }
  }

  /// Search prestataires by name and type
  Future<List<Map<String, dynamic>>> searchPrestataires({
    String? query,
    int? typeId,
    String? region,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      _logger.d('Searching prestataires with: query=$query, typeId=$typeId, region=$region');
      var request = _client.from('presta').select('*, tarifs(*)').eq('actif', true);

      if (query != null && query.isNotEmpty) {
        request = request.ilike('nom_entreprise', '%$query%');
      }

      if (typeId != null) {
        request = request.eq('presta_type_id', typeId);
      }

      if (region != null && region.isNotEmpty) {
        request = request.eq('region', region);
      }

      final response = await request.order('note_moyenne', ascending: false);
      final List<Map<String, dynamic>> result = [];
      
      // Traiter les résultats et filtrer par prix si nécessaire
      for (var item in response) {
        if (item is Map) {
          final Map<String, dynamic> prestataire = {};
          item.forEach((key, value) {
            prestataire[key.toString()] = value;
          });
          
          // Extraire le prix de base et filtrer si nécessaire
          double? lowestPrice;
          if (prestataire.containsKey('tarifs') && prestataire['tarifs'] is List && prestataire['tarifs'].isNotEmpty) {
            lowestPrice = double.infinity;
            for (var tarif in prestataire['tarifs']) {
              if (tarif['prix_base'] != null && tarif['prix_base'] < lowestPrice!) {
                lowestPrice = tarif['prix_base'];
              }
            }
            if (lowestPrice != double.infinity) {
              prestataire['prix_base'] = lowestPrice;
            } else {
              lowestPrice = null;
            }
          }
          
          // Filtrer par prix
          if ((minPrice == null || lowestPrice == null || lowestPrice >= minPrice) &&
              (maxPrice == null || lowestPrice == null || lowestPrice <= maxPrice) &&
              (minRating == null || prestataire['note_moyenne'] == null || prestataire['note_moyenne'] >= minRating)) {
            result.add(prestataire);
          }
        }
      }

      _logger.d('Received ${result.length} prestataires after filtering');
      return result;
    } catch (e) {
      _logger.e('Error searching prestataires: $e');
      rethrow;
    }
  }
}