import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/logger.dart';
import '../models/data/tarif_model.dart';

class TarifService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final TarifService _instance = TarifService._internal();
  factory TarifService() => _instance;
  TarifService._internal();

  /// Récupère tous les tarifs d'un partenaire
  Future<List<TarifModel>> getPartnerTarifs(String partnerId) async {
    try {
      final response = await _client
          .from('tarifs')
          .select()
          .eq('presta_id', partnerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((tarif) => TarifModel.fromMap(tarif))
          .toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des tarifs', e);
      rethrow;
    }
  }

  /// Récupère un tarif par son ID
  Future<TarifModel> getTarifById(String tarifId) async {
    try {
      final response =
          await _client.from('tarifs').select().eq('id', tarifId).single();

      return TarifModel.fromMap(response);
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération du tarif', e);
      rethrow;
    }
  }

  /// Crée un nouveau tarif
  Future<TarifModel> createTarif(TarifModel tarif) async {
    try {
      // Supprime l'ID pour que Supabase en génère un nouveau
      final Map<String, dynamic> tarifMap = tarif.toMap();
      tarifMap.remove('id');

      final response = await _client.from('tarifs').insert(tarifMap).select();

      return TarifModel.fromMap(response[0]);
    } catch (e) {
      AppLogger.error('Erreur lors de la création du tarif', e);
      rethrow;
    }
  }

  /// Met à jour un tarif existant
  Future<TarifModel> updateTarif(TarifModel tarif) async {
    try {
      final response = await _client
          .from('tarifs')
          .update(tarif.toMap())
          .eq('id', tarif.id)
          .select();

      return TarifModel.fromMap(response[0]);
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du tarif', e);
      rethrow;
    }
  }

  /// Supprime un tarif
  Future<void> deleteTarif(String tarifId) async {
    try {
      await _client.from('tarifs').delete().eq('id', tarifId);
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du tarif', e);
      rethrow;
    }
  }

  /// Change la visibilité d'un tarif
  Future<void> toggleTarifVisibility(String tarifId, bool isVisible) async {
    try {
      await _client
          .from('tarifs')
          .update({'actif': isVisible}).eq('id', tarifId);
    } catch (e) {
      AppLogger.error('Erreur lors du changement de visibilité du tarif', e);
      rethrow;
    }
  }
}
