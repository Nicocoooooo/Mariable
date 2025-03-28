import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../data/bouquet_model.dart';

class BouquetPrestataireDetailScreen extends StatefulWidget {
  final String type; // 'lieu', 'traiteur', ou 'photographe'
  final Map<String, dynamic> prestataire;
  final bool isSelected;
  final Function onSelect;

  const BouquetPrestataireDetailScreen({
    Key? key,
    required this.type,
    required this.prestataire,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<BouquetPrestataireDetailScreen> createState() => _BouquetPrestataireDetailScreenState();
}

class _BouquetPrestataireDetailScreenState extends State<BouquetPrestataireDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isDescriptionExpanded = false;
  
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
    // Couleurs du thème
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    // Extraire les données du prestataire
    final String nom = widget.prestataire['nom_entreprise'] ?? 'Sans nom';
    final String region = widget.prestataire['region'] ?? '';
    final String adresse = widget.prestataire['adresse'] ?? '';
    final String location = (region.isNotEmpty && adresse.isNotEmpty) 
        ? '$region, France' 
        : (region.isNotEmpty ? '$region, France' : 'France');
    final String description = widget.prestataire['description'] ?? 'Aucune description disponible';
    
    // Pour les lieux, récupérer les données spécifiques
    int? capaciteMax;
    if (widget.type == 'lieu' && widget.prestataire.containsKey('lieux')) {
      var lieuxData = widget.prestataire['lieux'];
      if (lieuxData is List && lieuxData.isNotEmpty) {
        capaciteMax = lieuxData[0]['capacite_max'];
      } else if (lieuxData is Map) {
        capaciteMax = lieuxData['capacite_max'];
      }
    } else {
      capaciteMax = widget.prestataire['capacite_max'];
    }
    
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
    
    // Titre et icône selon le type
    String typeTitle;
    IconData typeIcon;
    
    switch (widget.type) {
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
      default:
        typeTitle = 'Détails du prestataire';
        typeIcon = Icons.business;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
        elevation: _isScrolled ? 4 : 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: _isScrolled ? Colors.transparent : Colors.black.withAlpha(128),
            child: Icon(
              Icons.arrow_back,
              color: _isScrolled ? Colors.black : Colors.white,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!widget.isSelected)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onSelect();
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
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width,
                  child: _buildMainImage(),
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
                          Colors.black.withAlpha(77),
                          Colors.black.withAlpha(153),
                        ],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Informations principales
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.15,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du prestataire
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
                        
                        // Étoiles
                        if (rating != null)
                          Row(
                            children: [
                              for (int i = 1; i <= 5; i++)
                                Icon(
                                  i <= (rating) ? Icons.star : 
                                  (i - 0.5 <= (rating) ? Icons.star_half : Icons.star_border),
                                  color: Colors.amber,
                                  size: 24,
                                ),
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
                        
                        // Capacité (pour les lieux)
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
                              color: Colors.black.withAlpha(153),
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
                            color: Colors.black.withAlpha(128),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                maxLines: _isDescriptionExpanded ? null : 3,
                                overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                              ),
                              if (description.length > 150)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded = !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isDescriptionExpanded ? 'Voir moins' : 'Voir plus',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Badge "Sélectionné" s'il est déjà dans le bouquet
                if (widget.isSelected)
                  Positioned(
                    top: 80,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'SÉLECTIONNÉ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Caractéristiques et services selon le type de prestataire
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildTypeSpecificFeatures(),
            ),
          ),
          
          // Détails supplémentaires
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildAdditionalDetails(),
            ),
          ),
          
          // Espace pour le bouton en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      bottomNavigationBar: widget.isSelected ? null : Container(
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
        child: ElevatedButton(
          onPressed: () {
            widget.onSelect();
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
  
  // Construction de l'image principale
  Widget _buildMainImage() {
    String imageUrl = '';
    
    // Trouver l'URL d'image appropriée selon le type de prestataire
    if (widget.type == 'lieu') {
      // Pour les lieux, chercher dans le sous-objet lieux
      if (widget.prestataire.containsKey('lieux')) {
        var lieuxData = widget.prestataire['lieux'];
        if (lieuxData is List && lieuxData.isNotEmpty && lieuxData[0]['image_url'] != null) {
          imageUrl = lieuxData[0]['image_url'];
        } else if (lieuxData is Map && lieuxData['image_url'] != null) {
          imageUrl = lieuxData['image_url'];
        }
      }
    }
    
    // Si pas trouvé dans le sous-objet, utiliser l'image principale
    if (imageUrl.isEmpty) {
      imageUrl = widget.prestataire['image_url'] ?? widget.prestataire['photo_url'] ?? '';
    }
    
    // Si toujours vide, utiliser une image par défaut selon le type
    if (imageUrl.isEmpty) {
      switch (widget.type) {
        case 'lieu':
          imageUrl = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
          break;
        case 'traiteur':
          imageUrl = 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=2940&auto=format&fit=crop';
          break;
        case 'photographe':
          imageUrl = 'https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2940&auto=format&fit=crop';
          break;
        default:
          imageUrl = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
      }
    }
    
    return CachedNetworkImage(
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
        child: Icon(
          _getTypeIcon(),
          size: 48,
          color: const Color(0xFF2B2B2B),
        ),
      ),
    );
  }
  
  // Construction des caractéristiques spécifiques au type de prestataire
  Widget _buildTypeSpecificFeatures() {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    // Caractéristiques spécifiques selon le type
    final LinkedHashMap<String, dynamic> features = LinkedHashMap<String, dynamic>();
    final LinkedHashMap<String, IconData> services = LinkedHashMap<String, IconData>();
    
    switch (widget.type) {
      case 'lieu':
        _buildLieuFeatures(features, services);
        break;
      case 'traiteur':
        _buildTraiteurFeatures(features, services);
        break;
      case 'photographe':
        _buildPhotographeFeatures(features, services);
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Caractéristiques principales
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
          
          ...features.entries.map((entry) {
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
              return _buildFeatureItem(
                icon: entry.value,
                text: entry.key,
              );
            }
          }).toList(),
        ],
        
        const SizedBox(height: 32),
        
        // Services inclus
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
          
          ...services.entries.map((entry) => 
            _buildFeatureItem(icon: entry.value, text: entry.key)
          ).toList(),
        ],
      ],
    );
  }
  
  // Construction des caractéristiques pour un lieu
  void _buildLieuFeatures(LinkedHashMap<String, dynamic> features, LinkedHashMap<String, IconData> services) {
    // Vérifier si nous avons les données de lieu
    Map<String, dynamic>? lieuData;
    
    if (widget.prestataire.containsKey('lieux')) {
      var lieuxInfo = widget.prestataire['lieux'];
      if (lieuxInfo is List && lieuxInfo.isNotEmpty) {
        lieuData = Map<String, dynamic>.from(lieuxInfo[0]);
      } else if (lieuxInfo is Map) {
        lieuData = Map<String, dynamic>.from(lieuxInfo);
      }
    }
    
    // Si pas de données spécifiques, utiliser les données générales
    lieuData ??= Map<String, dynamic>.from(widget.prestataire);
    
    // Capacité maximale
    if (lieuData.containsKey('capacite_max') && lieuData['capacite_max'] != null) {
      features['Capacité maximale'] = {
        'type': 'numeric',
        'value': lieuData['capacite_max'],
        'unit': 'invités',
        'icon': Icons.people
      };
    }
    
    // Capacité minimale
    if (lieuData.containsKey('capacite_min') && lieuData['capacite_min'] != null) {
      features['Capacité minimale'] = {
        'type': 'numeric',
        'value': lieuData['capacite_min'],
        'unit': 'invités',
        'icon': Icons.people_outline
      };
    }
    
    // Hébergement et capacité
    if (lieuData.containsKey('hebergement') && _getBoolValue(lieuData['hebergement'])) {
      features['Hébergement'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.hotel
      };
      
      if (lieuData.containsKey('capacite_hebergement') && lieuData['capacite_hebergement'] != null) {
        features['Capacité d\'hébergement'] = {
          'type': 'numeric',
          'value': lieuData['capacite_hebergement'],
          'unit': 'couchages',
          'icon': Icons.hotel
        };
      }
    }
    
    // Caractéristiques booléennes
    Map<String, IconData> booleanFeatures = {
      'espace_exterieur': Icons.terrain,
      'piscine': Icons.pool,
      'parking': Icons.local_parking,
      'exclusivite': Icons.verified_user,
      'feu_artifice': Icons.celebration,
      'jardin': Icons.park,
      'parc': Icons.nature,
      'terrasse': Icons.deck,
      'cour': Icons.yard,
      'espace_ceremonie': Icons.celebration,
      'espace_cocktail': Icons.local_bar,
    };
    
    booleanFeatures.forEach((key, iconData) {
      if (lieuData!.containsKey(key) && _getBoolValue(lieuData[key])) {
        String displayName = key
            .split('_')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');
        
        features[displayName] = {
          'type': 'boolean',
          'value': true,
          'icon': iconData
        };
      }
    });
    
    // Services
    Map<String, IconData> booleanServices = {
      'wifi': Icons.wifi,
      'systeme_sonorisation': Icons.speaker,
      'tables_fournies': Icons.table_bar,
      'chaises_fournies': Icons.event_seat,
      'nappes_fournies': Icons.table_restaurant,
      'vaisselle_fournie': Icons.restaurant,
      'eclairage': Icons.lightbulb,
      'sonorisation': Icons.surround_sound,
      'coordinateur_sur_place': Icons.people,
      'vestiaire': Icons.checkroom,
      'voiturier': Icons.car_rental,
    };
    
    booleanServices.forEach((key, iconData) {
      if (lieuData!.containsKey(key) && _getBoolValue(lieuData[key])) {
        String displayName = key
            .split('_')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');
        
        services[displayName] = iconData;
      }
    });
  }
  
  // Construction des caractéristiques pour un traiteur
  void _buildTraiteurFeatures(LinkedHashMap<String, dynamic> features, LinkedHashMap<String, IconData> services) {
    // Caractéristiques du traiteur
    if (widget.prestataire.containsKey('type_cuisine')) {
      features['Type de cuisine'] = {
        'type': 'text',
        'value': _getTraiteurTypeText(),
        'icon': Icons.restaurant
      };
    }
    
    // Menu personnalisable (si spécifié dans les données)
    if (widget.prestataire.containsKey('menu_personnalisable') && 
        _getBoolValue(widget.prestataire['menu_personnalisable'])) {
      features['Menu personnalisable'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.edit_note
      };
    }
    
    // Capacité de service
    if (widget.prestataire.containsKey('max_invites') && widget.prestataire['max_invites'] != null) {
      features['Capacité de service'] = {
        'type': 'numeric',
        'value': widget.prestataire['max_invites'],
        'unit': 'invités',
        'icon': Icons.group
      };
    }
    
    // Options diététiques (si spécifiées dans les données)
    if (widget.prestataire.containsKey('options_dietetiques') && 
        widget.prestataire['options_dietetiques'] != null) {
      
      String optionsText = '';
      var options = widget.prestataire['options_dietetiques'];
      
      if (options is List) {
        optionsText = options.join(', ');
      } else if (options is String) {
        optionsText = options;
      }
      
      if (optionsText.isNotEmpty) {
        features['Options diététiques'] = {
          'type': 'text',
          'value': optionsText,
          'icon': Icons.spa
        };
      }
    }
    
    // Services inclus (uniquement ceux disponibles dans les données)
    if (widget.prestataire.containsKey('service_assiette') && 
        _getBoolValue(widget.prestataire['service_assiette'])) {
      services['Service à l\'assiette'] = Icons.restaurant_menu;
    }
    
    if (widget.prestataire.containsKey('vaisselle_incluse') && 
        _getBoolValue(widget.prestataire['vaisselle_incluse'])) {
      services['Vaisselle et verrerie'] = Icons.dining;
    }
    
    if (widget.prestataire.containsKey('degustation_offerte') && 
        _getBoolValue(widget.prestataire['degustation_offerte'])) {
      services['Menu dégustation offert'] = Icons.restaurant;
    }
    
    if (widget.prestataire.containsKey('personnel_service') && 
        _getBoolValue(widget.prestataire['personnel_service'])) {
      services['Personnel de service'] = Icons.people;
    }
    
    // Ajouter d'autres services selon les options du traiteur
    if (widget.prestataire.containsKey('gateau_inclus') && 
        _getBoolValue(widget.prestataire['gateau_inclus'])) {
      services['Gâteau personnalisé'] = Icons.cake;
    }
    
    if (widget.prestataire.containsKey('boissons_incluses') && 
        _getBoolValue(widget.prestataire['boissons_incluses'])) {
      services['Boissons et cocktails'] = Icons.local_bar;
    }
  }
  
  // Construction des caractéristiques pour un photographe
  void _buildPhotographeFeatures(LinkedHashMap<String, dynamic> features, LinkedHashMap<String, IconData> services) {
    // Style de photographie (si présent dans les données)
    if (widget.prestataire.containsKey('style')) {
      features['Style de photographie'] = {
        'type': 'text',
        'value': _getPhotographeStyleText(),
        'icon': Icons.camera_alt
      };
    }
    
    // Durée de présence (si présente dans les données)
    if (widget.prestataire.containsKey('duree')) {
      features['Durée de présence'] = {
        'type': 'text',
        'value': _getPhotographeDureeText(),
        'icon': Icons.access_time
      };
    }
    
    // Option drone (si présente dans les données)
    if (widget.prestataire.containsKey('drone') && _getBoolValue(widget.prestataire['drone'])) {
      features['Option drone'] = {
        'type': 'boolean',
        'value': true,
        'icon': Icons.airplanemode_active
      };
    }
  // Services inclus (uniquement ceux disponibles dans les données)
   if (widget.prestataire.containsKey('album_inclus') && 
       _getBoolValue(widget.prestataire['album_inclus'])) {
     services['Albums photo inclus'] = Icons.photo_album;
   }
   
   if (widget.prestataire.containsKey('galerie_en_ligne') && 
       _getBoolValue(widget.prestataire['galerie_en_ligne'])) {
     services['Galerie en ligne'] = Icons.cloud;
   }
   
   // Ajouter d'autres services selon les options du photographe
   if (widget.prestataire.containsKey('livre_inclus') && 
       _getBoolValue(widget.prestataire['livre_inclus'])) {
     services['Livre photo inclus'] = Icons.book;
   }
   
   if (widget.prestataire.containsKey('tirage_inclus') && 
       _getBoolValue(widget.prestataire['tirage_inclus'])) {
     services['Tirages inclus'] = Icons.photo;
   }
 }
 
 // Construction des détails supplémentaires selon le type
 Widget _buildAdditionalDetails() {
   switch (widget.type) {
     case 'lieu':
       return _buildLieuAdditionalDetails();
     case 'traiteur':
       return _buildTraiteurAdditionalDetails();
     case 'photographe':
       return _buildPhotographeAdditionalDetails();
     default:
       return const SizedBox.shrink();
   }
 }
 
 // Construction des détails additionnels pour un lieu
 Widget _buildLieuAdditionalDetails() {
   final Color accentColor = Theme.of(context).colorScheme.primary;
   final Color beige = Theme.of(context).colorScheme.secondary;
   
   // Vérifie si nous avons des données de salles ou une adresse
   final bool hasSalles = _getSallesData() != null && _getSallesData()!.isNotEmpty;
   final bool hasAdresse = widget.prestataire['adresse'] != null && widget.prestataire['adresse'].toString().isNotEmpty;
   
   if (!hasSalles && !hasAdresse) {
     return const SizedBox.shrink(); // Ne rien afficher s'il n'y a pas de données
   }
   
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Information sur les salles (si disponible)
       if (hasSalles) ...[
         const Text(
           'Information sur les salles',
           style: TextStyle(
             fontSize: 24,
             fontWeight: FontWeight.bold,
             color: Color(0xFF2B2B2B),
           ),
         ),
         const SizedBox(height: 16),
         
         // Description des salles
         _buildSallesDescription(),
         
         const SizedBox(height: 24),
       ],
       
       // Adresse et localisation (si disponible)
       if (hasAdresse) ...[
         const Text(
           'Adresse',
           style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: Color(0xFF2B2B2B),
           ),
         ),
         const SizedBox(height: 12),
         
         Card(
           elevation: 2,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
           ),
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Icon(Icons.place, color: accentColor),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Text(
                         widget.prestataire['adresse'],
                         style: const TextStyle(
                           fontSize: 16,
                         ),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 16),
                 OutlinedButton.icon(
                   icon: Icon(
                     Icons.map,
                     color: accentColor,
                   ),
                   label: const Text(
                     "Voir sur la carte",
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   style: OutlinedButton.styleFrom(
                     side: BorderSide(color: accentColor),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   ),
                   onPressed: () => _openMap(widget.prestataire['adresse']),
                 ),
               ],
             ),
           ),
         ),
       ],
     ],
   );
 }
 
 // Construction d'une description des salles pour un lieu
 Widget _buildSallesDescription() {
   Map<String, dynamic>? salles = _getSallesData();
   
   if (salles == null || salles.isEmpty) {
     return const SizedBox.shrink(); // Ne rien afficher si pas de données
   }
   
   // Si des données spécifiques sont disponibles
   List<Widget> salleWidgets = [];
   
   salles.forEach((key, value) {
     if (value is Map) {
       // Vérifier que les données nécessaires sont présentes
       if (value.containsKey('description')) {
         salleWidgets.add(
           _buildSalleCard(
             _formatKeyName(key),
             value['description'] ?? 'Aucune description disponible',
             capacite: value['capacite'],
             superficie: value['superficie'],
           ),
         );
         
         if (salleWidgets.length > 1) {
           salleWidgets.add(const SizedBox(height: 16));
         }
       }
     }
   });
   
   return Column(children: salleWidgets);
 }
 
 // Construction d'une carte pour une salle
 Widget _buildSalleCard(String title, String description, {dynamic capacite, dynamic superficie}) {
   final Color accentColor = Theme.of(context).colorScheme.primary;
   
   return Card(
     elevation: 2,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12),
     ),
     child: Padding(
       padding: const EdgeInsets.all(16),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             title,
             style: const TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: Color(0xFF2B2B2B),
             ),
           ),
           const SizedBox(height: 12),
           Text(
             description,
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[800],
             ),
           ),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               if (capacite != null) ...[
                 Expanded(
                   child: Row(
                     children: [
                       Icon(Icons.people, color: accentColor, size: 18),
                       const SizedBox(width: 8),
                       Text(
                         'Capacité: $capacite pers.',
                         style: const TextStyle(
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ],
                   ),
                 ),
               ],
               if (superficie != null) ...[
                 Expanded(
                   child: Row(
                     children: [
                       Icon(Icons.square_foot, color: accentColor, size: 18),
                       const SizedBox(width: 8),
                       Text(
                         'Surface: $superficie m²',
                         style: const TextStyle(
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ],
                   ),
                 ),
               ],
             ],
           ),
         ],
       ),
     ),
   );
 }
 
 // Construction des détails additionnels pour un traiteur
 Widget _buildTraiteurAdditionalDetails() {
   final Color accentColor = Theme.of(context).colorScheme.primary;
   final Color beige = Theme.of(context).colorScheme.secondary;
   
   // Vérifie si nous avons des données de menus ou un email de contact
   final bool hasMenus = widget.prestataire.containsKey('menus') && widget.prestataire['menus'] != null;
   final bool hasEmail = widget.prestataire.containsKey('email') && 
                         widget.prestataire['email'] != null && 
                         widget.prestataire['email'].toString().isNotEmpty;
   
   if (!hasMenus && !hasEmail) {
     return const SizedBox.shrink(); // Ne rien afficher s'il n'y a pas de données
   }
   
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Exemples de menus (si disponibles)
       if (hasMenus) ...[
         const Text(
           'Exemples de menus',
           style: TextStyle(
             fontSize: 24,
             fontWeight: FontWeight.bold,
             color: Color(0xFF2B2B2B),
           ),
         ),
         const SizedBox(height: 16),
         
         // Afficher les menus depuis les données
         ..._buildMenusFromData(widget.prestataire['menus'], beige.withOpacity(0.2), accentColor),
         
         const SizedBox(height: 24),
       ],
       
       // Contact (si email disponible)
       if (hasEmail) ...[
         const Text(
           'Contact direct',
           style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: Color(0xFF2B2B2B),
           ),
         ),
         const SizedBox(height: 12),
         
         Card(
           elevation: 2,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
           ),
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Icon(Icons.email, color: accentColor),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Text(
                         widget.prestataire['email'],
                         style: const TextStyle(
                           fontSize: 16,
                         ),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 16),
                 OutlinedButton.icon(
                   icon: Icon(
                     Icons.mail_outline,
                     color: accentColor,
                   ),
                   label: const Text(
                     "Contacter directement",
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   style: OutlinedButton.styleFrom(
                     side: BorderSide(color: accentColor),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   ),
                   onPressed: () => _sendEmail(widget.prestataire['email']),
                 ),
               ],
             ),
           ),
         ),
       ],
     ],
   );
 }
 
 // Construction des données de menus à partir des données
 List<Widget> _buildMenusFromData(dynamic menusData, Color bgColor, Color accentColor) {
   List<Widget> menuWidgets = [];
   
   // Si les menus sont disponibles dans un format lisible
   if (menusData is List) {
     for (var menu in menusData) {
       if (menu is Map<String, dynamic>) {
         final String title = menu['nom'] ?? 'Menu';
         final String price = menu['prix'] != null ? '${menu['prix']} € par personne' : 'Prix sur demande';
         final List<String> items = [];
         
         if (menu['plats'] is List) {
           for (var plat in menu['plats']) {
             if (plat is Map<String, dynamic>) {
               items.add('${plat['type'] ?? 'Plat'}: ${plat['description'] ?? ''}');
             } else if (plat is String) {
               items.add(plat);
             }
           }
         }
         
         if (items.isNotEmpty) {
           menuWidgets.add(
             _buildMenuCard(title, price, items, bgColor, accentColor),
           );
           
           if (menuWidgets.length > 1) {
             menuWidgets.add(const SizedBox(height: 16));
           }
         }
       }
     }
   }
   
   // Si aucun menu n'est disponible, retourner une liste vide
   return menuWidgets;
 }
 
 // Construction des détails additionnels pour un photographe
 Widget _buildPhotographeAdditionalDetails() {
   final Color accentColor = Theme.of(context).colorScheme.primary;
   final Color beige = Theme.of(context).colorScheme.secondary;
   
   // Vérifie si nous avons des données de formules ou un email de contact
   final bool hasFormules = widget.prestataire.containsKey('formules') && widget.prestataire['formules'] != null;
   final bool hasEmail = widget.prestataire.containsKey('email') && 
                         widget.prestataire['email'] != null && 
                         widget.prestataire['email'].toString().isNotEmpty;
   
   if (!hasFormules && !hasEmail) {
     return const SizedBox.shrink(); // Ne rien afficher s'il n'y a pas de données
   }
   
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Formules disponibles (si présentes)
       if (hasFormules) ...[
         const Text(
           'Formules disponibles',
           style: TextStyle(
             fontSize: 24,
             fontWeight: FontWeight.bold,
             color: Color(0xFF2B2B2B),
           ),
         ),
         const SizedBox(height: 16),
         
         // Afficher les formules depuis les données
         ..._buildFormulesFromData(widget.prestataire['formules'], beige.withOpacity(0.2), accentColor),
         
         const SizedBox(height: 24),
       ],
       
       // Portfolio (si email disponible)
       if (hasEmail) ...[
         const Text(
           'Portfolio',
           style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: Color(0xFF2B2B2B),
           ),
         ),
         const SizedBox(height: 12),
         
         Card(
           elevation: 2,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
           ),
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   'Contactez ce photographe pour voir son portfolio complet. Vous pourrez ainsi apprécier son style et sa sensibilité artistique.',
                   style: TextStyle(
                     fontSize: 14,
                     height: 1.5,
                   ),
                 ),
                 const SizedBox(height: 16),
                 OutlinedButton.icon(
                   icon: Icon(
                     Icons.photo_library,
                     color: accentColor,
                   ),
                   label: const Text(
                     "Demander le portfolio",
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   style: OutlinedButton.styleFrom(
                     side: BorderSide(color: accentColor),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   ),
                   onPressed: () => _sendEmail(widget.prestataire['email']),
                 ),
               ],
             ),
           ),
         ),
       ],
     ],
   );
 }
 
 // Construction des formules de photographe à partir des données
 List<Widget> _buildFormulesFromData(dynamic formulesData, Color bgColor, Color accentColor) {
   List<Widget> formuleWidgets = [];
   
   // Si les formules sont disponibles dans un format lisible
   if (formulesData is List) {
     for (var formule in formulesData) {
       if (formule is Map<String, dynamic>) {
         final String title = formule['nom'] ?? 'Formule';
         final String description = formule['description'] ?? '';
         final String price = formule['prix'] != null ? '${formule['prix']}€' : 'Prix sur demande';
         
         if (description.isNotEmpty) {
           formuleWidgets.add(
             _buildFormuleCard(title, description, price, bgColor, accentColor),
           );
           
           if (formuleWidgets.length > 1) {
             formuleWidgets.add(const SizedBox(height: 16));
           }
         }
       }
     }
   }
   
   // Si aucune formule n'est disponible, retourner une liste vide
   return formuleWidgets;
 }
 
 // Construction d'une carte pour un menu
 Widget _buildMenuCard(String title, String price, List<String> items, Color bgColor, Color accentColor) {
   return Card(
     elevation: 2,
     color: bgColor,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12),
     ),
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
                   fontSize: 18,
                   color: Color(0xFF2B2B2B),
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
             padding: const EdgeInsets.only(bottom: 8),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text('• ', style: TextStyle(fontSize: 15)),
                 Expanded(
                   child: Text(
                     item, 
                     style: const TextStyle(
                       fontSize: 14,
                       height: 1.4,
                     ),
                   ),
                 ),
               ],
             ),
           )).toList(),
         ],
       ),
     ),
   );
 }
 
 // Construction d'une carte pour une formule
 Widget _buildFormuleCard(String title, String description, String price, Color bgColor, Color accentColor) {
   return Card(
     elevation: 2,
     color: bgColor,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12),
     ),
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
                   fontSize: 18,
                   color: Color(0xFF2B2B2B),
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
           const SizedBox(height: 8),
           Text(
             description,
             style: const TextStyle(
               fontSize: 14,
               height: 1.4,
               color: Color(0xFF5A5A5A),
             ),
           ),
         ],
       ),
     ),
   );
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
 
 // Widget pour afficher un item de caractéristique (style Airbnb)
 Widget _buildFeatureItem({
   required IconData icon,
   required String text
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
 
 // Méthodes utilitaires
 
 // Récupère l'icône selon le type de prestataire
 IconData _getTypeIcon() {
   switch (widget.type) {
     case 'lieu':
       return Icons.villa;
     case 'traiteur':
       return Icons.restaurant;
     case 'photographe':
       return Icons.camera_alt;
     default:
       return Icons.business;
   }
 }
 
 // Obtient une valeur booléenne de façon sécurisée
 bool _getBoolValue(dynamic value) {
   if (value == null) return false;
   if (value is bool) return value;
   if (value is int) return value > 0;
   if (value is String) {
     return value.toLowerCase() == 'true' || value == '1';
   }
   return false;
 }
 
 // Récupère les données des salles
 Map<String, dynamic>? _getSallesData() {
   // Vérifier d'abord dans les champs directs
   if (widget.prestataire['description_salles'] != null) {
     final dynamic value = widget.prestataire['description_salles'];
     if (value is Map) return Map<String, dynamic>.from(value);
     if (value is String) {
       try {
         final dynamic decoded = jsonDecode(value);
         if (decoded is Map) return Map<String, dynamic>.from(decoded);
       } catch (_) {}
     }
   }
   
   // Vérifier dans le sous-objet lieux
   if (widget.prestataire['lieux'] != null && widget.prestataire['lieux'] is Map) {
     final dynamic value = widget.prestataire['lieux']['description_salles'];
     if (value is Map) return Map<String, dynamic>.from(value);
     if (value is String) {
       try {
         final dynamic decoded = jsonDecode(value);
         if (decoded is Map) return Map<String, dynamic>.from(decoded);
       } catch (_) {}
     }
   }
   
   return null;
 }
 
 // Formate le nom d'une clé
 String _formatKeyName(String key) {
   return key.split('_').map((word) => 
     word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
   ).join(' ');
 }
 
 // Récupère le texte du type de cuisine pour un traiteur
 String _getTraiteurTypeText() {
   if (widget.prestataire.containsKey('traiteur_type') && widget.prestataire['traiteur_type'] != null) {
     final traiteurType = widget.prestataire['traiteur_type'];
     if (traiteurType is Map && traiteurType.containsKey('name')) {
       return traiteurType['name'];
     }
   }
   
   return 'Cuisine française traditionnelle';
 }
 
 // Récupère le texte du style pour un photographe
 String _getPhotographeStyleText() {
   if (widget.prestataire.containsKey('style') && widget.prestataire['style'] != null) {
     final style = widget.prestataire['style'];
     if (style is List && style.isNotEmpty) {
       return style.join(', ');
     } else if (style is String) {
       return style;
     }
   }
   
   return 'Reportage naturel';
 }
 
 // Récupère le texte de la durée pour un photographe
 String _getPhotographeDureeText() {
   if (widget.prestataire.containsKey('duree') && widget.prestataire['duree'] != null) {
     return widget.prestataire['duree'];
   }
   
   return 'Journée complète';
 }
 
 // Ouvre l'adresse sur une application de carte
 void _openMap(String? address) {
   if (address == null || address.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Adresse non disponible')),
     );
     return;
   }
   
   // En situation réelle, utiliser une librairie comme url_launcher
   // Exemple : 
   // final encodedAddress = Uri.encodeComponent(address);
   // final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
   // launch(url);
   
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Ouverture de la carte pour: $address')),
   );
 }
 
 // Envoie un email au prestataire
 void _sendEmail(String? email) {
   if (email == null || email.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Email non disponible')),
     );
     return;
   }
   
   // En situation réelle, utiliser une librairie comme url_launcher
   // Exemple : 
   // final url = 'mailto:$email';
   // launch(url);
   
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Préparation d\'un email pour: $email')),
   );
 }
}