import 'package:flutter/material.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../Filtre/data/models/presta_type_model.dart';
import '../Filtre/Widgets/prestataire_card.dart';
import '../DetailsScreen/PrestaireDetailScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class PrestatairesListScreen extends StatefulWidget {
  final PrestaTypeModel prestaType;
  final Map<String, dynamic>? subType;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;

  const PrestatairesListScreen({
    Key? key,
    required this.prestaType,
    this.subType,
    this.location,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  State<PrestatairesListScreen> createState() => _PrestatairesListScreenState();
}

class _PrestatairesListScreenState extends State<PrestatairesListScreen> {
  final PrestaRepository _repository = PrestaRepository();
  List<Map<String, dynamic>> _prestataires = [];
  bool _isLoading = true;
  List<String> _availableRegions = [];
  bool _isLoadingRegions = true;
  String _errorMessage = '';
  List<int> _favorites = []; // Pour simuler les favoris
  
  // Filtres
  String? _regionFilter;
  double? _minPriceFilter;
  double? _maxPriceFilter;
  double? _minRatingFilter;

  @override
  void initState() {
    super.initState();
    _loadAvailableRegions();
    // Initialiser les filtres avec les paramètres reçus
    if (widget.location != null) {
      _regionFilter = widget.location;
    }
    _loadPrestataires();
  }

  Future<void> _loadAvailableRegions() async {
    setState(() {
      _isLoadingRegions = true;
    });
    
    try {
      final regions = await _fetchAvailableRegions();
      setState(() {
        _availableRegions = regions;
        _isLoadingRegions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRegions = false;
      });
    }
  }


Future<void> _loadPrestataires() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    List<Map<String, dynamic>> prestataires = [];
    
    // Récupérer le type principal de prestataire (Lieu, Traiteur, etc.)
    final int prestaTypeId = widget.prestaType.id;

    
    // Si c'est un lieu (type_id = 1) avec un sous-type spécifié
    if (prestaTypeId == 1 && widget.subType != null) {

      final lieuTypeId = widget.subType!['id'];
      // Charger les lieux par type
      prestataires = await _repository.getLieuxByType(lieuTypeId);
    }
    // Si c'est un traiteur (type_id = 2) avec un sous-type spécifié
    else if (prestaTypeId == 2 && widget.subType != null) {
      final traiteurTypeId = widget.subType!['id'];
      // Charger les traiteurs par type
      prestataires = await _repository.getTraiteursByType(
        traiteurTypeId, 
        region: widget.location
      );
    }
    // Pour tous les autres cas, utiliser la recherche générique
    else {
      prestataires = await _repository.searchPrestataires(
        typeId: prestaTypeId,
        region: widget.location,
      );
    }
    
   
    setState(() {
      _prestataires = prestataires;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Erreur lors du chargement des prestataires: ${e.toString()}';
      _isLoading = false;
      _prestataires = [];
    });
  }
}
  
  List<Map<String, dynamic>> get _filteredPrestataires {
    // Si aucun filtre n'est appliqué, retourner tous les prestataires
    if (_regionFilter == null && _minPriceFilter == null && 
        _maxPriceFilter == null && _minRatingFilter == null) {
      return _prestataires;
    }
    
    // Appliquer les filtres
    return _prestataires.where((p) {
      // Filtre par région
      if (_regionFilter != null && p['region'] != _regionFilter) {
        return false;
      }
      
      // Filtre par prix min
      if (_minPriceFilter != null) {
        final price = p['prix_base'] ?? 0.0;
        if (price < _minPriceFilter!) {
          return false;
        }
      }
      
      // Filtre par prix max
      if (_maxPriceFilter != null) {
        final price = p['prix_base'] ?? double.infinity;
        if (price > _maxPriceFilter!) {
          return false;
        }
      }
      
      // Filtre par note minimale
      if (_minRatingFilter != null) {
        final rating = p['note_moyenne'] ?? 0.0;
        if (rating < _minRatingFilter!) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser les couleurs du thème de l'application
    const Color accentColor = Color(0xFF524B46);
    const Color grisTexte = Color(0xFF2B2B2B);
    const Color beige = Color(0xFFFFF3E4);
    
    // Générer un titre approprié pour l'appbar
    String title = widget.subType != null 
        ? "${widget.subType!['name']}" 
        : widget.prestaType.name;
        
    if (widget.location != null) {
      title += " à ${widget.location}";
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: accentColor,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bouton de filtre
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: accentColor))
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
                          onPressed: _loadPrestataires,
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
              : RefreshIndicator(
                  onRefresh: _loadPrestataires,
                  color: accentColor,
                  child: CustomScrollView(
                    slivers: [
                      // En-tête avec statistiques
                      SliverToBoxAdapter(
                        child: _buildStatisticsHeader(context),
                      ),
                      
                      // Filtres actifs
                      if (_hasActiveFilters)
                        SliverToBoxAdapter(
                          child: _buildActiveFiltersBar(context),
                        ),
                      
                      // Liste des prestataires
                      _filteredPrestataires.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: grisTexte.withAlpha(102),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aucun prestataire trouvé',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: grisTexte.withAlpha(204),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Essayez de modifier vos critères de recherche',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: grisTexte.withAlpha(153),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _clearAllFilters,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text('Réinitialiser les filtres'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.all(16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final prestataire = _filteredPrestataires[index];
                                    final prestaId = prestataire['id'];
                                    
                                    return PrestaireCard(
                                      prestataire: prestataire,
                                      onTap: () => _navigateToDetails(prestataire),
                                      onFavoriteToggle: () => _toggleFavorite(prestataire),
                                      isFavorite: _favorites.contains(prestaId),
                                    );
                                  },
                                  childCount: _filteredPrestataires.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }
  
  // Vérifie si des filtres sont actifs
  bool get _hasActiveFilters => 
      _regionFilter != null || 
      _minPriceFilter != null || 
      _maxPriceFilter != null || 
      _minRatingFilter != null;
  
  // En-tête avec statistiques
  Widget _buildStatisticsHeader(BuildContext context) {
    String budgetText = 'N/A';
    IconData budgetIcon = Icons.euro;
    
    // Calculer l'affichage du prix moyen pour l'en-tête
    if (_filteredPrestataires.isNotEmpty) {
      final double? avgPrice = _calculateAveragePrice();
      if (avgPrice != null) {
        if (avgPrice < 1000) {
          budgetText = 'Abordable';
        } else if (avgPrice < 3000) {
          budgetText = 'Moyen';
        } else if (avgPrice < 5000) {
          budgetText = 'Premium';
        } else {
          budgetText = 'Luxe';
        }
      }
    }
    
    // Rating moyen
    final avgRating = _calculateAverageRating();
    final String ratingText = avgRating != null ? avgRating.toStringAsFixed(1) : 'N/A';
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFFFFF3E4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            '${_filteredPrestataires.length}',
            'Prestataires',
            Icons.business,
          ),
          _buildStatItem(
            context,
            budgetText,
            'Budget moyen',
            budgetIcon,
          ),
          _buildStatItem(
            context,
            ratingText,
            'Note moyenne',
            Icons.star,
            iconColor: Colors.amber,
          ),
        ],
      ),
    );
  }
  
  Future<List<String>> _fetchAvailableRegions() async {
  try {
    // Requête pour obtenir toutes les régions uniques des prestataires actifs
    final response = await Supabase.instance.client
        .from('presta')
        .select('region')
        .eq('actif', true)
        .order('region');
    
    // Convertir la réponse en liste de régions uniques
    final Set<String> uniqueRegions = {};
    
    for (var item in response) {
      if (item['region'] != null && item['region'].toString().isNotEmpty) {
        uniqueRegions.add(item['region'].toString());
      }
    }
    
    return uniqueRegions.toList();
  } catch (e) {
    // Retourner une liste par défaut en cas d'erreur
    return ['Paris', 'Lyon', 'Marseille', 'Bordeaux'];
  }
}

  // Élément de statistique
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon, {
    Color iconColor = const Color(0xFF524B46),
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2B2B2B),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xB32B2B2B),
          ),
        ),
      ],
    );
  }
  
  // Barre de filtres actifs
  Widget _buildActiveFiltersBar(BuildContext context) {
    final List<Widget> filterChips = [];
    
    if (_regionFilter != null) {
      filterChips.add(_buildFilterChip(
        'Région: $_regionFilter',
        () => _clearFilter('region'),
      ));
    }
    
    if (_minPriceFilter != null) {
      filterChips.add(_buildFilterChip(
        'Prix min: ${_minPriceFilter!.toInt()}€',
        () => _clearFilter('minPrice'),
      ));
    }
    
    if (_maxPriceFilter != null) {
      filterChips.add(_buildFilterChip(
        'Prix max: ${_maxPriceFilter!.toInt()}€',
        () => _clearFilter('maxPrice'),
      ));
    }
    
    if (_minRatingFilter != null) {
      filterChips.add(_buildFilterChip(
        'Note min: ${_minRatingFilter!.toStringAsFixed(1)}',
        () => _clearFilter('minRating'),
      ));
    }
    
    if (filterChips.isNotEmpty) {
      // Ajouter un bouton pour effacer tous les filtres
      filterChips.add(_buildFilterChip(
        'Effacer tout',
        _clearAllFilters,
        isReset: true,
      ));
    }
    
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filterChips,
      ),
    );
  }
  
  // Chip de filtre
  Widget _buildFilterChip(String label, VoidCallback onDelete, {bool isReset = false}) {
    const Color accentColor = Color(0xFF524B46);
    const Color beige = Color(0xFFFFF3E4);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isReset ? accentColor : beige,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReset ? accentColor : accentColor.withAlpha(51),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isReset ? Colors.white : accentColor,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isReset ? Colors.white.withAlpha(77) : accentColor.withAlpha(26),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 10,
                      color: isReset ? Colors.white : accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Naviguer vers les détails d'un prestataire
  void _navigateToDetails(Map<String, dynamic> prestataire) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => PrestaireDetailScreen(
            prestataire: prestataire,
          ),
        ),
      );
    }
  
  // Basculer l'état favori d'un prestataire
  void _toggleFavorite(Map<String, dynamic> prestataire) {
    final id = prestataire['id'];
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retiré des favoris: ${prestataire['nom_entreprise']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        _favorites.add(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ajouté aux favoris: ${prestataire['nom_entreprise']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }
  
  // Effacer un filtre spécifique
  void _clearFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'region':
          _regionFilter = null;
          break;
        case 'minPrice':
          _minPriceFilter = null;
          break;
        case 'maxPrice':
          _maxPriceFilter = null;
          break;
        case 'minRating':
          _minRatingFilter = null;
          break;
      }
    });
  }
  
  // Effacer tous les filtres
  void _clearAllFilters() {
    setState(() {
      _regionFilter = null;
      _minPriceFilter = null;
      _maxPriceFilter = null;
      _minRatingFilter = null;
    });
  }
  
  // Calculer la note moyenne
  double? _calculateAverageRating() {
    if (_filteredPrestataires.isEmpty) return null;
    
    double sum = 0;
    int count = 0;
    
    for (var prestataire in _filteredPrestataires) {
      final rating = prestataire['note_moyenne'];
      if (rating != null) {
        sum += rating is double ? rating : double.tryParse(rating.toString()) ?? 0;
        count++;
      }
    }
    
    return count > 0 ? sum / count : null;
  }
  
  // Calculer le prix moyen
  double? _calculateAveragePrice() {
    if (_filteredPrestataires.isEmpty) return null;
    
    double sum = 0;
    int count = 0;
    
    for (var prestataire in _filteredPrestataires) {
      final price = prestataire['prix_base'];
      if (price != null) {
        sum += price is double ? price : double.tryParse(price.toString()) ?? 0;
        count++;
      }
    }
    
    return count > 0 ? sum / count : null;
  }
  
  // Afficher le modal des filtres
