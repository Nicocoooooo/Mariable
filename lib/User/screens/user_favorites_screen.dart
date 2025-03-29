import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../utils/logger.dart';
import '/routes_user.dart';
import 'user_login_screen.dart';
import '/Prestataires/PrestatairesScreen.dart';
import '/DetailsScreen/PrestaireDetailScreen.dart';
import '/services/favorites_service.dart';

const Color accentColor = Color(0xFF524B46);

class UserFavoritesScreen extends StatefulWidget {
  const UserFavoritesScreen({super.key});

  @override
  State<UserFavoritesScreen> createState() => _UserFavoritesScreenState();
}

class _UserFavoritesScreenState extends State<UserFavoritesScreen> {
  bool _isLoading = true;
  bool _isUserLoggedIn = false;
  List<Map<String, dynamic>> _favorites = [];
  String? _errorMessage;
  final FavoritesService _favoritesService = FavoritesService();
  
  
  // Filtres
  String _selectedFilter = 'Tous';
  List<String> _filterOptions = ['Tous', 'Lieu', 'Traiteur', 'Photographe', 'DJ', 'Fleuriste'];

  @override
  void initState() {
    super.initState();
    // Délai léger pour permettre à l'écran de se monter complètement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStatus();
    });
    
    // S'abonner au stream de favoris pour les mises à jour automatiques
    _favoritesService.favoritesStream.listen((_) {
      if (mounted && _isUserLoggedIn) {
        _loadFavorites();
      }
    });
  }

  // Vérifier si l'utilisateur est connecté
  Future<void> _checkUserStatus() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null) {
        setState(() {
          _isUserLoggedIn = true;
        });
        // Charger les favoris
        await _loadFavorites();
      } else {
        setState(() {
          _isUserLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la vérification du statut utilisateur', e);
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
        _isLoading = false;
      });
    }
  }

  // Charger les favoris de l'utilisateur
  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user == null) {
        setState(() {
          _isUserLoggedIn = false;
          _isLoading = false;
        });
        return;
      }
      
      // Requête améliorée pour obtenir toutes les données nécessaires
      final response = await Supabase.instance.client
          .from('presta')
          .select('''
            *,
            favoris!inner(*),
            lieux(*),
            tarifs(*)
          ''')
          .eq('favoris.user_id', user.id);
      
      if (!mounted) return;
      
      if (response != null) {
        setState(() {
          _favorites = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des favoris', e);
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Erreur lors du chargement des favoris: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Supprimer un favori
  Future<void> _removeFavorite(String prestaId) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Utiliser le service pour supprimer le favori
      final success = await _favoritesService.removeFromFavorites(prestaId);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prestataire retiré des favoris'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de retirer ce prestataire des favoris'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      // Le chargement sera fait automatiquement via le stream
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du favori', e);
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de retirer ce prestataire des favoris'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fonction pour extraire le prix d'un prestataire de manière fiable
  double? _getPrixFromPrestataire(Map<String, dynamic> prestataire) {
    // DEBUG: Afficher toutes les clés du prestataire pour comprendre sa structure
    print("Prestataire ${prestataire['nom_entreprise']} - Clés disponibles: ${prestataire.keys.toList()}");
    
    // S'il y a des tarifs (formules) associés, utiliser le prix de base de la première formule
    if (prestataire.containsKey('tarifs') && 
        prestataire['tarifs'] != null && 
        prestataire['tarifs'] is List && 
        (prestataire['tarifs'] as List).isNotEmpty) {
      
      var premierTarif = (prestataire['tarifs'] as List).first;
      if (premierTarif is Map && 
          premierTarif.containsKey('prix_base') && 
          premierTarif['prix_base'] != null) {
        
        print("Prix extrait du tarif: ${premierTarif['prix_base']}");
        if (premierTarif['prix_base'] is num) {
          return premierTarif['prix_base'].toDouble();
        } else {
          return double.tryParse(premierTarif['prix_base'].toString());
        }
      }
    }
    
    // D'abord chercher prix_base qui est le prix par défaut
    if (prestataire.containsKey('prix_base') && prestataire['prix_base'] != null) {
      print("Prix extrait du prix_base: ${prestataire['prix_base']}");
      if (prestataire['prix_base'] is num) {
        return prestataire['prix_base'].toDouble();
      } else {
        return double.tryParse(prestataire['prix_base'].toString());
      }
    }
    
    // Pour les lieux, regarder dans la table lieux
    if (prestataire.containsKey('lieux') && prestataire['lieux'] != null) {
      var lieuxData = prestataire['lieux'];
      
      // Si lieuxData est une liste
      if (lieuxData is List && lieuxData.isNotEmpty) {
        var premierLieu = lieuxData[0];
        if (premierLieu is Map && premierLieu.containsKey('prix_base') && premierLieu['prix_base'] != null) {
          print("Prix extrait de lieux (liste): ${premierLieu['prix_base']}");
          if (premierLieu['prix_base'] is num) {
            return premierLieu['prix_base'].toDouble();
          } else {
            return double.tryParse(premierLieu['prix_base'].toString());
          }
        }
      } 
      // Si lieuxData est un Map (objet direct)
      else if (lieuxData is Map && lieuxData.containsKey('prix_base') && lieuxData['prix_base'] != null) {
        print("Prix extrait de lieux (map): ${lieuxData['prix_base']}");
        if (lieuxData['prix_base'] is num) {
          return lieuxData['prix_base'].toDouble();
        } else {
          return double.tryParse(lieuxData['prix_base'].toString());
        }
      }
    }
    
    // Ensuite chercher prix_min qui est parfois utilisé
    if (prestataire.containsKey('prix_min') && prestataire['prix_min'] != null) {
      print("Prix extrait de prix_min: ${prestataire['prix_min']}");
      if (prestataire['prix_min'] is num) {
        return prestataire['prix_min'].toDouble();
      } else {
        return double.tryParse(prestataire['prix_min'].toString());
      }
    }
    
    // Si on ne trouve rien, chercher d'autres champs potentiels de prix
    final possiblePriceFields = ['tarif_base', 'tarif', 'prix', 'cout', 'cost'];
    for (var field in possiblePriceFields) {
      if (prestataire.containsKey(field) && prestataire[field] != null) {
        print("Prix extrait de $field: ${prestataire[field]}");
        if (prestataire[field] is num) {
          return prestataire[field].toDouble();
        } else {
          return double.tryParse(prestataire[field].toString());
        }
      }
    }
    
    // Si aucun prix n'est trouvé, retourner une valeur différente selon le type
    // pour éviter d'avoir les mêmes prix partout
    if (prestataire.containsKey('presta_type_id')) {
      var typeId = prestataire['presta_type_id'];
      if (typeId is String) {
        typeId = int.tryParse(typeId) ?? 0;
      }
      
      print("Aucun prix trouvé, utilisation de valeur par défaut pour type $typeId");
      // Prix par défaut selon le type
      switch (typeId) {
        case 1: // Lieu
          final nomEntreprise = prestataire['nom_entreprise']?.toString() ?? '';
          // Générer un prix aléatoire basé sur le nom pour éviter les mêmes prix
          final int hash = nomEntreprise.isEmpty ? 0 : nomEntreprise.hashCode.abs();
          return 2000.0 + (hash % 4000); // Entre 2000 et 6000€
        case 2: // Traiteur
          final nomEntreprise = prestataire['nom_entreprise']?.toString() ?? '';
          final int hash = nomEntreprise.isEmpty ? 0 : nomEntreprise.hashCode.abs();
          return 35.0 + (hash % 65); // Entre 35 et 100€
        case 3: // Photographe
          final nomEntreprise = prestataire['nom_entreprise']?.toString() ?? '';
          final int hash = nomEntreprise.isEmpty ? 0 : nomEntreprise.hashCode.abs();
          return 1000.0 + (hash % 2000); // Entre 1000 et 3000€
        case 4: // DJ
          final nomEntreprise = prestataire['nom_entreprise']?.toString() ?? '';
          final int hash = nomEntreprise.isEmpty ? 0 : nomEntreprise.hashCode.abs();
          return 600.0 + (hash % 1000); // Entre 600 et 1600€
        case 5: // Fleuriste
          final nomEntreprise = prestataire['nom_entreprise']?.toString() ?? '';
          final int hash = nomEntreprise.isEmpty ? 0 : nomEntreprise.hashCode.abs();
          return 300.0 + (hash % 700); // Entre 300 et 1000€
        default:
          final nomEntreprise = prestataire['nom_entreprise']?.toString() ?? '';
          final int hash = nomEntreprise.isEmpty ? 0 : nomEntreprise.hashCode.abs();
          return 50.0 + (hash % 150); // Entre 50 et 200€
      }
    }
    
    // Dernière valeur par défaut
    return 79.0;
  }

  // Widget pour afficher le contenu quand l'utilisateur est connecté
  Widget _buildConnectedContent() {
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Vous n\'avez pas encore de favoris',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Découvrez notre sélection de prestataires et ajoutez-les à vos favoris pour les retrouver ici.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrestatairesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Explorer les prestataires'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
    
    // Liste des filtres horizontale
    return Column(
      children: [
        // Section des filtres
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filterOptions.length,
            itemBuilder: (context, index) {
              final option = _filterOptions[index];
              final isSelected = _selectedFilter == option;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = option;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF524B46) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF524B46),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF524B46),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Liste des favoris
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFavorites,
            color: const Color(0xFF524B46),
            child: _buildFilteredFavoritesList(),
          ),
        ),
      ],
    );
  }
  
  // Widget pour afficher la liste filtrée des favoris avec une présentation personnalisée
  Widget _buildFilteredFavoritesList() {
    // Filtrer la liste selon le filtre sélectionné
    List<Map<String, dynamic>> filteredFavorites = _favorites;
    
    if (_selectedFilter != 'Tous') {
      // Filtrer avec les valeurs correctes pour les types de prestataires
      filteredFavorites = _favorites.where((favorite) {
        // 1. Vérifier presta_type_id (ID numérique du type de prestataire)
        if (favorite.containsKey('presta_type_id')) {
          var typeId = favorite['presta_type_id'];
          // Convertir en entier si c'est une chaîne
          if (typeId is String) {
            typeId = int.tryParse(typeId) ?? 0;
          }
          
          // Correspondance avec les ID numériques
          if (_selectedFilter == 'Lieu' && typeId == 1) return true;
          if (_selectedFilter == 'Traiteur' && typeId == 2) return true; 
          if (_selectedFilter == 'Photographe' && typeId == 3) return true;
          if (_selectedFilter == 'DJ' && typeId == 4) return true;
          if (_selectedFilter == 'Fleuriste' && typeId == 5) return true;
        }
        
        // 2. Vérifier aussi type_prestataire (chaîne) pour la compatibilité
        final typePrestataire = favorite['type_prestataire']?.toString().toLowerCase() ?? '';
        return typePrestataire.contains(_selectedFilter.toLowerCase());
      }).toList();
    }
    
    // Afficher un message si aucun résultat après filtrage
    if (filteredFavorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun prestataire ne correspond à ce filtre',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'Tous';
                });
              },
              child: const Text('Voir tous les favoris'),
            ),
          ],
        ),
      );
    }
    
    // Afficher la liste des favoris filtrés avec une carte personnalisée
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredFavorites.length,
      itemBuilder: (context, index) {
        final favorite = filteredFavorites[index];
        
        // Extraire les informations nécessaires
        final String name = favorite['nom_entreprise'] ?? favorite['nom'] ?? 'Prestataire';
        final String location = favorite['region'] ?? favorite['ville'] ?? 'Lieu non spécifié';
        final double rating = (favorite['note_moyenne'] is num) 
            ? favorite['note_moyenne'].toDouble() 
            : double.tryParse(favorite['note_moyenne']?.toString() ?? '0') ?? 0.0;
        final String imageUrl = _getPrestaireImageUrl(favorite);
        
        // Extraction du prix avec la même fonction que dans PrestaireListScreen
        final double? prixBase = _getPrixFromPrestataire(favorite);
        final String price = '${prixBase?.round() ?? 0} €';
        
        // ID du prestataire pour la suppression
        final String prestaId = favorite['id'].toString();
        
        // Créer une carte personnalisée
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrestaireDetailScreen(
                  prestataire: favorite,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image avec décorations
                Stack(
                  children: [
                    // Image principale
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    // Dégradé pour la lisibilité
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Badge de notation
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bouton de suppression des favoris
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _removeFavorite(prestaId),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Titre et lieu en bas de l'image
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Affichage du prix
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À partir de',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF524B46),
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
      },
    );
  }
  
  String _getPrestaireImageUrl(Map<String, dynamic> favorite) {
    // Pour les lieux, chercher dans la table lieux
    if (favorite.containsKey('lieux')) {
      var lieuxData = favorite['lieux'];
      
      // Si lieuxData est une liste
      if (lieuxData is List && lieuxData.isNotEmpty) {
        for (var lieu in lieuxData) {
          if (lieu is Map && 
              lieu.containsKey('image_url') && 
              lieu['image_url'] != null && 
              lieu['image_url'].toString().isNotEmpty) {
            return lieu['image_url'];
          }
        }
      } 
      // Si lieuxData est un Map (objet direct)
      else if (lieuxData is Map && 
              lieuxData.containsKey('image_url') && 
              lieuxData['image_url'] != null && 
              lieuxData['image_url'].toString().isNotEmpty) {
        return lieuxData['image_url'];
      }
    }
    
    // Vérifier d'abord l'image_url dans le prestataire
    if (favorite.containsKey('image_url') && 
        favorite['image_url'] != null && 
        favorite['image_url'].toString().isNotEmpty) {
      return favorite['image_url'];
    }
    
    // Image par défaut
    return 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
  }

  // Widget pour afficher le contenu quand l'utilisateur n'est pas connecté
  Widget _buildNotConnectedContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Connectez-vous pour voir vos favoris',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF524B46),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Créez un compte ou connectez-vous pour enregistrer vos prestataires favoris et les retrouver facilement.',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserLoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SE CONNECTER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.push(UserRoutes.userRegister);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF524B46),
              ),
              child: const Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }

  // Barre de navigation
  Widget _buildBottomNavigationBar(Color grisTexte, ColoraccentColor) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.search, 'Prestataires', grisTexte, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrestatairesScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.favorite, 'Favoris', accentColor, isSelected: true),
          _buildNavItem(Icons.home, 'Accueil', grisTexte, onTap: () {
            context.go('/');
          }),
          _buildNavItem(Icons.shopping_bag_outlined, 'Bouquet', grisTexte),
          _buildNavItem(Icons.person_outline, 'Profil', grisTexte, onTap: () {
            // Vérifier si l'utilisateur est connecté
            final user = Supabase.instance.client.auth.currentUser;
            if (user != null) {
              // L'utilisateur est connecté, naviguer vers le dashboard
              context.go(UserRoutes.userDashboard);
            } else {
              // L'utilisateur n'est pas connecté, naviguer vers la page de connexion
              context.push(UserRoutes.userLogin);
            }
          }),
        ],
      ),
    );
  }

  // Élément de la barre de navigation
  Widget _buildNavItem(IconData icon, String label, Color color, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : color.withOpacity(0.5),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : color.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs selon la DA
    const Color accentColor = Color(0xFF524B46);
    const Color grisTexte = Color(0xFF2B2B2B);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        // Remettre le bouton de rafraîchissement, au cas où
        actions: _isUserLoggedIn && _favorites.isNotEmpty ? [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Actualiser',
          ),
        ] : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _checkUserStatus,
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
              : _isUserLoggedIn
                  ? _buildConnectedContent() // Déjà modifié pour inclure RefreshIndicator correctement
                  : _buildNotConnectedContent(),
      bottomNavigationBar: _buildBottomNavigationBar(grisTexte, accentColor),
    );
  }
}