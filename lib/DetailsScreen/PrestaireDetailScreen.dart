import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:collection'; // Pour LinkedHashMap
import '../Filtre/data/repositories/lieu_repository.dart'; // Ajoutez cette ligne
import '../Filtre/data/models/avis_model.dart';
import '../widgets/avis_card.dart';
import '../utils/fake_data.dart';
import 'package:url_launcher/url_launcher.dart';



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
  bool _isLoadingFormules = true;
  List<AvisModel> _avis = [];
  bool _isLoadingAvis = true;
  List<Map<String, dynamic>> _formules = [];
  final LieuRepository _lieuRepository = LieuRepository(); // Ajoutez cette ligne


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFormules();
    _loadAvis();
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
    // Ajoutez cette méthode
  Future<void> _loadFormules() async {
  setState(() => _isLoadingFormules = true);
  try {
    if (widget.prestataire['id'] != null) {
      final formules = await LieuRepository().getTarifsByPrestaId(widget.prestataire['id']);
      setState(() => _formules = formules);
    }
  } catch (e) {
    // Gestion d'erreur
  } finally {
    setState(() => _isLoadingFormules = false);
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
          if (_formules.isNotEmpty)
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
                    _isLoadingFormules
                      ? const Center(child: CircularProgressIndicator())
                      : _formules.isEmpty
                          ? const Text('Aucune formule disponible')
                          : Column(
                              children: _formules.map((formule) => _buildPackageItem(
                              title: formule['nom_formule'] ?? 'Formule',
                              price: formule['prix_base'] is num 
                                  ? formule['prix_base'].toDouble() 
                                  : double.tryParse(formule['prix_base'].toString()) ?? 0.0,
                              description: formule['description'] ?? '',
                              formule: formule,  // Passez la formule complète ici
                            )).toList(),
                            ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: buildLocationWidget(
              widget.prestataire['adresse'] ?? 'Adresse non disponible',
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
                  // Titre et note moyenne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Avis',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      if (_avis.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF524B46),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _calculateAverageRating().toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Affichage des avis
        _isLoadingAvis
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          : _avis.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun avis pour le moment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              : Column(
                  children: _avis
                      .take(3) // Limiter à 3 avis affichés initialement
                      .map((avis) => _buildAvisItem(avis))
                      .toList(),
                ),
        
        // Bouton "Voir tous les avis" si plus de 3 avis
        if (_avis.length > 3)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: OutlinedButton(
                onPressed: () => _showAllReviews(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF524B46)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Voir tous les avis (${_avis.length})',
                  style: const TextStyle(
                    color: Color(0xFF524B46),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          
        // Bouton pour laisser un avis
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cette fonctionnalité sera disponible prochainement'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.rate_review, color: Colors.white,),
              label: const Text('Laisser un avis'),
            ),
          ),
        ),
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
  child: Row(
    children: [
      // Premier bouton - Contacter
      Expanded(
        child: OutlinedButton(
          onPressed: () {
            // Action pour envoyer une demande de contact
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demande envoyée')),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF524B46)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Contacter',
            style: TextStyle(
              color: Color(0xFF524B46),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
          const SizedBox(width: 12),
          // Deuxième bouton - Réserver
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showFormulaCalculator(widget.prestataire),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Réserver',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
  
  // Widget pour afficher une formule/package
    Widget _buildPackageItem({
    required String title,
    required double price,
    required String description,
    required Map<String, dynamic> formule,  // Ajoutez ce paramètre
  }) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec titre et prix
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF524B46),
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
                  color: Colors.white,
                ),
              ),
              Text(
                '${price.round()} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Description
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
        // Bouton - remplacez ce qui était ici
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: OutlinedButton(
          onPressed: () => _showFormulaCalculator(formule),
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
  // Utiliser LinkedHashMap pour préserver l'ordre d'insertion
  final LinkedHashMap<String, dynamic> features = LinkedHashMap<String, dynamic>();
  final LinkedHashMap<String, IconData> services = LinkedHashMap<String, IconData>();
  
  // Récupérer les données de lieux depuis le prestataire
  if (widget.prestataire.containsKey('lieux')) {
    var lieuxData = widget.prestataire['lieux'];
    
    // Si c'est une liste, extraire le premier élément
    if (lieuxData is List && lieuxData.isNotEmpty) {
      final lieu = lieuxData[0];
      
      // Parcourir les propriétés du lieu
      if (lieu is Map<String, dynamic>) {
        // D'abord ajouter les caractéristiques numériques et textuelles
        _addNumericFeatures(lieu, features);
        
        // Ajouter les caractéristiques textuelles
        if (lieu.containsKey('cadre') && lieu['cadre'] != null && lieu['cadre'].toString().isNotEmpty) {
          features['Cadre'] = {
            'type': 'text',
            'value': lieu['cadre'],
            'icon': Icons.landscape
          };
        }
        
        // Ensuite ajouter les caractéristiques booléennes
        lieu.forEach((key, value) {
          if (value == true) {
            _addFeatureOrService(key, features, services);
          }
        });
      }
    } 
    // Si c'est directement un objet Map
    else if (lieuxData is Map<String, dynamic>) {
      // D'abord ajouter les caractéristiques numériques et textuelles
      _addNumericFeatures(lieuxData, features);
      
      // Ajouter les caractéristiques textuelles
      if (lieuxData.containsKey('cadre') && lieuxData['cadre'] != null && lieuxData['cadre'].toString().isNotEmpty) {
        features['Cadre'] = {
          'type': 'text',
          'value': lieuxData['cadre'],
          'icon': Icons.landscape
        };
      }
      
      // Ensuite ajouter les caractéristiques booléennes
      lieuxData.forEach((key, value) {
        if (value == true) {
          _addFeatureOrService(key, features, services);
        }
      });
    }
  }
  
  // Si aucune caractéristique n'est trouvée, ajouter quelques exemples par défaut
  if (features.isEmpty && services.isEmpty) {
    // D'abord ajouter les caractéristiques numériques
    features['Capacité maximale'] = {
      'type': 'numeric',
      'value': 150,
      'unit': 'invités',
      'icon': Icons.people
    };
    
    features['Capacité minimale'] = {
      'type': 'numeric',
      'value': 50,
      'unit': 'invités',
      'icon': Icons.people_outline
    };
    
    features['Capacité d\'hébergement'] = {
      'type': 'numeric',
      'value': 30,
      'unit': 'couchages',
      'icon': Icons.hotel
    };
    
    features['Nombre de chambres'] = {
      'type': 'numeric',
      'value': 8,
      'unit': '',
      'icon': Icons.bed
    };
    
    features['Superficie intérieure'] = {
      'type': 'numeric',
      'value': 400,
      'unit': 'm²',
      'icon': Icons.square_foot
    };
    
    features['Superficie extérieure'] = {
      'type': 'numeric',
      'value': 2000,
      'unit': 'm²',
      'icon': Icons.grass
    };
    
    features['Cadre'] = {
      'type': 'text',
      'value': 'Château avec parc à la française',
      'icon': Icons.park
    };
    
    // Ensuite ajouter les caractéristiques booléennes
    features['Espace extérieur'] = {
      'type': 'boolean',
      'value': true,
      'icon': Icons.terrain
    };
    
    features['Parking disponible'] = {
      'type': 'boolean',
      'value': true,
      'icon': Icons.local_parking
    };
    
    features['Vue sur la montagne'] = {
      'type': 'boolean',
      'value': true, 
      'icon': Icons.landscape
    };
    
    // Ajouter quelques services par défaut
    services['WiFi gratuit'] = Icons.wifi;
    services['Sonorisation incluse'] = Icons.music_note;
    services['Service voiturier'] = Icons.directions_car;
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
        ...features.entries.take(8).map((entry) {
          // Différencier l'affichage selon le type de caractéristique
          if (entry.value is Map) {
            final featureData = entry.value as Map<String, dynamic>;
            final type = featureData['type'];
            
            if (type == 'numeric') {
              return _buildNumericFeatureItem(
                icon: featureData['icon'],
                text: entry.key,
                value: featureData['value'],
                unit: featureData['unit'] ?? '',
              );
            } else if (type == 'text') {
              return _buildTextFeatureItem(
                icon: featureData['icon'],
                label: entry.key,
                text: featureData['value'],
              );
            } else {
              return _buildFeatureItem(
                icon: featureData['icon'],
                text: entry.key,
              );
            }
          } else {
            // Fallback pour les anciennes entrées (IconData direct)
            return _buildFeatureItem(
              icon: entry.value,
              text: entry.key,
            );
          }
        }).toList(),
        
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


  Future<void> _loadAvis() async {
    setState(() => _isLoadingAvis = true);
    try {
      // Au lieu d'appeler l'API, utilisez les données fictives
      if (widget.prestataire != null && widget.prestataire['id'] != null) {
        // Petit délai pour simuler un appel réseau
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Charger les données fictives
        final fakeAvis = FakeData.getFakeAvis(widget.prestataire['id']);
        
        setState(() {
          _avis = fakeAvis;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des avis: $e');
    } finally {
      setState(() => _isLoadingAvis = false);
    }
  }



// Méthode pour calculer la moyenne des notes
double _calculateAverageRating() {
  if (_avis.isEmpty) return 0.0;
  
  double total = 0.0;
  for (var avis in _avis) {
    total += avis.note;
  }
  return total / _avis.length;
}

// Widget pour l'état vide (aucun avis)
Widget _buildEmptyAvisState() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.rate_review_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'Aucun avis pour le moment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Soyez le premier à donner votre avis!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    ),
  );
}

// Méthode pour afficher tous les avis dans une modale
void _showAllAvis() {
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
                    Row(
                      children: [
                        const Text(
                          'Tous les avis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF524B46),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _calculateAverageRating().toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Liste des avis
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _avis.length,
                  itemBuilder: (context, index) => AvisCard(avis: _avis[index]),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}



// 6. Ajoutons un bouton pour laisser un avis dans la page de détail du prestataire
// (après la section des avis existants)

// 7. Enfin, implémentons la méthode pour afficher le dialogue d'ajout d'avis


  void _showAddAvisDialog() {
  double rating = 5.0;
  final commentController = TextEditingController();
  final avisService = AvisService(); // Instancier le service ici
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Laisser un avis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Votre note:'),
              const SizedBox(height: 8),
              // Étoiles pour la notation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text('Votre commentaire:'),
              const SizedBox(height: 8),
              // Champ de commentaire
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Vérifier si le commentaire n'est pas vide
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez ajouter un commentaire'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                // Récupérer l'ID utilisateur (exemple simple)
                final userId = 'anonymous'; // ID temporaire pour les tests
                
                // Soumettre l'avis avec le AvisService au lieu de LieuRepository
                final success = await avisService.addAvis(
                  prestataireId: widget.prestataire['id'],
                  userId: userId,
                  note: rating,
                  commentaire: commentController.text.trim(),
                );
                
                Navigator.pop(context);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Merci pour votre avis! Il sera visible après modération.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Une erreur est survenue lors de l\'envoi de votre avis'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
              ),
              child: const Text('Soumettre'),
            ),
          ],
        );
      },
    ),
  );
}

// Ces deux méthodes sont des placeholders à adapter selon votre système d'authentification
bool _userIsLoggedIn() {
  // Version simplifiée temporaire
  return true; // Toujours autorisé pendant le développement
}

String _getCurrentUserId() {
  // Version simplifiée temporaire
  return "user_test_id"; // ID fixe pour les tests
}


// Méthode pour ajouter les caractéristiques numériques et textuelles
void _addNumericFeatures(Map<String, dynamic> lieu, Map<String, dynamic> features) {
  // Capacité maximale
  if (lieu.containsKey('capacite_max') && lieu['capacite_max'] != null) {
    features['Capacité maximale'] = {
      'type': 'numeric',
      'value': lieu['capacite_max'],
      'unit': 'invités',
      'icon': Icons.people
    };
  }
  
  // Capacité minimale
  if (lieu.containsKey('capacite_min') && lieu['capacite_min'] != null) {
    features['Capacité minimale'] = {
      'type': 'numeric',
      'value': lieu['capacite_min'],
      'unit': 'invités',
      'icon': Icons.people_outline
    };
  }
  
  // Capacité d'hébergement
  if (lieu.containsKey('capacite_hebergement') && lieu['capacite_hebergement'] != null) {
    features['Capacité d\'hébergement'] = {
      'type': 'numeric',
      'value': lieu['capacite_hebergement'],
      'unit': 'couchages',
      'icon': Icons.hotel
    };
  }
  
  // Nombre de chambres
  if (lieu.containsKey('nombre_chambres') && lieu['nombre_chambres'] != null) {
    features['Nombre de chambres'] = {
      'type': 'numeric',
      'value': lieu['nombre_chambres'],
      'unit': '',
      'icon': Icons.bed
    };
  }
  
  // Superficie intérieure
  if (lieu.containsKey('superficie_interieur') && lieu['superficie_interieur'] != null) {
    features['Superficie intérieure'] = {
      'type': 'numeric',
      'value': lieu['superficie_interieur'],
      'unit': 'm²',
      'icon': Icons.square_foot
    };
  }
  
  // Superficie extérieure
  if (lieu.containsKey('superficie_exterieur') && lieu['superficie_exterieur'] != null) {
    features['Superficie extérieure'] = {
      'type': 'numeric',
      'value': lieu['superficie_exterieur'],
      'unit': 'm²',
      'icon': Icons.grass
    };
  }
}

// Widget pour afficher un item numérique (avec valeur et unité)
Widget _buildNumericFeatureItem({
  required IconData icon,
  required String text,
  required dynamic value,
  required String unit,
}) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$value ${unit.isNotEmpty ? unit : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


// Widget pour afficher un item textuel (avec label et contenu)
Widget _buildTextFeatureItem({
  required IconData icon,
  required String label,
  required String text,
}) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Méthode pour afficher toutes les caractéristiques dans une nouvelle vue
void _showAllFeatures(Map<String, dynamic> items, String title) {
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
                    
                    // Différencier l'affichage selon le type de caractéristique
                    if (entry.value is Map) {
                      final featureData = entry.value as Map<String, dynamic>;
                      final type = featureData['type'];
                      
                      if (type == 'numeric') {
                        return _buildNumericFeatureItem(
                          icon: featureData['icon'],
                          text: entry.key,
                          value: featureData['value'],
                          unit: featureData['unit'] ?? '',
                        );
                      } else if (type == 'text') {
                        return _buildTextFeatureItem(
                          icon: featureData['icon'],
                          label: entry.key,
                          text: featureData['value'],
                        );
                      } else {
                        return _buildFeatureItem(
                          icon: featureData['icon'],
                          text: entry.key,
                        );
                      }
                    } else if (entry.value is IconData) {
                      // Pour les services (toujours IconData)
                      return _buildFeatureItem(
                        icon: entry.value,
                        text: entry.key,
                      );
                    } else {
                      // Fallback
                      return _buildFeatureItem(
                        icon: Icons.info_outline,
                        text: entry.key,
                      );
                    }
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

Widget _buildAvisItem(AvisModel avis) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nom de l'auteur
            Text(
              "${avis.profile?['prenom'] ?? ''} ${avis.profile?['nom'] ?? 'Anonyme'}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Date
            Text(
              "${_getMonthName(avis.createdAt.month)} ${avis.createdAt.year}",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Étoiles pour la note
        Row(
          children: List.generate(5, (index) {
            if (index < avis.note.floor()) {
              return const Icon(Icons.star, color: Colors.amber, size: 16);
            } else if (index < avis.note.ceil() && avis.note % 1 > 0) {
              return const Icon(Icons.star_half, color: Colors.amber, size: 16);
            } else {
              return const Icon(Icons.star_border, color: Colors.amber, size: 16);
            }
          }),
        ),
        const SizedBox(height: 8),
        // Commentaire
        Text(
          avis.commentaire,
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


// Fonction utilitaire pour obtenir le nom du mois
String _getMonthName(int month) {
  List<String> months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];
  return months[month - 1];
}

// Fonction pour classer les propriétés dans features ou services
void _addFeatureOrService(String key, Map<String, dynamic> features, Map<String, IconData> services) {
  // Table complète de correspondance basée sur le schéma Supabase
  switch (key) {
    // CARACTERISTIQUES DU LIEU
    case 'espace_exterieur':
      features['Espace extérieur'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.terrain
      };
      break;
    case 'piscine':
      features['Piscine'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.pool
      };
      break;
    case 'parking':
      features['Parking'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.local_parking
      };
      break;
    case 'hebergement':
      features['Hébergement sur place'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.hotel
      };
      break;
    case 'exclusivite':
      features['Exclusivité du lieu'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.verified_user
      };
      break;
    case 'feu_artifice':
      features['Feu d\'artifice autorisé'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.celebration
      };
      break;
    case 'proximite_transports':
      features['Proximité transports'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.directions_bus
      };
      break;
    case 'accessibilite_pmr':
      features['Accessibilité PMR'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.accessible
      };
      break;
    case 'salle_reception':
      features['Salle de réception'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.meeting_room
      };
      break;
    case 'espace_cocktail':
      features['Espace cocktail'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.local_bar
      };
      break;
    case 'espace_ceremonie':
      features['Espace cérémonie'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.celebration
      };
      break;
    case 'jardin':
      features['Jardin'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.park
      };
      break;
    case 'parc':
      features['Parc'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.nature
      };
      break;
    case 'terrasse':
      features['Terrasse'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.deck
      };
      break;
    case 'cour':
      features['Cour intérieure'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.yard
      };
      break;
    case 'disponibilite_weekend':
      features['Disponible le weekend'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.weekend
      };
      break;
    case 'disponibilite_semaine':
      features['Disponible en semaine'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.work
      };
      break;
    case 'espace_enfants':
      features['Espace enfants'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.child_care
      };
      break;
    case 'climatisation':
      features['Climatisation'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.ac_unit
      };
      break;
    case 'espace_lacher_lanternes':
      features['Espace pour lanternes'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.light
      };
      break;
    case 'lieu_seance_photo':
      features['Lieu pour photos'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.photo_camera
      };
      break;
    case 'acces_bateau_helicoptere':
      features['Accès bateau/hélicoptère'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.flight
      };
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

void _showAllReviews() {
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
              // En-tête
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
                    Row(
                      children: [
                        const Text(
                          'Tous les avis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF524B46),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _calculateAverageRating().toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Liste des avis
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _avis.length,
                  itemBuilder: (context, index) => _buildAvisItem(_avis[index]),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showFormulaCalculator(Map<String, dynamic> formula) {
  // Récupération des données
  final String formulaName = formula['nom_formule'] ?? 'Formule';
  final double basePrice = formula['prix_base'] is num ? 
    formula['prix_base'].toDouble() : 
    double.tryParse(formula['prix_base'].toString()) ?? 0.0;
  
  // Variables pour les options
  int guestCount = 50;
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
                  // En-tête avec titre et bouton fermer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF524B46),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                        Row(
                          children: [
                            Text(
                              '${totalPrice.toInt()} €',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenu défilable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Nombre d'invités
                        const Text(
                          'Nombre d\'invités',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: guestCount.toDouble(),
                          min: 10,
                          max: 350,
                          divisions: 19,
                          label: guestCount.toString(),
                          activeColor: const Color(0xFF524B46),
                          onChanged: (value) {
                            setState(() {
                              guestCount = value.toInt();
                              // Recalcul du prix
                              totalPrice = basePrice;
                              if (guestCount > 100) {
                                totalPrice += (guestCount - 100) * 10;
                              }
                              for (var option in selectedOptions) {
                                totalPrice += option['prix'] ?? 0.0;
                              }
                            });
                          },
                        ),
                        Center(
                          child: Text(
                            '$guestCount invités',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Date
                        const Text(
                          'Date de l\'événement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
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
                                // Majoration week-end
                                if (picked.weekday == DateTime.saturday || picked.weekday == DateTime.sunday) {
                                  totalPrice = basePrice * 1.2;
                                } else {
                                  totalPrice = basePrice;
                                }
                                // Réappliquer les autres majorations
                                if (guestCount > 100) {
                                  totalPrice += (guestCount - 100) * 10;
                                }
                                for (var option in selectedOptions) {
                                  totalPrice += option['prix'] ?? 0.0;
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDate != null 
                                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                    : 'Choisir une date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: selectedDate != null ? Colors.black : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Options supplémentaires
                        const Text(
                          'Options supplémentaires',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Options à cocher
                        _buildOptionCheckbox(
                          'Service de nettoyage',
                          'Nettoyage complet avant et après l\'événement',
                          250.0,
                          selectedOptions.any((o) => o['nom'] == 'Service de nettoyage'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Service de nettoyage',
                                  'prix': 250.0
                                });
                                totalPrice += 250.0;
                              } else {
                                selectedOptions.removeWhere((o) => o['nom'] == 'Service de nettoyage');
                                totalPrice -= 250.0;
                              }
                            });
                          },
                        ),
                        
                        _buildOptionCheckbox(
                          'Coordinateur sur place',
                          'Un coordinateur dédié pendant toute la durée de l\'événement',
                          500.0,
                          selectedOptions.any((o) => o['nom'] == 'Coordinateur sur place'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Coordinateur sur place',
                                  'prix': 500.0
                                });
                                totalPrice += 500.0;
                              } else {
                                selectedOptions.removeWhere((o) => o['nom'] == 'Coordinateur sur place');
                                totalPrice -= 500.0;
                              }
                            });
                          },
                        ),
                        
                        _buildOptionCheckbox(
                          'Hébergement',
                          'Chambres disponibles pour 20 personnes',
                          800.0,
                          selectedOptions.any((o) => o['nom'] == 'Hébergement'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Hébergement',
                                  'prix': 800.0
                                });
                                totalPrice += 800.0;
                              } else {
                                selectedOptions.removeWhere((o) => o['nom'] == 'Hébergement');
                                totalPrice -= 800.0;
                              }
                            });
                          },
                        ),
                        
                        _buildOptionCheckbox(
                          'Système son et lumière',
                          'Équipement professionnel pour votre soirée',
                          350.0,
                          selectedOptions.any((o) => o['nom'] == 'Système son et lumière'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Système son et lumière',
                                  'prix': 350.0
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
                  
                  // Bouton d'action en bas
                  Container(
                    padding: const EdgeInsets.all(16),
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
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('features bientôt disponible'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF524B46),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: const Text(
                            'Téléchager le devis',
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
Widget buildLocationWidget(String address) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec titre (comme pour les formules)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF524B46),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Adresse",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Contenu (adresse)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            address,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        // Bouton au même style que "Choisir cette formule"
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: OutlinedButton.icon(
            icon: const Icon(
              Icons.map,
              color: Color(0xFF524B46),
            ),
            label: const Text(
              "Voir sur la carte",
              style: TextStyle(
                color: Color(0xFF524B46),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF524B46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              final encodedAddress = Uri.encodeComponent(address);
              final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedAddress");
              
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Impossible d\'ouvrir la carte')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${e.toString()}')),
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}
    


Widget _buildOptionCheckbox(
  String title,
  String description,
  double price,
  bool isSelected,
  Function(bool) onChanged,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      border: Border.all(
        color: isSelected ? const Color(0xFF524B46) : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
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
      value: isSelected,
      onChanged: (value) => onChanged(value ?? false),
      activeColor: const Color(0xFF524B46),
      checkColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      controlAffinity: ListTileControlAffinity.trailing,
    ),
  );
}

}