import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/Filtre/data/repositories/presta_repository.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../widgets/empty_state.dart';
import '../Widgets/prestataireCard.dart';  // Assurez-vous que ce chemin est correct
import '../widgets/details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Écran de sélection du lieu pour le bouquet avec filtrage par région
class ChoixLieuScreen extends StatefulWidget {
  final Function(LieuModel) onLieuSelected;
  final LieuModel? selectedLieu;
  final QuizResults? quizResults;

  const ChoixLieuScreen({
    Key? key,
    required this.onLieuSelected,
    this.selectedLieu,
    this.quizResults,
  }) : super(key: key);

  @override
  State<ChoixLieuScreen> createState() => _ChoixLieuScreenState();
}

class _ChoixLieuScreenState extends State<ChoixLieuScreen> {
  final PrestaRepository _repository = PrestaRepository();
  final ScrollController _scrollController = ScrollController();
  
  List<LieuModel> _lieux = [];
  List<LieuModel> _lieuxFiltres = [];
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _favorites = []; // Pour simuler les favoris
  
  // Filtre par région sélectionnée dans le quiz
  String? _selectedRegion;
  bool _isLoadingRegions = true;
  List<String> _availableRegions = [];

  @override
  void initState() {
    super.initState();
    
    // Récupérer la région depuis les résultats du quiz
    if (widget.quizResults != null && widget.quizResults!.answers.containsKey('region')) {
      _selectedRegion = widget.quizResults!.answers['region'] as String?;
    }
    
    _loadRegions();
    _loadLieux();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Charge les régions disponibles
  Future<void> _loadRegions() async {
    setState(() {
      _isLoadingRegions = true;
    });
    
    try {
      // Récupérer les régions uniques des prestataires actifs
      final response = await Supabase.instance.client
          .from('presta')
          .select('region')
          .eq('actif', true)
          .eq('presta_type_id', 1) // 1 = lieu
          .order('region');
      
      // Extraire les régions uniques
      final Set<String> uniqueRegions = {};
      
      for (var item in response) {
        if (item is Map && item['region'] != null && item['region'].toString().isNotEmpty) {
          uniqueRegions.add(item['region'].toString());
        }
      }
      
      setState(() {
        _availableRegions = uniqueRegions.toList();
        _isLoadingRegions = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des régions: $e');
      
      // Régions par défaut en cas d'erreur
      setState(() {
        _availableRegions = [
          'Île-de-France',
          'Provence-Alpes-Côte d\'Azur',
          'Auvergne-Rhône-Alpes',
          'Occitanie',
          'Nouvelle-Aquitaine',
          'Bretagne',
          'Normandie',
          'Hauts-de-France',
          'Grand Est',
          'Pays de la Loire',
          'Bourgogne-Franche-Comté',
          'Centre-Val de Loire',
          'Corse'
        ];
        _isLoadingRegions = false;
      });
    }
  }

  /// Charge la liste des lieux depuis le repository
  Future<void> _loadLieux() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      List<Map<String, dynamic>> lieuxData;
      
      try {
        // Si une région est sélectionnée, filtrer par région
        if (_selectedRegion != null && _selectedRegion!.isNotEmpty) {
          lieuxData = await _repository.searchPrestataires(
            typeId: 1,  // 1 = lieu
            region: _selectedRegion,
          );
        } else {
          // Sinon, récupérer tous les lieux
          lieuxData = await _repository.getPrestairesByType(1);
        }
        
        // Convertir les données en modèles LieuModel
        final List<LieuModel> lieux = [];
        
        for (var data in lieuxData) {
          try {
            lieux.add(LieuModel.fromMap(data));
          } catch (e) {
            print('Erreur lors de la conversion d\'un lieu: $e');
          }
        }
        
        setState(() {
          _lieux = lieux;
          _filterLieux();
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur lors du chargement des lieux: $e');
        _loadMockLieux();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des lieux: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  /// Filtre les lieux selon la région sélectionnée
  void _filterLieux() {
    if (_selectedRegion == null || _selectedRegion!.isEmpty) {
      // Si aucune région n'est sélectionnée, afficher tous les lieux
      _lieuxFiltres = _lieux;
    } else {
      // Filtrer les lieux par région (correspondance insensible à la casse)
      _lieuxFiltres = _lieux.where((lieu) {
        return lieu.region.toLowerCase() == _selectedRegion!.toLowerCase();
      }).toList();
    }
  }
  
  /// Change la région sélectionnée
  void _changeRegion(String? region) {
    setState(() {
      _selectedRegion = region;
    });
    
    // Recharger les lieux
    _loadLieux();
  }
  
  /// Ajoute/retire un lieu des favoris
  void _toggleFavorite(String id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }
  
  /// Charge des données fictives en cas d'erreur
  void _loadMockLieux() {
    final List<Map<String, dynamic>> mockData = [];
    
    // Générer des lieux fictifs
    final regions = [
      'Île-de-France', 'Provence-Alpes-Côte d\'Azur', 'Auvergne-Rhône-Alpes', 
      'Occitanie', 'Nouvelle-Aquitaine', 'Bretagne', 'Normandie', 
      'Hauts-de-France', 'Grand Est', 'Pays de la Loire'
    ];
    
    final typesLieu = [
      'Château', 'Domaine', 'Salle de réception', 'Hôtel', 'Villa', 'Manoir'
    ];
    
    for (int i = 1; i <= 30; i++) {
      final regionIndex = i % regions.length;
      final String region = regions[regionIndex];
      final String typeLieu = typesLieu[i % typesLieu.length];
      
      // Générer des caractéristiques aléatoires
      final bool hasHebergement = i % 2 == 0;
      final bool hasEspaceExterieur = i % 3 != 0;
      final bool hasPiscine = i % 5 == 0;
      final bool hasParking = true;
      final int capacite = 50 + (i * 20);
      
      // Description des salles
      final Map<String, dynamic> descriptionSalles = {
        'salle_reception': {
          'capacite': capacite,
          'description': 'Salle principale avec vue panoramique',
        },
        'salle_cocktail': {
          'capacite': capacite ~/ 2,
          'description': 'Espace convivial pour cocktail et vin d\'honneur',
        },
      };
      
      // URL d'image fictive
      final String imageUrl = _getRandomLieuImage(i);
      
      mockData.add({
        'id': '${i}',
        'nom_entreprise': '$typeLieu ${_getRandomName(i)}',
        'description': 'Magnifique $typeLieu situé en $region. Cadre exceptionnel pour votre mariage avec une capacité jusqu\'à $capacite personnes.',
        'photo_url': imageUrl,
        'image_url': imageUrl,
        'prix_base': 3000.0 + (i * 500.0),
        'note_moyenne': 3.5 + (i % 5) * 0.3,
        'region': region,
        'adresse': 'Adresse fictive en $region',
        'presta_type_id': 1, // 1 = lieu
        'type_lieu': typeLieu,
        'lieux_type_id': (i % 5) + 1,
        'description_salles': descriptionSalles,
        'capacite_max': capacite,
        'espace_exterieur': hasEspaceExterieur,
        'piscine': hasPiscine,
        'parking': hasParking,
        'hebergement': hasHebergement,
        'capacite_hebergement': hasHebergement ? 20 + (i * 4) : 0,
        'exclusivite': i % 3 == 0,
        'feu_artifice': i % 7 == 0,
      });
    }
    
    setState(() {
      _lieux = mockData.map((data) => LieuModel.fromMap(data)).toList();
      _filterLieux();
      _isLoading = false;
    });
  }

  String _getRandomName(int seed) {
    final names = [
      'Royal', 'Élégance', 'Belle Vue', 'Grand Siècle', 'Prestige', 
      'Paradis', 'Émeraude', 'Romantique', 'Charme', 'Sérénité'
    ];
    return names[seed % names.length];
  }
  
  String _getRandomLieuImage(int seed) {
    final images = [
      'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=2940&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=2940&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1515715709530-858f7bfa1b10?q=80&w=3003&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1635996145160-54e6bb3c8341?q=80&w=2942&auto=format&fit=crop',
    ];
    return images[seed % images.length];
  }
  
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color backgroundColor = Colors.white;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Choisir un lieu'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtre région
          _buildRegionFilter(context),
          
          // Indication lieu sélectionné
          if (widget.selectedLieu != null)
            _buildSelectedLieuIndicator(context),
          
          // Liste des lieux
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[700]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadLieux,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _lieuxFiltres.isEmpty
                  ? EmptyState(
                      title: 'Aucun lieu disponible',
                      message: _selectedRegion != null 
                          ? 'Aucun lieu trouvé dans la région $_selectedRegion' 
                          : 'Aucun lieu disponible actuellement',
                      icon: Icons.villa,
                      actionLabel: 'Modifier la région',
                      onActionPressed: () => _showRegionSelector(context),
                    )
                  : _buildLieuList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegionFilter(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: beige.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              const Icon(Icons.place, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Région',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (_selectedRegion != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedRegion = null;
                    });
                    _loadLieux();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Effacer'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Sélecteur de région
          InkWell(
            onTap: () => _showRegionSelector(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedRegion != null ? accentColor : Colors.grey.shade300,
                  width: _selectedRegion != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isLoadingRegions
                          ? 'Chargement des régions...'
                          : _selectedRegion ?? 'Toutes les régions',
                      style: TextStyle(
                        color: _selectedRegion != null ? accentColor : Colors.grey.shade700,
                        fontWeight: _selectedRegion != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: _selectedRegion != null ? accentColor : Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectedLieuIndicator(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: accentColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sélectionné: ${widget.selectedLieu!.nomEntreprise}',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLieuList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _lieuxFiltres.length,
      itemBuilder: (context, index) {
        final lieu = _lieuxFiltres[index];
        final bool isSelected = widget.selectedLieu?.id == lieu.id;
        final bool isFavorite = _favorites.contains(lieu.id);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BouquetPrestaireCard(
            prestataire: _convertLieuToMap(lieu),
            onTap: () => _selectLieu(lieu),
            onFavoriteToggle: () => _toggleFavorite(lieu.id),
            isFavorite: isFavorite,
            isSelected: isSelected,
            onDetailPressed: () => _openLieuDetails(lieu),  // Ajouter cette propriété pour le bouton "+"
          ),
        );
      },
    );
  }
  
  void _showRegionSelector(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // En-tête avec titre et bouton fermer
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sélectionner une région',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Liste des régions
                Expanded(
                  child: _isLoadingRegions
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        children: [
                          // Option pour toutes les régions
                          ListTile(
                            title: const Text('Toutes les régions'),
                            leading: _selectedRegion == null 
                                ? Icon(Icons.check_circle, color: accentColor)
                                : const Icon(Icons.circle_outlined),
                            onTap: () {
                              _changeRegion(null);
                              Navigator.pop(context);
                            },
                          ),
                          
                          const Divider(),
                          
                          // Régions disponibles
                          ..._availableRegions.map((region) {
                            final isSelected = region == _selectedRegion;
                            return ListTile(
                              title: Text(
                                region,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              leading: isSelected 
                                  ? Icon(Icons.check_circle, color: accentColor)
                                  : const Icon(Icons.circle_outlined),
                              onTap: () {
                                _changeRegion(region);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  /// Convertit un LieuModel en Map pour l'affichage dans PrestaireCard
  Map<String, dynamic> _convertLieuToMap(LieuModel lieu) {
    // Vérifier si le lieu a déjà une méthode toMap qui retourne une Map complète
    Map<String, dynamic> lieuMap = lieu.toMap();
    
    // S'assurer que tous les champs nécessaires pour l'affichage sont présents
    lieuMap['presta_type_id'] = 1; // 1 = lieu
    
    // Gérer les images correctement
    if ((!lieuMap.containsKey('photo_url') || lieuMap['photo_url'] == null) &&
        (!lieuMap.containsKey('image_url') || lieuMap['image_url'] == null)) {
      lieuMap['image_url'] = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
    }
    
    return lieuMap;
  }
  
  /// Ouvre la page de détails du lieu
  void _openLieuDetails(LieuModel lieu) {
    final Map<String, dynamic> lieuMap = _convertLieuToMap(lieu);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BouquetPrestataireDetailScreen(
          type: 'lieu',
          prestataire: lieuMap,
          isSelected: widget.selectedLieu?.id == lieu.id,
          onSelect: () => _selectLieu(lieu),
        ),
      ),
    );
  }
  
  /// Sélectionne un lieu et le communique au parent
  void _selectLieu(LieuModel lieu) {
    widget.onLieuSelected(lieu);
    
    // Confirmer visuellement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lieu.nomEntreprise} sélectionné'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}