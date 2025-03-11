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

    // Équipements (pour les lieux)
    List<Map<String, dynamic>> equipements = [];
    if (widget.prestataire.containsKey('lieux') && 
        widget.prestataire['lieux'] is List && 
        widget.prestataire['lieux'].isNotEmpty) {
      final lieux = widget.prestataire['lieux'][0];
      if (lieux['hebergement'] == true) {
        equipements.add({
          'nom': 'Hébergement',
          'icon': Icons.hotel,
          'details': lieux['capacite_hebergement'] != null ? 
              '${lieux['capacite_hebergement']} personnes' : 'Disponible'
        });
      }
      if (lieux['espace_exterieur'] == true) {
        equipements.add({
          'nom': 'Espace extérieur',
          'icon': Icons.park,
          'details': 'Disponible'
        });
      }
      if (lieux['parking'] == true) {
        equipements.add({
          'nom': 'Parking',
          'icon': Icons.local_parking,
          'details': 'Disponible'
        });
      }
      if (lieux['piscine'] == true) {
        equipements.add({
          'nom': 'Piscine',
          'icon': Icons.pool,
          'details': 'Disponible'
        });
      }
    }

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
                // Changez ces valeurs pour remonter les éléments
                bottom: MediaQuery.of(context).size.height * 0.15, // Position plus haute 
                // ou utilisez un positionnement depuis le haut
                // top: MediaQuery.of(context).size.height * 0.5, // Essayez différentes valeurs
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
          
          // Description complète (visible uniquement en scrollant)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Équipements et caractéristiques
          SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre "Caractéristiques principales"
                const Text(
                  'Caractéristiques principales',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Liste des caractéristiques
                _buildFeatureRow(Icons.pool, 'Piscine à débordement'),
                _buildFeatureRow(Icons.beach_access, 'Plage à distance de marche'),
                _buildFeatureRow(Icons.landscape, 'Vue sur la mer et la nature'),
                _buildFeatureRow(Icons.ac_unit, 'Climatisation'),
                _buildFeatureRow(Icons.fitness_center, 'Salle de fitness'),
                _buildFeatureRow(Icons.spa, 'Salle de massage'),
                _buildFeatureRow(Icons.outdoor_grill, 'Barbecue'),
                _buildFeatureRow(Icons.park, 'Jardin méditerranéen'),
                
                const SizedBox(height: 24),
                
                // Titre "Services inclus"
                const Text(
                  'Services inclus',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Liste des services inclus
                _buildFeatureRow(Icons.people, 'Personnel sur place'),
                _buildFeatureRow(Icons.cleaning_services, 'Ménage quotidien'),
                _buildFeatureRow(Icons.local_parking, 'Parking privé'),
                _buildFeatureRow(Icons.wifi, 'WiFi haut débit'),
              ],
            ),
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
  
  // Widget pour afficher un équipement/caractéristique
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45 - 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF524B46)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
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
  
    Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF524B46), size: 28),
          const SizedBox(width: 16),
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