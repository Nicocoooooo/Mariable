import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../widgets/bouquet_stepper.dart';
import 'bouquet_quiz.dart';
import 'ChoixLieu.dart';
import 'ChoixTraiteur.dart';
import 'ChoixPhotographe.dart';
import 'bouquet_resumé.dart';

/// Écran principal de création de bouquet qui gère le processus étape par étape
class BouquetCreationScreen extends StatefulWidget {
  const BouquetCreationScreen({Key? key}) : super(key: key);

  @override
  State<BouquetCreationScreen> createState() => _BouquetCreationScreenState();
}

class _BouquetCreationScreenState extends State<BouquetCreationScreen> {
  // Modèle de bouquet en construction (non-final pour permettre les mises à jour)
  BouquetModel _bouquet = BouquetModel();
  
  // Résultats du quiz pour filtrer les prestataires
  QuizResults? _quizResults;

  // Index de l'étape actuelle où -1 représente l'étape du quiz (non incluse dans la barre de progression)
  int _currentStep = -1;

  // Liste des étapes du processus (sans le quiz)
  final List<String> _steps = [
    'Lieu',
    'Traiteur',
    'Photographe',
    'Résumé'
  ];

  @override
  Widget build(BuildContext context) {
    // Couleurs basées sur le thème
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color backgroundColor = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == -1 ? 'Questionnaire initial' : 'Créer votre bouquet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Confirmer si l'utilisateur veut vraiment quitter
            if (_currentStep >= 0) {
              _showExitConfirmationDialog(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Stepper horizontal pour indiquer la progression (visible uniquement après le quiz)
          if (_currentStep >= 0)
            Column(
              children: [
                BouquetStepper(
                  steps: _steps,
                  currentStep: _currentStep,
                ),
                // Séparateur
                Divider(height: 1, thickness: 1, color: Colors.grey[200]),
              ],
            ),
          
          // Contenu principal qui change selon l'étape
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
      // Boutons de navigation entre les étapes (pas pour le quiz qui a ses propres boutons)
      bottomNavigationBar: _currentStep >= 0 
          ? _buildBottomNavigation(accentColor)
          : null,  // Pas de barre de navigation pour l'étape de quiz (elle a ses propres boutons)
    );
  }

  // Construit l'écran correspondant à l'étape actuelle
  Widget _buildCurrentStep() {
    if (_currentStep == -1) {
      // Phase de quiz
      return BouquetQuizScreen(
        onQuizCompleted: (results) {
          setState(() {
            _quizResults = results;
            
            // Mettre à jour la date de l'événement dans le bouquet si disponible
            if (results.getEventDate() != null) {
              _bouquet = _bouquet.copyWith(dateEvenement: results.getEventDate());
            }
            
            // Passer à la première étape réelle (Lieu)
            _currentStep = 0;
          });
        },
        initialResults: _quizResults,
      );
    }
    
    // Les étapes réelles du processus (après le quiz)
    switch (_currentStep) {
      case 0:  // Lieu
        return ChoixLieuScreen(
          onLieuSelected: (lieu) {
            setState(() {
              _bouquet = _bouquet.copyWith(lieu: lieu);
            });
          },
          selectedLieu: _bouquet.lieu,
          quizResults: _quizResults, // Passer les résultats du quiz pour filtrer
        );
      case 1:  // Traiteur
        return ChoixTraiteurScreen(
          onTraiteurSelected: (traiteur) {
            setState(() {
              _bouquet = _bouquet.copyWith(traiteur: traiteur);
            });
          },
          selectedTraiteur: _bouquet.traiteur,
          lieuId: _bouquet.lieu?.id, // Optionnel : filtrer par compatibilité avec le lieu
          quizResults: _quizResults, // Passer les résultats du quiz pour filtrer
        );
      case 2:  // Photographe
        return ChoixPhotographeScreen(
          onPhotographeSelected: (photographe) {
            setState(() {
              _bouquet = _bouquet.copyWith(photographe: photographe);
            });
          },
          selectedPhotographe: _bouquet.photographe,
          quizResults: _quizResults, // Passer les résultats du quiz pour filtrer
        );
      case 3:  // Résumé
        return BouquetResumScreen(
          bouquet: _bouquet,
          quizResults: _quizResults, // Inclure les résultats du quiz
          onSaveBouquet: _saveBouquet,
          onNavigateToStep: (step) {
            // Pour permettre de revenir au quiz (-1) ou à une étape spécifique
            _navigateToStep(step);
          },
        );
      default:
        return const Center(
          child: Text('Étape non reconnue'),
        );
    }
  }

  // Construit la barre de navigation inférieure
  Widget _buildBottomNavigation(Color accentColor) {
    bool isFirstStep = _currentStep == 0;
    bool isLastStep = _currentStep == _steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Précédent
          Visibility(
            visible: !isFirstStep,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: ElevatedButton.icon(
              onPressed: isFirstStep ? null : _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Précédent'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor),
              ),
            ),
          ),

          // Bouton Suivant ou Terminer
          ElevatedButton.icon(
            onPressed: _canMoveToNextStep() ? _nextStep : null,
            icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
            label: Text(isLastStep ? 'Finaliser' : 'Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  // Vérifie si on peut passer à l'étape suivante
  bool _canMoveToNextStep() {
    switch (_currentStep) {
      case 0:  // Lieu
        return _bouquet.lieu != null;
      case 1:  // Traiteur
        return _bouquet.traiteur != null;
      case 2:  // Photographe
        return _bouquet.photographe != null;
      case 3:  // Résumé
        return true; // À l'étape de résumé, on peut toujours finaliser
      default:
        return false;
    }
  }

  // Passe à l'étape suivante
  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Si c'est la dernière étape, finaliser le bouquet
      _saveBouquet();
    }
  }

  // Revient à l'étape précédente
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Navigue vers une étape spécifique
  void _navigateToStep(int step) {
    // Permet de naviguer vers le quiz (-1) ou les autres étapes (0-3)
    if (step >= -1 && step < _steps.length) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  // Sauvegarde le bouquet finalisé
  void _saveBouquet() {
    // Implémenter la logique de sauvegarde ici
    // Exemple: appel d'API, mise à jour de Supabase, etc.
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Votre bouquet a été créé avec succès!'),
        backgroundColor: Colors.green,
      ),
    );

    // Naviguer vers la page de détail du bouquet ou retourner à la page d'accueil
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Affiche une boîte de dialogue de confirmation pour quitter
  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quitter la création de bouquet?'),
          content: const Text(
            'Votre progression ne sera pas sauvegardée. Êtes-vous sûr de vouloir quitter?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                Navigator.of(context).pop(); // Revient à l'écran précédent
              },
              child: const Text('Quitter'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}