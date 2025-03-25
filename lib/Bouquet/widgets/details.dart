import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Écran de détail pour un prestataire
class PrestataireDetailScreen extends StatelessWidget {
  final String type; // 'lieu', 'traiteur', ou 'photographe'
  final Map<String, dynamic> prestataire;
  final bool isSelected;
  final VoidCallback onSelect;

  const PrestataireDetailScreen({
    Key? key,
    required this.type,
    required this.prestataire,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer les données du prestataire
    final String nom = prestataire['nom_entreprise'] ?? 'Sans nom';
    final String description = prestataire['description'] ?? '';
    final double? prixBase = prestataire['prix_base'] != null
        ? (prestataire['prix_base'] as num).toDouble()
        : null;
    final double? noteAverage = prestataire['note_moyenne'] != null
        ? (prestataire['note_moyenne'] as num).toDouble()
        : null;
    final String? region = prestataire['region'];
    final String? photoUrl = prestataire['photo_url'];
    
    // Formateur pour les prix
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    
    // Couleurs du thème
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    // Titre et icône selon le type
    String typeTitle = 'Détails du prestataire';
    IconData typeIcon = Icons.business;
    
    switch (type) {
      case 'lieu':
        typeTitle = 'Détails du lieu';
        typeIcon = Icons.villa;
        break;
      case 'traiteur':
        typeTitle = 'Détails du traiteur';
        typeIcon = Icons.restaurant;
        break;
      case 'photographe':
        typeTitle = 'Détails du photographe';
        typeIcon = Icons.camera_alt;
        break;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(nom),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isSelected)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  onSelect();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Sélectionner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du prestataire
            SizedBox(
              height: 250,
              width: double.infinity,
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(context, typeIcon),
                    )
                  : _buildPlaceholderImage(context, typeIcon),
            ),
            
            // Indicateur de sélection
            if (isSelected)
              Container(
                width: double.infinity,
                color: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Center(
                  child: Text(
                    'SÉLECTIONNÉ POUR VOTRE BOUQUET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Informations générales
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      if (noteAverage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                noteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Type spécifique
                  _buildTypeSpecificInfo(context),
                  
                  const SizedBox(height: 12),
                  
                  // Région
                  if (region != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          region,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Prix
                  if (prixBase != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: beige.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Prix de base:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(prixBase),
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
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Détails spécifiques au type de prestataire
                  _buildDetailedTypeContent(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isSelected ? null : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            onSelect();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text(
            'SÉLECTIONNER CE PRESTATAIRE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Construit les informations spécifiques au type (icône et texte)
  Widget _buildTypeSpecificInfo(BuildContext context) {
    final dynamic typeValue = _getTypeSpecificValue();
    if (typeValue == null) return const SizedBox();
    
    String typeText = '';
    IconData icon = Icons.info;
    
    switch (type) {
      case 'lieu':
        typeText = 'Type de lieu: ${typeValue.toString()}';
        icon = Icons.villa;
        break;
      case 'traiteur':
        if (typeValue is List) {
          typeText = 'Cuisine: ${typeValue.join(", ")}';
        } else {
          typeText = 'Cuisine: $typeValue';
        }
        icon = Icons.restaurant_menu;
        break;
      case 'photographe':
        if (typeValue is List) {
          typeText = 'Style: ${typeValue.join(", ")}';
        } else {
          typeText = 'Style: $typeValue';
        }
        icon = Icons.camera;
        break;
    }
    
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            typeText,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Récupère la valeur spécifique au type de prestataire
  dynamic _getTypeSpecificValue() {
    switch (type) {
      case 'lieu':
        return prestataire['type_lieu'];
      case 'traiteur':
        return prestataire['type_cuisine'];
      case 'photographe':
        return prestataire['style'];
      default:
        return null;
    }
  }
  
  /// Construit le contenu détaillé spécifique au type de prestataire
  Widget _buildDetailedTypeContent(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    switch (type) {
      case 'lieu':
        // Informations spécifiques aux lieux
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Caractéristiques du lieu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Capacité
            _buildFeatureRow(
              context,
              'Capacité maximale:', 
              '${prestataire['capacite_max'] ?? 'Non spécifiée'} personnes',
              Icons.people
            ),
            
            // Espace extérieur
            _buildFeatureRow(
              context,
              'Espace extérieur:', 
              prestataire['espace_exterieur'] == true ? 'Oui' : 'Non',
              Icons.park
            ),
            
            // Piscine
            _buildFeatureRow(
              context,
              'Piscine:', 
              prestataire['piscine'] == true ? 'Oui' : 'Non',
              Icons.pool
            ),
            
            // Parking
            _buildFeatureRow(
              context,
              'Parking:', 
              prestataire['parking'] == true ? 'Oui' : 'Non',
              Icons.local_parking
            ),
            
            // Hébergement
            _buildFeatureRow(
              context,
              'Hébergement:', 
              prestataire['hebergement'] == true ? 'Oui (${prestataire['capacite_hebergement']} personnes)' : 'Non',
              Icons.hotel
            ),
            
            // Salles disponibles
            if (prestataire['description_salles'] != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Salles disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildSallesGrid(prestataire['description_salles']),
            ],
          ],
        );
      
      case 'traiteur':
        // Informations spécifiques aux traiteurs
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services proposés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Nombre maximum d'invités
            _buildFeatureRow(
              context,
              'Capacité maximale:', 
              '${prestataire['max_invites'] ?? 'Non spécifiée'} personnes',
              Icons.people
            ),
            
            // Équipements inclus
            _buildFeatureRow(
              context,
              'Équipements inclus:', 
              prestataire['equipements_inclus'] == true ? 'Oui' : 'Non',
              Icons.restaurant
            ),
            
            // Personnel inclus
            _buildFeatureRow(
              context,
              'Personnel de service:', 
              prestataire['personnel_inclus'] == true ? 'Oui' : 'Non',
              Icons.person
            ),
            
            // Menus proposés (fictif pour l'exemple)
            const SizedBox(height: 24),
            const Text(
              'Exemples de menus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildMenuCard(
              'Menu Tradition',
              '75€ par personne',
              [
                'Entrée: Foie gras maison ou Velouté de saison',
                'Plat: Suprême de volaille ou Filet de poisson',
                'Dessert: Pièce montée ou Assortiment de mignardises'
              ],
              beige.withOpacity(0.2),
              accentColor,
            ),
            
            const SizedBox(height: 12),
            
            _buildMenuCard(
              'Menu Prestige',
              '95€ par personne',
              [
                'Entrée: Duo de foie gras et saumon fumé',
                'Plat: Filet de bœuf ou Lotte à l\'armoricaine',
                'Dessert: Pièce montée et buffet de desserts'
              ],
              beige.withOpacity(0.2),
              accentColor,
            ),
          ],
        );
      
      case 'photographe':
        // Informations spécifiques aux photographes
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services proposés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Option drone
            _buildFeatureRow(
              context,
              'Option drone:', 
              prestataire['drone'] == true ? 'Disponible' : 'Non disponible',
              Icons.airplanemode_active
            ),
            
            // Formules de durée
            if (prestataire['options_duree'] != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Formules disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildFormulesList(context, prestataire['options_duree'], accentColor, beige),
            ],
            
            // Exemples de photos (fictif pour l'exemple)
            const SizedBox(height: 24),
            const Text(
              'Portfolio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contactez ce photographe pour voir son portfolio complet.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      
      default:
        return const SizedBox();
    }
  }
  
  /// Construit une ligne pour une caractéristique avec icône
  Widget _buildFeatureRow(BuildContext context, String label, String value, IconData icon) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construit une grille pour les salles disponibles
  Widget _buildSallesGrid(Map<String, dynamic> salles) {
    final List<Widget> salleWidgets = [];
    
    salles.forEach((key, value) {
      if (value is Map) {
        salleWidgets.add(
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatKeyName(key),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (value['capacite'] != null)
                    Text('Capacité: ${value['capacite']} personnes'),
                  if (value['description'] != null)
                    Text(value['description']),
                ],
              ),
            ),
          ),
        );
      }
    });
    
    return Column(children: salleWidgets);
  }
  
  /// Formate le nom de la clé en format lisible
  String _formatKeyName(String key) {
    // Convertit snake_case en texte formaté
    return key.split('_').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }
  
  /// Construit une carte pour un menu
  Widget _buildMenuCard(String title, String price, List<String> items, Color bgColor, Color accentColor) {
    return Card(
      elevation: 2,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 15)),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  /// Construit la liste des formules pour photographe
  Widget _buildFormulesList(BuildContext context, Map<String, dynamic> options, Color accentColor, Color beige) {
    final List<Widget> formuleWidgets = [];
    
    options.forEach((key, value) {
      if (value is Map) {
        formuleWidgets.add(
          Card(
            elevation: 2,
            color: beige.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatKeyName(key),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (value['prix'] != null)
                        Text(
                          '${value['prix']}€',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (value['description'] != null)
                    Text(
                      value['description'],
                      style: const TextStyle(fontSize: 15),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    });
    
    return Column(children: formuleWidgets);
  }
  
  /// Crée une image de placeholder avec un arrière-plan coloré et une icône
  Widget _buildPlaceholderImage(BuildContext context, IconData icon) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Image non disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}