import 'package:flutter/material.dart';

class ComparisonProvider extends ChangeNotifier {
  // Liste des prestataires à comparer (maximum 2)
  final List<Map<String, dynamic>> _prestatairesToCompare = [];
  
  List<Map<String, dynamic>> get prestatairesToCompare => _prestatairesToCompare;
  
  // Vérifier si on peut ajouter d'autres prestataires à la comparaison
  bool get canAddMore => _prestatairesToCompare.length < 2;
  
  // Vérifier si un prestataire est déjà dans la liste de comparaison
  bool isInComparison(String id) {
    return _prestatairesToCompare.any((presta) => presta['id'] == id);
  }
  
  // Ajouter un prestataire à la comparaison
  void addToComparison(Map<String, dynamic> prestataire) {
    if (_prestatairesToCompare.length < 2 && 
        !isInComparison(prestataire['id'])) {
      _prestatairesToCompare.add(prestataire);
      notifyListeners();
    }
  }
  
  // Retirer un prestataire de la comparaison
  void removeFromComparison(String id) {
    _prestatairesToCompare.removeWhere((presta) => presta['id'] == id);
    notifyListeners();
  }
  
  // Vider la liste de comparaison
  void clearComparison() {
    _prestatairesToCompare.clear();
    notifyListeners();
  }
}