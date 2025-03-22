import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/logger.dart';
import '../models/data/data_point_model.dart';

class StatsService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  // Récupérer le nombre de réservations pour un partenaire
  Future<int> getReservationsCount(String partnerId) async {
    try {
      final response = await _client
          .from('reservations')
          .select()
          .eq('presta_id', partnerId);

      // Compter manuellement les éléments
      return (response as List).length;
    } catch (e) {
      AppLogger.error('Erreur lors du comptage des réservations', e);
      return 0;
    }
  }

  // Récupérer le nombre de vues du profil
  Future<int> getProfileViews(String partnerId) async {
    try {
      // Dans une version réelle, cela viendrait d'une table de statistiques
      // Pour l'exemple, nous générons une valeur aléatoire
      return 120 + (partnerId.hashCode % 880);
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des vues du profil', e);
      return 0;
    }
  }

  // Récupérer la note moyenne
  Future<double> getAverageRating(String partnerId) async {
    try {
      final response = await _client
          .from('presta')
          .select('note_moyenne')
          .eq('id', partnerId)
          .single();

      final rating = response['note_moyenne'];
      if (rating == null) return 0.0;

      return double.parse(rating.toString());
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération de la note moyenne', e);
      return 0.0;
    }
  }

  // Récupérer le nombre total de messages
  Future<int> getTotalMessagesCount(String partnerId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('expediteur_id', partnerId)
          .or('destinataire_id.eq.$partnerId');

      // Compter manuellement les éléments
      return (response as List).length;
    } catch (e) {
      AppLogger.error('Erreur lors du comptage des messages', e);
      return 0;
    }
  }

  // Récupérer les réservations par mois (pour le graphique)
  Future<List<DataPointModel>> getReservationsByMonth(String partnerId,
      {int months = 6}) async {
    try {
      // Dans une version réelle, cela serait une requête agrégée par mois
      // Pour l'exemple, nous générons des données fictives
      final now = DateTime.now();
      final List<DataPointModel> result = [];

      for (int i = 0; i < months; i++) {
        final date = DateTime(now.year, now.month - i, 1);
        final value =
            3 + (date.month * date.day) % 7; // Valeur aléatoire entre 3 et 9

        result.add(DataPointModel(date: date, value: value));
      }

      // Inverser pour avoir l'ordre chronologique
      return result.reversed.toList();
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération des réservations par mois', e);
      return [];
    }
  }

  // Récupérer les vues par jour (pour le graphique)
  Future<List<DataPointModel>> getViewsByDay(String partnerId,
      {int days = 14}) async {
    try {
      // Dans une version réelle, cela serait une requête agrégée par jour
      // Pour l'exemple, nous générons des données fictives
      final now = DateTime.now();
      final List<DataPointModel> result = [];

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final value = 10 +
            (date.day * date.weekday) % 40; // Valeur aléatoire entre 10 et 49

        result.add(DataPointModel(date: date, value: value));
      }

      // Inverser pour avoir l'ordre chronologique
      return result.reversed.toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des vues par jour', e);
      return [];
    }
  }

  // Récupérer la distribution des notes (pour le graphique en camembert)
  Future<Map<int, int>> getRatingsDistribution(String partnerId) async {
    try {
      // Dans une version réelle, cela serait une requête groupée par note
      // Pour l'exemple, nous générons des données fictives
      return {
        5: 25 + (partnerId.hashCode % 25),
        4: 15 + (partnerId.hashCode % 15),
        3: 8 + (partnerId.hashCode % 8),
        2: 4 + (partnerId.hashCode % 4),
        1: 2 + (partnerId.hashCode % 2),
      };
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération de la distribution des notes', e);
      return {};
    }
  }
}
