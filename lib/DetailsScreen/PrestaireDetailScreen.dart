import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _isFavorite = false;
  bool _isReservePressed = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarBackground = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Change AppBar background color when scrolling down
    if (_scrollController.offset > 180 && !_showAppBarBackground) {
      setState(() => _showAppBarBackground = true);
    } else if (_scrollController.offset <= 180 && _showAppBarBackground) {
      setState(() => _showAppBarBackground = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la charte graphique
    const Color accentColor = Color(0xFF524B46);
    const Color grisTexte = Color(0xFF2B2B2B);
    const Color beige = Color(0xFFFFF3E4);
    
    // Extraire les informations du prestataire en vérifiant qu'elles existent
    final Map<String, dynamic> prestataire = widget.prestataire;
    
    // Utiliser des valeurs par défaut sécurisées pour éviter les erreurs
    final String nom = prestataire.containsKey('nom_entreprise') ? prestataire['nom_entreprise'] ?? 'Sans nom' : 'Sans nom';
    final String region = prestataire.containsKey('region') ? prestataire['region'] ?? '' : '';
    final String description = prestataire.containsKey('description') ? prestataire['description'] ?? 'Aucune description disponible' : 'Aucune description disponible';
    
    // Gestion sécurisée des valeurs numériques
    double? prix;
    if (prestataire.containsKey('prix_base') && prestataire['prix_base'] != null) {
      if (prestataire['prix_base'] is double) {
        prix = prestataire['prix_base'];
      } else if (prestataire['prix_base'] is int) {
        prix = prestataire['prix_base'].toDouble();
      } else {
        try {
          prix = double.tryParse(prestataire['prix_base'].toString());
        } catch (_) {
          prix = 12500.0; // Valeur par défaut
        }
      }
    } else {
      prix = 12500.0; // Valeur par défaut
    }
    
    final String? photoUrl = prestataire.containsKey('photo_url') ? prestataire['photo_url'] : null;
    
    // Gestion sécurisée des valeurs entières
    int? capacite;
    if (prestataire.containsKey('capacite_max') && prestataire['capacite_max'] != null) {
      if (prestataire['capacite_max'] is int) {
        capacite = prestataire['capacite_max'];
      } else {
        try {
          capacite = int.tryParse(prestataire['capacite_max'].toString());
        } catch (_) {
          capacite = 250; // Valeur par défaut
        }
      }
    } else {
      capacite = 250; // Valeur par défaut
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showAppBarBackground 
            ? accentColor
            : Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF524B46),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          // Bouton de partage
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF524B46),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partage en cours...')),
                );
              },
            ),
          ),
          // Bouton favori
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF524B46),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenu défilable
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Image principale en tête
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Image de fond
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                      child: photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.business, size: 80, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.business, size: 80, color: Colors.grey),
                            ),
                    ),
                    
                    // Dégradé pour la lisibilité du texte
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Titre et informations superposés en bas de l'image
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nom,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  region + ', France',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$capacite invités",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "À partir de ${prix != null ? prix.round() : 0} €",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sections détaillées
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Description
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: grisTexte,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color: grisTexte.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Ajoutez d'autres sections pour les détails, équipements, etc.
                      const Text(
                        "Ce que ce lieu propose",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: grisTexte,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Équipements (simplifiés pour l'exemple)
                      _buildFeatureItem(Icons.kitchen, "Cuisine équipée"),
                      _buildFeatureItem(Icons.accessibility_new, "Vestiaire"),
                      _buildFeatureItem(Icons.lightbulb_outline, "Service de décoration"),
                      _buildFeatureItem(Icons.security, "Système de sécurité"),
                      _buildFeatureItem(Icons.music_note, "Système de sonorisation"),
                      _buildFeatureItem(Icons.ac_unit, "Climatisation"),
                      
                      const SizedBox(height: 16),
                      
                      // Bouton Afficher tous les équipements
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: grisTexte,
                          side: BorderSide(color: grisTexte.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Text("Afficher tous les équipements"),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Section Formules
                      const Text(
                        "Formules",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: grisTexte,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Formule Classique
                      _buildPackageItem(
                        "Formule Classique",
                        "Formule complète incluant toutes les prestations de base",
                        5000,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Formule Premium
                      _buildPackageItem(
                        "Formule Premium",
                        "Inclut la formule classique avec des services additionnels premium",
                        7500,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Formule Luxe
                      _buildPackageItem(
                        "Formule Luxe",
                        "Expérience complète avec tous les services haut de gamme inclus",
                        12000,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Section Avis
                      Row(
                        children: [
                          const Text(
                            "Avis",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: grisTexte,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: List.generate(
                              5,
                              (index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "4.5 • 2 avis",
                            style: TextStyle(
                              fontSize: 16,
                              color: grisTexte.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Premier avis
                      _buildReviewItem(
                        "Sophie Dupont",
                        "janvier 2025",
                        5.0,
                        "Un lieu magnifique et un service impeccable. Notre mariage était parfait !",
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Deuxième avis
                      _buildReviewItem(
                        "Thomas Martin",
                        "décembre 2024",
                        4.0,
                        "Très beau lieu, équipe professionnelle. Seul bémol : le parking un peu limité.",
                      ),
                      
                      // Espace pour le bouton fixe en bas
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Bouton Réserver fixe en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isReservePressed = true),
              onTapUp: (_) => setState(() => _isReservePressed = false),
              onTapCancel: () => setState(() => _isReservePressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.identity()..scale(_isReservePressed ? 0.98 : 1.0),
                child: Container(
                  color: const Color(0xFF524B46),
                  height: 60,
                  alignment: Alignment.center,
                  child: const Text(
                    "Réserver",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF2B2B2B)),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPackageItem(String title, String description, double price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E4).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFF3E4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2B2B),
                ),
              ),
                                    Text(
                "${price.round()} €",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF524B46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF2B2B2B).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF524B46),
              side: const BorderSide(color: Color(0xFF524B46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Choisir cette formule"),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewItem(String name, String date, double rating, String comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFF3E4),
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Color(0xFF524B46),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2B2B2B).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 16,
              color: index < rating ? Colors.amber : Colors.grey[300],
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          comment,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF2B2B2B).withOpacity(0.9),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}