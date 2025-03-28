import 'package:flutter/material.dart';
import '../data/bouquet_model.dart';
import '../data/quiz_model.dart';
import '../data/presta_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/prestataireCard.dart';
import '../widgets/details.dart';

/// Écran de sélection du photographe pour le bouquet avec filtrage par région
class ChoixPhotographeScreen extends StatefulWidget {
  final Function(PhotographeModel) onPhotographeSelected;
  final PhotographeModel? selectedPhotographe;
  final QuizResults? quizResults;

  const ChoixPhotographeScreen({
    Key? key,
    required this.onPhotographeSelected,
    this.selectedPhotographe,
    this.quizResults,
  }) : super(key: key);

  @override
  State<ChoixPhotographeScreen> createState() => _ChoixPhotographeScreenState();
}

class _ChoixPhotographeScreenState extends State<ChoixPhotographeScreen> {
  final PrestaRepository _repository = PrestaRepository();
  List<PhotographeModel> _photographes = [];
  List<PhotographeModel> _photographesFiltres = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Filtre par région sélectionnée dans le quiz
  String? _selectedRegion;
  
  // Filtre par style de photographie
  String? _selectedStyle;

  @override
  void initState() {
    super.initState();
    
    // Récupérer la région et le style depuis les résultats du quiz
    if (widget.quizResults != null) {
      if (widget.quizResults!.answers.containsKey('region')) {
        _selectedRegion = widget.quizResults!.answers['region'] as String?;
      }
      
      if (widget.quizResults!.answers.containsKey('photo_preferences')) {
        _selectedStyle = widget.quizResults!.answers['photo_preferences'] as String?;
      }
    }
    
    _loadPhotographes();
  }

  /// Charge la liste des photographes depuis le repository
  Future<void> _loadPhotographes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Récupérer les photographes depuis la base de données
      try {
        final photographesData = await _repository.getPrestairesByType(3);
        final photographes = photographesData.map((data) => PhotographeModel.fromMap(data)).toList();
        
        setState(() {
          _photographes = photographes;
          _filterPhotographes();
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur lors du chargement des photographes: $e');
        // En cas d'erreur, utiliser des données fictives
        _loadMockPhotographes();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des photographes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  /// Filtre les photographes selon la région et le style sélectionnés
  void _filterPhotographes() {
    List<PhotographeModel> photographesFiltres = _photographes;
    
    // Filtre par région
    if (_selectedRegion != null && _selectedRegion!.isNotEmpty) {
      photographesFiltres = photographesFiltres.where((photographe) {
        return photographe.region.toLowerCase() == _selectedRegion!.toLowerCase();
      }).toList();
    }
    
    // Filtre par style (si un style est sélectionné)
    if (_selectedStyle != null && _selectedStyle!.isNotEmpty) {
      photographesFiltres = photographesFiltres.where((photographe) {
      // Vérifier si l'un des styles du photographe correspond au style sélectionné
      // Si style est null, la méthode any ne sera pas appelée et false sera retourné
        return photographe.style?.any((style) => style.toLowerCase().contains(_selectedStyle!.toLowerCase())) ?? false; // Retourne false si photographe.style est null
      }).toList();
    }
    
    setState(() {
      _photographesFiltres = photographesFiltres;
    });
  }
  
  /// Change la région de filtre
  void _changeRegion(String? region) {
    setState(() {
      _selectedRegion = region;
      _filterPhotographes();
    });
  }
  
  /// Charge des données fictives en attendant l'API
  void _loadMockPhotographes() {
    final List<Map<String, dynamic>> mockData = [];
    
    // Générer des photographes fictifs
    final regions = [
      'Île-de-France', 'Provence-Alpes-Côte d\'Azur', 'Auvergne-Rhône-Alpes', 
      'Occitanie', 'Nouvelle-Aquitaine', 'Bretagne', 'Normandie', 
      'Hauts-de-France', 'Grand Est', 'Pays de la Loire'
    ];
    
    final stylesPhoto = [
      'reportage', 'artistique', 'traditionnel', 'journalistique', 'contemporain', 'vintage'
    ];
    
    for (int i = 1; i <= 30; i++) {
      final regionIndex = i % regions.length;
      final String region = regions[regionIndex];
      
      // Générer 1-2 styles pour chaque photographe
      final List<String> styles = [];
      styles.add(stylesPhoto[i % stylesPhoto.length]);
      if (i % 2 == 0) {
        styles.add(stylesPhoto[(i + 3) % stylesPhoto.length]);
      }
      
      // Caractéristiques du photographe
      final bool hasDrone = i % 3 == 0;
      final Map<String, dynamic> optionsDuree = {
        'demi_journee': {
          'prix': 800 + (i * 50),
          'description': 'Couverture de la cérémonie et des premiers moments de la réception',
        },
        'journee': {
          'prix': 1200 + (i * 80),
          'description': 'Couverture de la préparation jusqu\'au début de soirée',
        },
        'journee_complete': {
          'prix': 1500 + (i * 100),
          'description': 'Couverture complète de la préparation jusqu\'à la fin de soirée',
        },
      };
      
      mockData.add({
        'id': i.toString(),
        'nom_entreprise': 'Studio ${_getRandomName(i)}',
        'description': 'Photographe spécialisé dans le style ${styles.join(", ")}. Capturez les plus beaux moments de votre mariage.',
        'photo_url': null,
        'prix_base': 800.0 + (i * 100),
        'note_moyenne': 3.5 + (i % 5) * 0.3,
        'region': region,
        'adresse': 'Adresse fictive en $region',
        'style': styles,
        'options_duree': optionsDuree,
        'drone': hasDrone,
      });
    }
    
    setState(() {
      _photographes = mockData.map((data) => PhotographeModel.fromMap(data)).toList();
      _filterPhotographes();
      _isLoading = false;
    });
  }
  
  /// Génère un nom aléatoire pour les données fictives
  String _getRandomName(int seed) {
    final names = [
      'Lumière', 'Vision', 'Capture', 'Objectif', 'Clic', 
      'Image', 'Cadre', 'Moment', 'Pixel', 'Focus'
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
                'Choisissez votre photographe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              // Filtre par région
              const SizedBox(height: 16),
              _buildRegionFilter(context),
            ],
          ),
        ),
        
        // Indication de sélection
        if (widget.selectedPhotographe != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Photographe sélectionné: ${widget.selectedPhotographe!.nomEntreprise}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Contenu principal - Liste verticale de photographes
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
              : _photographesFiltres.isEmpty
                ? EmptyState(
                    title: 'Aucun photographe disponible',
                    message: _selectedRegion != null 
                        ? 'Aucun photographe trouvé dans la région $_selectedRegion' 
                        : 'Aucun photographe disponible actuellement',
                    icon: Icons.camera_alt_outlined,
                    actionLabel: 'Modifier la région',
                    onActionPressed: () => _showRegionSelector(context),
                  )
                : _buildVerticalPhotographesList(),
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
                  _filterPhotographes();
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
  
  /// Construit la liste verticale des photographes
  Widget _buildVerticalPhotographesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _photographesFiltres.length,
      itemBuilder: (context, index) {
        final photographe = _photographesFiltres[index];
        final isSelected = widget.selectedPhotographe?.id == photographe.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BouquetPrestaireCard(
            prestataire: _createDetailedMap(photographe),
            isSelected: isSelected,
            onTap: () => _selectPhotographe(photographe),
            onDetailPressed: () => _openPhotographeDetails(photographe),
          ),
        );
      },
    );
  }
  
