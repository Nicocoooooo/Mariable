import 'package:flutter/material.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../data/presta_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/prestataireCard.dart';
import '../widgets/details.dart';

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
  List<LieuModel> _lieux = [];
  List<LieuModel> _lieuxFiltres = [];
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
    
    _loadLieux();
  }

  /// Charge la liste des lieux depuis le repository
  Future<void> _loadLieux() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Récupérer les lieux depuis la base de données via le repository
      try {
        final lieuxData = await _repository.getPrestairesByType(1);
        final lieux = lieuxData.map((data) => LieuModel.fromMap(data)).toList();
        
        setState(() {
          _lieux = lieux;
          _filterLieux();
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur lors du chargement des lieux: $e');
        // En cas d'erreur, utiliser des données fictives
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
      // Filtrer les lieux par région
      _lieuxFiltres = _lieux.where((lieu) {
        // Vérifier si la région du lieu correspond à la région sélectionnée (insensible à la casse)
        return lieu.region.toLowerCase() == _selectedRegion!.toLowerCase();
      }).toList();
    }
    
    setState(() {});
  }
  
  /// Change la région de filtre
  void _changeRegion(String? region) {
    setState(() {
      _selectedRegion = region;
      _filterLieux();
    });
  }
  
  /// Charge des données fictives en attendant l'API
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
      
      // Caractéristiques du lieu
      final bool hasHebergement = i % 2 == 0;
      final bool hasEspaceExterieur = i % 3 != 0;
      final bool hasPiscine = i % 5 == 0;
      final int capacite = 50 + (i * 20);
      
      // Description des salles
      final Map<String, dynamic> descriptionSalles = {
        'salle_reception': {
          'capacite': capacite,
          'description': 'Salle principale avec vue panoramique',
        },
        'salle_cocktail': {
          'capacite': capacite / 2,
          'description': 'Espace convivial pour cocktail et vin d\'honneur',
        },
      };
      
      mockData.add({
        'id': i.toString(),
        'nom_entreprise': '$typeLieu ${_getRandomName(i)}',
        'description': 'Magnifique $typeLieu situé en $region. Cadre exceptionnel pour votre mariage avec une capacité jusqu\'à $capacite personnes.',
        'photo_url': null,
        'prix_base': 2000.0 + (i * 500),
        'note_moyenne': 3.5 + (i % 5) * 0.3,
        'region': region,
        'adresse': 'Adresse fictive en $region',
        'type_lieu': typeLieu,
        'description_salles': descriptionSalles,
        'capacite_max': capacite,
        'espace_exterieur': hasEspaceExterieur,
        'piscine': hasPiscine,
        'parking': true,
        'hebergement': hasHebergement,
        'capacite_hebergement': hasHebergement ? 20 + (i * 4) : 0,
      });
    }
    
    setState(() {
      _lieux = mockData.map((data) => LieuModel.fromMap(data)).toList();
      _filterLieux();
      _isLoading = false;
    });
  }
  
  /// Génère un nom aléatoire pour les données fictives
  String _getRandomName(int seed) {
    final names = [
      'Royal', 'Élégance', 'Belle Vue', 'Grand Siècle', 'Prestige', 
      'Paradis', 'Émeraude', 'Romantique', 'Charme', 'Sérénité'
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
                'Choisissez votre lieu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              // Filtre par région
              const SizedBox(height: 16),
              _buildRegionFilter(context),
            ],
          ),
        ),
        
        // Indication de sélection
        if (widget.selectedLieu != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Lieu sélectionné: ${widget.selectedLieu!.nomEntreprise}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Contenu principal - Liste verticale de lieux
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
                : _buildVerticalLieuxList(),
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
                  _filterLieux();
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
  
  /// Construit la liste verticale des lieux
  Widget _buildVerticalLieuxList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _lieuxFiltres.length,
      itemBuilder: (context, index) {
        final lieu = _lieuxFiltres[index];
        final isSelected = widget.selectedLieu?.id == lieu.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PrestaireCard(
            prestataire: lieu.toMap(),
            isSelected: isSelected,
            onTap: () => _selectLieu(lieu),
            onDetailPressed: () => _openLieuDetails(lieu),
          ),
        );
      },
    );
  }
  
  /// Ouvre la page de détails du lieu
  void _openLieuDetails(LieuModel lieu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestataireDetailScreen(
          type: 'lieu',
          prestataire: lieu.toMap(),
          isSelected: widget.selectedLieu?.id == lieu.id,
          onSelect: () => _selectLieu(lieu),
        ),
      ),
    );
  }
  
  /// Sélectionne un lieu et le communique au parent
  void _selectLieu(LieuModel lieu) {
    widget.onLieuSelected(lieu);
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lieu.nomEntreprise} sélectionné'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}