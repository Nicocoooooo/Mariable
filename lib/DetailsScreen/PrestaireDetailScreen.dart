import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:collection'; // Pour LinkedHashMap
import '../Filtre/data/repositories/lieu_repository.dart'; // Ajoutez cette ligne
import '../Filtre/data/models/avis_model.dart';
import '../utils/fake_data.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/availability_selector.dart';
import 'package:intl/intl.dart';
import 'ImageGalleryScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:mariable/Widgets/chatbot_widget.dart';



class PrestaireDetailScreen extends StatefulWidget {
  final Map<String, dynamic> prestataire;

  const PrestaireDetailScreen({
    super.key,
    required this.prestataire,
  });

  @override
  State<PrestaireDetailScreen> createState() => _PrestaireDetailScreenState();
}

class _PrestaireDetailScreenState extends State<PrestaireDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isLoadingFormules = true;
  bool _isDescriptionExpanded = false;
  List<AvisModel> _avis = [];
  List<String> _galleryImages = [];
  bool _isLoadingAvis = true;
  List<Map<String, dynamic>> _formules = [];
  bool _hasChatbotDocument = false;
  bool _isCheckingChatbot = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFormules();
    _loadAvis();
    _loadGalleryImages();
    _loadRecommendedPrestataires();
    _checkChatbotAvailability();
  
  print('Prestataire complet: ${widget.prestataire}');
  print('Type ID: ${widget.prestataire['presta_type_id']}');
  _scrollController.addListener(_onScroll);
  _loadFormules();
  _loadAvis();
  _loadGalleryImages();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Changer l'état si on scrolle plus bas que l'image
    final imageHeight = MediaQuery.of(context).size.height * 0.6;
    if (_scrollController.offset > imageHeight - kToolbarHeight && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset < imageHeight - kToolbarHeight && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

   
  void _loadGalleryImages() {
    // Récupérer proprement le type de prestataire
  final int prestaTypeId = _getActualPrestaireType();
  print('Type pour galerie: $prestaTypeId');

  // Sélection des images selon le type
  switch (prestaTypeId) {
    case 2: // Traiteur
      _galleryImages = [
        'https://images.unsplash.com/photo-1525151498231-bc059cfafa2b?q=80&w=2189&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1607403217872-27422b4ece0b?q=80&w=3131&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1580959375944-abd7e991f971?q=80&w=2205&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1621327017866-6fb07e6c96ea?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1625108956250-0497f690d867?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1520181973954-cf92f53359ff?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ];
      break;
    case 3: // Photographe
      _galleryImages = [
        'https://images.unsplash.com/photo-1733759414886-6b3a5423ceb3?q=80&w=3008&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1561593367-66c79c2294e6?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1504716864043-384fcec48a3d?q=80&w=3174&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1532454781337-fc3edff34f91?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2940&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1503508961401-4f07813e63ed?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ];
      break;
    case 4: // Wedding Planner
      _galleryImages = [
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=2940&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1501139083538-0139583c060f?q=80&w=2940&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1520854221256-17451cc331bf?q=80&w=2940&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?q=80&w=2940&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=2940&auto=format&fit=crop',
      ];
      break;
    case 1: // Lieu
    default:
      _galleryImages = [
        'https://images.unsplash.com/photo-1624486853918-f7bd17d70321?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1515715709530-858f7bfa1b10?q=80&w=3003&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1485178075098-49f78b4b43b4?q=80&w=2449&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1629744418692-345355518e78?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://plus.unsplash.com/premium_photo-1674760219927-29d571ea20ec?q=80&w=3088&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1635996145160-54e6bb3c8341?q=80&w=2942&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ];
      break;
  }
}

List<Map<String, dynamic>> _recommendedPrestataires = [];
bool _isLoadingRecommendations = true;
int _getActualPrestaireType() {
  // Si le prestataire a un presta_type_id explicite, l'utiliser d'abord
  if (widget.prestataire.containsKey('presta_type_id') && 
      widget.prestataire['presta_type_id'] != null) {
    
    var typeId = widget.prestataire['presta_type_id'];
    if (typeId is int) {
      return typeId;
    } else if (typeId is String) {
      return int.tryParse(typeId) ?? 1;
    }
  }
  
  // Détection par l'ID de sous-type
  if (widget.prestataire.containsKey('traiteur_type_id') && 
      widget.prestataire['traiteur_type_id'] != null) {
    return 2; // C'est un traiteur
  }
  
  if (widget.prestataire.containsKey('lieux_type_id') && 
      widget.prestataire['lieux_type_id'] != null) {
    return 1; // C'est un lieu
  }
  
  // Détection par le nom ou la description
  String nomEntreprise = widget.prestataire['nom_entreprise'] ?? '';
  String description = widget.prestataire['description'] ?? '';
  
  if (nomEntreprise.toLowerCase().contains('traiteur') || 
      description.toLowerCase().contains('traiteur') ||
      nomEntreprise.toLowerCase().contains('food') ||
      description.toLowerCase().contains('cuisine')) {
    return 2; // C'est un traiteur
  }
  
  if (nomEntreprise.toLowerCase().contains('photo') || 
      description.toLowerCase().contains('photo') ||
      description.toLowerCase().contains('photographe')) {
    return 3; // C'est un photographe
  }
  
  if (nomEntreprise.toLowerCase().contains('planner') || 
      description.toLowerCase().contains('planner') ||
      description.toLowerCase().contains('wedding planner')) {
    return 4; // C'est un wedding planner
  }
  
  // Par défaut, considérer comme un lieu
  return 1;
}

  void _showAvailabilitySelector() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AvailabilitySelector(
        prestataireName: widget.prestataire['nom_entreprise'] ?? 'ce prestataire',
        onClose: () => Navigator.pop(context),
        onTimeSelected: (date, timeSlot) {
          Navigator.pop(context);
          _handleAppointmentConfirmation(date, timeSlot);
        },
      );
    },
  );
  }

  void _handleAppointmentConfirmation(DateTime date, String timeSlot) {
    final DateFormat formatter = DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR');
    final String formattedDate = formatter.format(
      DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeSlot.split(':')[0]),
        int.parse(timeSlot.split(':')[1]),
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rendez-vous confirmé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Votre rendez-vous avec ${widget.prestataire['nom_entreprise']} est confirmé pour le :'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    color: Color(0xFF1A4D2E),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Un email de confirmation vous a été envoyé avec les détails du rendez-vous.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous recevrez également un rappel 24h avant le rendez-vous.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A4D2E),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Ici, vous pourriez naviguer vers la page du calendrier ou des rendez-vous
            },
            child: const Text('Voir mes rendez-vous'),
          ),
        ],
      ),
    );
  }

    // Ajoutez cette méthode
  Future<void> _loadFormules() async {
  setState(() => _isLoadingFormules = true);
  try {
    if (widget.prestataire['id'] != null) {
      final formules = await LieuRepository().getTarifsByPrestaId(widget.prestataire['id']);
      setState(() => _formules = formules);
    }
  } catch (e) {
    // Gestion d'erreur
  } finally {
    setState(() => _isLoadingFormules = false);
  }
  }


