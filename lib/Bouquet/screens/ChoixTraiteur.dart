import 'package:flutter/material.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../data/presta_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/prestataireCard.dart';
import '../widgets/details.dart';

/// Écran de sélection du traiteur pour le bouquet avec filtrage par région
class ChoixTraiteurScreen extends StatefulWidget {
  final Function(TraiteurModel) onTraiteurSelected;
  final TraiteurModel? selectedTraiteur;
  final String? lieuId; // ID du lieu sélectionné pour filtrer les traiteurs compatibles
  final QuizResults? quizResults;

  const ChoixTraiteurScreen({
    Key? key,
    required this.onTraiteurSelected,
    this.selectedTraiteur,
    this.lieuId,
    this.quizResults,
  }) : super(key: key);

  @override
  State<ChoixTraiteurScreen> createState() => _ChoixTraiteurScreenState();
}

class _ChoixTraiteurScreenState extends State<ChoixTraiteurScreen> {
  final PrestaRepository _repository = PrestaRepository();
  List<TraiteurModel> _traiteurs = [];
  List<TraiteurModel> _traiteursFiltres = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Filtre par région sélectionnée dans le quiz
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    
    // Récupérer la région depuis les résultats du quiz
    if (widget.quizResults != null && widget.quizResults!.answers.containsKey('region')) {
      _selectedRegion = widget.quizResults!.answers['region'] as String?;
    }
    
