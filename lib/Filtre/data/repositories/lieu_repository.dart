import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lieu_type_model.dart';
import 'package:logger/logger.dart';
import '../models/avis_model.dart';

/// Repository class for all lieu-related data operations
class LieuRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final Logger _logger = Logger();


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
      rethrow;
    }
  }

  /// Fetch lieux by type
  Future<List<Map<String, dynamic>>> getLieuxByType(int typeId) async {
    try {
      // Joint presta et lieux pour obtenir toutes les infos nécessaires
      final response = await _client
          .from('presta')
          .select('''
            id, 
            nom_entreprise, 
            description, 
            region, 
            adresse, 
            note_moyenne, 
            verifie, 
            actif,
            lieux!inner(
              id, 
              capacite_max, 
              espace_exterieur, 
              parking, 
              hebergement, 
              capacite_hebergement,
              exclusivite, 
              feu_artifice
            ),
            tarifs(
              id,
              nom_formule,
              prix_base,
              description
            )
          ''')
          .eq('lieux_type_id', typeId)
          .eq('actif', true);

      // Transformer les données pour correspondre à la structure attendue
      return _transformLieuxResponse(response);
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
      var request = _client
          .from('presta')
          .select('''
            id, 
            nom_entreprise, 
            description, 
            region, 
            adresse, 
            note_moyenne, 
            verifie, 
            actif,
            lieux!inner(
              id, 
              capacite_max, 
              espace_exterieur, 
              parking, 
              hebergement, 
              capacite_hebergement,
              exclusivite, 
              feu_artifice
            ),
            tarifs(
              id,
              nom_formule,
              prix_base,
              description
            )
          ''')
          .eq('actif', true);

      if (query != null && query.isNotEmpty) {
        request = request.ilike('nom_entreprise', '%$query%');
      }

      if (typeId != null) {
        request = request.eq('lieux_type_id', typeId);
      }

      if (region != null && region.isNotEmpty) {
        request = request.eq('region', region);
      }

      final response = await request.order('note_moyenne', ascending: false);
      
      // Transformer les données pour correspondre à la structure attendue
      return _transformLieuxResponse(response);
    } catch (e) {
      rethrow;
    }
  }


Future<List<Map<String, dynamic>>> getTarifsByPrestaId(String prestaId) async {
  try {
    _logger.d('Fetching tarifs for prestataire: $prestaId');
    
    final tarifsResponse = await _client
        .from('tarifs')
        .select('*')
        .eq('presta_id', prestaId)
        .order('prix_base', ascending: true);
    
    _logger.d('Found ${tarifsResponse.length} tarifs for prestataire: $prestaId');
    return tarifsResponse;
  } catch (e) {
_logger.e('Error fetching tarifs for prestataire: $prestaId: ${e.toString()}');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getTarifsByLieuId(String lieuId) async {
  try {
    _logger.d('Fetching tarifs for lieu: $lieuId');
    
    // D'abord obtenir le presta_id associé au lieu
    final lieuResponse = await _client
        .from('lieux')
        .select('presta_id')
        .eq('id', lieuId)
        .single();
    
    // Si nous avons trouvé un prestataire associé
    if (lieuResponse != null && lieuResponse['presta_id'] != null) {
      String prestaId = lieuResponse['presta_id'];
      _logger.d('Found presta_id: $prestaId for lieu: $lieuId');
      
      // Maintenant chercher les tarifs associés à ce prestataire
      final tarifsResponse = await _client
          .from('tarifs')
          .select('*')
          .eq('presta_id', prestaId)
          .order('prix_base', ascending: true);
      
      _logger.d('Found ${tarifsResponse.length} tarifs for prestataire: $prestaId');
      return tarifsResponse;
    }
    
    _logger.w('No presta_id found for lieu: $lieuId');
    return [];
  } catch (e) {
  _logger.e('Error fetching tarifs for lieu: $lieuId: ${e.toString()}');
    return [];
  }
}

  // Transforme la réponse Supabase en format attendu par l'UI
  List<Map<String, dynamic>> _transformLieuxResponse(List<dynamic> response) {
    return response.map<Map<String, dynamic>>((item) {
      // Extraire le prix de base à partir des tarifs si disponible
      double? prixBase;
      if (item['tarifs'] != null && item['tarifs'].isNotEmpty) {
        prixBase = item['tarifs'][0]['prix_base'];
      }

      // Créer un nouvel objet avec la structure attendue par l'UI
      return {
        'id': item['id'],
        'nom_entreprise': item['nom_entreprise'] ?? 'Sans nom',
        'description': item['description'] ?? 'Aucune description',
        'region': item['region'] ?? 'Non spécifié',
        'adresse': item['adresse'] ?? '',
        'note_moyenne': item['note_moyenne'] ?? 0.0,
        'prix_base': prixBase ?? 0.0,
        'type_presta': 1, // ID du type "Lieu"
        'type_lieu': item['lieux_type_id'], 
        'photo_url': null, // À ajouter si les URLs des photos sont dans la base de données
        // Ajouter d'autres champs si nécessaire
      };
    }).toList();
  }

  /// Récupère les avis pour un prestataire spécifique
  Future<List<AvisModel>> getAvisByPrestataireId(String prestataireId) async {
    try {
      _logger.d('Fetching avis for prestataire: $prestataireId');
      
      final response = await _client
          .from('avis')
          .select('*, profiles(*)')
          .eq('prestataire_id', prestataireId)
          .eq('status', 'publie') // Seulement les avis publiés
          .order('created_at', ascending: false);
      
      final List<AvisModel> avis = (response as List)
          .map((item) => AvisModel.fromMap(item))
          .toList();
          
      _logger.d('Found ${avis.length} avis for prestataire: $prestataireId');
      return avis;
    } catch (e) {
    _logger.e('Error fetching avis for prestataire: $prestataireId: ${e.toString()}');
      return [];
    }
  }



}

class AvisService {
  final _client = Supabase.instance.client;
  
  Future<bool> addAvis({
    required String prestataireId,
    required String userId,
    required double note,
    required String commentaire,
  }) async {
    try {
      print('Adding avis for prestataire: $prestataireId by user: $userId');
      
      await _client.from('avis').insert({
        'prestataire_id': prestataireId,
        'user_id': userId,
        'note': note,
        'commentaire': commentaire,
        'status': 'en_attente', // L'avis sera modéré avant publication
      });
      
      print('Successfully added avis for prestataire: $prestataireId');
      return true;
    } catch (e) {
      print('Error adding avis for prestataire: $prestataireId: $e');
      return false;
    }
  }
}
