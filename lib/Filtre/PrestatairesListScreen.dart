import 'package:flutter/material.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../Filtre/data/models/presta_type_model.dart';
import '../Filtre/prestataires_filter_screen.dart';
import '../Filtre/Widgets/prestataire_card.dart';

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
    // Initialiser les filtres avec les paramètres reçus
    if (widget.location != null) {
      _regionFilter = widget.location;
    }
    _loadPrestataires();
  }

  Future<void> _loadPrestataires() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      List<Map<String, dynamic>> prestataires = [];
      
      // Si nous avons un sous-type (pour les lieux), nous faisons une requête spécifique
      if (widget.subType != null) {
        try {
          prestataires = await _repository.searchPrestataires(
            typeId: widget.prestaType.id,
            //subTypeId: widget.subType!['id'],
            region: widget.location,
            //startDate: widget.startDate,
            //endDate: widget.endDate,
          );
        } catch (e) {
          // Utiliser des données factices car l'API n'est pas encore prête
          prestataires = _getMockPrestataires();
        }
      } else {
        // Sinon nous faisons une requête générale par type de prestataire
        try {
          prestataires = await _repository.getPrestairesByType(
            widget.prestaType.id,
            //region: widget.location,
            //startDate: widget.startDate,
            //endDate: widget.endDate,
          );
        } catch (e) {
          // Utiliser des données factices car l'API n'est pas encore prête
          prestataires = _getMockPrestataires();
        }
      }
      
      setState(() {
        _prestataires = prestataires;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des prestataires: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  // Méthode pour générer des données fictives en attendant l'API
  List<Map<String, dynamic>> _getMockPrestataires() {
    final String prestaType = widget.prestaType.name.toLowerCase();
    final String subType = widget.subType != null 
        ? widget.subType!['name'].toString() 
        : '';
    
    final List<Map<String, dynamic>> mockData = [];
    
    // Génération de données selon le type
    if (prestaType == 'lieu') {
      String prefix = subType.isNotEmpty ? subType : 'Lieu';
      for (int i = 1; i <= 10; i++) {
        mockData.add({
          'id': i,
          'nom_entreprise': '$prefix Prestige $i',
          'description': 'Un magnifique $prefix idéal pour votre mariage. Capacité de 100 à 300 personnes.',
          'region': widget.location ?? 'Paris',
          'adresse': '123 rue de Paris, 75001 Paris',
          'note_moyenne': (3.5 + (i / 10)),
          'prix_base': 2000.0 + (i * 500),
          'type_presta': widget.prestaType.id,
          'type_lieu': widget.subType != null ? widget.subType!['id'] : 1,
          'photo_url': null,
        });
      }
    } else if (prestaType == 'traiteur') {
      for (int i = 1; i <= 8; i++) {
        mockData.add({
          'id': i + 100,
          'nom_entreprise': 'Délices Traiteur $i',
          'description': 'Service traiteur de qualité avec une cuisine raffinée et créative.',
          'region': widget.location ?? 'Lyon',
          'adresse': '456 avenue de Lyon, 69002 Lyon',
          'note_moyenne': (3.7 + (i / 10)),
          'prix_base': 50.0 + (i * 15),
          'type_presta': widget.prestaType.id,
          'photo_url': null,
        });
      }
    } else if (prestaType == 'photographe') {
      for (int i = 1; i <= 12; i++) {
        mockData.add({
          'id': i + 200,
          'nom_entreprise': 'Studio Photo $i',
          'description': 'Photographe professionnel spécialisé dans les mariages avec une approche naturelle et élégante.',
          'region': widget.location ?? 'Marseille',
          'adresse': '789 boulevard de Marseille, 13008 Marseille',
          'note_moyenne': (4.0 + (i / 20)),
          'prix_base': 1000.0 + (i * 250),
          'type_presta': widget.prestaType.id,
          'photo_url': null,
        });
      }
    } else {
      // Données génériques pour les autres types
      for (int i = 1; i <= 6; i++) {
        mockData.add({
          'id': i + 300,
          'nom_entreprise': '${widget.prestaType.name} Service $i',
          'description': 'Prestataire de qualité spécialisé dans les mariages et événements.',
          'region': widget.location ?? 'Bordeaux',
          'adresse': '10 rue de Bordeaux, 33000 Bordeaux',
          'note_moyenne': (3.8 + (i / 10)),
          'prix_base': 500.0 + (i * 200),
          'type_presta': widget.prestaType.id,
          'photo_url': null,
        });
      }
    }
    
    return mockData;
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
    final Color accentColor = Theme.of(context).colorScheme.primary; // #524B46
    final Color grisTexte = Theme.of(context).colorScheme.onSurface; // #2B2B2B
    final Color beige = Theme.of(context).colorScheme.secondary; // #FFF3E4
    
    // Générer un titre approprié pour l'appbar
    String title = widget.prestaType.name;
    if (widget.subType != null) {
      title = widget.subType!['name'];
    }
    if (widget.location != null) {
      title += ' à ${widget.location}';
    }
    
    // Calculer l'affichage du prix moyen pour l'en-tête
    String budgetText = 'Prix non déterminés';
    IconData budgetIcon = Icons.euro;
    
    if (_filteredPrestataires.isNotEmpty) {
      // Calculer le prix moyen (si disponible)
      double? avgPrice = _calculateAveragePrice();
      if (avgPrice != null) {
        if (avgPrice < 1000) {
          budgetText = 'Abordable';
          budgetIcon = Icons.euro;
        } else if (avgPrice < 3000) {
          budgetText = 'Prix moyen';
          budgetIcon = Icons.euro_symbol;
        } else {
          budgetText = 'Premium';
          budgetIcon = Icons.attach_money;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: accentColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bouton de filtre
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _filteredPrestataires.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: grisTexte.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun prestataire trouvé',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: grisTexte.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Essayez de modifier vos critères de recherche',
                            style: TextStyle(
                              fontSize: 14,
                              color: grisTexte.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _regionFilter = null;
                                _minPriceFilter = null;
                                _maxPriceFilter = null;
                                _minRatingFilter = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Réinitialiser les filtres'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // En-tête avec statistiques
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: beige.withOpacity(0.3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context,
                                '${_filteredPrestataires.length}',
                                'Prestataires',
                                Icons.business,
                                accentColor,
                              ),
                              _buildStatItem(
                                context,
                                budgetText,
                                'Budget moyen',
                                budgetIcon,
                                accentColor,
                              ),
                              _buildStatItem(
                                context,
                                _calculateAverageRating()?.toStringAsFixed(1) ?? 'N/A',
                                'Note moyenne',
                                Icons.star,
                                Colors.amber,
                              ),
                            ],
                          ),
                        ),
                        
                        // Liste des filtres actifs (si des filtres sont appliqués)
                        if (_regionFilter != null || _minPriceFilter != null || 
                            _maxPriceFilter != null || _minRatingFilter != null)
                          _buildActiveFiltersBar(context),
                        
                        // Liste des prestataires
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadPrestataires,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredPrestataires.length,
                              itemBuilder: (context, index) {
                                final prestataire = _filteredPrestataires[index];
                                return PrestaireCard(
                                  prestataire: prestataire,
                                  //onTap: () => _navigateToPrestaireDetails(context, prestataire),
                                  onFavoriteToggle: () => _toggleFavorite(prestataire),
                                  isFavorite: _favorites.contains(prestataire['id']),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
  
  // Méthode pour basculer l'état favori d'un prestataire
  void _toggleFavorite(Map<String, dynamic> prestataire) {
    final id = prestataire['id'] as int;
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
  
  // Affiche une barre avec les filtres actifs
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterChips,
        ),
      ),
    );
  }
  
  // Construit une puce de filtre avec une option de suppression
  Widget _buildFilterChip(String label, VoidCallback onDelete, {bool isReset = false}) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isReset ? Colors.white : accentColor,
          ),
        ),
        backgroundColor: isReset 
            ? accentColor 
            : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: isReset ? Colors.white : accentColor,
        ),
        onDeleted: onDelete,
      ),
    );
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
  
  // Affiche la boîte de dialogue de filtres
  void _showFilterBottomSheet(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    // Liste des régions disponibles (à remplacer par vos données réelles)
    final List<String> availableRegions = [
      'Paris',
      'Île-de-France',
      'Lyon',
      'Marseille',
      'Bordeaux',
      'Lille',
      'Nantes',
      'Strasbourg',
      'Nice',
      'Toulouse',
    ];
    
    // Variables temporaires pour les filtres
    String? tempRegion = _regionFilter;
    double? tempMinPrice = _minPriceFilter;
    double? tempMaxPrice = _maxPriceFilter;
    double? tempMinRating = _minRatingFilter;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrer les prestataires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  
                  const Divider(),
                  
                  // Contenu avec défilement
                  Expanded(
                    child: ListView(
                      children: [
                        // Filtre par région
                        Text(
                          'Région',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: availableRegions.map((region) {
                            final isSelected = tempRegion == region;
                            return ChoiceChip(
                              label: Text(region),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  tempRegion = selected ? region : null;
                                });
                              },
                              selectedColor: accentColor.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? accentColor : null,
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Filtre par prix
                        Text(
                          'Fourchette de prix',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Min (€)',
                                  border: OutlineInputBorder(),
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Max (€)',
                                  border: OutlineInputBorder(),
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
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Filtre par note
                        Text(
                          'Note minimale',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Slider(
                          value: tempMinRating ?? 0,
                          max: 5,
                          divisions: 10,
                          label: tempMinRating?.toString() ?? '0',
                          onChanged: (value) {
                            setModalState(() {
                              tempMinRating = value > 0 ? value : null;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('0'),
                            Text(
                              tempMinRating == null 
                                  ? 'Toutes les notes' 
                                  : '${tempMinRating!.toStringAsFixed(1)} étoiles et plus',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('5'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempRegion = null;
                              tempMinPrice = null;
                              tempMaxPrice = null;
                              tempMinRating = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Appliquer les filtres
                            setState(() {
                              _regionFilter = tempRegion;
                              _minPriceFilter = tempMinPrice;
                              _maxPriceFilter = tempMaxPrice;
                              _minRatingFilter = tempMinRating;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Widget pour construire un élément statistique
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  // Méthode pour naviguer vers les détails du prestataire
  //void _navigateToPrestaireDetails(BuildContext context, Map<String, dynamic> prestataire) {
    //Navigator.push(
      //context,
      //MaterialPageRoute(
        //builder: (context) => PrestaireDetailScreen(prestataire: prestataire),
      //),
    //);
  //}
  
  // Calculer la note moyenne
  double? _calculateAverageRating() {
    if (_filteredPrestataires.isEmpty) return null;
    
    double sum = 0;
    int count = 0;
    
    for (var prestataire in _filteredPrestataires) {
      final rating = prestataire['note_moyenne'];
      if (rating != null) {
        sum += rating;
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
        sum += price;
        count++;
      }
    }
    
    return count > 0 ? sum / count : null;
  }
}