// Ajoutez cette méthode à votre classe _PrestatairesListScreenState

void _showFilterBottomSheet(BuildContext context) {
  const Color accentColor = Color(0xFF524B46);
  const Color grisTexte = Color(0xFF2B2B2B);
  const Color beige = Color(0xFFFFF3E4);
  
  // Liste des régions disponibles (à remplacer par vos données réelles)
  final List<String> availableRegions = _isLoadingRegions 
    ? ['Chargement...'] 
    : _availableRegions;
  
  // Variables temporaires pour les filtres
  String? tempRegion = _regionFilter;
  double? tempMinPrice = _minPriceFilter;
  double? tempMaxPrice = _maxPriceFilter;
  double tempMinRating = _minRatingFilter ?? 0;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            // Hauteur du modal: 80% de l'écran
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre et titre
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Barre d'indication
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(77),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Titre avec bouton fermer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtres',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: grisTexte,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: grisTexte),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                
                // Contenu avec défilement
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        
                        // Filtre par région
                        const Text('Région', style: TextStyle(/*...*/)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: availableRegions.map((region) {
                            final isSelected = tempRegion == region;
                            return GestureDetector(
                              onTap: () {
                                if (region != 'Chargement...') {
                                  setModalState(() {
                                    tempRegion = isSelected ? null : region;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? accentColor : beige.withAlpha(102),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? accentColor : beige,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  region,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? Colors.white : grisTexte,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Filtre par prix
                        const Text(
                          'Fourchette de prix',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: grisTexte,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: beige.withAlpha(77),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Min (€)',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    labelStyle: TextStyle(color: grisTexte),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                    text: tempMinPrice?.toString() ?? '',
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      tempMinPrice = value.isNotEmpty ? double.tryParse(value) : null;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: beige.withAlpha(77),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Max (€)',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    labelStyle: TextStyle(color: grisTexte),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                    text: tempMaxPrice?.toString() ?? '',
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      tempMaxPrice = value.isNotEmpty ? double.tryParse(value) : null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Filtre par note
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Note minimale',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: grisTexte,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  tempMinRating > 0 ? '${tempMinRating.toStringAsFixed(1)}+' : 'Toutes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: grisTexte,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: accentColor,
                            inactiveTrackColor: beige.withAlpha(77),
                            thumbColor: accentColor,
                            overlayColor: accentColor.withAlpha(51),
                            valueIndicatorColor: accentColor,
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          child: Slider(
                            value: tempMinRating,
                            max: 5,
                            min: 0,
                            divisions: 10,
                            label: tempMinRating.toStringAsFixed(1),
                            onChanged: (value) {
                              setModalState(() {
                                tempMinRating = value;
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toutes',
                              style: TextStyle(color: grisTexte, fontSize: 12),
                            ),
                            const Text(
                              '5.0',
                              style: TextStyle(color: grisTexte, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Barre de séparation
                Divider(height: 32, thickness: 1, color: Colors.grey.withAlpha(51)),
                
                // Boutons d'action
                Row(
                  children: [
                    // Bouton réinitialiser
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempRegion = null;
                          tempMinPrice = null;
                          tempMaxPrice = null;
                          tempMinRating = 0;
                        });
                      },
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bouton appliquer
                    ElevatedButton(
                      onPressed: () {
                        // Appliquer les filtres
                        setState(() {
                          _regionFilter = tempRegion;
                          _minPriceFilter = tempMinPrice;
                          _maxPriceFilter = tempMaxPrice;
                          _minRatingFilter = tempMinRating > 0 ? tempMinRating : null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Voir les résultats',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}



}