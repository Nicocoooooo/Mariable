import 'package:equatable/equatable.dart';

/// Types de questions possibles dans le quiz
enum QuizQuestionType {
  text,
  number,
  date,
  singleChoice,
  multipleChoice,
}

/// Modèle pour une option de réponse
class QuizOption extends Equatable {
  final String label;
  final String value;
  
  const QuizOption({
    required this.label,
    required this.value,
  });
  
  @override
  List<Object> get props => [label, value];
}

/// Modèle pour une question du quiz
class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final QuizQuestionType type;
  final List<QuizOption>? options;
  final bool required;
  
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.required = false,
  });
  
  @override
  List<Object?> get props => [id, question, type, options, required];
}

/// Modèle pour les résultats du quiz
class QuizResults extends Equatable {
  final Map<String, dynamic> answers;
  
  const QuizResults({
    required this.answers,
  });
  
  /// Récupère une réponse spécifique par ID
  T? getAnswer<T>(String id) {
    if (!answers.containsKey(id)) return null;
    
    final value = answers[id];
    if (value is T) {
      return value;
    }
    
    return null;
  }
  
  /// Obtient les préférences de lieu
  List<String> getLieuPreferences() {
    return List<String>.from(answers['lieu_preferences'] ?? []);
  }
  
  /// Obtient les préférences culinaires
  List<String> getCuisinePreferences() {
    return List<String>.from(answers['cuisine_preferences'] ?? []);
  }
  
  /// Obtient le style de photographie préféré
  String? getPhotoStyle() {
    return answers['photo_preferences'] as String?;
  }
  
  /// Obtient le style de mariage préféré
  String? getWeddingStyle() {
    return answers['style'] as String?;
  }
  
  /// Obtient la région préférée
  String? getRegion() {
    return answers['region'] as String?;
  }
  
  /// Obtient la fourchette de nombre d'invités
  String? getGuestsRange() {
    return answers['guests'] as String?;
  }
  
  /// Obtient le nombre d'invités (limite inférieure de la fourchette)
  int? getMinGuests() {
    final range = getGuestsRange();
    if (range == null) return null;
    
    if (range == '<50') return 0;
    if (range == '>200') return 200;
    
    final parts = range.split('-');
    if (parts.length != 2) return null;
    
    return int.tryParse(parts[0]);
  }
  
  /// Obtient le nombre d'invités (limite supérieure de la fourchette)
  int? getMaxGuests() {
    final range = getGuestsRange();
    if (range == null) return null;
    
    if (range == '<50') return 50;
    if (range == '>200') return 500; // Valeur arbitraire élevée
    
    final parts = range.split('-');
    if (parts.length != 2) return null;
    
    return int.tryParse(parts[1]);
  }
  
  /// Obtient la fourchette de budget
  String? getBudgetRange() {
    return answers['budget'] as String?;
  }
  
  /// Obtient le budget minimum
  int? getMinBudget() {
    final range = getBudgetRange();
    if (range == null) return null;
    
    if (range == '<10000') return 0;
    if (range == '>50000') return 50000;
    
    final parts = range.split('-');
    if (parts.length != 2) return null;
    
    return int.tryParse(parts[0]);
  }
  
  /// Obtient le budget maximum
  int? getMaxBudget() {
    final range = getBudgetRange();
    if (range == null) return null;
    
    if (range == '<10000') return 10000;
    if (range == '>50000') return 100000; // Valeur arbitraire élevée
    
    final parts = range.split('-');
    if (parts.length != 2) return null;
    
    return int.tryParse(parts[1]);
  }
  
  /// Obtient la date de l'événement
  DateTime? getEventDate() {
    final dateStr = answers['date'] as String?;
    if (dateStr == null) return null;
    
    return DateTime.tryParse(dateStr);
  }
  
  @override
  List<Object> get props => [answers];
  
  /// Copie avec nouvelles valeurs
  QuizResults copyWith({
    Map<String, dynamic>? answers,
  }) {
    return QuizResults(
      answers: answers ?? this.answers,
    );
  }
  
  /// Convertit les résultats en Map
  Map<String, dynamic> toMap() {
    return {
      'answers': answers,
    };
  }
  
  /// Crée une instance à partir d'un Map
  factory QuizResults.fromMap(Map<String, dynamic> map) {
    return QuizResults(
      answers: Map<String, dynamic>.from(map['answers'] ?? {}),
    );
  }
}