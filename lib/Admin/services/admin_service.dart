import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/logger.dart';
import '../models/admin_model.dart';
import '../../Partner/models/partner_model.dart';

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
    required String password,
  }) async {
    try {
      // 1. Créer un compte utilisateur
      final authResponse = await _client.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Échec de la création du compte utilisateur');
      }

      // 2. Ajouter l'administrateur dans la table admins
      final response = await _client.from('admins').insert({
        'id': authResponse.user!.id,
        'email': email,
        'nom': nom,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      return AdminModel.fromMap(response[0]);
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
}
