import 'package:flutter/material.dart';

class FormulaCalculatorScreen extends StatefulWidget {
  final Map<String, dynamic> formula;

  const FormulaCalculatorScreen({
    super.key,
    required this.formula,
  });

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
                color: Colors.black.withAlpha(26), // 0.1 * 255 = environ 26
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