  /// Crée une Map détaillée avec toutes les propriétés nécessaires pour l'affichage des détails
  Map<String, dynamic> _createDetailedMap(PhotographeModel photographe) {
    // Commencer avec les données de base
    final Map<String, dynamic> detailedMap = photographe.toMap();
    
    // S'assurer que les champs spécifiques au photographe sont présents
    if (!detailedMap.containsKey('style') || detailedMap['style'] == null) {
      detailedMap['style'] = photographe.style;
    }
    if (!detailedMap.containsKey('options_duree') || detailedMap['options_duree'] == null) {
      detailedMap['options_duree'] = photographe.optionsDuree;
    }
    if (!detailedMap.containsKey('drone') || detailedMap['drone'] == null) {
      detailedMap['drone'] = photographe.drone;
    }
    
    return detailedMap;
  }
  
  /// Ouvre la page de détails du photographe
  void _openPhotographeDetails(PhotographeModel photographe) {
    // Créer une Map détaillée avec toutes les propriétés nécessaires
    final Map<String, dynamic> detailedMap = _createDetailedMap(photographe);
    
    // Afficher les données pour le débogage
    print('Données envoyées à PrestataireDetailScreen:');
    detailedMap.forEach((key, value) {
      print('$key: $value (${value?.runtimeType})');
    });
    
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BouquetPrestataireDetailScreen(
      type: 'photographe',
      prestataire: detailedMap,
      isSelected: widget.selectedPhotographe?.id == photographe.id,
      onSelect: () => _selectPhotographe(photographe),
    ),
  ),
);
  }
  
  /// Sélectionne un photographe et le communique au parent
  void _selectPhotographe(PhotographeModel photographe) {
    widget.onPhotographeSelected(photographe);
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${photographe.nomEntreprise} sélectionné'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}