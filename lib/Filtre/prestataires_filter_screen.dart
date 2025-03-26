import 'package:flutter/material.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../widgets/empty_state.dart';
import 'lieu_types_screen.dart';
import 'traiteur_types_screen.dart';

class PrestatairesFilterScreen extends StatefulWidget {
  const PrestatairesFilterScreen({Key? key}) : super(key: key);

  @override
  State<PrestatairesFilterScreen> createState() => _PrestatairesFilterScreenState();
}

class _PrestatairesFilterScreenState extends State<PrestatairesFilterScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final PrestaRepository _repository = PrestaRepository();
  
  List<Map<String, dynamic>> _prestaTypes = [];
  List<Map<String, dynamic>> _filteredPrestaTypes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Pour les animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchPrestaTypes();
    _searchController.addListener(_filterPrestaTypes);
    
    // Initialiser l'animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPrestaTypes);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterPrestaTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPrestaTypes = List.from(_prestaTypes);
      } else {
        _filteredPrestaTypes = _prestaTypes
            .where((type) => type['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _fetchPrestaTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

<<<<<<< HEAD
Future<void> _fetchPrestaTypes() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // Utilisez la méthode existante si elle existe
    List<Map<String, dynamic>> typesData = [];
    
    try {
      // Utilisez le repository au lieu d'accéder directement à Supabase
      typesData = await _repository.getPrestaTypesAsMap();
    } catch (innerError) {
      // Utiliser des données factices si la requête échoue
      typesData = [
        {'id': 1, 'name': 'Lieu', 'description': 'Lieux pour votre mariage'},
        {'id': 2, 'name': 'Traiteur', 'description': 'Services de restauration'},
        {'id': 3, 'name': 'Photographe', 'description': 'Capture de vos souvenirs'},
        {'id': 4, 'name': 'Wedding Planner', 'description': 'Organisation complète de votre mariage'},
      ];
    }
    
    setState(() {
      _prestaTypes = typesData;
      _filteredPrestaTypes = List.from(_prestaTypes);
      _isLoading = false;
    });
  } catch (e) {
    // Gestion d'erreur...
=======
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prestaTypes = await _repository.getPrestaTypes();
      
      if (prestaTypes.isEmpty) {
        print('No prestataire types found, using default values');

        final defaultTypes = [
          PrestaTypeModel(id: 1, name: 'Lieu', description: 'Du château romantique à la plage paradisiaque, trouvez le cadre parfait pour votre mariage.'),
          PrestaTypeModel(id: 2, name: 'Traiteur', description: 'Des mets raffinés servis avec élégance pour enchanter vos invités et créer un moment de partage inoubliable.'),
          PrestaTypeModel(id: 3, name: 'Photographe', description: 'L\'artiste qui immortalisera vos précieux souvenirs pour revivre éternellement votre plus beau jour.'),
          PrestaTypeModel(id: 4, name: 'Wedding Planner', description: 'L\'organisateur qui s\'occupera de tous les détails pour que vous profitiez pleinement de votre journée.'),
        ];
        
        final prestaTypesMapList = defaultTypes.map((type) => type.toMap()).toList();
        
        setState(() {
          _prestaTypes = prestaTypesMapList;
          _filteredPrestaTypes = List.from(_prestaTypes);
          _isLoading = false;
        });
        return;
      }
      
      final prestaTypesMapList = prestaTypes.map((type) => type.toMap()).toList();

      setState(() {
        _prestaTypes = prestaTypesMapList;
        _filteredPrestaTypes = List.from(_prestaTypes);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching prestataire types: $e');
      
      setState(() {
        _errorMessage = 'Erreur lors du chargement des types de prestataires: ${e.toString()}';
        _isLoading = false;
        
        // Données par défaut avec images et descriptions
        _prestaTypes = [
          {
            'id': 1, 
            'name': 'Lieu', 
            'description': 'Du château romantique à la plage paradisiaque, trouvez le cadre parfait pour votre mariage.', 
            'imageUrl': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop'
          },
          {
            'id': 2, 
            'name': 'Traiteur', 
            'description': 'Des mets raffinés servis avec élégance pour enchanter vos invités et créer un moment de partage inoubliable.', 
            'imageUrl': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?q=80&w=2874&auto=format&fit=crop'
          },
          {
            'id': 3, 
            'name': 'Photographe', 
            'description': 'L\'artiste qui immortalisera vos précieux souvenirs pour revivre éternellement votre plus beau jour.', 
            'imageUrl': 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?q=80&w=2940&auto=format&fit=crop'
          },
          {
            'id': 4, 
            'name': 'Wedding Planner', 
            'description': 'L\'organisateur qui s\'occupera de tous les détails pour que vous profitiez pleinement de votre journée.', 
            'imageUrl': 'https://images.unsplash.com/photo-1501139083538-0139583c060f?q=80&w=2940&auto=format&fit=crop'
          },
        ];
        _filteredPrestaTypes = List.from(_prestaTypes);
      });
    }
>>>>>>> feature/prestataires
  }


  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color grisTexte = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Types de prestataires'),
        backgroundColor: const Color(0xFF524B46),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière en haut (style The Collectionist)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            color: const Color(0xFF524B46),
            width: double.infinity,
            child: const Text(
              'Nos prestataires pour votre mariage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Zone de recherche améliorée
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un type de prestataire',
                hintStyle: TextStyle(color: grisTexte.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: accentColor),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          // Contenu principal
          Expanded(
            child: _isLoading 
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
                    : _filteredPrestaTypes.isEmpty
                        ? EmptyState(
                            title: 'Aucun type de prestataire trouvé',
                            message: 'Essayez de modifier votre recherche.',
                            icon: Icons.search_off,
                            actionLabel: 'Réinitialiser',
                            onActionPressed: () {
                              _searchController.clear();
                              _filterPrestaTypes();
                            },
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.builder(
                                itemCount: _filteredPrestaTypes.length,
                                itemBuilder: (context, index) {
                                  final prestaType = _filteredPrestaTypes[index];
                                  // Utiliser la nouvelle méthode de carte ici
                                  return _buildPrestaTypeCardNew(prestaType);
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrestaTypeCardNew(Map<String, dynamic> prestaType) {
    // Obtenir l'URL de l'image (de l'objet ou par défaut)
    final String imageUrl = prestaType['imageUrl'] ?? 
                            'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _handlePrestaTypeSelection(prestaType),
        child: Stack(
          children: [
            // Image d'arrière-plan
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),
            ),
            
            // Dégradé pour la lisibilité du texte
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Contenu texte
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prestaType['name'] ?? 'Sans nom',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prestaType['description'] ?? 'Aucune description',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Icône flèche pour indiquer l'action
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Color(0xFF524B46),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
// Dans PrestatairesFilterScreen.dart
Future<void> _handlePrestaTypeSelection(Map<String, dynamic> prestaType) async {
  // Get the name of the prestataire type
  final String typeName = prestaType['name'].toString().toLowerCase();
  final int? typeId = prestaType['id'];
  
  // Ajoutez un print pour déboguer
  print('Selected prestaType: $typeName with ID: $typeId');
  
  // Handle different types of prestataires
  switch (typeName) {
    case 'lieu':
      // Show lieu types screen
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return const LieuTypesScreen();
          },
        ),
      );
      
      if (result != null) {
        // Return both presta type and lieu type
        Navigator.pop(context, {
          'prestaType': prestaType,
          'subType': result,
        });
      }
      break;
      
    case 'traiteur':
      // Show traiteur types screen
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return const TraiteurTypesScreen();
          },
        ),
      );
      
      if (result != null) {
        // Return both presta type and traiteur type
        Navigator.pop(context, {
          'prestaType': prestaType,
          'subType': result,
        });
      }
      break;
      
    case 'photographe':
    case 'wedding planner':
      // For now, just return the selected prestataire type
      Navigator.pop(context, prestaType);
      break;
      
    default:
      // For all other types, just return the selected type
      Navigator.pop(context, prestaType);
      break;
=======

  // Méthode de sélection
  Future<void> _handlePrestaTypeSelection(Map<String, dynamic> prestaType) async {
    final String typeName = prestaType['name'].toString().toLowerCase();
    
    switch (typeName) {
      case 'lieu':
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return const LieuTypesScreen();
            },
          ),
        );
        
        if (result != null) {
          Navigator.pop(context, {
            'prestaType': prestaType,
            'subType': result,
          });
        }
        break;
        
      case 'photographe':
      case 'traiteur':
      case 'wedding planner':
        Navigator.pop(context, prestaType);
        break;
        
      default:
        Navigator.pop(context, prestaType);
        break;
    }
>>>>>>> feature/prestataires
  }
}
}