@override
Widget build(BuildContext context) {
  // Extraire les données du prestataire
  final String nom = widget.prestataire['nom_entreprise'] ?? 'Sans nom';
  final String region = widget.prestataire['region'] ?? '';
  final String adresse = widget.prestataire['adresse'] ?? '';
  final String location = (region.isNotEmpty && adresse.isNotEmpty) 
      ? '$region, France' 
      : (region.isNotEmpty ? '$region, France' : 'France');
  final String description = widget.prestataire['description'] ?? 'Aucune description disponible';
  
  // Récupérer les données spécifiques au type de prestataire
  final int prestaTypeId = _getActualPrestaireType();
  
  // Pour les lieux, récupérer les données de la table lieux
  int? capaciteMax;
  if (prestaTypeId == 1 && widget.prestataire.containsKey('lieux')) {
    var lieuxData = widget.prestataire['lieux'];
    if (lieuxData is List && lieuxData.isNotEmpty) {
      capaciteMax = lieuxData[0]['capacite_max'];
    } else if (lieuxData is Map) {
      capaciteMax = lieuxData['capacite_max'];
    }
  }
  
  final double? prixBase = widget.prestataire['prix_base'] != null 
      ? (widget.prestataire['prix_base'] is double 
          ? widget.prestataire['prix_base'] 
          : double.tryParse(widget.prestataire['prix_base'].toString()))
      : null;
  final double? rating = widget.prestataire['note_moyenne'] != null 
      ? (widget.prestataire['note_moyenne'] is double 
          ? widget.prestataire['note_moyenne'] 
          : double.tryParse(widget.prestataire['note_moyenne'].toString()))
      : null;
   // ici 

  // Formules/Packages (à partir de tarifs)
  List<Map<String, dynamic>> formules = [];
  if (widget.prestataire.containsKey('tarifs') && 
      widget.prestataire['tarifs'] is List) {
    for (var tarif in widget.prestataire['tarifs']) {
      if (tarif is Map) {
        formules.add({
          'nom': tarif['nom_formule'] ?? 'Formule standard',
          'prix': tarif['prix_base'] ?? 0.0,
          'description': tarif['description'] ?? 'Aucune description disponible',
        });
      }
    }
  }
  // Ajouter une formule par défaut si aucune n'est disponible
  if (formules.isEmpty && prixBase != null) {
    formules.add({
      'nom': 'Formule standard',
      'prix': prixBase,
      'description': 'Prestation de base',
    });
  }

  return Scaffold(
    floatingActionButton: !_isCheckingChatbot && _hasChatbotDocument ? 
    Padding(
    // Ajouter un padding pour éloigner le bouton du bas de l'écran
    padding: const EdgeInsets.only(bottom: 80), // Ajuster cette valeur selon vos besoins
    child: FloatingActionButton(
      backgroundColor: const Color(0xFF524B46),
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      onPressed: () => _showChatbotModal(context),
    ),
  ) : null,
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
      elevation: _isScrolled ? 4 : 0,
      leading: IconButton(
        icon: CircleAvatar(
          backgroundColor: _isScrolled ? Colors.transparent : Colors.black.withAlpha(128),
          child: Icon(
            Icons.arrow_back,
            color: _isScrolled ? Colors.black : Colors.white,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: CircleAvatar(
            backgroundColor: _isScrolled ? Colors.transparent : Colors.black.withAlpha(128),
            child: Icon(
              Icons.share,
              color: _isScrolled ? Colors.black : Colors.white,
            ),
          ),
          onPressed: () {
            // Ajouter la fonctionnalité de partage
          },
        ),
        IconButton(
        icon: CircleAvatar(
          backgroundColor: _isScrolled ? Colors.transparent : Colors.black.withAlpha(128),
          child: Icon(
            Icons.favorite_border,
            color: _isScrolled ? Colors.black : Colors.white,
          ),
        ),
        onPressed: () {
          // Action lors du clic sur le cœur
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajouté aux favoris'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
        const SizedBox(width: 8),
      ],
      title: _isScrolled ? Text(
        nom,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ) : null,
      systemOverlayStyle: _isScrolled 
          ? SystemUiOverlayStyle.dark 
          : SystemUiOverlayStyle.light,
    ),

    body: CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Image principale avec informations superposées
        SliverToBoxAdapter(
          child: GestureDetector(  // GestureDetector englobant pour l'ouverture de la galerie
          onTap: () => _openGallery(),
          child: Stack(
            children: [
              // Image principale prenant tout l'écran
              SizedBox(
                height: MediaQuery.of(context).size.height, // Pleine hauteur de l'écran
                width: MediaQuery.of(context).size.width, // Pleine largeur de l'écran
                child: CachedNetworkImage(
                imageUrl: widget.prestataire['image_url'] ?? 
                  (widget.prestataire.containsKey('lieux') && 
                  widget.prestataire['lieux'] is List && 
                  widget.prestataire['lieux'].isNotEmpty && 
                  widget.prestataire['lieux'][0].containsKey('image_url') ? 
                  widget.prestataire['lieux'][0]['image_url'] : ''),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.business,
                    size: 48,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              )
              ),
              
              // Dégradé pour assurer la lisibilité des textes
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(77), // 0.3 * 255 = 76.5, arrondi à 77
                        Colors.black.withAlpha(153), // 0.6 * 255 = 153
                      ],
                      stops: const [0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Informations principales
              Positioned(
                // Position depuis le bas
                bottom: MediaQuery.of(context).size.height * 0.15, 
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du lieu
                      Text(
                        nom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32, 
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.black,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      
                      // Localisation
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                                              
                      // Première section d'étoiles améliorée
                      Row(
                        children: [
                          for (int i = 1; i <= 5; i++)
                            Icon(
                              i <= (rating ?? 0) ? Icons.star : 
                              (i - 0.5 <= (rating ?? 0) ? Icons.star_half : Icons.star_border),
                              color: Colors.amber,
                              size: 24,
                            ),
                          if (rating != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                      color: Colors.black,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Capacité
                      if (capaciteMax != null)
                        Text(
                          '$capaciteMax invités',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Prix
                      if (prixBase != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(153), // Un peu plus opaque
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'À partir de ${prixBase.round()} €',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Description
                      Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(128),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                          ),
                          if (description.length > 150) // Afficher le bouton seulement si la description est longue
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDescriptionExpanded = !_isDescriptionExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isDescriptionExpanded ? 'Voir moins' : 'Voir plus',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(
                                      _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
        
        
        // Caractéristiques et services (UNE SEULE FOIS)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildFeaturesAndServices(),
          ),
        ),
        
        // Formules/Packages
        if (_formules.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nos formules',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoadingFormules
                    ? const Center(child: CircularProgressIndicator())
                    : _formules.isEmpty
                        ? const Text('Aucune formule disponible')
                        : Column(
                            children: _formules.map((formule) => _buildPackageItem(
                              title: formule['nom_formule'] ?? 'Formule',
                              price: formule['prix_base'] is num 
                                ? formule['prix_base'].toDouble() 
                                : double.tryParse(formule['prix_base'].toString()) ?? 0.0,
                              description: formule['description'] ?? '',
                              formule: formule,  // Passez la formule complète ici
                            )).toList(),
                          ),
                ],
              ),
            ),
          ),

        // Adresse & Localisation
        SliverToBoxAdapter(
          child: buildLocationWidget(
            widget.prestataire['adresse'] ?? 'Adresse non disponible',
          ),
        ),
        
        // Avis
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et note moyenne
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Avis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    if (_avis.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF524B46),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              rating?.toStringAsFixed(1) ?? "0.0",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Affichage des avis
                _isLoadingAvis
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _avis.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun avis pour le moment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                      : Column(
                          children: _avis
                              .take(3) // Limiter à 3 avis affichés initialement
                              .map((avis) => _buildAvisItem(avis))
                              .toList(),
                        ),
                
                // Boutons côte à côte si des avis existent
                if (_avis.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bouton "Voir tous les avis"
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showAllReviews(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF524B46)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Voir tous les avis (${_avis.length})',
                              style: const TextStyle(
                                color: Color(0xFF524B46),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Bouton "Laisser un avis"
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cette fonctionnalité sera disponible prochainement'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF524B46),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.rate_review, color: Colors.white, size: 18),
                            label: const Text('Laisser un avis'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Conditions d'annulation
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conditions d\'annulation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withAlpha(77)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Color(0xFF524B46),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Politique d\'annulation souple',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2B2B2B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildCancellationItem(
                        'Remboursement à 100%',
                        'Jusqu\'à 60 jours avant la date de l\'événement',
                        const Color(0xFF3CB371),
                      ),
                      const Divider(height: 30, thickness: 1),
                      _buildCancellationItem(
                        'Remboursement à 50%',
                        'Entre 60 et 30 jours avant l\'événement',
                        const Color(0xFFFFA500),
                      ),
                      const Divider(height: 30, thickness: 1),
                      _buildCancellationItem(
                        'Non remboursable',
                        'Moins de 30 jours avant l\'événement',
                        const Color(0xFFDC3545),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        

        // Widget à ajouter à la fin de votre CustomScrollView dans le build de PrestaireDetailScreen
        SliverToBoxAdapter(
          child: _buildRecommendedPrestataires(),
        ),

        // Espace pour ne pas que le bouton cache du contenu
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    ),
    

    // Bouton Réserver fixe en bas
    bottomSheet: Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Premier bouton - Contacter
          Expanded(
            child: OutlinedButton(
              onPressed: _showAvailabilitySelector,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF524B46)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Prendre RDV',
                style: TextStyle(
                  color: Color(0xFF524B46),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Deuxième bouton - Réserver
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showFormulaCalculator(widget.prestataire),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Réserver',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper pour l'affichage des conditions d'annulation
Widget _buildCancellationItem(String title, String subtitle, Color color) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2B2B2B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
  
  // Widget pour afficher une formule/package
    Widget _buildPackageItem({
    required String title,
    required double price,
    required String description,
    required Map<String, dynamic> formule,  // Ajoutez ce paramètre
  }) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withAlpha(77)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec titre et prix
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF524B46),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                '${price.round()} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Description
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            description,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
        // Bouton - remplacez ce qui était ici
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: OutlinedButton(
          onPressed: () => _showFormulaCalculator(formule),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF524B46)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Choisir cette formule',
            style: TextStyle(
              color: Color(0xFF524B46),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ),
      ],
    ),
  );
}


void _showChatbotModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        margin: const EdgeInsets.all(16),
        child: ChatbotWidget(
          prestaId: widget.prestataire['id'],
          prestaName: widget.prestataire['nom_entreprise'] ?? 'ce prestataire',
          prestaEmail: widget.prestataire['email'],
        ),
      );
    },
  );
}

// Fonction principale pour construire les caractéristiques et services
Widget _buildFeaturesAndServices() {
  // Récupérer proprement le type de prestataire
  var prestaTypeId = widget.prestataire['presta_type_id'];
  final Logger logger = Logger('PrestaireDetailScreen');
  logger.fine('Type original: $prestaTypeId');


  // Vérifier le nom pour corriger les traiteurs sans ID correct
  String nomEntreprise = widget.prestataire['nom_entreprise'] ?? '';
  String description = widget.prestataire['description'] ?? '';

  // Si c'est clairement un traiteur par le nom ou la description
  if (nomEntreprise.toLowerCase().contains('traiteur') || 
      description.toLowerCase().contains('traiteur') ||
      nomEntreprise.toLowerCase().contains('food') ||
      nomEntreprise.toLowerCase().contains('cuisine') ||
      widget.prestataire['traiteur_type_id'] != null) {
    prestaTypeId = 2;  // FORCER le type traiteur
  }

  // Si c'est une chaîne, convertir en entier
  if (prestaTypeId is String) {
    prestaTypeId = int.tryParse(prestaTypeId) ?? 1;
  } else if (prestaTypeId is! int) {
    prestaTypeId = 1; // Valeur par défaut si pas de type
  }

  // Utiliser LinkedHashMap pour préserver l'ordre d'insertion
  final LinkedHashMap<String, dynamic> features = LinkedHashMap<String, dynamic>();
  final LinkedHashMap<String, IconData> services = LinkedHashMap<String, IconData>();

// Pour les lieux uniquement (type_id = 1)
if (prestaTypeId == 1) {
  print('DEBUG LIEU: Récupération des données lieu pour: ${widget.prestataire['nom_entreprise']}');
  
  // Récupérer les données de lieux depuis le prestataire
  if (widget.prestataire.containsKey('lieux')) {

    var lieuxData = widget.prestataire['lieux'];

    
    // Objet Map directement 
    if (lieuxData is Map<String, dynamic>) {
      _processLieuData(lieuxData, features, services);
    } 
    // Si c'est une liste, essayer d'extraire le premier élément
    else if (lieuxData is List && lieuxData.isNotEmpty) {
      
      // Convertir l'élément de la liste en Map<String, dynamic>
      final Map<String, dynamic> lieuMap = {};
      final lieu = lieuxData[0];
      
      if (lieu is Map) {
        lieu.forEach((key, value) {
          lieuMap[key.toString()] = value;
        });
        
        _processLieuData(lieuMap, features, services);
      } else {
       
        _addDefaultLieuFeatures(features, services);
      }
    } else {
      _addDefaultLieuFeatures(features, services);
    }
  } else {
    // Si aucune donnée n'est trouvée, ajoutons des valeurs par défaut
    _addDefaultLieuFeatures(features, services);
  }
}
 
else if (prestaTypeId == 2) {
  
  // Caractéristiques du traiteur
  features['Type de cuisine'] = {
    'type': 'text',
    'value': 'Cuisine française traditionnelle',
    'icon': Icons.restaurant
  };
  
  features['Menu personnalisable'] = {
    'type': 'boolean',
    'value': true,
    'icon': Icons.edit_note
  };
  
  features['Capacité de service'] = {
    'type': 'numeric',
    'value': 200,
    'unit': 'invités',
    'icon': Icons.group
  };
  
  features['Expérience'] = {
    'type': 'text',
    'value': 'Plus de 10 ans dans l\'événementiel',
    'icon': Icons.star
  };
  
  features['Options diététiques'] = {
    'type': 'text',
    'value': 'Végétarien, Végan, Sans gluten',
    'icon': Icons.spa
  };
  
  // Services inclus du traiteur
  services['Service à l\'assiette'] = Icons.restaurant_menu;
  services['Vaisselle et verrerie'] = Icons.dining;
  services['Menu dégustation offert'] = Icons.restaurant;
  services['Gâteau personnalisé'] = Icons.cake;
  services['Boissons et cocktails'] = Icons.local_bar;
  services['Installation et débarrassage'] = Icons.cleaning_services;
  services['Maître d\'hôtel dédié'] = Icons.support_agent;
  services['Personnel de service'] = Icons.people;
}
  // Pour les photographes (type_id = 3)
  else if (prestaTypeId == 3) {
    features['Style de photographie'] = {
      'type': 'text',
      'value': 'Reportage naturel',
      'icon': Icons.camera_alt
    };
    
    features['Durée de présence'] = {
      'type': 'text',
      'value': 'Journée complète',
      'icon': Icons.access_time
    };
    
    services['Albums photo inclus'] = Icons.photo_album;
    services['Galerie en ligne'] = Icons.cloud;
    services['Drone disponible'] = Icons.flight;
  }
  
  // Si aucune caractéristique n'est trouvée, ajouter quelques exemples par défaut
  if (features.isEmpty && services.isEmpty) {
    // D'abord ajouter les caractéristiques numériques
    features['Capacité maximale'] = {
      'type': 'numeric',
      'value': 150,
      'unit': 'invités',
      'icon': Icons.people
    };
    
    features['Capacité minimale'] = {
      'type': 'numeric',
      'value': 50,
      'unit': 'invités',
      'icon': Icons.people_outline
    };
    
    features['Capacité d\'hébergement'] = {
      'type': 'numeric',
      'value': 30,
      'unit': 'couchages',
      'icon': Icons.hotel
    };
    
    features['Nombre de chambres'] = {
      'type': 'numeric',
      'value': 8,
      'unit': '',
      'icon': Icons.bed
    };
    
    features['Superficie intérieure'] = {
      'type': 'numeric',
      'value': 400,
      'unit': 'm²',
      'icon': Icons.square_foot
    };
    
    features['Superficie extérieure'] = {
      'type': 'numeric',
      'value': 2000,
      'unit': 'm²',
      'icon': Icons.grass
    };
    
    features['Cadre'] = {
      'type': 'text',
      'value': 'Château avec parc à la française',
      'icon': Icons.park
    };
    
    // Ensuite ajouter les caractéristiques booléennes
    features['Espace extérieur'] = {
      'type': 'boolean',
      'value': true,
      'icon': Icons.terrain
    };
    
    features['Parking disponible'] = {
      'type': 'boolean',
      'value': true,
      'icon': Icons.local_parking
    };
    
    features['Vue sur la montagne'] = {
      'type': 'boolean',
      'value': true, 
      'icon': Icons.landscape
    };
    
    // Ajouter quelques services par défaut
    services['WiFi gratuit'] = Icons.wifi;
    services['Sonorisation incluse'] = Icons.music_note;
    services['Service voiturier'] = Icons.directions_car;
  }
  
  // Retourner la structure UI
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Caractéristiques principales (si non vides)
      if (features.isNotEmpty) ...[
        const Text(
          'Caractéristiques',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 16),
        
        // Limiter l'affichage à 8 caractéristiques maximum initialement
        ...features.entries.take(8).map((entry) {
          // Différencier l'affichage selon le type de caractéristique
          if (entry.value is Map) {
            final featureData = entry.value as Map<String, dynamic>;
            final type = featureData['type'];
            
            if (type == 'numeric') {
              return _buildNumericFeatureItem(
                icon: featureData['icon'],
                text: entry.key,
                value: featureData['value'],
                unit: featureData['unit'] ?? '',
              );
            } else if (type == 'text') {
              return _buildTextFeatureItem(
                icon: featureData['icon'],
                label: entry.key,
                text: featureData['value'],
              );
            } else {
              return _buildFeatureItem(
                icon: featureData['icon'],
                text: entry.key,
              );
            }
          } else {
            // Fallback pour les anciennes entrées (IconData direct)
            return _buildFeatureItem(
              icon: entry.value,
              text: entry.key,
            );
          }
        }),
        
        // Bouton "Voir plus" si plus de 8 caractéristiques
        if (features.length > 8)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkWell(
              onTap: () => _showAllFeatures(features, 'Toutes les caractéristiques (${features.length})'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Voir toutes les caractéristiques (${features.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
      
      const SizedBox(height: 32),
      
      // Services inclus (si non vides)
      if (services.isNotEmpty) ...[
        const Text(
          'Services inclus',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 16),
        
        // Limiter l'affichage à 8 services maximum initialement
        ...services.entries.take(8).map((entry) => 
          _buildFeatureItem(icon: entry.value, text: entry.key)
        ),
        
        // Bouton "Voir plus" si plus de 8 services
        if (services.length > 8)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkWell(
              onTap: () => _showAllFeatures(services, 'Tous les services inclus (${services.length})'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Voir tous les services inclus (${services.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ],
  );
}


  Future<void> _loadAvis() async {
    setState(() => _isLoadingAvis = true);
    try {
      // Au lieu d'appeler l'API, utilisez les données fictives
      if (widget.prestataire['id'] != null) {
        // Petit délai pour simuler un appel réseau
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Charger les données fictives
        final fakeAvis = FakeData.getFakeAvis(widget.prestataire['id']);
        
        setState(() {
          _avis = fakeAvis;
        });
      }
    } finally {
      setState(() => _isLoadingAvis = false);
    }
  }



Widget _buildRecommendedPrestataires() {
  if (_isLoadingRecommendations) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  if (_recommendedPrestataires.isEmpty) {
    return SizedBox(); // Ne rien afficher s'il n'y a pas de recommandations
  }
  
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vous allez aimer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280, // Hauteur fixe pour le carrousel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedPrestataires.length,
            itemBuilder: (context, index) {
              final prestataire = _recommendedPrestataires[index];
              return _buildRecommendedCard(prestataire);
            },
          ),
        ),
      ],
    ),
  );
}
void _navigateToPrestaireDetail(Map<String, dynamic> prestataire) async {
  try {
    // Récupérer l'ID du prestataire
    final String prestaId = prestataire['id'] ?? '';
    if (prestaId.isEmpty) {
      print('Erreur: ID du prestataire manquant');
      return;
    }
    
    // Déterminer le type de prestataire
    int prestaTypeId = 1; // Par défaut: lieu
    if (prestataire.containsKey('presta_type_id') && prestataire['presta_type_id'] != null) {
      prestaTypeId = prestataire['presta_type_id'] is int 
        ? prestataire['presta_type_id'] 
        : int.tryParse(prestataire['presta_type_id'].toString()) ?? 1;
    }
    
    
    // Enrichir les données en fonction du type
    var enrichedData = Map<String, dynamic>.from(prestataire);
    
    try {
      // Requête pour obtenir les données complètes selon le type de prestataire
      var query = Supabase.instance.client.from('presta').select('''
        id, 
        nom_entreprise, 
        description, 
        region, 
        adresse, 
        note_moyenne, 
        verifie, 
        actif,
        presta_type_id,
        image_url,
        tarifs(
          id,
          nom_formule,
          prix_base,
          description
        )
      ''');
      
      // Si c'est un lieu (type 1), inclure les données de la table lieux
      if (prestaTypeId == 1) {
        query = Supabase.instance.client.from('presta').select('''
          id, 
          nom_entreprise, 
          description, 
          region, 
          adresse, 
          note_moyenne, 
          verifie, 
          actif,
          presta_type_id,
          image_url,
          lieux(
            id, 
            capacite_max,
            capacite_min,
            nombre_chambres,
            espace_exterieur, 
            piscine,
            parking, 
            hebergement, 
            capacite_hebergement,
            exclusivite, 
            feu_artifice,
            image_url,
            systeme_sonorisation,
            tables_fournies,
            chaises_fournies,
            nappes_fournies,
            vaisselle_fournie,
            eclairage,
            sonorisation,
            wifi,
            coordinateur_sur_place,
            vestiaire,
            voiturier,
            espace_enfants,
            climatisation,
            espace_lacher_lanternes,
            lieu_seance_photo,
            acces_bateau_helicoptere,
            jardin,
            parc,
            terrasse,
            cour,
            espace_ceremonie,
            espace_cocktail,
            superficie_interieur,
            superficie_exterieur,
            cadre
          ),
          tarifs(
            id,
            nom_formule,
            prix_base,
            description
          )
        ''');
      }
      
      // Finaliser la requête
      final response = await query
        .eq('id', prestaId)
        .limit(1)
        .single();
      
      if (response.isNotEmpty) {

        enrichedData = response;
      }
    } catch (e) {
    }
    
    // Naviguer vers la page de détail avec les données enrichies
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestaireDetailScreen(
          prestataire: enrichedData,
        ),
      ),
    );
  } catch (e) {

    // Naviguer quand même avec les données existantes en cas d'erreur
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrestaireDetailScreen(
          prestataire: prestataire,
        ),
      ),
    );
  }
}


Widget _buildRecommendedCard(Map<String, dynamic> prestataire) {
  // Déterminer le type et l'URL de l'image
  int prestaTypeId = prestataire['presta_type_id'] ?? 1;
  String imageUrl;
  
  // Pour les lieux (type 1), chercher dans la table lieux
  if (prestaTypeId == 1 && prestataire.containsKey('lieux')) {
    var lieuxData = prestataire['lieux'];
    
    if (lieuxData is List && lieuxData.isNotEmpty) {
      var premierLieu = lieuxData[0];
      if (premierLieu is Map && 
          premierLieu.containsKey('image_url') && 
          premierLieu['image_url'] != null) {
        imageUrl = premierLieu['image_url'];
      } else {
        imageUrl = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
      }
    } else if (lieuxData is Map && 
               lieuxData.containsKey('image_url') && 
               lieuxData['image_url'] != null) {
      imageUrl = lieuxData['image_url'];
    } else {
      imageUrl = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
    }
  } 
  // Pour les autres types, utiliser l'image de presta
  else {
    imageUrl = prestataire['image_url'] ?? _getDefaultImageByType(prestaTypeId);
  }
  
  return GestureDetector(
    onTap: () => _navigateToPrestaireDetail(prestataire),
    child: Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec l'URL déterminée
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                height: 160,
                child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
              ),
            ),
          ),
          // Informations
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prestataire['nom_entreprise'] ?? 'Nom inconnu',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        prestataire['region'] ?? 'Région inconnue',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (prestataire['note_moyenne'] != null)
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${prestataire['note_moyenne']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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

void _checkChatbotAvailability() async {
  setState(() => _isCheckingChatbot = true);
  
  try {
    final response = await Supabase.instance.client
        .from('presta')
        .select('chatbot_document')
        .eq('id', widget.prestataire['id'])
        .single();
        
    setState(() {
      _hasChatbotDocument = response['chatbot_document'] != null && 
                          response['chatbot_document'].toString().isNotEmpty;
      _isCheckingChatbot = false;
    });
  } catch (e) {
    setState(() {
      _hasChatbotDocument = false;
      _isCheckingChatbot = false;
    });
    print('Erreur: $e');
  }
}


Future<void> _loadRecommendedPrestataires() async {
  try {
    setState(() {
      _isLoadingRecommendations = true;
    });

    final int currentPrestaType = _getActualPrestaireType();
    final String currentId = widget.prestataire['id'] ?? '';
    
    // Construire la requête selon le type
    PostgrestList response;
    if (currentPrestaType == 1) {
      // Pour les lieux, inclure les données de la table lieux
      response = await Supabase.instance.client
          .from('presta')
          .select('id, nom_entreprise, region, note_moyenne, image_url, presta_type_id, lieux(id, image_url)')
          .eq('presta_type_id', currentPrestaType)
          .eq('actif', true)
          .neq('id', currentId)
          .limit(10);
    } else {
      // Pour les autres types, pas besoin d'inclure lieux
      response = await Supabase.instance.client
          .from('presta')
          .select('id, nom_entreprise, region, note_moyenne, image_url, presta_type_id')
          .eq('presta_type_id', currentPrestaType)
          .eq('actif', true)
          .neq('id', currentId)
          .limit(10);
    }
  
    
    if (response != null && response.isNotEmpty) {
      final List<Map<String, dynamic>> prestataires = [];
      for (var item in response) {
        if (item is Map) {
          Map<String, dynamic> prestataire = {};
          item.forEach((key, value) {
            prestataire[key.toString()] = value;
          });
          prestataires.add(prestataire);
        }
      }
      
      prestataires.shuffle();
      final recommendedList = prestataires.take(4).toList();
      
      setState(() {
        _recommendedPrestataires = recommendedList;
        _isLoadingRecommendations = false;
      });
    } else {
      setState(() {
        _recommendedPrestataires = [];
        _isLoadingRecommendations = false;
      });
    }
  } catch (e) {
    setState(() {
      _recommendedPrestataires = [];
      _isLoadingRecommendations = false;
    });
  }
}

String _getDefaultImageByType(int prestaTypeId) {
  switch (prestaTypeId) {
    case 2: // Traiteur
      return 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=2940&auto=format&fit=crop';
    case 3: // Photographe
      return 'https://images.unsplash.com/photo-1532712938310-34cb3982ef74?q=80&w=2940&auto=format&fit=crop';
    case 4: // Wedding Planner
      return 'https://images.unsplash.com/photo-1501139083538-0139583c060f?q=80&w=2940&auto=format&fit=crop';
    case 1: // Lieu
    default:
      return 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
  }
}


// Widget pour afficher un item numérique (avec valeur et unité)
Widget _buildNumericFeatureItem({
  required IconData icon,
  required String text,
  required dynamic value,
  required String unit,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 16),
          child: Icon(icon, size: 24, color: const Color(0xFF2B2B2B)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$value ${unit.isNotEmpty ? unit : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


// Widget pour afficher un item textuel (avec label et contenu)
Widget _buildTextFeatureItem({
  required IconData icon,
  required String label,
  required String text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 16),
          child: Icon(icon, size: 24, color: const Color(0xFF2B2B2B)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Méthode pour afficher toutes les caractéristiques dans une nouvelle vue
void _showAllFeatures(Map<String, dynamic> items, String title) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header avec titre et bouton fermer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.split(' (')[0], // Prendre uniquement la partie nom sans le nombre
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Liste des caractéristiques
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items.entries.elementAt(index);
                    
                    // Différencier l'affichage selon le type de caractéristique
                    if (entry.value is Map) {
                      final featureData = entry.value as Map<String, dynamic>;
                      final type = featureData['type'];
                      
                      if (type == 'numeric') {
                        return _buildNumericFeatureItem(
                          icon: featureData['icon'],
                          text: entry.key,
                          value: featureData['value'],
                          unit: featureData['unit'] ?? '',
                        );
                      } else if (type == 'text') {
                        return _buildTextFeatureItem(
                          icon: featureData['icon'],
                          label: entry.key,
                          text: featureData['value'],
                        );
                      } else {
                        return _buildFeatureItem(
                          icon: featureData['icon'],
                          text: entry.key,
                        );
                      }
                    } else if (entry.value is IconData) {
                      // Pour les services (toujours IconData)
                      return _buildFeatureItem(
                        icon: entry.value,
                        text: entry.key,
                      );
                    } else {
                      // Fallback
                      return _buildFeatureItem(
                        icon: Icons.info_outline,
                        text: entry.key,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
// Widget pour afficher un item de caractéristique (style Airbnb)
Widget _buildFeatureItem({required IconData icon, required String text}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 16),
          child: Icon(icon, size: 24, color: const Color(0xFF2B2B2B)),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildAvisItem(AvisModel avis) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black.withAlpha(13)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nom de l'auteur
            Text(
              "${avis.profile?['prenom'] ?? ''} ${avis.profile?['nom'] ?? 'Anonyme'}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Date
            Text(
              "${_getMonthName(avis.createdAt.month)} ${avis.createdAt.year}",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Étoiles pour la note
        Row(
          children: List.generate(5, (index) {
            if (index < avis.note.floor()) {
              return const Icon(Icons.star, color: Colors.amber, size: 16);
            } else if (index < avis.note.ceil() && avis.note % 1 > 0) {
              return const Icon(Icons.star_half, color: Colors.amber, size: 16);
            } else {
              return const Icon(Icons.star_border, color: Colors.amber, size: 16);
            }
          }),
        ),
        const SizedBox(height: 8),
        // Commentaire
        Text(
          avis.commentaire,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}


// Fonction utilitaire pour obtenir le nom du mois
String _getMonthName(int month) {
  List<String> months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];
  return months[month - 1];
}


void _showAllReviews() {
  final double? reviewRating = widget.prestataire['note_moyenne'] != null 
      ? (widget.prestataire['note_moyenne'] is double 
          ? widget.prestataire['note_moyenne'] 
          : double.tryParse(widget.prestataire['note_moyenne'].toString()))
      : null;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // En-tête
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Tous les avis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF524B46),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                reviewRating?.toStringAsFixed(1) ?? "0.0",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Liste des avis
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _avis.length,
                  itemBuilder: (context, index) => _buildAvisItem(_avis[index]),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showFormulaCalculator(Map<String, dynamic> formula) {
  // Récupération des données
  final String formulaName = formula['nom_formule'] ?? 'Formule';
  final double basePrice = formula['prix_base'] is num ? 
    formula['prix_base'].toDouble() : 
    double.tryParse(formula['prix_base'].toString()) ?? 0.0;
  
  // Variables pour les options
  int guestCount = 50;
  DateTime? selectedDate;
  List<Map<String, dynamic>> selectedOptions = [];
  double totalPrice = basePrice;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // En-tête avec titre et bouton fermer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF524B46),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formulaName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${totalPrice.toInt()} €',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenu défilable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Nombre d'invités
                        const Text(
                          'Nombre d\'invités',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: guestCount.toDouble(),
                          min: 10,
                          max: 350,
                          divisions: 19,
                          label: guestCount.toString(),
                          activeColor: const Color(0xFF524B46),
                          onChanged: (value) {
                            setState(() {
                              guestCount = value.toInt();
                              // Recalcul du prix
                              totalPrice = basePrice;
                              if (guestCount > 100) {
                                totalPrice += (guestCount - 100) * 10;
                              }
                              for (var option in selectedOptions) {
                                totalPrice += option['prix'] ?? 0.0;
                              }
                            });
                          },
                        ),
                        Center(
                          child: Text(
                            '$guestCount invités',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Date
                        const Text(
                          'Date de l\'événement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                                // Majoration week-end
                                if (picked.weekday == DateTime.saturday || picked.weekday == DateTime.sunday) {
                                  totalPrice = basePrice * 1.2;
                                } else {
                                  totalPrice = basePrice;
                                }
                                // Réappliquer les autres majorations
                                if (guestCount > 100) {
                                  totalPrice += (guestCount - 100) * 10;
                                }
                                for (var option in selectedOptions) {
                                  totalPrice += option['prix'] ?? 0.0;
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDate != null 
                                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                    : 'Choisir une date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: selectedDate != null ? Colors.black : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Options supplémentaires
                        const Text(
                          'Options supplémentaires',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Options à cocher
                        _buildOptionCheckbox(
                          'Service de nettoyage',
                          'Nettoyage complet avant et après l\'événement',
                          250.0,
                          selectedOptions.any((o) => o['nom'] == 'Service de nettoyage'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Service de nettoyage',
                                  'prix': 250.0
                                });
                                totalPrice += 250.0;
                              } else {
                                selectedOptions.removeWhere((o) => o['nom'] == 'Service de nettoyage');
                                totalPrice -= 250.0;
                              }
                            });
                          },
                        ),
                        
                        _buildOptionCheckbox(
                          'Coordinateur sur place',
                          'Un coordinateur dédié pendant toute la durée de l\'événement',
                          500.0,
                          selectedOptions.any((o) => o['nom'] == 'Coordinateur sur place'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Coordinateur sur place',
                                  'prix': 500.0
                                });
                                totalPrice += 500.0;
                              } else {
                                selectedOptions.removeWhere((o) => o['nom'] == 'Coordinateur sur place');
                                totalPrice -= 500.0;
                              }
                            });
                          },
                        ),
                        
                        _buildOptionCheckbox(
                          'Hébergement',
                          'Chambres disponibles pour 20 personnes',
                          800.0,
                          selectedOptions.any((o) => o['nom'] == 'Hébergement'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Hébergement',
                                  'prix': 800.0
                                });
                                totalPrice += 800.0;
                              } else {
                                selectedOptions.removeWhere((o) => o['nom'] == 'Hébergement');
                                totalPrice -= 800.0;
                              }
                            });
                          },
                        ),
                        
                        _buildOptionCheckbox(
                          'Système son et lumière',
                          'Équipement professionnel pour votre soirée',
                          350.0,
                          selectedOptions.any((o) => o['nom'] == 'Système son et lumière'),
                          (isChecked) {
                            setState(() {
                              if (isChecked) {
                                selectedOptions.add({
                                  'nom': 'Système son et lumière',
                                  'prix': 350.0
                                });
                                totalPrice += 350.0;
                              } else {
                                selectedOptions.removeWhere((o) => o['nom'] == 'Système son et lumière');
                                totalPrice -= 350.0;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Bouton d'action en bas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${totalPrice.toInt()} €',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF524B46),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Ajouter au panier et fermer
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('features bientôt disponible'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF524B46),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: const Text(
                            'Téléchager le devis',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

  void _openGallery() {
  // Utiliser la même méthode que pour l'image principale
  final String imageUrl = _getMainImage();
      
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImageGalleryScreen(
        mainImageUrl: imageUrl,
        additionalImages: _galleryImages,
      ),
    ),
  );
}
String _getMainImage() {
  // Récupérer le type de prestataire
  int prestaTypeId = _getActualPrestaireType();
  
  // Pour les lieux (type_id = 1), chercher EXCLUSIVEMENT dans la table lieux
  if (prestaTypeId == 1) {
    if (widget.prestataire.containsKey('lieux')) {
      var lieuxData = widget.prestataire['lieux'];
      
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
    
    // Si aucune image n'est trouvée dans lieux, utiliser l'image par défaut pour les lieux
    return 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
  } 
  // Pour les autres types (2, 3, etc.), chercher EXCLUSIVEMENT dans la table presta
  else {
    if (widget.prestataire['image_url'] != null && 
        widget.prestataire['image_url'].toString().isNotEmpty) {
      return widget.prestataire['image_url'];
    }
    
    // Si aucune image n'est trouvée, utiliser l'image par défaut selon le type
    return _getDefaultImageByType(prestaTypeId);
  }
}
Widget buildLocationWidget(String address) {
  // Vérifier si l'adresse est véritablement non disponible
  bool isAddressAvailable = address.isNotEmpty && 
                            address != 'Adresse non disponible' && 
                            address != 'null';
  
  String displayAddress = isAddressAvailable ? address : 'Adresse non disponible';
  
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre "Adresse"
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            "Adresse",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B2B2B),
            ),
          ),
        ),
        
        // Contenu (adresse)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            displayAddress,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        
        // Bouton "Voir sur la carte" (seulement si l'adresse est disponible)
        if (isAddressAvailable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              icon: const Icon(
                Icons.map,
                color: Color(0xFF524B46),
              ),
              label: const Text(
                "Voir sur la carte",
                style: TextStyle(
                  color: Color(0xFF524B46),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF524B46)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                final encodedAddress = Uri.encodeComponent(address);
                final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedAddress");
                
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir la carte')),
                    );
                  }
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${e.toString()}')),
                  );
                }
              },
            ),
          ),
      ],
    ),
  );
}
    


