import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Service d'authentification pour les utilisateurs
class UserAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final UserAuthService _instance = UserAuthService._internal();
  factory UserAuthService() => _instance;
  UserAuthService._internal();

  /// Vérifie si l'utilisateur est connecté
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Récupère l'utilisateur actuellement connecté
  User? get currentUser => _client.auth.currentUser;

  /// Vérifie si l'utilisateur est un utilisateur régulier (non admin, non prestataire)
  Future<bool> isRegularUser() async {
    if (!isLoggedIn) return false;

    try {
      final response = await _client
          .from('users')
          .select('id')
          .eq('id', currentUser!.id)
          .single();

      return response != null;
    } catch (e) {
      AppLogger.error('Erreur lors de la vérification du statut utilisateur', e);
      return false;
    }
  }

  /// Connexion avec email et mot de passe
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion avec email', e);
      rethrow;
    }
  }

  /// Inscription avec email et mot de passe
  Future<AuthResponse> signUpWithEmail(
      String email, String password, String fullName, String phone, DateTime? weddingDate) async {
    try {
      // 1. Créer un compte utilisateur
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 2. Ajouter les informations de l'utilisateur dans la table users
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'wedding_date': weddingDate?.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'inscription avec email', e);
      rethrow;
    }
  }

  /// Connexion avec Google
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.mariable://login-callback/',
      );
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion avec Google', e);
      rethrow;
    }
  }

  /// Connexion avec Apple
  Future<void> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.mariable://login-callback/',
      );
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion avec Apple', e);
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

  /// Mise à jour du profil utilisateur
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      if (!isLoggedIn) throw Exception('Utilisateur non connecté');
      
      await _client
          .from('users')
          .update(userData)
          .eq('id', currentUser!.id);
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du profil utilisateur', e);
      rethrow;
    }
  }

  /// Récupération des données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (!isLoggedIn) return null;
      
      final response = await _client
          .from('users')
          .select()
          .eq('id', currentUser!.id)
          .single();
      
      return response;
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des données utilisateur', e);
      return null;
    }
  }
}