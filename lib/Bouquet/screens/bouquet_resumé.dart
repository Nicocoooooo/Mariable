import 'package:flutter/material.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import 'package:intl/intl.dart';

/// Écran qui affiche le résumé du bouquet avec tous les prestataires sélectionnés
class BouquetResumScreen extends StatefulWidget {
  final BouquetModel bouquet;
  final QuizResults? quizResults;
  final VoidCallback onSaveBouquet;
  final Function(int)? onNavigateToStep;

  const BouquetResumScreen({
    Key? key,
    required this.bouquet,
    this.quizResults,
    required this.onSaveBouquet,
    this.onNavigateToStep,
  }) : super(key: key);

  @override
  State<BouquetResumScreen> createState() => _BouquetResumScreenState();
}

class _BouquetResumScreenState extends State<BouquetResumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bouquetNameController = TextEditingController();
  DateTime? _eventDate;
  
  @override
  void initState() {
    super.initState();
    _bouquetNameController.text = widget.bouquet.nom ?? 'Mon bouquet de mariage';
    
    // Initialiser la date de l'événement à partir du bouquet ou du quiz
    _eventDate = widget.bouquet.dateEvenement ?? 
                (widget.quizResults?.getEventDate() ?? 
                DateTime.now().add(const Duration(days: 180)));
  }
  
  @override
  void dispose() {
    _bouquetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculer le prix total du bouquet
    final double totalPrice = widget.bouquet.calculerPrixTotal();
    
    // Formatters pour les prix et dates
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    // Couleurs du thème
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et description du bouquet
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _bouquetNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de votre bouquet',
                    hintText: 'Ex: Mon mariage de rêve',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez donner un nom à votre bouquet';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Date de l'événement
                InkWell(
                  onTap: () => _selectEventDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de l\'événement',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _eventDate != null 
                          ? dateFormatter.format(_eventDate!) 
                          : 'Sélectionner une date',
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Résumé du quiz si disponible
          if (widget.quizResults != null)
            _buildQuizSummary(accentColor, beige),
          
          const SizedBox(height: 24),
          
          // Résumé du prix total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: beige.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total estimé:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencyFormatter.format(totalPrice),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Affichage des prestataires sélectionnés
          Text(
            'Prestataires sélectionnés',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // Carte du lieu
          if (widget.bouquet.lieu != null)
            _buildPrestataireSummaryCard(
              icon: Icons.place,
              title: 'Lieu',
              prestataire: widget.bouquet.lieu!,
              context: context,
              step: 0, // Étape 0 pour le Lieu dans le nouveau système
            ),
            
          // Carte du traiteur
          if (widget.bouquet.traiteur != null)
            _buildPrestataireSummaryCard(
              icon: Icons.restaurant,
              title: 'Traiteur',
              prestataire: widget.bouquet.traiteur!,
              context: context,
              step: 1, // Étape 1 pour le Traiteur
            ),
            
          // Carte du photographe
          if (widget.bouquet.photographe != null)
            _buildPrestataireSummaryCard(
              icon: Icons.camera_alt,
              title: 'Photographe',
              prestataire: widget.bouquet.photographe!,
              context: context,
              step: 2, // Étape 2 pour le Photographe
            ),
          
          const SizedBox(height: 24),
          
          // Bouton de finalisation
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Mettre à jour le nom et la date du bouquet
                  widget.onSaveBouquet();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Finaliser mon bouquet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Informations complémentaires
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations importantes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Ce bouquet est une estimation. Des options supplémentaires pourront être ajoutées lors de la finalisation avec les prestataires.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Les tarifs affichés sont donnés à titre indicatif et peuvent varier selon la date exacte et les détails de votre événement.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• En validant ce bouquet, vous ne procédez pas encore à une réservation définitive. Vous pourrez contacter les prestataires pour finaliser les détails.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construit une carte de résumé pour le quiz
  Widget _buildQuizSummary(Color accentColor, Color beige) {
    final quiz = widget.quizResults!;
    
    // Formatage de la date
    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    // Récupérer les principales informations du quiz
    final String? region = quiz.getRegion();
    final String? guestsRange = quiz.getGuestsRange();
    final String? budgetRange = quiz.getBudgetRange();
    final String? weddingStyle = quiz.getWeddingStyle();
    final DateTime? eventDate = quiz.getEventDate();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: accentColor),
                const SizedBox(width: 8),
                const Text(
                  'Résumé de vos préférences',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () {
                    // Retourner à l'étape du quiz (indice -1 dans le nouveau système)
                    if (widget.onNavigateToStep != null) {
                      widget.onNavigateToStep!(-1);
                    }
                  },
                  tooltip: 'Modifier les préférences',
                ),
              ],
            ),
            const Divider(),
            
            // Date de l'événement
            if (eventDate != null)
              _buildQuizInfoItem(
                context,
                'Date du mariage',
                dateFormatter.format(eventDate),
                Icons.calendar_month,
              ),
            
            // Région
            if (region != null)
              _buildQuizInfoItem(
                context,
                'Région',
                region,
                Icons.location_on,
              ),
            
            // Nombre d'invités
            if (guestsRange != null)
              _buildQuizInfoItem(
                context,
                'Invités',
                _formatGuestsRange(guestsRange),
                Icons.people,
              ),
            
            // Budget
            if (budgetRange != null)
              _buildQuizInfoItem(
                context,
                'Budget global',
                _formatBudgetRange(budgetRange),
                Icons.euro,
              ),
            
            // Style de mariage
            if (weddingStyle != null)
              _buildQuizInfoItem(
                context,
                'Style de mariage',
                _formatWeddingStyle(weddingStyle),
                Icons.style,
              ),
          ],
        ),
      ),
    );
  }
  
  /// Construit un élément d'information du quiz
  Widget _buildQuizInfoItem(BuildContext context, String label, String value, IconData icon) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Formate la fourchette d'invités pour l'affichage
  String _formatGuestsRange(String range) {
    switch (range) {
      case '<50':
        return 'Moins de 50 personnes';
      case '50-100':
        return 'Entre 50 et 100 personnes';
      case '100-150':
        return 'Entre 100 et 150 personnes';
      case '150-200':
        return 'Entre 150 et 200 personnes';
      case '>200':
        return 'Plus de 200 personnes';
      default:
        return range;
    }
  }
  
  /// Formate la fourchette de budget pour l'affichage
  String _formatBudgetRange(String range) {
    switch (range) {
      case '<10000':
        return 'Moins de 10 000€';
      case '10000-20000':
        return 'Entre 10 000€ et 20 000€';
      case '20000-30000':
        return 'Entre 20 000€ et 30 000€';
      case '30000-50000':
        return 'Entre 30 000€ et 50 000€';
      case '>50000':
        return 'Plus de 50 000€';
      default:
        return range;
    }
  }
  
  /// Formate le style de mariage pour l'affichage
  String _formatWeddingStyle(String style) {
    switch (style) {
      case 'classique':
        return 'Classique & Élégant';
      case 'champetre':
        return 'Champêtre & Rustique';
      case 'boheme':
        return 'Bohème';
      case 'moderne':
        return 'Moderne & Minimaliste';
      case 'luxe':
        return 'Luxueux';
      case 'original':
        return 'Original & Décalé';
      default:
        return style;
    }
  }
  
  /// Construit une carte de résumé pour un prestataire
  Widget _buildPrestataireSummaryCard({
    required IconData icon,
    required String title,
    required PrestataireModel prestataire,
    required BuildContext context,
    required int step,
  }) {
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final accentColor = Theme.of(context).colorScheme.primary;
    
    // Déterminer des détails spécifiques selon le type de prestataire
    List<Widget> detailWidgets = [];
    
    if (prestataire is LieuModel) {
      // Ajouter des détails spécifiques au lieu
      if (prestataire.capaciteMax != null) {
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Capacité: ${prestataire.capaciteMax} personnes',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        );
      }
      if (prestataire.typeLieu != null) {
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.house, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Type: ${prestataire.typeLieu}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        );
      }
    } else if (prestataire is TraiteurModel) {
      // Ajouter des détails spécifiques au traiteur
      if (prestataire.typeCuisine != null && prestataire.typeCuisine!.isNotEmpty) {
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Cuisine: ${prestataire.typeCuisine!.join(", ")}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (prestataire is PhotographeModel) {
      // Ajouter des détails spécifiques au photographe
      if (prestataire.style != null && prestataire.style!.isNotEmpty) {
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.style, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Style: ${prestataire.style!.join(", ")}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      if (prestataire.drone == true) {
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.flight, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Drone disponible',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône et type
            Row(
              children: [
                Icon(icon, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (prestataire.noteAverage != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        prestataire.noteAverage!.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(),
            
            // Nom et détails du prestataire
            Text(
              prestataire.nomEntreprise,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            
            // Détails spécifiques au type de prestataire
            ...detailWidgets,
            
            const SizedBox(height: 8),
            
            // Description courte
            Text(
              _getShortDescription(prestataire.description),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Formule choisie si disponible
            if (prestataire.formuleChoisie != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Formule: ${prestataire.formuleChoisie!['nom'] ?? 'Standard'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (prestataire.formuleChoisie!['description'] != null)
                      Text(
                        prestataire.formuleChoisie!['description'],
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Prix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prix estimé:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(prestataire.prixBase ?? 0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Bouton pour modifier la sélection
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  // Naviguer à l'étape correspondante
                  if (widget.onNavigateToStep != null) {
                    widget.onNavigateToStep!(step);
                  }
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifier'),
                style: TextButton.styleFrom(
                  foregroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Raccourcit la description si elle est trop longue
  String _getShortDescription(String description) {
    if (description.length <= 100) {
      return description;
    }
    return '${description.substring(0, 97)}...';
  }
  
  /// Affiche le sélecteur de date pour l'événement
  Future<void> _selectEventDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    
    if (picked != null && picked != _eventDate) {
      setState(() {
        _eventDate = picked;
      });
    }
  }
}