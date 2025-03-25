import 'package:supabase_flutter/supabase_flutter.dart';

class PrestaRepository {
  final _supabase = Supabase.instance.client;

  /// Récupère la liste des prestataires par type
  Future<List<Map<String, dynamic>>> getPrestairesByType(
    int typeId, {
    String? region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Adapter la requête selon le type
      String select;
      if (typeId == 1) { // Traiteurs
        select = '*, traiteur_type(*), medias(*)';
      } else if (typeId == 2) { // Photographes
        select = '*, medias(*)';
      } else if (typeId == 3) { // Lieux
        select = '*, lieu_type(*), medias(*)';
      } else {
        select = '*, medias(*)';
      }
      
      var query = _supabase
          .from('presta')
          .select(select)
          .eq('presta_type_id', typeId);
      
      // Filtrer par région si spécifiée
      if (region != null && region.isNotEmpty) {
        query = query.eq('region', region);
      }
      
      final response = await query.order('nom_entreprise', ascending: true);
      
      // Traiter la réponse
      return (response as List).map((item) {
        final presta = Map<String, dynamic>.from(item);
        
        // Traiter les types spécifiques de prestataire
        if (typeId == 1 && presta.containsKey('traiteur_type')) { // Traiteurs
          _processTraiteurTypeData(presta);
        } else if (typeId == 3 && presta.containsKey('lieu_type')) { // Lieux
          _processLieuTypeData(presta);
        }
        
        // Gérer l'URL de l'image
        _processImageUrl(presta);
        
        return presta;
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des prestataires: $e');
      throw Exception('Erreur lors de la récupération des prestataires: $e');
    }
  }

  /// Récupère les détails d'un prestataire par son ID
  Future<Map<String, dynamic>> getPrestaireById(String id) async {
    try {
      final response = await _supabase
          .from('presta')
          .select('*, traiteur_type(*), lieu_type(*), medias(*)')
          .eq('id', id)
          .single();

      final presta = Map<String, dynamic>.from(response);
      
      // Déterminer le type et traiter les données spécifiques
      final int prestaTypeId = presta['presta_type_id'];
      
      if (prestaTypeId == 1 && presta.containsKey('traiteur_type')) {
        _processTraiteurTypeData(presta);
      } else if (prestaTypeId == 3 && presta.containsKey('lieu_type')) {
        _processLieuTypeData(presta);
      }
      
      // Gérer l'URL de l'image
      _processImageUrl(presta);
      
      return presta;
    } catch (e) {
      print('Erreur lors de la récupération du prestataire: $e');
      throw Exception('Erreur lors de la récupération du prestataire: $e');
    }
  }

  /// Récupère la liste des types de prestataires
  Future<List<Map<String, dynamic>>> getPrestaTypes() async {
    try {
      final response = await _supabase
          .from('presta_type')
          .select('id, name, description, image_url')
          .order('id', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des types de prestataires: $e');
      throw Exception('Erreur lors de la récupération des types de prestataires: $e');
    }
  }

  /// Récupère la liste des types de lieux
  Future<List<Map<String, dynamic>>> getLieuTypes() async {
    try {
      final response = await _supabase
          .from('lieu_type')
          .select('id, name, description, image_url')
          .order('id', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des types de lieux: $e');
      throw Exception('Erreur lors de la récupération des types de lieux: $e');
    }
  }

  /// Récupère la liste des types de traiteurs
  Future<List<Map<String, dynamic>>> getTraiteurTypes() async {
    try {
      final response = await _supabase
          .from('traiteur_type')
          .select('id, name, description, image_url')
          .order('id', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des types de traiteurs: $e');
      throw Exception('Erreur lors de la récupération des types de traiteurs: $e');
    }
  }

  /// Recherche des prestataires par critères
  Future<List<Map<String, dynamic>>> searchPrestataires({
    required int typeId,
    int? subTypeId,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      // Définir la sélection appropriée
      String select;
      if (typeId == 1) { // Traiteurs
        select = '*, traiteur_type(*), medias(*)';
      } else if (typeId == 2) { // Photographes
        select = '*, medias(*)';
      } else if (typeId == 3) { // Lieux
        select = '*, lieu_type(*), medias(*)';
      } else {
        select = '*, medias(*)';
      }
      
      // Créer la requête avec la sélection
      var query = _supabase
          .from('presta')
          .select(select)
          .eq('presta_type_id', typeId);
      
      // Filtrer par région si spécifiée
      if (region != null && region.isNotEmpty) {
        query = query.eq('region', region);
      }
      
      // Filtrer par note minimale si spécifiée
      if (minRating != null) {
        query = query.gte('note_moyenne', minRating);
      }
      
      // Ajouter les filtres de sous-type appropriés
      if (typeId == 1 && subTypeId != null) { // Traiteurs
        query = query.eq('traiteur_type_id', subTypeId);
      } else if (typeId == 3 && subTypeId != null) { // Lieux
        query = query.eq('lieu_type_id', subTypeId);
      }
      
      final response = await query.order('nom_entreprise', ascending: true);
      
      List<Map<String, dynamic>> results = (response as List).map((item) {
        final presta = Map<String, dynamic>.from(item);
        
        // Traiter les données spécifiques selon le type
        if (typeId == 1 && presta.containsKey('traiteur_type')) {
          _processTraiteurTypeData(presta);
        } else if (typeId == 3 && presta.containsKey('lieu_type')) {
          _processLieuTypeData(presta);
        }
        
        // Gérer l'URL de l'image
        _processImageUrl(presta);
        
        return presta;
      }).toList();
      
      // Filtrer par prix ici car les tables associées peuvent contenir les prix
      if (minPrice != null || maxPrice != null) {
        results = results.where((presta) {
          final prix = presta['prix_base'] ?? double.negativeInfinity;
          if (minPrice != null && prix < minPrice) {
            return false;
          }
          if (maxPrice != null && prix > maxPrice) {
            return false;
          }
          return true;
        }).toList();
      }
      
      return results;
    } catch (e) {
      print('Erreur lors de la recherche des prestataires: $e');
      throw Exception('Erreur lors de la recherche des prestataires: $e');
    }
  }

  /// Récupère les lieux de type spécifique
  Future<List<Map<String, dynamic>>> getLieuxByType(int typeId, {
    String? region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('presta')
          .select('*, lieu_type(*), medias(*)')
          .eq('presta_type_id', 3)  // 3 = Lieux
          .eq('lieu_type_id', typeId);
      
      if (region != null && region.isNotEmpty) {
        query = query.eq('region', region);
      }
      
      final response = await query.order('nom_entreprise', ascending: true);
      
      return (response as List).map((item) {
        final lieu = Map<String, dynamic>.from(item);
        _processLieuTypeData(lieu);
        _processImageUrl(lieu);
        return lieu;
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des lieux par type: $e');
      throw Exception('Erreur lors de la récupération des lieux par type: $e');
    }
  }

  /// Récupère les traiteurs de type spécifique
  Future<List<Map<String, dynamic>>> getTraiteursByType(int typeId, {
    String? region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('presta')
          .select('*, traiteur_type(*), medias(*)')
          .eq('presta_type_id', 1)  // 1 = Traiteurs
          .eq('traiteur_type_id', typeId);
      
      if (region != null && region.isNotEmpty) {
        query = query.eq('region', region);
      }
      
      final response = await query.order('nom_entreprise', ascending: true);
      
      return (response as List).map((item) {
        final traiteur = Map<String, dynamic>.from(item);
        _processTraiteurTypeData(traiteur);
        _processImageUrl(traiteur);
        return traiteur;
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des traiteurs par type: $e');
      throw Exception('Erreur lors de la récupération des traiteurs par type: $e');
    }
  }

  /// Récupère les traiteurs qui peuvent servir dans un lieu spécifique
  Future<List<Map<String, dynamic>>> getTraiteursByLieu(String lieuId) async {
    try {
      // D'abord, récupérer le lieu pour obtenir sa région
      final lieuResponse = await _supabase
          .from('presta')
          .select('region')
          .eq('id', lieuId)
          .single();
    
      final String region = lieuResponse['region'] ?? '';
      
      // Ensuite, récupérer les traiteurs dans cette région
      if (region.isNotEmpty) {
        return await getPrestairesByType(1, region: region);
      } else {
        // Si pas de région, retourner tous les traiteurs
        return await getPrestairesByType(1);
      }
    } catch (e) {
      print('Erreur lors de la récupération des traiteurs par lieu: $e');
      throw Exception('Erreur lors de la récupération des traiteurs par lieu: $e');
    }
  }

  /// Récupère les avis d'un prestataire
  Future<List<Map<String, dynamic>>> getAvisByPrestaId(String prestaId) async {
    try {
      final response = await _supabase
          .from('avis')
          .select('*, profiles(prenom, nom)')
          .eq('presta_id', prestaId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des avis: $e');
      throw Exception('Erreur lors de la récupération des avis: $e');
    }
  }

  /// Ajoute un prestataire aux favoris
  Future<void> addToFavorites(String userId, String prestaId) async {
    try {
      await _supabase
          .from('favoris')
          .insert({
            'user_id': userId,
            'presta_id': prestaId,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  /// Supprime un prestataire des favoris
  Future<void> removeFromFavorites(String userId, String prestaId) async {
    try {
      await _supabase
          .from('favoris')
          .delete()
          .match({
            'user_id': userId,
            'presta_id': prestaId,
          });
    } catch (e) {
      print('Erreur lors de la suppression des favoris: $e');
      throw Exception('Erreur lors de la suppression des favoris: $e');
    }
  }

  /// Vérifie si un prestataire est dans les favoris
  Future<bool> isFavorite(String userId, String prestaId) async {
    try {
      final response = await _supabase
          .from('favoris')
          .select('id')
          .match({
            'user_id': userId,
            'presta_id': prestaId,
          });
      
      return (response as List).isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      throw Exception('Erreur lors de la vérification des favoris: $e');
    }
  }

  /// Récupère les prestataires favoris d'un utilisateur
  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    try {
      final response = await _supabase
          .from('favoris')
          .select('presta_id, presta(*)')
          .eq('user_id', userId);
      
      List<Map<String, dynamic>> favorites = [];
      
      for (var item in response) {
        final presta = item['presta'];
        if (presta != null) {
          final prestaMap = Map<String, dynamic>.from(presta);
          
          // Déterminer le type et récupérer les données spécifiques
          final int prestaTypeId = prestaMap['presta_type_id'];
          final prestaId = prestaMap['id'];
          
          // Récupérer les données de type supplémentaires selon le type
          if (prestaTypeId == 1) { // Traiteur
            try {
              final typeResponse = await _supabase
                  .from('traiteur_type')
                  .select('*')
                  .eq('id', prestaMap['traiteur_type_id'])
                  .maybeSingle();
              
              if (typeResponse != null) {
                prestaMap['traiteur_type'] = typeResponse;
                _processTraiteurTypeData(prestaMap);
              }
            } catch (e) {
              print('Erreur lors de la récupération du type traiteur: $e');
            }
          } else if (prestaTypeId == 3) { // Lieu
            try {
              final typeResponse = await _supabase
                  .from('lieu_type')
                  .select('*')
                  .eq('id', prestaMap['lieu_type_id'])
                  .maybeSingle();
              
              if (typeResponse != null) {
                prestaMap['lieu_type'] = typeResponse;
                _processLieuTypeData(prestaMap);
              }
            } catch (e) {
              print('Erreur lors de la récupération du type lieu: $e');
            }
          }
          
          // Récupérer les médias
          try {
            final mediaResponse = await _supabase
                .from('medias')
                .select('*')
                .eq('presta_id', prestaId);
            
            if ((mediaResponse as List).isNotEmpty) {
              prestaMap['medias'] = mediaResponse;
              _processImageUrl(prestaMap);
            }
          } catch (e) {
            print('Erreur lors de la récupération des médias: $e');
          }
          
          favorites.add(prestaMap);
        }
      }
      
      return favorites;
    } catch (e) {
      print('Erreur lors de la récupération des favoris: $e');
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }

  /// Enregistre un bouquet complet
  Future<Map<String, dynamic>> saveBouquet(Map<String, dynamic> bouquetData) async {
    try {
      final response = await _supabase
          .from('bouquets')
          .insert(bouquetData)
          .select()
          .single();
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Erreur lors de la sauvegarde du bouquet: $e');
      throw Exception('Erreur lors de la sauvegarde du bouquet: $e');
    }
  }

  /// Récupère les bouquets d'un utilisateur
  Future<List<Map<String, dynamic>>> getBouquetsByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('bouquets')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des bouquets: $e');
      throw Exception('Erreur lors de la récupération des bouquets: $e');
    }
  }

  /// Méthode privée pour traiter les données de type traiteur
  void _processTraiteurTypeData(Map<String, dynamic> presta) {
    if (!presta.containsKey('traiteur_type')) return;
    
    final typeData = presta['traiteur_type'];
    if (typeData != null) {
      if (typeData is Map) {
        // Extraire les informations utiles du type de traiteur
        presta['type_cuisine'] = typeData['name'] ?? '';
        presta['type_traiteur_description'] = typeData['description'] ?? '';
        if (typeData['image_url'] != null && presta['photo_url'] == null) {
          presta['photo_url'] = typeData['image_url'];
        }
      }
    }
  }

  /// Méthode privée pour traiter les données de type lieu
  void _processLieuTypeData(Map<String, dynamic> presta) {
    if (!presta.containsKey('lieu_type')) return;
    
    final typeData = presta['lieu_type'];
    if (typeData != null) {
      if (typeData is Map) {
        // Extraire les informations utiles du type de lieu
        presta['type_lieu'] = typeData['name'] ?? '';
        presta['type_lieu_description'] = typeData['description'] ?? '';
        if (typeData['image_url'] != null && presta['photo_url'] == null) {
          presta['photo_url'] = typeData['image_url'];
        }
      }
    }
  }

  /// Méthode privée pour traiter l'URL de l'image
  void _processImageUrl(Map<String, dynamic> presta) {
    if (presta['image_url'] != null && presta['image_url'].toString().isNotEmpty) {
      presta['photo_url'] = presta['image_url'];
    } else if (presta.containsKey('medias') && presta['medias'] != null) {
      final mediasList = presta['medias'] as List;
      if (mediasList.isNotEmpty) {
        final mediaItem = mediasList.first;
        if (mediaItem is Map && mediaItem.containsKey('url')) {
          presta['photo_url'] = mediaItem['url'];
        }
      }
    }
    
    // Si aucune image n'est trouvée, utiliser une image par défaut selon le type
    if (presta['photo_url'] == null || presta['photo_url'].toString().isEmpty) {
      final int prestaTypeId = presta['presta_type_id'] ?? 0;
      presta['photo_url'] = prestaTypeId == 1 ? 'assets/images/default_traiteur.jpg'
          : prestaTypeId == 2 ? 'assets/images/default_photographe.jpg'
          : prestaTypeId == 3 ? 'assets/images/default_lieu.jpg'
          : 'assets/images/default_prestataire.jpg';
    }
  }
}