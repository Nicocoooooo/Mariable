import 'package:flutter/material.dart';

/// Widget qui affiche un stepper horizontal pour indiquer la progression
/// dans le processus de création de bouquet
class BouquetStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const BouquetStepper({
    Key? key,
    required this.steps,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 80,
      color: beige.withOpacity(0.2),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          // Éléments aux positions paires (0, 2, 4) sont des étapes
          if (index % 2 == 0) {
            final stepIndex = index ~/ 2;
            final bool isActive = stepIndex == currentStep;
            final bool isCompleted = stepIndex < currentStep;
            
            return Expanded(
              child: _buildStep(
                context: context,
                label: steps[stepIndex],
                stepNumber: stepIndex + 1,
                isActive: isActive,
                isCompleted: isCompleted,
                accentColor: accentColor,
                textColor: textColor,
              ),
            );
          }
          // Éléments aux positions impaires (1, 3) sont des connecteurs
          else {
            final beforeStepIndex = index ~/ 2;
            final bool isCompleted = beforeStepIndex < currentStep;
            
            return _buildConnector(
              isCompleted: isCompleted,
              accentColor: accentColor,
            );
          }
        }),
      ),
    );
  }

  /// Construit une étape du stepper
  Widget _buildStep({
    required BuildContext context,
    required String label,
    required int stepNumber,
    required bool isActive,
    required bool isCompleted,
    required Color accentColor,
    required Color textColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cercle avec numéro ou icône de validation
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted ? accentColor : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    stepNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        // Libellé de l'étape
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? accentColor : textColor.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construit un connecteur entre deux étapes
  Widget _buildConnector({
    required bool isCompleted,
    required Color accentColor,
  }) {
    return SizedBox(
      width: 20,
      child: Divider(
        color: isCompleted ? accentColor : Colors.grey[300],
        thickness: 1.5,
        height: 1,
      ),
    );
  }
}