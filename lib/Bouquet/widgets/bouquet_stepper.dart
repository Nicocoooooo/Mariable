import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // Couleurs du thème pour harmoniser avec le reste de l'app
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          // Rangée de fleurs et de symboles entre les étapes
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              // Pour les index pairs (0, 2, 4, ...), on affiche la fleur
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                final bool isCompleted = stepIndex < currentStep;
                final bool isCurrent = stepIndex == currentStep;
                final bool isLast = stepIndex == steps.length - 1;
                
                return Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cercle de background pour les étapes complétées uniquement
                        if (isCompleted)
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: accentColor,
                                width: 2,
                              ),
                            ),
                          ),
                          
                        // SVG de fleur pour les étapes normales, bouquet pour la dernière
                        SvgPicture.asset(
                          isLast ? 'assets/images/12.svg' : 'assets/images/f.svg',
                          width: 32,
                          height: 32,
                          colorFilter: isCompleted || isCurrent 
                            ? ColorFilter.mode(accentColor, BlendMode.srcIn)
                            : ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Pour les index impairs (1, 3, 5, ...), on affiche un symbole + ou =
                final stepBeforeIndex = index ~/ 2;
                final bool isCompleted = stepBeforeIndex < currentStep;
                final bool isBeforeLast = stepBeforeIndex == steps.length - 2;
                
                return Center(
                  child: Text(
                    isBeforeLast ? '=' : '+',
                    style: TextStyle(
                      color: isCompleted ? accentColor : Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                );
              }
            }),
          ),
          
          // Libellés des étapes
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: steps.asMap().entries.map((entry) {
              final int idx = entry.key;
              final String step = entry.value;
              final bool isCompleted = idx < currentStep;
              final bool isCurrent = idx == currentStep;
              
              return Expanded(
                child: Text(
                  step,
                  style: TextStyle(
                    color: isCompleted ? accentColor : (isCurrent ? accentColor : textColor.withOpacity(0.5)),
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}