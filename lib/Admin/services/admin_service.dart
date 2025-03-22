import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/logger.dart';
import '../models/admin_model.dart';
import '../../Partner/models/partner_model.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';

/// Service pour gérer les opérations administratives
class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  /// Récupère les informations d'un administrateur par son ID
  Future<AdminModel?> getAdminById(String adminId) async {
    try {
      final response =
          await _client.from('admins').select().eq('id', adminId).single();

      return AdminModel.fromMap(response);
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération de l\'administrateur', e);
      return null;
    }
  }

  /// Crée un nouvel administrateur
  Future<AdminModel?> createAdmin({
    required String email,
    required String nom,
    String role = 'admin',
    required String password, // Non utilisé, mais gardé pour compatibilité
  }) async {
    try {
      // Générer un UUID pour l'administrateur
      final String adminId = const Uuid().v4();

      // Insérer directement dans la table admins
      final response = await _client.from('admins').insert({
        'id': adminId,
        'email': email,
        'nom': nom,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (response != null && response.isNotEmpty) {
        return AdminModel.fromMap(response[0]);
      }

      return null;
    } catch (e) {
      AppLogger.error('Erreur lors de la création de l\'administrateur', e);
      return null;
    }
  }

  /// Met à jour le dernier login d'un administrateur
  Future<void> updateAdminLastLogin(String adminId) async {
    try {
      await _client.from('admins').update({
        'last_login': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du dernier login', e);
    }
  }

  /// Récupère la liste de tous les prestataires
  Future<List<PartnerModel>> getAllPartners() async {
    try {
      final response = await _client.from('presta').select();

      return (response as List)
          .map((data) => PartnerModel.fromMap(data))
          .toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des prestataires', e);
      return [];
    }
  }

  /// Récupère les prestataires non vérifiés qui nécessitent validation
  Future<List<PartnerModel>> getUnverifiedPartners() async {
    try {
      final response =
          await _client.from('presta').select().eq('is_verified', false);

      return (response as List)
          .map((data) => PartnerModel.fromMap(data))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération des prestataires non vérifiés', e);
      return [];
    }
  }

  /// Met à jour le statut de vérification d'un prestataire
  Future<bool> updatePartnerVerificationStatus(
      String partnerId, bool isVerified) async {
    try {
      await _client.from('presta').update({
        'is_verified': isVerified,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', partnerId);

      return true;
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la mise à jour du statut de vérification', e);
      return false;
    }
  }

  /// Active ou désactive un prestataire
  Future<bool> updatePartnerActiveStatus(
      String partnerId, bool isActive) async {
    try {
      await _client.from('presta').update({
        'actif': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', partnerId);

      return true;
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la mise à jour du statut d\'activation', e);
      return false;
    }
  }

  /// Récupère un prestataire par son ID
  Future<PartnerModel?> getPartnerById(String partnerId) async {
    try {
      final response =
          await _client.from('presta').select().eq('id', partnerId).single();

      return PartnerModel.fromMap(response);
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération du prestataire', e);
      return null;
    }
  }

  /// Met à jour les informations d'un prestataire
  Future<bool> updatePartner(PartnerModel partner) async {
    try {
      await _client.from('presta').update(partner.toMap()).eq('id', partner.id);

      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du prestataire', e);
      return false;
    }
  }

  /// Crée un nouveau prestataire
  Future<bool> createPartner({
    required String nomEntreprise,
    required String nomContact,
    required String email,
    required String telephone,
    String? telephoneSecondaire,
    required String adresse,
    required String region,
    required String description,
    String? imageUrl,
    required String typeBudget,
    required bool isVerified,
    required bool actif,
  }) async {
    try {
      // Générer un UUID pour le prestataire
      final String prestaId = const Uuid().v4();

      // Insérer directement dans la table presta
      await _client.from('presta').insert({
        'id': prestaId,
        'nom_entreprise': nomEntreprise,
        'nom_contact': nomContact,
        'email': email,
        'telephone': telephone,
        'telephone_secondaire': telephoneSecondaire,
        'adresse': adresse,
        'region': region,
        'description': description,
        'image_url': imageUrl,
        'type_budget': typeBudget,
        'is_verified': isVerified,
        'actif': actif,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la création du prestataire', e);
      return false;
    }
  }

  // Fonction utilitaire pour générer un mot de passe aléatoire
  String generateRandomPassword() {
    final random = Random();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        12, // Longueur du mot de passe
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Récupère les statistiques globales de la plateforme
  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      // Nombre total de prestataires
      final prestaResponse = await _client.from('presta').select('id');
      final int totalPresta = (prestaResponse as List).length;

      // Nombre de prestataires vérifiés
      final verifiedResponse =
          await _client.from('presta').select('id').eq('is_verified', true);
      final int verifiedPresta = (verifiedResponse as List).length;

      // Nombre total d'utilisateurs
      final usersResponse = await _client.from('profiles').select('id');
      final int totalUsers = (usersResponse as List).length;

      // Nombre total de réservations
      final reservationsResponse =
          await _client.from('reservations').select('id');
      final int totalReservations = (reservationsResponse as List).length;

      return {
        'totalPrestataires': totalPresta,
        'prestatairesVerifies': verifiedPresta,
        'totalUtilisateurs': totalUsers,
        'totalReservations': totalReservations,
      };
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération des statistiques globales', e);
      return {
        'totalPrestataires': 0,
        'prestatairesVerifies': 0,
        'totalUtilisateurs': 0,
        'totalReservations': 0,
      };
    }
  }

  // Récupérer des statistiques utilisateurs détaillées
  Future<Map<String, dynamic>> getUsersAnalytics() async {
    try {
      // Total des utilisateurs
      final usersResponse =
          await _client.from('profiles').select('id, created_at, status');
      final List users = usersResponse;

      // Calcul des utilisateurs par statut
      final Map<String, int> usersByStatus = {};
      for (var user in users) {
        final status = user['status'] ?? 'unknown';
        usersByStatus[status] = (usersByStatus[status] ?? 0) + 1;
      }

      // Calcul des nouveaux utilisateurs par mois (derniers 6 mois)
      final Map<String, int> newUsersByMonth = {};
      final now = DateTime.now();

      for (var i = 0; i < 6; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthKey =
            '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
        newUsersByMonth[monthKey] = 0;
      }

      for (var user in users) {
        if (user['created_at'] == null) continue;

        final createdAt = DateTime.parse(user['created_at']);
        final monthsSinceCreation =
            (now.year - createdAt.year) * 12 + now.month - createdAt.month;

        if (monthsSinceCreation < 6) {
          final monthKey =
              '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
          newUsersByMonth[monthKey] = (newUsersByMonth[monthKey] ?? 0) + 1;
        }
      }

      return {
        'total': users.length,
        'byStatus': usersByStatus,
        'newUsersByMonth': newUsersByMonth,
      };
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération des statistiques utilisateurs', e);
      return {
        'total': 0,
        'byStatus': {},
        'newUsersByMonth': {},
      };
    }
  }

  // Récupérer des statistiques détaillées sur les prestataires
  Future<Map<String, dynamic>> getPartnersAnalytics() async {
    try {
      // Récupérer tous les prestataires avec leurs types
      final partnersResponse =
          await _client.from('presta').select('*, presta_type(name)');

      final List partners = partnersResponse;

      // Prestataires par type
      final Map<String, int> partnersByType = {};
      for (var partner in partners) {
        final type = partner['presta_type'] != null
            ? (partner['presta_type']['name'] ?? 'Non catégorisé')
            : 'Non catégorisé';
        partnersByType[type] = (partnersByType[type] ?? 0) + 1;
      }

      // Prestataires par région
      final Map<String, int> partnersByRegion = {};
      for (var partner in partners) {
        final region = partner['region'] ?? 'Inconnue';
        partnersByRegion[region] = (partnersByRegion[region] ?? 0) + 1;
      }

      // Prestataires par budget
      final Map<String, int> partnersByBudget = {};
      for (var partner in partners) {
        final budget = partner['type_budget'] ?? 'Inconnu';
        partnersByBudget[budget] = (partnersByBudget[budget] ?? 0) + 1;
      }

      // Taux de vérification par type
      final Map<String, Map<String, dynamic>> verificationRateByType = {};
      for (var partner in partners) {
        final type = partner['presta_type'] != null
            ? (partner['presta_type']['name'] ?? 'Non catégorisé')
            : 'Non catégorisé';

        if (!verificationRateByType.containsKey(type)) {
          verificationRateByType[type] = {
            'total': 0,
            'verified': 0,
          };
        }

        verificationRateByType[type]!['total'] =
            (verificationRateByType[type]!['total'] ?? 0) + 1;
        if (partner['is_verified'] == true) {
          verificationRateByType[type]!['verified'] =
              (verificationRateByType[type]!['verified'] ?? 0) + 1;
        }
      }

      // Calcul du taux pour chaque type
      for (var type in verificationRateByType.keys) {
        final total = verificationRateByType[type]!['total'] ?? 0;
        final verified = verificationRateByType[type]!['verified'] ?? 0;

        if (total > 0) {
          verificationRateByType[type]?['rate'] =
              (verified / total * 100).toStringAsFixed(1);
        } else {
          verificationRateByType[type]?['rate'] = '0.0';
        }
      }

      return {
        'total': partners.length,
        'byType': partnersByType,
        'byRegion': partnersByRegion,
        'byBudget': partnersByBudget,
        'verificationRateByType': verificationRateByType,
      };
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération des statistiques prestataires', e);
      return {
        'total': 0,
        'byType': {},
        'byRegion': {},
        'byBudget': {},
        'verificationRateByType': {},
      };
    }
  }

  // Récupérer des statistiques détaillées sur les réservations
  Future<Map<String, dynamic>> getReservationsAnalytics() async {
    try {
      // Récupérer toutes les réservations
      final reservationsResponse = await _client
          .from('reservations')
          .select('*, presta(*)')
          .order('date_evenement', ascending: false);

      final List reservations = reservationsResponse;

      // Réservations par mois
      final Map<String, dynamic> reservationsByMonth = {};
      final Map<String, dynamic> revenueByMonth = {};

      // Initialiser les 12 derniers mois
      final now = DateTime.now();
      for (var i = 0; i < 12; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthKey =
            '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
        reservationsByMonth[monthKey] = 0;
        revenueByMonth[monthKey] = 0.0;
      }

      // Compter les réservations par mois
      for (var reservation in reservations) {
        if (reservation['date_evenement'] == null) continue;

        final dateEvenement = DateTime.parse(reservation['date_evenement']);
        final monthsSince = (now.year - dateEvenement.year) * 12 +
            now.month -
            dateEvenement.month;

        if (monthsSince < 12) {
          final monthKey =
              '${dateEvenement.year}-${dateEvenement.month.toString().padLeft(2, '0')}';
          reservationsByMonth[monthKey] =
              (reservationsByMonth[monthKey] ?? 0) + 1;

          // Ajouter le prix total au revenu du mois
          final prixTotal = reservation['prix_total'] ?? 0;
          revenueByMonth[monthKey] =
              (revenueByMonth[monthKey] ?? 0) + prixTotal;
        }
      }

      // Réservations par statut
      final Map<String, int> reservationsByStatus = {};
      for (var reservation in reservations) {
        final status = reservation['statut'] ?? 'Inconnu';
        reservationsByStatus[status] = (reservationsByStatus[status] ?? 0) + 1;
      }

      // Réservations par type de prestataire
      final Map<String, int> reservationsByPartnerType = {};
      for (var reservation in reservations) {
        if (reservation['presta'] != null &&
            reservation['presta']['presta_type_id'] != null) {
          // Dans un cas réel, on ferait une jointure pour obtenir le nom du type
          final typeId = reservation['presta']['presta_type_id'].toString();
          reservationsByPartnerType[typeId] =
              (reservationsByPartnerType[typeId] ?? 0) + 1;
        }
      }

      // Top 5 des prestataires avec le plus de réservations
      final Map<String, int> reservationsByPartner = {};
      for (var reservation in reservations) {
        if (reservation['presta_id'] != null) {
          final partnerId = reservation['presta_id'];
          final partnerName = reservation['presta'] != null
              ? reservation['presta']['nom_entreprise'] ??
                  'Prestataire #$partnerId'
              : 'Prestataire #$partnerId';

          reservationsByPartner[partnerName] =
              (reservationsByPartner[partnerName] ?? 0) + 1;
        }
      }

      // Trier et prendre les 5 premiers
      final List<MapEntry<String, int>> sortedPartners =
          reservationsByPartner.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final Map<String, int> topPartners = {};
      for (var i = 0; i < sortedPartners.length && i < 5; i++) {
        topPartners[sortedPartners[i].key] = sortedPartners[i].value;
      }

      return {
        'total': reservations.length,
        'byMonth': reservationsByMonth,
        'revenueByMonth': revenueByMonth,
        'byStatus': reservationsByStatus,
        'byPartnerType': reservationsByPartnerType,
        'topPartners': topPartners,
      };
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération des statistiques réservations', e);
      return {
        'total': 0,
        'byMonth': {},
        'revenueByMonth': {},
        'byStatus': {},
        'byPartnerType': {},
        'topPartners': {},
      };
    }
  }
}
