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
    
    // Utilisez explicitement la bonne table et les bons champs
    final response = await _client
        .from('presta_type')  // Assurez-vous que le nom de la table est correct
        .select('id, name, description, image_url')
        .order('id', ascending: true);
    
    _logger.d('Response raw: $response');
    
    // Convertir explicitement le résultat en List<Map<String, dynamic>>
    final List<PrestaTypeModel> result = [];
    
    if (response is List) {
      for (var item in response) {
        if (item is Map) {
          // Conversion explicite en Map<String, dynamic>
          final Map<String, dynamic> typedItem = {};
          item.forEach((key, value) {
            typedItem[key.toString()] = value;
          });
          
          // Créer un modèle à partir de la map typée
          result.add(PrestaTypeModel.fromMap(typedItem));
        }
      }
    }
    
    _logger.d('Parsed ${result.length} prestataire types');
    return result;
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
        .select('''
          *, 
          tarifs(*),
          lieux(*)
        ''')
        .eq('presta_type_id', typeId)
        .eq('actif', true);

    _logger.d('Response raw data: ${response.length} items');
    
    final List<Map<String, dynamic>> result = [];
    
    // Conversion des données
    for (var item in response) {
      if (item is Map) {
        final Map<String, dynamic> prestataire = {};
        item.forEach((key, value) {
          prestataire[key.toString()] = value;
        });
        
        // Extraction de l'URL de l'image
        if (prestataire.containsKey('lieux') && prestataire['lieux'] != null) {
          var lieux = prestataire['lieux'];
          _logger.d('Lieux data: $lieux');
          
          if (lieux is List && lieux.isNotEmpty) {
            // Parcourir la liste des lieux pour trouver une image
            for (var lieu in lieux) {
              if (lieu is Map && lieu.containsKey('image_url') && lieu['image_url'] != null) {
                prestataire['photo_url'] = lieu['image_url'];
                _logger.d('Found image URL in lieux list: ${lieu['image_url']}');
                break;
              }
            }
          } else if (lieux is Map && lieux.containsKey('image_url') && lieux['image_url'] != null) {
            prestataire['photo_url'] = lieux['image_url'];
            _logger.d('Found image URL in lieux map: ${lieux['image_url']}');
          }
        }

        // Si pas d'image trouvée, utiliser une URL par défaut
        if (!prestataire.containsKey('photo_url') || prestataire['photo_url'] == null) {
          prestataire['photo_url'] = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
          _logger.d('Using default image for prestataire: ${prestataire['nom_entreprise']}');
        } else {
          _logger.d('Using image URL: ${prestataire['photo_url']} for prestataire: ${prestataire['nom_entreprise']}');
        }
        
        // Reste du code inchangé
        result.add(prestataire);
      }
    }

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
      var request = _client.from('presta').select('''
        *, 
        tarifs(*),
        lieux(*)
      ''').eq('actif', true); // Ajout de la sélection de lieux

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
      
      // Conversion des données
      for (var item in response) {
        if (item is Map) {
          final Map<String, dynamic> prestataire = {};
          item.forEach((key, value) {
            prestataire[key.toString()] = value;
          });
          
          // Extraire le prix de base et filtrer si nécessaire
          double? lowestPrice;
          if (prestataire.containsKey('tarifs') && prestataire['tarifs'] != null) {
            var tarifs = prestataire['tarifs'];
            List<dynamic> tarifsList = [];
            
            if (tarifs is List) {
              tarifsList = tarifs;
            } else if (tarifs is Map) {
              tarifsList = [tarifs];
            }
            
            if (tarifsList.isNotEmpty) {
              lowestPrice = double.infinity;
              for (var tarif in tarifsList) {
                var prixBase = tarif is Map ? tarif['prix_base'] : null;
                if (prixBase != null && prixBase is num && prixBase < lowestPrice!) {
                  lowestPrice = prixBase.toDouble();
                }
              }
              
              if (lowestPrice != double.infinity) {
                prestataire['prix_base'] = lowestPrice;
              } else {
                lowestPrice = null;
              }
            }
            if (prestataire.containsKey('lieux') && prestataire['lieux'] != null) {
            var lieux = prestataire['lieux'];
            _logger.d('Lieux data: $lieux');
            
            if (lieux is List && lieux.isNotEmpty) {
              // Parcourir la liste des lieux pour trouver une image
              for (var lieu in lieux) {
                if (lieu is Map && lieu.containsKey('image_url') && lieu['image_url'] != null) {
                  prestataire['photo_url'] = lieu['image_url'];
                  _logger.d('Found image URL in lieux list: ${lieu['image_url']}');
                  break;
                }
              }
            } else if (lieux is Map && lieux.containsKey('image_url') && lieux['image_url'] != null) {
              prestataire['photo_url'] = lieux['image_url'];
              _logger.d('Found image URL in lieux map: ${lieux['image_url']}');
            }
          }
          }
          
          // Filtrer par prix et note
          bool passesFilter = true;
          
          if (minPrice != null && lowestPrice != null && lowestPrice < minPrice) {
            passesFilter = false;
          }
          
          if (maxPrice != null && lowestPrice != null && lowestPrice > maxPrice) {
            passesFilter = false;
          }
          
          var noteMoyenne = prestataire['note_moyenne'];
          if (minRating != null && noteMoyenne != null) {
            double? noteValue;
            if (noteMoyenne is num) {
              noteValue = noteMoyenne.toDouble();
            } else if (noteMoyenne is String) {
              noteValue = double.tryParse(noteMoyenne);
            }
            
            if (noteValue != null && noteValue < minRating) {
              passesFilter = false;
            }
          }
          
          if (passesFilter) {
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