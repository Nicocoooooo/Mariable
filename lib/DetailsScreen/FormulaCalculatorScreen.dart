import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates
import '../theme/app_theme.dart'; // Si vous utilisez votre thème custom
import '../utils/logger.dart'; // Pour les logs, si nécessaire
import '../buttons/AnimatedReserveButton.dart'; // Pour utiliser votre bouton personnalisé
import 'dart:collection'; // Pour LinkedHashMap si vous avez besoin de collections ordonnées



class FormulaCalculatorScreen extends StatefulWidget {
  final Map<String, dynamic> formula;

  const FormulaCalculatorScreen({
    Key? key,
    required this.formula,
  }) : super(key: key);

  @override
  State<FormulaCalculatorScreen> createState() => _FormulaCalculatorScreenState();
}

class _FormulaCalculatorScreenState extends State<FormulaCalculatorScreen> {
  late double basePrice;
  late String formulaName;
  int guestCount = 50;
  DateTime? selectedDate;
  List<Map<String, dynamic>> selectedOptions = [];
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    formulaName = widget.formula['nom_formule'] ?? 'Formule';
    basePrice = widget.formula['prix_base'] is num ? 
      widget.formula['prix_base'].toDouble() : 
      double.tryParse(widget.formula['prix_base'].toString()) ?? 0.0;
    totalPrice = basePrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formulaName),
        backgroundColor: const Color(0xFF524B46),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Contenu principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [Même contenu que précédemment]
                  // Ajoutez les widgets pour le nombre d'invités, la date, et les options
                ],
              ),
            ),
          ),
          
          // Pied de page avec total et bouton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        '${totalPrice.toInt()} €',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF524B46),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Ajouter au panier
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Formule ajoutée au panier')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF524B46),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter au panier'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  

// Dans le fichier DetailScreen ou un nouveau fichier FormulaCalculatorScreen
  void _showFormulaCalculator(Map<String, dynamic> formula) {
    // Récupération des données de base de la formule
    final String formulaName = formula['nom_formule'] ?? 'Formule';
    final double basePrice = formula['prix_base'] ?? 0.0;
    
    // Variables pour les options
    int guestCount = 50; // Valeur par défaut
    DateTime? selectedDate;
    List<Map<String, dynamic>> selectedOptions = [];
    double totalPrice = basePrice;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Titre et prix
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF524B46),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formulaName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${totalPrice.toInt()} €',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Contenu
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sélection du nombre d'invités
                            const Text(
                              'Nombre d\'invités',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Slider(
                              value: guestCount.toDouble(),
                              min: 10,
                              max: 200,
                              divisions: 19,
                              label: guestCount.toString(),
                              onChanged: (value) {
                                setState(() {
                                  guestCount = value.toInt();
                                  // Recalculer le prix en fonction du nombre d'invités
                                  totalPrice = basePrice;
                                  
                                  // Ajouter un supplément pour les grands événements
                                  if (guestCount > 100) {
                                    totalPrice += (guestCount - 100) * 10; // 10€ par invité supplémentaire au-delà de 100
                                  }
                                  
                                  // Ajouter le prix des options
                                  for (var option in selectedOptions) {
                                    totalPrice += option['prix'] ?? 0.0;
                                  }
                                });
                              },
                            ),
                            Center(
                              child: Text(
                                '$guestCount invités',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Sélection de la date
                            const Text(
                              'Date de l\'événement',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                    
                                    // Vérifier si c'est un week-end et appliquer une majoration
                                    if (picked.weekday == DateTime.saturday || picked.weekday == DateTime.sunday) {
                                      totalPrice = basePrice * 1.2; // 20% de plus pour les week-ends
                                    } else {
                                      totalPrice = basePrice;
                                    }
                                    
                                    // Réappliquer les majorations pour le nombre d'invités
                                    if (guestCount > 100) {
                                      totalPrice += (guestCount - 100) * 10;
                                    }
                                    
                                    // Ajouter le prix des options
                                    for (var option in selectedOptions) {
                                      totalPrice += option['prix'] ?? 0.0;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                width: double.infinity,
                                child: Text(
                                  selectedDate != null 
                                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                    : 'Sélectionner une date',
                                  style: TextStyle(
                                    color: selectedDate != null ? Colors.black : Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Options supplémentaires
                            const Text(
                              'Options supplémentaires',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildOption(
                              'Service de nettoyage',
                              'Nettoyage complet avant et après l\'événement',
                              250.0,
                              selectedOptions.any((o) => o['nom'] == 'Service de nettoyage'),
                              (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    selectedOptions.add({
                                      'nom': 'Service de nettoyage',
                                      'prix': 250.0,
                                    });
                                    totalPrice += 250.0;
                                  } else {
                                    selectedOptions.removeWhere((o) => o['nom'] == 'Service de nettoyage');
                                    totalPrice -= 250.0;
                                  }
                                });
                              },
                            ),
                            _buildOption(
                              'Coordinateur sur place',
                              'Un coordinateur dédié pendant toute la durée de l\'événement',
                              500.0,
                              selectedOptions.any((o) => o['nom'] == 'Coordinateur sur place'),
                              (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    selectedOptions.add({
                                      'nom': 'Coordinateur sur place',
                                      'prix': 500.0,
                                    });
                                    totalPrice += 500.0;
                                  } else {
                                    selectedOptions.removeWhere((o) => o['nom'] == 'Coordinateur sur place');
                                    totalPrice -= 500.0;
                                  }
                                });
                              },
                            ),
                            _buildOption(
                              'Hébergement',
                              'Chambres disponibles pour 20 personnes',
                              800.0,
                              selectedOptions.any((o) => o['nom'] == 'Hébergement'),
                              (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    selectedOptions.add({
                                      'nom': 'Hébergement',
                                      'prix': 800.0,
                                    });
                                    totalPrice += 800.0;
                                  } else {
                                    selectedOptions.removeWhere((o) => o['nom'] == 'Hébergement');
                                    totalPrice -= 800.0;
                                  }
                                });
                              },
                            ),
                            _buildOption(
                              'Système son et lumière',
                              'Équipement professionnel pour votre soirée',
                              350.0,
                              selectedOptions.any((o) => o['nom'] == 'Système son et lumière'),
                              (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    selectedOptions.add({
                                      'nom': 'Système son et lumière',
                                      'prix': 350.0,
                                    });
                                    totalPrice += 350.0;
                                  } else {
                                    selectedOptions.removeWhere((o) => o['nom'] == 'Système son et lumière');
                                    totalPrice -= 350.0;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Barre d'actions en bas
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${totalPrice.toInt()} €',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF524B46),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Ajouter au panier et fermer
                              // Ici, implémentez la logique pour ajouter au panier
                              Navigator.pop(context);
                              
                              // Afficher un message de confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Formule ajoutée au panier'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF524B46),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Ajouter au panier',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // Widget pour construire une option
  Widget _buildOption(
    String title, 
    String description, 
    double price, 
    bool isSelected, 
    Function(bool) onToggle
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF524B46) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => onToggle(!isSelected),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${price.toInt()} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF524B46),
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (value) => onToggle(value ?? false),
                activeColor: const Color(0xFF524B46),
              ),
            ],
          ),
        ),
      ),
    );
  }
}