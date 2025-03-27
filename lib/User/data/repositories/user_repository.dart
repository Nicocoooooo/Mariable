import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../utils/logger.dart';

/// Repository pour gérer toutes les opérations de données liées aux utilisateurs
class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  /// Récupérer les données d'un utilisateur par son ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromMap(response);
          return null;
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération de l\'utilisateur', e);
      return null;
    }
  }

  /// Récupérer les données de l'utilisateur actuellement connecté
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;
    
    return getUserById(currentUser.id);
  }

  /// Mettre à jour les données d'un utilisateur
  Future<bool> updateUser(UserModel user) async {
    try {
      await _client
          .from('users')
          .update(user.toMap())
          .eq('id', user.id);
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour de l\'utilisateur', e);
      return false;
    }
  }

  /// Ajouter un prestataire aux favoris
  Future<bool> addToFavorites(String prestataireId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      // Récupérer la liste actuelle des favoris ou créer une liste vide
      List<String> favorites = currentUser.favoritePrestataires ?? [];
      
      // Vérifier si le prestataire est déjà dans les favoris
      if (favorites.contains(prestataireId)) return true;
      
      // Ajouter le prestataire aux favoris
      favorites.add(prestataireId);
      
      // Mettre à jour la liste des favoris dans la base de données
      await _client
          .from('users')
          .update({'favorite_prestataires': favorites})
          .eq('id', currentUser.id);
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'ajout aux favoris', e);
      return false;
    }
  }

  /// Supprimer un prestataire des favoris
  Future<bool> removeFromFavorites(String prestataireId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      // Récupérer la liste actuelle des favoris
      List<String> favorites = currentUser.favoritePrestataires ?? [];
      
      // Vérifier si le prestataire est dans les favoris
      if (!favorites.contains(prestataireId)) return true;
      
      // Supprimer le prestataire des favoris
      favorites.remove(prestataireId);
      
      // Mettre à jour la liste des favoris dans la base de données
      await _client
          .from('users')
          .update({'favorite_prestataires': favorites})
          .eq('id', currentUser.id);
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression des favoris', e);
      return false;
    }
  }

  /// Vérifier si un prestataire est dans les favoris
  Future<bool> isFavorite(String prestataireId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      // Vérifier si le prestataire est dans les favoris
      return currentUser.favoritePrestataires?.contains(prestataireId) ?? false;
    } catch (e) {
      AppLogger.error('Erreur lors de la vérification des favoris', e);
      return false;
    }
  }

  /// Récupérer les tâches d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserTasks() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];
      
      final response = await _client
          .from('user_tasks')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des tâches', e);
      return [];
    }
  }

  /// Ajouter une tâche
  Future<bool> addTask(String title, String? description) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;
      
      await _client.from('user_tasks').insert({
        'user_id': currentUser.id,
        'title': title,
        'description': description,
        'done': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'ajout d\'une tâche', e);
      return false;
    }
  }

  /// Marquer une tâche comme terminée ou non
  Future<bool> updateTaskStatus(String taskId, bool done) async {
    try {
      await _client
          .from('user_tasks')
          .update({'done': done})
          .eq('id', taskId);
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du statut de la tâche', e);
      return false;
    }
  }

  /// Mettre à jour la date de mariage
  Future<bool> updateWeddingDate(DateTime weddingDate) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;
      
      await _client
          .from('users')
          .update({'wedding_date': weddingDate.toIso8601String()})
          .eq('id', currentUser.id);
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour de la date de mariage', e);
      return false;
    }
  }
}