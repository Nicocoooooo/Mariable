import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Widgets/empty_state.dart';
import 'bouquetQuizScreen.dart';
import 'bouquet_detail_screen.dart';

class BouquetHomeScreen extends StatefulWidget {
  final bool forceRefresh;
  
  const BouquetHomeScreen({
    Key? key, 
    this.forceRefresh = false,
  }) : super(key: key);

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
      // Get current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      if (userId == null) {
        setState(() {
          _bouquets = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch bouquets from Supabase
      final response = await Supabase.instance.client
          .from('bouquets')
          .select('*, lieux:lieu_id(*), traiteurs:traiteur_id(*), photographes:photographe_id(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response != null) {
        // Convert to List<Map<String, dynamic>>
        List<Map<String, dynamic>> bouquets = [];
        for (var item in response) {
          if (item is Map) {
            Map<String, dynamic> bouquet = {};
            item.forEach((key, value) {
              bouquet[key.toString()] = value;
            });
            bouquets.add(bouquet);
          }
        }

        setState(() {
          _bouquets = bouquets;
          _isLoading = false;
        });
      } else {
        setState(() {
          _bouquets = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des bouquets: $e';
        _isLoading = false;
      });
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
                  message: 'Créez votre premier bouquet pour organiser votre mariage facilement',
                  icon: Icons.celebration_outlined,
                  actionLabel: 'Créer mon premier bouquet',
                  onActionPressed: _startNewBouquet,
                )
              : RefreshIndicator(
                  onRefresh: _loadBouquets,
                  child: CustomScrollView(
                    slivers: [
                      // Header section with description
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewBouquet,
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau bouquet'),
      ),
    );
  }

  Widget _buildBouquetCard(Map<String, dynamic> bouquet) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color grisTexte = Theme.of(context).colorScheme.onSurface;
    
    // Extract information from bouquet
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
    
    // Get image from related entities
    String? imageUrl;
    
    // Prioritize venue image
    if (bouquet['lieux'] != null) {
      // Check if lieux has image_url directly
      if (bouquet['lieux']['image_url'] != null) {
        imageUrl = bouquet['lieux']['image_url'];
      }
      // Check if lieux contains a nested structure
      else if (bouquet['lieux']['lieux'] is List && 
               bouquet['lieux']['lieux'].isNotEmpty && 
               bouquet['lieux']['lieux'][0]['image_url'] != null) {
        imageUrl = bouquet['lieux']['lieux'][0]['image_url'];
      }
    }
    
    // Fallback to photographer image
    if (imageUrl == null && bouquet['photographes'] != null && bouquet['photographes']['image_url'] != null) {
      imageUrl = bouquet['photographes']['image_url'];
    }
    
    // Fallback to caterer image
    if (imageUrl == null && bouquet['traiteurs'] != null && bouquet['traiteurs']['image_url'] != null) {
      imageUrl = bouquet['traiteurs']['image_url'];
    }
    
    // Use default image if no image found
    final String defaultImage = 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=2940&auto=format&fit=crop';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  
                  // View details button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _openBouquetDetails(bouquet),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Voir les détails'),
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
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

  void _startNewBouquet() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const BouquetQuizScreen(),
      ),
    ).then((_) => _loadBouquets());
  }

  void _openBouquetDetails(Map<String, dynamic> bouquet) {
    // Vérifier si le bouquet a un ID valide
    if (bouquet.containsKey('id') && bouquet['id'] != null) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => BouquetSummaryScreen(bouquetId: bouquet['id']),
        ),
      ).then((_) => _loadBouquets());
    } else {
      // Si pour une raison quelconque l'ID est manquant, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir ce bouquet'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}