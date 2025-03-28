import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Widgets/empty_state.dart';
import '../Bouquet/bouquetQuizScreen.dart';
import '../Bouquet/bouquet_detail_screen.dart';

class BouquetHomeScreen extends StatefulWidget {
  const BouquetHomeScreen({Key? key}) : super(key: key);

  @override
  State<BouquetHomeScreen> createState() => _BouquetHomeScreenState();
}

class _BouquetHomeScreenState extends State<BouquetHomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bouquets = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBouquets();
  }

  Future<void> _loadBouquets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Chargement de tous les bouquets de la base de données...');
      
      // Vérification de la table bouquets
      print('Vérification de la table bouquets...');
      
      // Requête pour récupérer TOUS les bouquets, sans filtrer par user_id
      final response = await Supabase.instance.client
          .from('bouquets')
          .select('*, lieux:lieu_id(*), traiteurs:traiteur_id(*), photographes:photographe_id(*)')
          .order('created_at', ascending: false);

      print('Réponse reçue. Type: ${response.runtimeType}');
      
      // Analyse de la réponse pour le débogage
      if (response is List) {
        print('La réponse est une liste de longueur: ${response.length}');
      } else {
        print('La réponse n\'est PAS une liste: $response');
      }

      if (response != null) {
        // Tenter de convertir en List<Map<String, dynamic>>
        List<Map<String, dynamic>> bouquets = [];
        
        try {
          if (response is List) {
            for (var item in response) {
              if (item is Map) {
                Map<String, dynamic> bouquet = {};
                item.forEach((key, value) {
                  bouquet[key.toString()] = value;
                });
                bouquets.add(bouquet);
                
                // Log des bouquets pour vérifier la structure
                if (bouquets.length <= 3) {
                  print('Bouquet ${bouquets.length}: ${bouquet["name"] ?? "Sans nom"}, ID: ${bouquet["id"]}');
                }
              } else {
                print('ATTENTION: un élément n\'est pas une Map: ${item.runtimeType}');
              }
            }
          } else {
            print('ERREUR: la réponse n\'est pas une liste');
          }
        } catch (conversionError) {
          print('ERREUR lors de la conversion des données: $conversionError');
        }

        print('Total des bouquets récupérés: ${bouquets.length}');
        
        // Mettre à jour l'état avec les bouquets récupérés
        setState(() {
          _bouquets = bouquets;
          _isLoading = false;
        });
      } else {
        print('La réponse est nulle');
        setState(() {
          _bouquets = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('EXCEPTION lors du chargement des bouquets: $e');
      setState(() {
        _errorMessage = 'Erreur lors du chargement des bouquets: $e';
        _isLoading = false;
      });
    }
    
    // Si aucun bouquet n'est trouvé
    if (_bouquets.isEmpty && _errorMessage == null) {
      print('Aucun bouquet trouvé dans la base de données');
      setState(() {
        _errorMessage = 'Aucun bouquet trouvé dans la base de données';
      });
    }
  }
  
  // Méthode pour créer un nouveau bouquet (sans lien avec un utilisateur)
  Future<void> _createNewBouquet() async {
    try {
      print('Création d\'un nouveau bouquet...');
      
      // Créer un bouquet sans spécifier de user_id
      final response = await Supabase.instance.client.from('bouquets').insert({
        'name': 'Nouveau Bouquet ${DateTime.now().millisecondsSinceEpoch}',
        'region': 'Paris',
        'event_date': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
        'guest_count': 100,
        'budget_range': 'medium',
        'style': 'classic',
      }).select();
      
      print('Nouveau bouquet créé: $response');
      
      // Recharger les bouquets
      _loadBouquets();
      
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nouveau bouquet créé avec succès')),
      );
    } catch (e) {
      print('Erreur lors de la création du bouquet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  
  // Option 1: Naviguer vers BouquetQuizScreen (comme demandé initialement)
  void _startNewBouquet() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const BouquetQuizScreen(),
      ),
    ).then((_) => _loadBouquets());
  }
  
  // Méthode pour supprimer un bouquet
  Future<void> _deleteBouquet(String bouquetId) async {
    try {
      // Afficher une boîte de dialogue de confirmation
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Supprimer le bouquet'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce bouquet ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;
      
      if (!confirmDelete) return;
      
      // Supprimer le bouquet de la base de données
      await Supabase.instance.client
          .from('bouquets')
          .delete()
          .eq('id', bouquetId);
      
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bouquet supprimé avec succès')),
      );
      
      // Recharger la liste des bouquets
      _loadBouquets();
    } catch (e) {
      print('Erreur lors de la suppression du bouquet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  void _openBouquetDetails(Map<String, dynamic> bouquet) {
    // Vérifier si le bouquet a un ID valide
    if (bouquet.containsKey('id') && bouquet['id'] != null) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => BouquetSummaryScreen(bouquet: bouquet),
        ),
      ).then((_) => _loadBouquets());
    } else {
      // Si pour une raison quelconque l'ID est manquant, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir ce bouquet: ID manquant'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use theme colors from the app
    final Color accentColor = Theme.of(context).colorScheme.primary; // #524B46
    final Color grisTexte = Theme.of(context).colorScheme.onSurface; // #2B2B2B
    final Color beige = Theme.of(context).colorScheme.secondary; // #FFF3E4
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mes Bouquets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Bouton de rafraîchissement
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBouquets,
            tooltip: 'Rafraîchir la liste',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
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
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBouquets,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          : _bouquets.isEmpty
              ? EmptyState(
                  title: 'Aucun bouquet trouvé',
                  message: 'Aucun bouquet n\'existe dans la base de données. Créez votre premier bouquet.',
                  icon: Icons.celebration_outlined,
                  actionLabel: 'Créer un bouquet',
                  onActionPressed: _startNewBouquet,
                )
              : RefreshIndicator(
                  onRefresh: _loadBouquets,
                  child: CustomScrollView(
                    slivers: [
                      // Header section with description and create button
                      SliverToBoxAdapter(
                        child: Container(
                          color: beige,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vos bouquets de mariage',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: grisTexte,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Retrouvez tous vos projets de mariage en un seul endroit',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: grisTexte.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Bouton Créer déplacé ici
                              Center(
                                child: ElevatedButton.icon(
                              
                                  label: const Text(
                                    'Créer un nouveau bouquet', 
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: _startNewBouquet,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    minimumSize: const Size(200, 50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // List of bouquets
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final bouquet = _bouquets[index];
                              return _buildBouquetCard(bouquet);
                            },
                            childCount: _bouquets.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBouquetCard(Map<String, dynamic> bouquet) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color grisTexte = Theme.of(context).colorScheme.onSurface;
    
    // Extract information from bouquet
    final String bouquetId = bouquet['id'] ?? '';
    final String name = bouquet['name'] ?? 'Mon bouquet';
    final String date = bouquet['event_date'] != null 
        ? _formatDate(DateTime.parse(bouquet['event_date'])) 
        : 'Date non définie';
    
    // Calculate total prestataires selected
    final int totalSelectedPrestataires = [
      bouquet['lieu_id'] != null,
      bouquet['traiteur_id'] != null,
      bouquet['photographe_id'] != null,
    ].where((isSelected) => isSelected).length;
    
    // Get images from related entities
    String? imageUrl;
    
    // Prioritize venue image
    if (bouquet['lieux'] != null) {
      // Check if lieux has image_url directly
      if (bouquet['lieux']['image_url'] != null) {
        imageUrl = bouquet['lieux']['image_url'];
      }
    }
    
    // Fallback to photographer image
    if (imageUrl == null && bouquet['photographes'] != null && bouquet['photographes']['image_url'] != null) {
      imageUrl = bouquet['photographes']['image_url'];
    }
    
    // Fallback to caterer image
    if (imageUrl == null && bouquet['traiteurs'] !=null && bouquet['traiteurs']['image_url'] != null) {
      imageUrl = bouquet['traiteurs']['image_url'];
    }
    
    // Use default image if no image found
    final String defaultImage = 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=2940&auto=format&fit=crop';
    
    return Dismissible(
      key: Key(bouquetId),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer le bouquet'),
            content: const Text('Êtes-vous sûr de vouloir supprimer ce bouquet ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteBouquet(bouquetId);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: InkWell(
          onTap: () => _openBouquetDetails(bouquet),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with progress overlay
              Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imageUrl ?? defaultImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Erreur de chargement d\'image: $error');
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 40),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Progress indicator overlay (only if not complete)
                  if (totalSelectedPrestataires < 3)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalSelectedPrestataires/3',
                              style: const TextStyle(
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
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: grisTexte.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Service icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildServiceIndicator(
                          icon: Icons.location_on,
                          label: 'Lieu',
                          isSelected: bouquet['lieu_id'] != null,
                        ),
                        const SizedBox(width: 12),
                        _buildServiceIndicator(
                          icon: Icons.restaurant,
                          label: 'Traiteur',
                          isSelected: bouquet['traiteur_id'] != null,
                        ),
                        const SizedBox(width: 12),
                        _buildServiceIndicator(
                          icon: Icons.camera_alt,
                          label: 'Photo',
                          isSelected: bouquet['photographe_id'] != null,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Actions buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bouton Voir détails
                        TextButton.icon(
                          onPressed: () => _openBouquetDetails(bouquet),
                          icon: const Icon(Icons.visibility),
                          label: const Text('Voir'),
                          style: TextButton.styleFrom(
                            foregroundColor: accentColor,
                          ),
                        ),
                        // Bouton Supprimer
                        TextButton.icon(
                          onPressed: () => _deleteBouquet(bouquetId),
                          icon: const Icon(Icons.delete),
                          label: const Text('Supprimer'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
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
      ),
    );
  }

  Widget _buildServiceIndicator({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? accentColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    // Return day/month/year format
    return '${date.day}/${date.month}/${date.year}';
  }
}