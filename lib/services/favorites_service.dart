import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'dart:async';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() {
    return _instance;
  }
  FavoritesService._internal();

  // Stream pour notifier des changements aux favoris
  final _favoritesStreamController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get favoritesStream => _favoritesStreamController.stream;
  List<String> _currentFavorites = [];

  // Vérifier si l'utilisateur est connecté
  bool isUserLoggedIn() {
    return Supabase.instance.client.auth.currentUser != null;
  }

  // Récupérer l'ID de l'utilisateur connecté
  String? getUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  // Charger tous les favoris actuels en une seule requête
  Future<List<String>> loadFavorites() async {
    try {
      final userId = getUserId();
      if (userId == null) return [];

      final response = await Supabase.instance.client
          .from('favoris')
          .select('presta_id')
          .eq('user_id', userId);
      
      _currentFavorites = response
          .map<String>((item) => item['presta_id'].toString())
          .toList();
      
      // Notifier les abonnés des changements
      _favoritesStreamController.add(_currentFavorites);
      return _currentFavorites;
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des favoris', e);
      return [];
    }
  }

  // Vérifier si un prestataire est dans les favoris de l'utilisateur
  Future<bool> isPrestaInFavorites(String prestaId) async {
    // Vérifier d'abord dans la cache locale si disponible
    if (_currentFavorites.isNotEmpty) {
      return _currentFavorites.contains(prestaId);
    }

    try {
      final userId = getUserId();
      if (userId == null) return false;
      
      final response = await Supabase.instance.client
          .from('favoris')
          .select()
          .eq('user_id', userId)
          .eq('presta_id', prestaId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      AppLogger.error('Erreur lors de la vérification des favoris', e);
      return false;
    }
  }

  // Ajouter un prestataire aux favoris
  Future<bool> addToFavorites(String prestaId) async {
    try {
      final userId = getUserId();
      if (userId == null) return false;
      
      // Vérifier si ce prestataire est déjà dans les favoris
      final isAlreadyFavorite = await isPrestaInFavorites(prestaId);
      if (isAlreadyFavorite) return true; // Déjà dans les favoris
      
      // Ajouter aux favoris
      await Supabase.instance.client.from('favoris').insert({
        'user_id': userId,
        'presta_id': prestaId,
      });
      
      // Mettre à jour la liste locale et notifier
      if (!_currentFavorites.contains(prestaId)) {
        _currentFavorites.add(prestaId);
        _favoritesStreamController.add(_currentFavorites);
      }
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'ajout aux favoris', e);
      return false;
    }
  }

  // Supprimer un prestataire des favoris
  Future<bool> removeFromFavorites(String prestaId) async {
    try {
      final userId = getUserId();
      if (userId == null) return false;
      
      await Supabase.instance.client
          .from('favoris')
          .delete()
          .eq('user_id', userId)
          .eq('presta_id', prestaId);
      
      // Mettre à jour la liste locale et notifier
      if (_currentFavorites.contains(prestaId)) {
        _currentFavorites.remove(prestaId);
        _favoritesStreamController.add(_currentFavorites);
      }
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression des favoris', e);
      return false;
    }
  }

  // Récupérer les favoris de l'utilisateur
  Future<List<Map<String, dynamic>>> getUserFavorites() async {
    try {
      final userId = getUserId();
      if (userId == null) return [];
      
      final response = await Supabase.instance.client
          .from('presta')
          .select('*, favoris!inner(*)')
          .eq('favoris.user_id', userId);
      
      // Mettre à jour la liste des IDs en mémoire
      _currentFavorites = response
          .map<String>((item) => item['id'].toString())
          .toList();
      
      // Notifier les abonnés
      _favoritesStreamController.add(_currentFavorites);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des favoris', e);
      return [];
    }
  }

  // Basculer l'état du favori (ajouter ou supprimer)
  Future<bool> toggleFavorite(String prestaId) async {
    try {
      final isInFavorites = await isPrestaInFavorites(prestaId);
      
      bool result;
      if (isInFavorites) {
        result = await removeFromFavorites(prestaId);
      } else {
        result = await addToFavorites(prestaId);
      }
      
      return result;
    } catch (e) {
      AppLogger.error('Erreur lors du basculement de favori', e);
      return false;
    }
  }
  
  // Méthode pour fermer le stream lorsqu'il n'est plus nécessaire
  void dispose() {
    _favoritesStreamController.close();
  }
}