import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class PrestaireDetailScreen extends StatefulWidget {
  final Map<String, dynamic> prestataire;

  const PrestaireDetailScreen({
    Key? key,
    required this.prestataire,
  }) : super(key: key);

  @override
  State<PrestaireDetailScreen> createState() => _PrestaireDetailScreenState();
}

class _PrestaireDetailScreenState extends State<PrestaireDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Écouter le scroll pour changer l'apparence de l'AppBar
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Changer l'état si on scrolle plus bas que l'image
    final imageHeight = MediaQuery.of(context).size.height * 0.6;
    if (_scrollController.offset > imageHeight - kToolbarHeight && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset < imageHeight - kToolbarHeight && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraire les données du prestataire
    final String nom = widget.prestataire['nom_entreprise'] ?? 'Sans nom';
    final String region = widget.prestataire['region'] ?? '';
    final String adresse = widget.prestataire['adresse'] ?? '';
    final String location = (region.isNotEmpty && adresse.isNotEmpty) 
        ? '$region, France' 
        : (region.isNotEmpty ? '$region, France' : 'France');
    final String description = widget.prestataire['description'] ?? 'Aucune description disponible';
    final int? capaciteMax = widget.prestataire.containsKey('lieux') && 
                            widget.prestataire['lieux'] is List && 
                            widget.prestataire['lieux'].isNotEmpty && 
                            widget.prestataire['lieux'][0].containsKey('capacite_max') 
                              ? widget.prestataire['lieux'][0]['capacite_max'] 
                              : null;
    final double? prixBase = widget.prestataire['prix_base'] != null 
        ? (widget.prestataire['prix_base'] is double 
            ? widget.prestataire['prix_base'] 
            : double.tryParse(widget.prestataire['prix_base'].toString()))
        : null;
    final double? rating = widget.prestataire['note_moyenne'] != null 
        ? (widget.prestataire['note_moyenne'] is double 
            ? widget.prestataire['note_moyenne'] 
            : double.tryParse(widget.prestataire['note_moyenne'].toString()))
        : null;
    final bool isFavorite = false; // À implémenter avec la gestion des favoris
    
    // URL de l'image (à remplacer par la vraie source)
    final String imageUrl = widget.prestataire['photo_url'] ?? 
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';

    // Formules/Packages (à partir de tarifs)
    List<Map<String, dynamic>> formules = [];
    if (widget.prestataire.containsKey('tarifs') && 
        widget.prestataire['tarifs'] is List) {
      for (var tarif in widget.prestataire['tarifs']) {
        if (tarif is Map) {
          formules.add({
            'nom': tarif['nom_formule'] ?? 'Formule standard',
            'prix': tarif['prix_base'] ?? 0.0,
            'description': tarif['description'] ?? 'Aucune description disponible',
          });
        }
      }
    }
    // Ajouter une formule par défaut si aucune n'est disponible
    if (formules.isEmpty && prixBase != null) {
      formules.add({
        'nom': 'Formule standard',
        'prix': prixBase,
        'description': 'Prestation de base',
      });
    }

    // Avis (à remplacer par les vrais avis)
    List<Map<String, dynamic>> avis = [
      {
        'auteur': 'Sophie & Thomas',
        'date': 'Juillet 2023',
        'commentaire': 'Un lieu magnifique pour notre mariage ! L\'équipe était très professionnelle et attentionnée.',
        'note': 5.0,
      },
      {
        'auteur': 'Marie & Jean',
        'date': 'Septembre 2023',
        'commentaire': 'Cadre exceptionnel, mais quelques petits soucis d\'organisation.',
        'note': 4.0,
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
        elevation: _isScrolled ? 4 : 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: _isScrolled ? Colors.transparent : Colors.black.withOpacity(0.5),
            child: Icon(
              Icons.arrow_back,
              color: _isScrolled ? Colors.black : Colors.white,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: _isScrolled ? Colors.transparent : Colors.black.withOpacity(0.5),
              child: Icon(
                Icons.share,
                color: _isScrolled ? Colors.black : Colors.white,
              ),
            ),
            onPressed: () {
              // Ajouter la fonctionnalité de partage
            },
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: _isScrolled ? Colors.transparent : Colors.black.withOpacity(0.5),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isScrolled ? (isFavorite ? Colors.red : Colors.black) : Colors.white,
              ),
            ),
            onPressed: () {
              // Ajouter/retirer des favoris
              setState(() {
                // isFavorite = !isFavorite;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
        title: _isScrolled ? Text(
          nom,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ) : null,
        systemOverlayStyle: _isScrolled 
            ? SystemUiOverlayStyle.dark 
            : SystemUiOverlayStyle.light,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Image principale avec informations superposées
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Image principale
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                    ),
                  ),
                ),
                
                // Dégradé pour assurer la lisibilité des textes
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Informations principales
                Positioned(
                // Position depuis le bas
                bottom: MediaQuery.of(context).size.height * 0.15, 
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du lieu
                      Text(
                        nom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32, 
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.black,
                              offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        
                        // Localisation
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    blurRadius: 3,
                                    color: Colors.black,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                                                
                        // Première section d'étoiles améliorée
                        Row(
                          children: [
                            for (int i = 1; i <= 5; i++)
                              Icon(
                                i <= (rating ?? 0) ? Icons.star : 
                                (i - 0.5 <= (rating ?? 0) ? Icons.star_half : Icons.star_border),
                                color: Colors.amber,
                                size: 24,
                              ),
                            if (rating != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 3,
                                        color: Colors.black,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Capacité
                        if (capaciteMax != null)
                        Text(
                          '$capaciteMax invités',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black,
                                offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        
                        
                        const SizedBox(height: 12),
                        
                        // Prix
                        if (prixBase != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6), // Un peu plus opaque
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'À partir de ${prixBase.round()} €',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Caractéristiques et services (UNE SEULE FOIS)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildFeaturesAndServices(),
            ),
          ),
          
          // Formules/Packages
          if (formules.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nos formules',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...formules.map((formule) => _buildPackageItem(
                      title: formule['nom'],
                      price: formule['prix'],
                      description: formule['description'],
                    )).toList(),
                  ],
                ),
              ),
            ),
          
          // Avis
          if (avis.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...avis.map((review) => _buildReviewItem(
                      author: review['auteur'],
                      date: review['date'],
                      rating: review['note'],
                      comment: review['commentaire'],
                    )).toList(),
                  ],
                ),
              ),
            ),
          
          // Espace pour ne pas que le bouton cache du contenu
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      
      // Bouton Réserver fixe en bas
      bottomSheet: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        child: ElevatedButton(
          onPressed: () {
            // Action de réservation
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF524B46),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Réserver',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  // Widget pour afficher une formule/package
  Widget _buildPackageItem({
    required String title,
    required double price,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                Text(
                  '${price.round()} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF524B46),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton(
              onPressed: () {
                // Action pour en savoir plus ou ajouter au devis
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF524B46)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Choisir cette formule',
                style: TextStyle(
                  color: Color(0xFF524B46),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
// Fonction principale pour construire les caractéristiques et services
Widget _buildFeaturesAndServices() {
  // Variables pour les caractéristiques principales et services
  final Map<String, IconData> features = {};
  final Map<String, IconData> services = {};
  
  // Récupérer les données de lieux depuis le prestataire
  if (widget.prestataire.containsKey('lieux')) {
    var lieuxData = widget.prestataire['lieux'];
    
    // Si c'est une liste, extraire le premier élément
    if (lieuxData is List && lieuxData.isNotEmpty) {
      final lieu = lieuxData[0];
      
      // Parcourir les propriétés du lieu
      if (lieu is Map<String, dynamic>) {
        lieu.forEach((key, value) {
          // Ajouter à features ou services uniquement si la valeur est true
          if (value == true) {
            _addFeatureOrService(key, features, services);
          }
        });
      } 
    } 
    // Si c'est directement un objet Map
    else if (lieuxData is Map<String, dynamic>) {
      lieuxData.forEach((key, value) {
        if (value == true) {
          _addFeatureOrService(key, features, services);
        }
      });
    }
  }
  
  // Si aucune caractéristique n'est trouvée, ajouter quelques exemples par défaut
  if (features.isEmpty && services.isEmpty) {
    // Ajouter quelques caractéristiques par défaut
    features['Espace extérieur'] = Icons.terrain;
    features['Parking disponible'] = Icons.local_parking;
    features['Vue sur la montagne'] = Icons.landscape;
    features['Piscine'] = Icons.pool;
    features['Terrasse privée'] = Icons.deck;
    features['Climatisation'] = Icons.ac_unit;
    features['Accès handicapés'] = Icons.accessible;
    features['Barbecue'] = Icons.outdoor_grill;
    features['Jardin'] = Icons.park;
    
    // Ajouter quelques services par défaut
    services['WiFi gratuit'] = Icons.wifi;
    services['Sonorisation incluse'] = Icons.music_note;
    services['Service voiturier'] = Icons.directions_car;
    services['Traiteur sur place'] = Icons.restaurant;
    services['Vestiaire'] = Icons.checkroom;
  }
  
  // Retourner la structure UI
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Caractéristiques principales (si non vides)
      if (features.isNotEmpty) ...[
        const Text(
          'Caractéristiques',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 16),
        
        // Limiter l'affichage à 8 caractéristiques maximum initialement
        ...features.entries.take(8).map((entry) => 
          _buildFeatureItem(icon: entry.value, text: entry.key)
        ).toList(),
        
        // Bouton "Voir plus" si plus de 8 caractéristiques
        if (features.length > 8)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkWell(
              onTap: () => _showAllFeatures(features, 'Toutes les caractéristiques (${features.length})'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Voir toutes les caractéristiques (${features.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
      
      const SizedBox(height: 32),
      
      // Services inclus (si non vides)
      if (services.isNotEmpty) ...[
        const Text(
          'Services inclus',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 16),
        
        // Limiter l'affichage à 8 services maximum initialement
        ...services.entries.take(8).map((entry) => 
          _buildFeatureItem(icon: entry.value, text: entry.key)
        ).toList(),
        
        // Bouton "Voir plus" si plus de 8 services
        if (services.length > 8)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkWell(
              onTap: () => _showAllFeatures(services, 'Tous les services inclus (${services.length})'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Voir tous les services inclus (${services.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ],
  );
}


// Widget pour afficher un item de caractéristique (style Airbnb)
Widget _buildFeatureItem({required IconData icon, required String text}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 16),
          child: Icon(icon, size: 24, color: const Color(0xFF2B2B2B)),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ),
      ],
    ),
  );
}

 // Méthode pour afficher toutes les caractéristiques dans une nouvelle vue
void _showAllFeatures(Map<String, IconData> items, String title) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header avec titre et bouton fermer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.split(' (')[0], // Prendre uniquement la partie nom sans le nombre
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Liste des caractéristiques
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items.entries.elementAt(index);
                    return _buildFeatureItem(icon: entry.value, text: entry.key);
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// Fonction pour classer les propriétés dans features ou services
void _addFeatureOrService(String key, Map<String, IconData> features, Map<String, IconData> services) {
  print("Classification de la propriété: $key");
  
  // Table complète de correspondance basée sur le schéma Supabase
  switch (key) {
    // CARACTERISTIQUES DU LIEU
    case 'espace_exterieur':
      features['Espace extérieur'] = Icons.terrain;
      break;
    case 'piscine':
      features['Piscine'] = Icons.pool;
      break;
    case 'parking':
      features['Parking'] = Icons.local_parking;
      break;
    case 'hebergement':
      features['Hébergement sur place'] = Icons.hotel;
      break;
    case 'exclusivite':
      features['Exclusivité du lieu'] = Icons.verified_user;
      break;
    case 'feu_artifice':
      features['Feu d\'artifice autorisé'] = Icons.celebration;
      break;
    case 'cadre':
      features['Cadre exceptionnel'] = Icons.landscape;
      break;
    case 'proximite_transports':
      features['Proximité transports'] = Icons.directions_bus;
      break;
    case 'accessibilite_pmr':
      features['Accessibilité PMR'] = Icons.accessible;
      break;
    case 'salle_reception':
      features['Salle de réception'] = Icons.meeting_room;
      break;
    case 'espace_cocktail':
      features['Espace cocktail'] = Icons.local_bar;
      break;
    case 'espace_ceremonie':
      features['Espace cérémonie'] = Icons.celebration;
      break;
    case 'jardin':
      features['Jardin'] = Icons.park;
      break;
    case 'parc':
      features['Parc'] = Icons.nature;
      break;
    case 'terrasse':
      features['Terrasse'] = Icons.deck;
      break;
    case 'cour':
      features['Cour intérieure'] = Icons.yard;
      break;
    case 'disponibilite_weekend':
      features['Disponible le weekend'] = Icons.weekend;
      break;
    case 'disponibilite_semaine':
      features['Disponible en semaine'] = Icons.work;
      break;
    case 'espace_enfants':
      features['Espace enfants'] = Icons.child_care;
      break;
    case 'climatisation':
      features['Climatisation'] = Icons.ac_unit;
      break;
    case 'espace_lacher_lanternes':
      features['Espace pour lanternes'] = Icons.light;
      break;
    case 'lieu_seance_photo':
      features['Lieu pour photos'] = Icons.photo_camera;
      break;
    case 'acces_bateau_helicoptere':
      features['Accès bateau/hélicoptère'] = Icons.flight;
      break;
    
    // SERVICES INCLUS
    case 'systeme_sonorisation':
      services['Système de sonorisation'] = Icons.speaker;
      break;
    case 'tables_fournies':
      services['Tables fournies'] = Icons.table_bar;
      break;
    case 'chaises_fournies':
      services['Chaises fournies'] = Icons.event_seat;
      break;
    case 'nappes_fournies':
      services['Nappes fournies'] = Icons.table_restaurant;
      break;
    case 'vaisselle_fournie':
      services['Vaisselle fournie'] = Icons.restaurant;
      break;
    case 'eclairage':
      services['Éclairage'] = Icons.lightbulb;
      break;
    case 'sonorisation':
      services['Sonorisation'] = Icons.surround_sound;
      break;
    case 'wifi':
      services['Wi-Fi'] = Icons.wifi;
      break;
    case 'coordinateur_sur_place':
      services['Coordinateur sur place'] = Icons.people;
      break;
    case 'vestiaire':
      services['Vestiaire'] = Icons.checkroom;
      break;
    case 'voiturier':
      services['Service voiturier'] = Icons.car_rental;
      break;
    default:
      print("Propriété non reconnue: $key");
      break;
  }
}

  // Widget pour afficher un avis
  Widget _buildReviewItem({
    required String author,
    required String date,
    required double rating,
    required String comment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
               fontSize: 16,
             ),
           ),
           Text(
             date,
             style: TextStyle(
               color: Colors.grey[600],
               fontSize: 14,
             ),
           ),
         ],
       ),
       const SizedBox(height: 8),
       Row(
         children: [
           for (int i = 1; i <= 5; i++)
             Icon(
               i <= rating ? Icons.star : 
               (i - 0.5 <= rating ? Icons.star_half : Icons.star_border),
               color: Colors.amber,
               size: 16,
             ),
         ],
       ),
       const SizedBox(height: 8),
       Text(
         comment,
         style: TextStyle(
           color: Colors.grey[800],
           fontSize: 14,
           height: 1.5,
         ),
       ),
     ],
   ),
 );
}
}