Widget _buildOptionCheckbox(
  String title,
  String description,
  double price,
  bool isSelected,
  Function(bool) onChanged,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      border: Border.all(
        color: isSelected ? const Color(0xFF524B46) : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          const SizedBox(height: 4),
          Text(
            '${price.toInt()} €',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF524B46),
            ),
          ),
        ],
      ),
      value: isSelected,
      onChanged: (value) => onChanged(value ?? false),
      activeColor: const Color(0xFF524B46),
      checkColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      controlAffinity: ListTileControlAffinity.trailing,
    ),
  );
}

// Méthode pour traiter les données de lieu
void _processLieuData(Map<String, dynamic> lieu, Map<String, dynamic> features, Map<String, IconData> services) {
  print('Traitement des données lieu: ${lieu.keys}');
  
  try {
    // CARACTÉRISTIQUES NUMÉRIQUES
    // Capacité maximale
    if (lieu.containsKey('capacite_max') && lieu['capacite_max'] != null) {
      features['Capacité maximale'] = {
        'type': 'numeric',
        'value': lieu['capacite_max'],
        'unit': 'invités',
        'icon': Icons.people
      };
    }
    
    // Capacité minimale
    if (lieu.containsKey('capacite_min') && lieu['capacite_min'] != null) {
      features['Capacité minimale'] = {
        'type': 'numeric',
        'value': lieu['capacite_min'],
        'unit': 'invités',
        'icon': Icons.people_outline
      };
    }
    
    // Capacité d'hébergement
    if (lieu.containsKey('capacite_hebergement') && lieu['capacite_hebergement'] != null) {
      features['Capacité d\'hébergement'] = {
        'type': 'numeric',
        'value': lieu['capacite_hebergement'],
        'unit': 'couchages',
        'icon': Icons.hotel
      };
    }
    
    // Nombre de chambres
    if (lieu.containsKey('nombre_chambres') && lieu['nombre_chambres'] != null) {
      features['Nombre de chambres'] = {
        'type': 'numeric',
        'value': lieu['nombre_chambres'],
        'unit': '',
        'icon': Icons.bed
      };
    }
    
    // Superficie intérieure
    if (lieu.containsKey('superficie_interieur') && lieu['superficie_interieur'] != null) {
      features['Superficie intérieure'] = {
        'type': 'numeric',
        'value': lieu['superficie_interieur'],
        'unit': 'm²',
        'icon': Icons.square_foot
      };
    }
    
    // Superficie extérieure
    if (lieu.containsKey('superficie_exterieur') && lieu['superficie_exterieur'] != null) {
      features['Superficie extérieure'] = {
        'type': 'numeric',
        'value': lieu['superficie_exterieur'],
        'unit': 'm²',
        'icon': Icons.grass
      };
    }
    
    // CARACTÉRISTIQUES TEXTUELLES
    // Cadre
    if (lieu.containsKey('cadre') && lieu['cadre'] != null && lieu['cadre'].toString().isNotEmpty) {
      features['Cadre'] = {
        'type': 'text',
        'value': lieu['cadre'],
        'icon': Icons.landscape
      };
    }
    
    // CARACTÉRISTIQUES BOOLÉENNES - Traiter toutes les clés possibles
    Map<String, IconData> booleanFeatures = {
      'parking': Icons.local_parking,
      'exclusivite': Icons.verified_user,
      'hebergement': Icons.hotel,
      'feu_artifice': Icons.celebration,
      'espace_exterieur': Icons.terrain,
      'piscine': Icons.pool,
      'jardin': Icons.park,
      'parc': Icons.nature,
      'terrasse': Icons.deck,
      'cour': Icons.yard,
      'espace_ceremonie': Icons.celebration,
      'espace_cocktail': Icons.local_bar,
      'accessibilite_pmr': Icons.accessible,
      'disponibilite_weekend': Icons.weekend,
      'disponibilite_semaine': Icons.work,
      'espace_enfants': Icons.child_care,
      'climatisation': Icons.ac_unit,
      'espace_lacher_lanternes': Icons.light,
      'lieu_seance_photo': Icons.photo_camera,
      'acces_bateau_helicoptere': Icons.flight,
    };
    
    // SERVICES INCLUS - Traiter toutes les clés possibles
    Map<String, IconData> booleanServices = {
      'wifi': Icons.wifi,
      'systeme_sonorisation': Icons.speaker,
      'tables_fournies': Icons.table_bar,
      'chaises_fournies': Icons.event_seat,
      'nappes_fournies': Icons.table_restaurant,
      'vaisselle_fournie': Icons.restaurant,
      'eclairage': Icons.lightbulb,
      'sonorisation': Icons.surround_sound,
      'coordinateur_sur_place': Icons.people,
      'vestiaire': Icons.checkroom,
      'voiturier': Icons.car_rental,
    };
    
    // Ajouter les caractéristiques booléennes - avec vérification explicite de la valeur booléenne
    booleanFeatures.forEach((key, iconData) {
      // Vérifier que la clé existe et a une valeur booléenne true
      if (lieu.containsKey(key) && lieu[key] != null) {
        bool isEnabled = false;
        if (lieu[key] is bool) {
          isEnabled = lieu[key];
        } else if (lieu[key] is String) {
          isEnabled = lieu[key].toLowerCase() == 'true';
        } else if (lieu[key] is num) {
          isEnabled = lieu[key] > 0;
        }
        
        if (isEnabled) {
          String displayName = key
              .split('_')
              .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
              .join(' ');
          
          features[displayName] = {
            'type': 'boolean',
            'value': true,
            'icon': iconData
          };
        }
      }
    });
    
    // Ajouter les services booléens - avec vérification explicite de la valeur booléenne
    booleanServices.forEach((key, iconData) {
      // Vérifier que la clé existe et a une valeur booléenne true
      if (lieu.containsKey(key) && lieu[key] != null) {
        bool isEnabled = false;
        if (lieu[key] is bool) {
          isEnabled = lieu[key];
        } else if (lieu[key] is String) {
          isEnabled = lieu[key].toLowerCase() == 'true';
        } else if (lieu[key] is num) {
          isEnabled = lieu[key] > 0;
        }
        
        if (isEnabled) {
          String displayName = key
              .split('_')
              .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
              .join(' ');
          
          services[displayName] = iconData;
        }
      }
    });
    
    // Log des caractéristiques et services trouvés
    print('DEBUG LIEU: ${features.length} caractéristiques trouvées');
    print('DEBUG SERVICES: ${services.length} services trouvés');
  } catch (e) {
    print('Erreur lors du traitement des données lieu: $e');
    // En cas d'erreur, ajouter des valeurs par défaut
    _addDefaultLieuFeatures(features, services);
  }
}