    _loadTraiteurs();
  }

  /// Charge la liste des traiteurs depuis le repository
  Future<void> _loadTraiteurs() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Récupérer les traiteurs depuis la base de données
      try {
        final traiteursData = await _repository.getPrestairesByType(2);
        final traiteurs = traiteursData.map((data) => TraiteurModel.fromMap(data)).toList();
        
        setState(() {
          _traiteurs = traiteurs;
          _filterTraiteurs();
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur lors du chargement des traiteurs: $e');
        // En cas d'erreur, utiliser des données fictives
        _loadMockTraiteurs();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des traiteurs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  /// Filtre les traiteurs selon la région sélectionnée
  void _filterTraiteurs() {
    if (_selectedRegion == null || _selectedRegion!.isEmpty) {
      // Si aucune région n'est sélectionnée, afficher tous les traiteurs
      _traiteursFiltres = _traiteurs;
    } else {
      // Filtrer les traiteurs par région
      _traiteursFiltres = _traiteurs.where((traiteur) {
        // Vérifier si la région du traiteur correspond à la région sélectionnée (insensible à la casse)
        return traiteur.region.toLowerCase() == _selectedRegion!.toLowerCase();
      }).toList();
    }
    
    setState(() {});
  }
  
  /// Change la région de filtre
  void _changeRegion(String? region) {
    setState(() {
      _selectedRegion = region;
      _filterTraiteurs();
    });
  }
  
  /// Charge des données fictives en attendant l'API
  void _loadMockTraiteurs() {
    final List<Map<String, dynamic>> mockData = [];
    
    // Générer des traiteurs fictifs
    final regions = [
      'Île-de-France', 'Provence-Alpes-Côte d\'Azur', 'Auvergne-Rhône-Alpes', 
      'Occitanie', 'Nouvelle-Aquitaine', 'Bretagne', 'Normandie', 
      'Hauts-de-France', 'Grand Est', 'Pays de la Loire'
    ];
    
    final typesCuisine = [
      'Française', 'Italienne', 'Méditerranéenne', 'Fusion', 'Gastronomique', 'Végétarienne'
    ];
    
    for (int i = 1; i <= 30; i++) {
      final regionIndex = i % regions.length;
      final String region = regions[regionIndex];
      
      // Générer 2-3 types de cuisine pour chaque traiteur
      final List<String> cuisines = [];
      cuisines.add(typesCuisine[(i * 2) % typesCuisine.length]);
      cuisines.add(typesCuisine[(i * 3) % typesCuisine.length]);
      if (i % 3 == 0) {
        cuisines.add(typesCuisine[(i * 5) % typesCuisine.length]);
      }
      
      // Caractéristiques du traiteur
      final bool hasEquipements = i % 2 == 0;
      final bool hasPersonnel = i % 3 != 0;
      final int maxInvites = 80 + (i * 15);
      
      mockData.add({
        'id': i.toString(),
        'nom_entreprise': 'Traiteur ${_getRandomName(i)}',
        'description': 'Traiteur spécialisé dans la cuisine ${cuisines.join(", ")}. Service de qualité pour votre mariage.',
        'photo_url': null,
        'prix_base': 50.0 + (i * 8),
        'note_moyenne': 3.5 + (i % 5) * 0.3,
        'region': region,
        'adresse': 'Adresse fictive en $region',
        'type_cuisine': cuisines,
        'max_invites': maxInvites,
        'equipements_inclus': hasEquipements,
        'personnel_inclus': hasPersonnel,
      });
    }
    
    setState(() {
      _traiteurs = mockData.map((data) => TraiteurModel.fromMap(data)).toList();
      _filterTraiteurs();
      _isLoading = false;
    });
  }
  
  /// Génère un nom aléatoire pour les données fictives
  String _getRandomName(int seed) {
    final names = [
      'Délices', 'Saveurs', 'Excellence', 'Gourmet', 'Passion', 
      'Gourmandise', 'Gastronomie', 'Prestige', 'Arôme', 'Festif'
    ];
    return names[seed % names.length];
  }
  
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre et filtres
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la section
              Text(
                'Choisissez votre traiteur',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              // Filtre par région
              const SizedBox(height: 16),
              _buildRegionFilter(context),
            ],
          ),
        ),
        
        // Indication de sélection
        if (widget.selectedTraiteur != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Traiteur sélectionné: ${widget.selectedTraiteur!.nomEntreprise}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Contenu principal - Liste verticale de traiteurs
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                )
              : _traiteursFiltres.isEmpty
                ? EmptyState(
                    title: 'Aucun traiteur disponible',
                    message: _selectedRegion != null 
                        ? 'Aucun traiteur trouvé dans la région $_selectedRegion' 
                        : 'Aucun traiteur disponible actuellement',
                    icon: Icons.restaurant_menu,
                    actionLabel: 'Modifier la région',
                    onActionPressed: () => _showRegionSelector(context),
                  )
                : _buildVerticalTraiteursList(),
        ),
      ],
    );
  }
  
  /// Construit le sélecteur de région
  Widget _buildRegionFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrer par région:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showRegionSelector(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedRegion ?? 'Toutes les régions',
                    style: TextStyle(
                      fontWeight: _selectedRegion != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_selectedRegion != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedRegion = null;
                  _filterTraiteurs();
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Effacer le filtre'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }
  
  /// Affiche le sélecteur de région
  void _showRegionSelector(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    // Liste des régions disponibles
    final regions = [
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
    ];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre du sélecteur
              Text(
                'Sélectionnez une région',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Divider(),
              
              // Liste de régions
              Expanded(
                child: ListView.builder(
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    final isSelected = region == _selectedRegion;
                    
                    return ListTile(
                      title: Text(
                        region,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? accentColor : null,
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
                  },
                ),
              ),
              
              // Option pour afficher toutes les régions
              const Divider(),
              ListTile(
                title: const Text('Afficher toutes les régions'),
                leading: _selectedRegion == null 
                    ? Icon(Icons.check_circle, color: accentColor)
                    : const Icon(Icons.circle_outlined),
                onTap: () {
                  _changeRegion(null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Construit la liste verticale des traiteurs
  Widget _buildVerticalTraiteursList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _traiteursFiltres.length,
      itemBuilder: (context, index) {
        final traiteur = _traiteursFiltres[index];
        final isSelected = widget.selectedTraiteur?.id == traiteur.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PrestaireCard(
            prestataire: traiteur.toMap(),
            isSelected: isSelected,
            onTap: () => _selectTraiteur(traiteur),
            onDetailPressed: () => _openTraiteurDetails(traiteur),
          ),
        );
      },
    );
  }
  
  /// Ouvre la page de détails du traiteur
  void _openTraiteurDetails(TraiteurModel traiteur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestataireDetailScreen(
          type: 'traiteur',
          prestataire: traiteur.toMap(),
          isSelected: widget.selectedTraiteur?.id == traiteur.id,
          onSelect: () => _selectTraiteur(traiteur),
        ),
      ),
    );
  }
  
  /// Sélectionne un traiteur et le communique au parent
  void _selectTraiteur(TraiteurModel traiteur) {
    widget.onTraiteurSelected(traiteur);
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${traiteur.nomEntreprise} sélectionné'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}