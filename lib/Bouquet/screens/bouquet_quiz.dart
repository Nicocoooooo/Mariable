import 'package:flutter/material.dart';
import 'package:mariable/theme/app_theme.dart';
import '../data/quiz_model.dart';

class BouquetQuizScreen extends StatefulWidget {
  final Function(QuizResults) onQuizCompleted;
  final QuizResults? initialResults;

  const BouquetQuizScreen({
    Key? key,
    required this.onQuizCompleted,
    this.initialResults,
  }) : super(key: key);

  @override
  State<BouquetQuizScreen> createState() => _BouquetQuizScreenState();
}

class _BouquetQuizScreenState extends State<BouquetQuizScreen> {
  // Index de la question actuelle
  int _currentQuestionIndex = 0;
  
  // Résultats du quiz
  late QuizResults _quizResults;
  
  // Liste des questions du quiz
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: 'guests',
      question: 'Combien d\'invités prévoyez-vous pour votre mariage ?',
      type: QuizQuestionType.singleChoice,
      options: [
        QuizOption(label: 'Moins de 50 personnes', value: '<50'),
        QuizOption(label: '50 à 100 personnes', value: '50-100'),
        QuizOption(label: '100 à 150 personnes', value: '100-150'),
        QuizOption(label: '150 à 200 personnes', value: '150-200'),
        QuizOption(label: 'Plus de 200 personnes', value: '>200'),
      ],
      required: true,
    ),
    QuizQuestion(
      id: 'region',
      question: 'Dans quelle région souhaitez-vous organiser votre mariage ?',
      type: QuizQuestionType.singleChoice,
      options: [
        QuizOption(label: 'Île-de-France', value: 'Île-de-France'),
        QuizOption(label: 'Provence-Alpes-Côte d\'Azur', value: 'Provence-Alpes-Côte d\'Azur'),
        QuizOption(label: 'Auvergne-Rhône-Alpes', value: 'Auvergne-Rhône-Alpes'),
        QuizOption(label: 'Occitanie', value: 'Occitanie'),
        QuizOption(label: 'Nouvelle-Aquitaine', value: 'Nouvelle-Aquitaine'),
        QuizOption(label: 'Bretagne', value: 'Bretagne'),
        QuizOption(label: 'Normandie', value: 'Normandie'),
        QuizOption(label: 'Hauts-de-France', value: 'Hauts-de-France'),
        QuizOption(label: 'Grand Est', value: 'Grand Est'),
        QuizOption(label: 'Pays de la Loire', value: 'Pays de la Loire'),
      ],
      required: true,
    ),
    QuizQuestion(
      id: 'style',
      question: 'Quel style de mariage imaginez-vous ?',
      type: QuizQuestionType.singleChoice,
      options: [
        QuizOption(label: 'Classique & Élégant', value: 'classique'),
        QuizOption(label: 'Champêtre & Rustique', value: 'champetre'),
        QuizOption(label: 'Bohème', value: 'boheme'),
        QuizOption(label: 'Moderne & Minimaliste', value: 'moderne'),
        QuizOption(label: 'Luxueux', value: 'luxe'),
        QuizOption(label: 'Original & Décalé', value: 'original'),
      ],
    ),
    QuizQuestion(
      id: 'lieu_preferences',
      question: 'Quels éléments sont importants pour votre lieu de réception ?',
      type: QuizQuestionType.multipleChoice,
      options: [
        QuizOption(label: 'Espace extérieur', value: 'exterieur'),
        QuizOption(label: 'Hébergement sur place', value: 'hebergement'),
        QuizOption(label: 'Vue exceptionnelle', value: 'vue'),
        QuizOption(label: 'Capacité importante', value: 'grande_capacite'),
        QuizOption(label: 'Lieu historique', value: 'historique'),
      ],
    ),
    QuizQuestion(
      id: 'cuisine_preferences',
      question: 'Quelles sont vos préférences culinaires ?',
      type: QuizQuestionType.multipleChoice,
      options: [
        QuizOption(label: 'Cuisine française traditionnelle', value: 'francaise'),
        QuizOption(label: 'Cuisine gastronomique', value: 'gastronomique'),
        QuizOption(label: 'Cuisine internationale', value: 'internationale'),
        QuizOption(label: 'Buffet', value: 'buffet'),
        QuizOption(label: 'Service à table', value: 'service_table'),
      ],
    ),
  ];
  
  // Map pour stocker les réponses aux questions
  final Map<String, dynamic> _answers = {};
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser les résultats du quiz
    _quizResults = widget.initialResults ?? QuizResults(answers: {});
    
    // Pré-remplir les réponses si disponibles
    if (widget.initialResults != null) {
      _answers.addAll(widget.initialResults!.answers);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final Color accentColor = AppTheme.accentColor;
    final Color beige = AppTheme.beige;
    
    // Calcul de la progression
    final double progress = (_currentQuestionIndex + 1) / _questions.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos préférences'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // En-tête avec progression
          Container(
            padding: const EdgeInsets.all(16),
            color: beige,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicateur de progression textuel
                Text(
                  'Question ${_currentQuestionIndex + 1} sur ${_questions.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Barre de progression
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          
          // Contenu principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Text(
                    _getCurrentQuestion().question,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Options de réponse selon le type de question
                  _buildQuestionContent(),
                ],
              ),
            ),
          ),
          
          // Boutons de navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Précédent
                if (_currentQuestionIndex > 0)
                  OutlinedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                
                // Bouton Suivant ou Terminer
                ElevatedButton.icon(
                  onPressed: _hasAnswer() ? _nextQuestion : null,
                  icon: Icon(_currentQuestionIndex < _questions.length - 1 
                      ? Icons.arrow_forward 
                      : Icons.check),
                  label: Text(_currentQuestionIndex < _questions.length - 1 
                      ? 'Suivant' 
                      : 'Terminer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Obtient la question actuelle
  QuizQuestion _getCurrentQuestion() {
    return _questions[_currentQuestionIndex];
  }
  
  /// Vérifie si la question actuelle a une réponse
  bool _hasAnswer() {
    final questionId = _getCurrentQuestion().id;
    
    if (!_getCurrentQuestion().required) {
      return true;
    }
    
    return _answers.containsKey(questionId) && 
           _answers[questionId] != null && 
           (_answers[questionId] is! List || (_answers[questionId] as List).isNotEmpty);
  }
  
  /// Passe à la question précédente
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }
  
  /// Passe à la question suivante
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Fin du quiz, envoyer les résultats
      _finalizeQuiz();
    }
  }
  
  /// Finalise le quiz et envoie les résultats
  void _finalizeQuiz() {
    _quizResults = QuizResults(answers: Map.from(_answers));
    widget.onQuizCompleted(_quizResults);
  }
  
  /// Sélectionne une option pour une question à choix unique
  void _selectSingleOption(String value) {
    setState(() {
      _answers[_getCurrentQuestion().id] = value;
    });
  }
  
  /// Sélectionne ou désélectionne une option pour une question à choix multiple
  void _toggleMultiOption(String value) {
    setState(() {
      final questionId = _getCurrentQuestion().id;
      
      if (!_answers.containsKey(questionId)) {
        _answers[questionId] = <String>[];
      }
      
      final List<String> selectedOptions = List<String>.from(_answers[questionId] ?? []);
      
      if (selectedOptions.contains(value)) {
        selectedOptions.remove(value);
      } else {
        selectedOptions.add(value);
      }
      
      _answers[questionId] = selectedOptions;
    });
  }
  
  /// Vérifie si une option est sélectionnée pour une question à choix unique
  bool _isOptionSelected(String value) {
    final questionId = _getCurrentQuestion().id;
    return _answers.containsKey(questionId) && _answers[questionId] == value;
  }
  
  /// Vérifie si une option est sélectionnée pour une question à choix multiple
  bool _isMultiOptionSelected(String value) {
    final questionId = _getCurrentQuestion().id;
    if (!_answers.containsKey(questionId)) return false;
    
    final List<String> selectedOptions = List<String>.from(_answers[questionId] ?? []);
    return selectedOptions.contains(value);
  }
  
  /// Construit le contenu de la question en fonction de son type
  Widget _buildQuestionContent() {
    final question = _getCurrentQuestion();
    
    switch (question.type) {
      case QuizQuestionType.singleChoice:
        return _buildSingleChoiceOptions();
        
      case QuizQuestionType.multipleChoice:
        return _buildMultipleChoiceOptions();
        
      default:
        return const Text('Type de question non pris en charge');
    }
  }
  
  /// Construit les options pour une question à choix unique
  Widget _buildSingleChoiceOptions() {
    final question = _getCurrentQuestion();
    final options = question.options ?? [];
    
    // Mise en forme spéciale pour les régions
    if (question.id == 'region') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final bool isSelected = _isOptionSelected(option.value);
          
          return Card(
            elevation: isSelected ? 4 : 1,
            color: isSelected 
                ? AppTheme.accentColor
                : AppTheme.beige.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected 
                    ? AppTheme.accentColor
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: () => _selectSingleOption(option.value),
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      );
    }
    
    // Affichage standard pour les autres questions à choix unique
    return Column(
      children: options.map((option) {
        final bool isSelected = _isOptionSelected(option.value);
        
        return Card(
          elevation: isSelected ? 2 : 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected 
                  ? AppTheme.accentColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => _selectSingleOption(option.value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Radio<String>(
                    value: option.value,
                    groupValue: _answers[question.id],
                    onChanged: (value) {
                      if (value != null) {
                        _selectSingleOption(value);
                      }
                    },
                    activeColor: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// Construit les options pour une question à choix multiple
  Widget _buildMultipleChoiceOptions() {
    final question = _getCurrentQuestion();
    final options = question.options ?? [];
    
    return Column(
      children: options.map((option) {
        final bool isSelected = _isMultiOptionSelected(option.value);
        
        return Card(
          elevation: isSelected ? 2 : 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected 
                  ? AppTheme.accentColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => _toggleMultiOption(option.value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      _toggleMultiOption(option.value);
                    },
                    activeColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}