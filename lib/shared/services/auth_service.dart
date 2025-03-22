import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/logger.dart'; // Chemin corrigé vers le logger existant

/// Service d'authentification pour les partenaires et les administrateurs
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Vérifie si l'utilisateur est connecté
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Récupère l'utilisateur actuellement connecté
  User? get currentUser => _client.auth.currentUser;

  /// Vérifie si l'utilisateur est un partenaire
  Future<bool> isPartner() async {
    // Remplacer la condition currentUser == null par:
    if (!isLoggedIn) return false;

    try {
      final response = await _client
          .from('presta')
          .select('id')
          .eq('id', currentUser!.id)
          .single();

      return response != null;
    } catch (e) {
      AppLogger.error('Erreur lors de la vérification du statut partenaire', e);
      return false;
    }
  }

  /// Vérifie si l'utilisateur est un administrateur
  /// Vérifie si l'utilisateur est un administrateur
  Future<bool> isAdmin() async {
    if (!isLoggedIn) return false;

    try {
      // Utiliser une requête simplifiée pour éviter la récursion
      final response = await _client
          .from('admins')
          .select('email')
          .eq('id', currentUser!.id)
          .single();

      // Si la requête réussit, c'est un admin
      return response != null;
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la vérification du statut administrateur', e);
      return false;
    }
  }

  /// Connexion d'un utilisateur
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion', e);
      rethrow;
    }
  }

  Future<AuthResponse> registerPartner(
      String email, String password, String nom, String telephone) async {
    try {
      // 1. Créer un compte utilisateur
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 2. Ajouter les informations du partenaire dans la table presta
        await _client.from('presta').insert({
          'id': response.user!.id,
          'email': email,
          'nom_entreprise': nom,
          'nom_contact': nom, // Champ obligatoire
          'telephone': telephone,
          'adresse': 'À compléter', // Champ obligatoire
          'region': 'Paris', // Champ obligatoire
          'description': 'Description à compléter', // Champ obligatoire
          'type_budget':
              'abordable', // Champ obligatoire, à adapter selon l'enum budget_type
          'actif': true,
          'is_verified': false,
        });
      }

      return response;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'inscription du partenaire', e);
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      AppLogger.error('Erreur lors de la déconnexion', e);
      rethrow;
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.mariable://reset-callback/',
      );
    } catch (e) {
      AppLogger.error('Erreur lors de la réinitialisation du mot de passe', e);
      rethrow;
    }
  }

  /// Mise à jour du mot de passe
  Future<UserResponse> updatePassword(String password) async {
    try {
      return await _client.auth.updateUser(
        UserAttributes(
          password: password,
        ),
      );
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du mot de passe', e);
      rethrow;
    }
  }
}