// Méthode pour ajouter des valeurs par défaut si aucune donnée n'est trouvée
void _addDefaultLieuFeatures(Map<String, dynamic> features, Map<String, IconData> services) {
  features['Capacité maximale'] = {
    'type': 'numeric',
    'value': 200,
    'unit': 'invités',
    'icon': Icons.people
  };
  
  features['Capacité d\'hébergement'] = {
    'type': 'numeric',
    'value': 40,
    'unit': 'couchages',
    'icon': Icons.hotel
  };
  
  features['Parking'] = {
    'type': 'boolean',
    'value': true,
    'icon': Icons.local_parking
  };
  
  features['Exclusivité du lieu'] = {
    'type': 'boolean',
    'value': true,
    'icon': Icons.verified_user
  };
  
  features['Hébergement sur place'] = {
    'type': 'boolean',
    'value': true,
    'icon': Icons.hotel
  };
  
  features['Feu d\'artifice autorisé'] = {
    'type': 'boolean',
    'value': true,
    'icon': Icons.celebration
  };
  
  features['Espace extérieur'] = {
    'type': 'boolean',
    'value': true,
    'icon': Icons.terrain
  };
  
  // Services par défaut
  services['Wi-Fi'] = Icons.wifi;
  services['Sonorisation'] = Icons.speaker;
  services['Tables fournies'] = Icons.table_bar;
  services['Chaises fournies'] = Icons.event_seat;
}
  
}