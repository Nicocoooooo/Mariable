import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/favorites_service.dart';

class FeaturedVendorCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double rating;
  final VoidCallback onTap;
  final String prestaId; // Ajout de l'ID du prestataire

  const FeaturedVendorCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.onTap,
    required this.prestaId, // Nouveau paramètre requis
  });

  @override
  State<FeaturedVendorCard> createState() => _FeaturedVendorCardState();
}

class _FeaturedVendorCardState extends State<FeaturedVendorCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFavorite = false;
  bool _isProcessing = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Vérifier si ce prestataire est déjà en favoris
    _checkIfFavorite();
  }

  // Vérifier si ce prestataire est dans les favoris
  Future<void> _checkIfFavorite() async {
    if (!_favoritesService.isUserLoggedIn()) return;
    
    try {
      final isInFavorites = await _favoritesService.isPrestaInFavorites(widget.prestaId);
      if (mounted) {
        setState(() {
          _isFavorite = isInFavorites;
        });
      }
    } catch (e) {
      // Ignorer les erreurs lors de la vérification
    }
  }

  // Gérer le clic sur le bouton favoris
  Future<void> _toggleFavorite() async {
    // Si l'utilisateur n'est pas connecté, afficher un message
    if (!_favoritesService.isUserLoggedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour ajouter des favoris'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_isProcessing) return; // Éviter les doubles clics
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final success = await _favoritesService.toggleFavorite(widget.prestaId);
      
      if (mounted && success) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isProcessing = false;
        });
        
        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite 
              ? 'Prestataire ajouté aux favoris' 
              : 'Prestataire retiré des favoris'),
            backgroundColor: _isFavorite ? Colors.green : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                      blurRadius: _isHovered ? 12 : 6,
                      offset: Offset(0, _isHovered ? 6 : 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image du prestataire
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Image
                          CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                          
                          // Dégradé pour assurer la lisibilité du texte
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
                                    widget.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Bouton "Favori" modifié pour fonctionner
                          Positioned(
                            top: 12,
                            left: 12,
                            child: GestureDetector(
                              onTap: _isProcessing ? null : _toggleFavorite,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isProcessing
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A4D2E)),
                                        ),
                                      )
                                    : Icon(
                                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: _isFavorite
                                            ? Colors.red
                                            : _isHovered
                                                ? const Color(0xFF1A4D2E)
                                                : Colors.grey[600],
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                          
                          // Titre et sous-titre
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
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
                                        widget.subtitle,
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
                    ),
                    
                    // Pied de carte avec prix et bouton
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              const Text(
                                '5 000 €',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A4D2E),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: widget.onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A4D2E),
                              foregroundColor: Colors.white,
                              elevation: _isHovered ? 4 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Voir détails'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}