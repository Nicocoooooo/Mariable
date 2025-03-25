import 'package:flutter/material.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';

/// Écran de quiz pour filtrer les prestataires selon les préférences utilisateur
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
      QuizOption(label: 'Paris', value: 'Paris'),
      QuizOption(label: 'Île-de-France', value: 'Île-de-France'),
      QuizOption(label: 'Lyon', value: 'Lyon'),
      QuizOption(label: 'Marseille', value: 'Marseille'),
      QuizOption(label: 'Bordeaux', value: 'Bordeaux'),
      QuizOption(label: 'Autre', value: 'Autre'),
    ],
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
      QuizOption(label: 'Proche de Paris', value: 'paris'),
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
  
  // Contrôleur pour les champs de texte
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  
  // Date sélectionnée pour la question de date
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser les résultats du quiz
    _quizResults = widget.initialResults ?? QuizResults(answers: {});
    
    // Pré-remplir les réponses si disponibles
    if (widget.initialResults != null) {
      _answers.addAll(widget.initialResults!.answers);
      
      // Initialiser les contrôleurs avec les valeurs existantes si disponibles
      if (_getCurrentQuestion().id == 'date' && _answers.containsKey('date')) {
        _selectedDate = DateTime.tryParse(_answers['date']);
      }
      
      if (_getCurrentQuestion().type == QuizQuestionType.text && 
          _answers.containsKey(_getCurrentQuestion().id)) {
        _textController.text = _answers[_getCurrentQuestion().id];
      }
      
      if (_getCurrentQuestion().type == QuizQuestionType.number && 
          _answers.containsKey(_getCurrentQuestion().id)) {
        _numberController.text = _answers[_getCurrentQuestion().id].toString();
      }
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    super.dispose();
  }
  
  /// Obtient la question actuelle
  QuizQuestion _getCurrentQuestion() {
    return _questions[_currentQuestionIndex];
  }
  
  /// Vérifie si la question actuelle a une réponse
  bool _hasAnswer() {
    final questionId = _getCurrentQuestion().id;
    
    if (_getCurrentQuestion().type == QuizQuestionType.date) {
      return _selectedDate != null;
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
        
        // Réinitialiser les contrôleurs pour la nouvelle question
        _updateControllers();
      });
    }
  }
  
  /// Passe à la question suivante
  void _nextQuestion() {
    // Enregistrer la réponse actuelle
    _saveCurrentAnswer();
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        
        // Réinitialiser les contrôleurs pour la nouvelle question
        _updateControllers();
      });
    } else {
      // Fin du quiz, envoyer les résultats
      _finalizeQuiz();
    }
  }
  
  /// Mettre à jour les contrôleurs en fonction de la question actuelle
  void _updateControllers() {
    final question = _getCurrentQuestion();
    
    if (question.type == QuizQuestionType.text && _answers.containsKey(question.id)) {
      _textController.text = _answers[question.id] ?? '';
    } else {
      _textController.clear();
    }
    
    if (question.type == QuizQuestionType.number && _answers.containsKey(question.id)) {
      _numberController.text = _answers[question.id]?.toString() ?? '';
    } else {
      _numberController.clear();
    }
    
    if (question.type == QuizQuestionType.date && _answers.containsKey(question.id)) {
      _selectedDate = DateTime.tryParse(_answers[question.id]);
    }
  }
  
  /// Sauvegarde la réponse à la question actuelle
  void _saveCurrentAnswer() {
    final question = _getCurrentQuestion();
    
    switch (question.type) {
      case QuizQuestionType.text:
        if (_textController.text.isNotEmpty) {
          _answers[question.id] = _textController.text;
        }
        break;
      case QuizQuestionType.number:
        if (_numberController.text.isNotEmpty) {
          _answers[question.id] = _numberController.text;
        }
        break;
      case QuizQuestionType.date:
        if (_selectedDate != null) {
          _answers[question.id] = _selectedDate!.toIso8601String();
        }
        break;
      // Les autres types sont gérés lors de la sélection des options
      default:
        break;
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
  
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    // Calcul de la progression
    final double progress = (_currentQuestionIndex + 1) / _questions.length;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec progression
            Container(
              padding: const EdgeInsets.all(16),
              color: beige.withOpacity(0.2),
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
                    color: Colors.black.withOpacity(0.05),
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construit le contenu de la question en fonction de son type
  Widget _buildQuestionContent() {
    final question = _getCurrentQuestion();
    
    switch (question.type) {
      case QuizQuestionType.text:
        return TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Votre réponse...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              // La mise à jour de l'état permet d'activer/désactiver le bouton Suivant
            });
          },
        );
        
      case QuizQuestionType.number:
        return TextFormField(
          controller: _numberController,
          decoration: const InputDecoration(
            hintText: 'Nombre...',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              // La mise à jour de l'état permet d'activer/désactiver le bouton Suivant
            });
          },
        );
        
      case QuizQuestionType.date:
        return _buildDatePicker();
        
      case QuizQuestionType.singleChoice:
        return _buildSingleChoiceOptions();
        
      case QuizQuestionType.multipleChoice:
        return _buildMultipleChoiceOptions();
        
      default:
        return const Text('Type de question non pris en charge');
    }
  }
  
  /// Construit un sélecteur de date
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: _selectedDate != null 
                        ? Colors.black 
                        : Colors.grey[600],
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cliquez pour sélectionner une date',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  /// Ouvre un sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  /// Construit les options pour une question à choix unique
  Widget _buildSingleChoiceOptions() {
    final question = _getCurrentQuestion();
    final options = question.options ?? [];
    
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
                  ? Theme.of(context).colorScheme.primary 
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
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  ? Theme.of(context).colorScheme.primary 
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
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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