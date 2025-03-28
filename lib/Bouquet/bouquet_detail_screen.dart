import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../buttons/AnimatedReserveButton.dart';


import 'bouquet_venue_selection_screen.dart';
import 'bouquet_caterer_selection_screen.dart';
import 'bouquet_photographer_selection_screen.dart';

class BouquetSummaryScreen extends StatefulWidget {
  final String? bouquetId;
  final Map<String, dynamic>? bouquet; // Can pass bouquet data directly

  const BouquetSummaryScreen({
    Key? key,
    this.bouquetId,
    this.bouquet,
  }) : assert(bouquetId != null || bouquet != null),
       super(key: key);

  @override
  State<BouquetSummaryScreen> createState() => _BouquetSummaryScreenState();
}

class _BouquetSummaryScreenState extends State<BouquetSummaryScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _bouquetData;
  double _totalBudget = 0;
  
  // Prestataires sélectionnés
  Map<String, dynamic>? _venue;
  Map<String, dynamic>? _caterer;
  Map<String, dynamic>? _photographer;
  
  // Détails des tarifs pour chaque prestataire
  Map<String, dynamic>? _venueTarif;
  Map<String, dynamic>? _catererTarif;
  Map<String, dynamic>? _photographerTarif;

  @override
  void initState() {
    super.initState();
    if (widget.bouquet != null) {
      _bouquetData = widget.bouquet;
      _processInitialData();
    } else if (widget.bouquetId != null) {
      _loadBouquetData(widget.bouquetId!);
    } else {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Aucun ID de bouquet fourni')),
        );
      });
    }
  }

  Future<void> _processInitialData() async {
    if (_bouquetData != null) {
      // Extraire les données des prestataires
      if (_bouquetData!.containsKey('lieux') && _bouquetData!['lieux'] != null) {
        _venue = _bouquetData!['lieux'];
        await _loadTarif('lieu', _venue!['id']);
      }
      
      if (_bouquetData!.containsKey('traiteurs') && _bouquetData!['traiteurs'] != null) {
        _caterer = _bouquetData!['traiteurs'];
        await _loadTarif('traiteur', _caterer!['id']);
      }
      
      if (_bouquetData!.containsKey('photographes') && _bouquetData!['photographes'] != null) {
        _photographer = _bouquetData!['photographes'];
        await _loadTarif('photographe', _photographer!['id']);
      }
      
      _calculateTotalBudget();
      
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTarif(String type, String prestaId) async {
    try {
      // Récupérer le meilleur tarif (le moins cher) pour ce prestataire
      final response = await Supabase.instance.client
          .from('tarifs')
          .select('*')
          .eq('presta_id', prestaId)
          .eq('actif', true)
          .order('prix_base', ascending: true)
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        Map<String, dynamic> tarif = {};
        response.forEach((key, value) {
          tarif[key.toString()] = value;
        });
        
        // Assigner le tarif au bon prestataire
        switch (type) {
          case 'lieu':
            _venueTarif = tarif;
            break;
          case 'traiteur':
            _catererTarif = tarif;
            break;
          case 'photographe':
            _photographerTarif = tarif;
            break;
        }
      }
    } catch (e) {
      print('Erreur lors du chargement du tarif pour $type: $e');
    }
  }

  Future<void> _loadBouquetData(String bouquetId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les données du bouquet avec tous les prestataires sélectionnés
      final response = await Supabase.instance.client
          .from('bouquets')
          .select('*, lieux:lieu_id(*), traiteurs:traiteur_id(*), photographes:photographe_id(*)')
          .eq('id', bouquetId)
          .single();

      if (response != null) {
        _bouquetData = {};
        response.forEach((key, value) {
          _bouquetData![key.toString()] = value;
        });
        
        // Traiter les données et charger les tarifs
        await _processInitialData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotalBudget() {
    _totalBudget = 0;
    final int guestCount = _bouquetData?['guest_count'] ?? 50;
    DateTime? eventDate;
    bool isWeekend = false;
    
    // Déterminer si la date est un week-end
    if (_bouquetData?['event_date'] != null) {
      try {
        eventDate = DateTime.parse(_bouquetData!['event_date']);
        isWeekend = eventDate.weekday == DateTime.saturday || eventDate.weekday == DateTime.sunday;
      } catch (e) {
        // Ignorer les erreurs de parsing de date
      }
    }
    
    // Calculer le prix du lieu
    if (_venue != null) {
      // Si nous avons un tarif spécifique pour ce lieu
      if (_venueTarif != null) {
        double basePrice = _venueTarif!['prix_base'] is num 
            ? _venueTarif!['prix_base'].toDouble() 
            : double.tryParse(_venueTarif!['prix_base'].toString()) ?? 0;
        
        // Appliquer le tarif par personne si nécessaire
        if (_venueTarif!['type_prix'] == 'par_personne') {
          basePrice *= guestCount;
        }
        
        // Appliquer coefficient week-end si nécessaire
        if (isWeekend && _venueTarif!['coef_weekend'] != null) {
          double weekendCoef = _venueTarif!['coef_weekend'] is num 
              ? _venueTarif!['coef_weekend'].toDouble() 
              : double.tryParse(_venueTarif!['coef_weekend'].toString()) ?? 1.0;
          basePrice *= weekendCoef;
        }
        
        _totalBudget += basePrice;
      } 
      // Fallback sur le prix de base du prestataire
      else if (_venue!.containsKey('prix_base') && _venue!['prix_base'] != null) {
        final price = _venue!['prix_base'];
        if (price is num) {
          _totalBudget += price.toDouble();
        } else if (price is String) {
          _totalBudget += double.tryParse(price) ?? 0;
        }
      }
    }
    
    // Calculer le prix du traiteur
    if (_caterer != null) {
      // Si nous avons un tarif spécifique pour ce traiteur
      if (_catererTarif != null) {
        double basePrice = _catererTarif!['prix_base'] is num 
            ? _catererTarif!['prix_base'].toDouble() 
            : double.tryParse(_catererTarif!['prix_base'].toString()) ?? 0;
        
        // Appliquer le tarif par personne si nécessaire
        if (_catererTarif!['type_prix'] == 'par_personne') {
          basePrice *= guestCount;
        }
        
        // Appliquer coefficient week-end si nécessaire
        if (isWeekend && _catererTarif!['coef_weekend'] != null) {
          double weekendCoef = _catererTarif!['coef_weekend'] is num 
              ? _catererTarif!['coef_weekend'].toDouble() 
              : double.tryParse(_catererTarif!['coef_weekend'].toString()) ?? 1.0;
          basePrice *= weekendCoef;
        }
        
        _totalBudget += basePrice;
      } 
      // Fallback sur le prix de base du prestataire
      else if (_caterer!.containsKey('prix_base') && _caterer!['prix_base'] != null) {
        final price = _caterer!['prix_base'];
        if (price is num) {
          _totalBudget += price.toDouble();
        } else if (price is String) {
          _totalBudget += double.tryParse(price) ?? 0;
        }
      }
    }
    
    // Calculer le prix du photographe
    if (_photographer != null) {
      // Si nous avons un tarif spécifique pour ce photographe
      if (_photographerTarif != null) {
        double basePrice = _photographerTarif!['prix_base'] is num 
            ? _photographerTarif!['prix_base'].toDouble() 
            : double.tryParse(_photographerTarif!['prix_base'].toString()) ?? 0;
        
        // Les photographes ont rarement un tarif par personne,
        // mais on applique quand même la logique par cohérence
        if (_photographerTarif!['type_prix'] == 'par_personne') {
          basePrice *= guestCount;
        }
        
        // Appliquer coefficient week-end si nécessaire
        if (isWeekend && _photographerTarif!['coef_weekend'] != null) {
          double weekendCoef = _photographerTarif!['coef_weekend'] is num 
              ? _photographerTarif!['coef_weekend'].toDouble() 
              : double.tryParse(_photographerTarif!['coef_weekend'].toString()) ?? 1.0;
          basePrice *= weekendCoef;
        }
        
        _totalBudget += basePrice;
      } 
      // Fallback sur le prix de base du prestataire
      else if (_photographer!.containsKey('prix_base') && _photographer!['prix_base'] != null) {
        final price = _photographer!['prix_base'];
        if (price is num) {
          _totalBudget += price.toDouble();
        } else if (price is String) {
          _totalBudget += double.tryParse(price) ?? 0;
        }
      }
    }
  }

  // Méthode pour naviguer vers l'écran de sélection du lieu
  void _navigateToVenueSelection() {
    if (_bouquetData != null && _bouquetData!['id'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BouquetVenueSelectionScreen(bouquetId: _bouquetData!['id']),
        ),
      ).then((_) {
        // Recharger les données après retour à cet écran
        if (_bouquetData != null && _bouquetData!['id'] != null) {
          _loadBouquetData(_bouquetData!['id']!);
        }
      });
    }
  }

  // Méthode pour naviguer vers l'écran de sélection du traiteur
  void _navigateToCatererSelection() {
    if (_bouquetData != null && _bouquetData!['id'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BouquetCatererSelectionScreen(bouquetId: _bouquetData!['id']),
        ),
      ).then((_) {
        // Recharger les données après retour à cet écran
        if (_bouquetData != null && _bouquetData!['id'] != null) {
          _loadBouquetData(_bouquetData!['id']!);
        }
      });
    }
  }

  // Méthode pour naviguer vers l'écran de sélection du photographe
  void _navigateToPhotographerSelection() {
    if (_bouquetData != null && _bouquetData!['id'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BouquetPhotographerSelectionScreen(bouquetId: _bouquetData!['id']),
        ),
      ).then((_) {
        // Recharger les données après retour à cet écran
        if (_bouquetData != null && _bouquetData!['id'] != null) {
          _loadBouquetData(_bouquetData!['id']!);
        }
      });
    }
  }

  // Méthode pour contacter tous les prestataires
  void _contactAllProviders() {
    // Collecter les emails des prestataires
    List<String> emails = [];
    if (_venue != null && _venue!.containsKey('email') && _venue!['email'] != null) {
      emails.add(_venue!['email']);
    }
    if (_caterer != null && _caterer!.containsKey('email') && _caterer!['email'] != null) {
      emails.add(_caterer!['email']);
    }
    if (_photographer != null && _photographer!.containsKey('email') && _photographer!['email'] != null) {
      emails.add(_photographer!['email']);
    }

    // Vérifier qu'il y a au moins un email
    if (emails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun prestataire à contacter')),
      );
      return;
    }

    // Afficher un dialogue de confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter les prestataires'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vous allez contacter les prestataires suivants :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_venue != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_venue!['nom_entreprise'] ?? 'Lieu non spécifié'),
                    ),
                  ],
                ),
              ),
            if (_caterer != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_caterer!['nom_entreprise'] ?? 'Traiteur non spécifié'),
                    ),
                  ],
                ),
              ),
            if (_photographer != null)
              Row(
                children: [
                  const Icon(Icons.camera_alt, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_photographer!['nom_entreprise'] ?? 'Photographe non spécifié'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            const Text(
              'Un email groupé sera envoyé pour coordonner votre mariage.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Simuler l'envoi d'email (à remplacer par l'implémentation réelle)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email envoyé aux prestataires'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _returnToHome() {
    // Approche la plus simple et la plus fiable
    // Utiliser Navigator.of(context).pop() jusqu'à ce qu'on atteigne l'écran d'accueil
    
    // Montrer le message de succès d'abord
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Votre bouquet a été créé avec succès'),
        duration: Duration(seconds: 3),
      ),
    );
    
    // Simplement fermer cet écran
    // Si la pile de navigation est correctement configurée,
    // cela devrait nous ramener à l'écran d'accueil
    Navigator.of(context).pop();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date non définie';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date non définie';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color grisTexte = Theme.of(context).colorScheme.onSurface;
    final Color beige = Theme.of(context).colorScheme.secondary;
    
    final String bouquetName = _bouquetData?['name'] ?? 'Mon bouquet';
    final String eventDate = _formatDate(_bouquetData?['event_date']);
    final int guestCount = _bouquetData?['guest_count'] ?? 0;
    
    // Vérifier si tous les prestataires sont sélectionnés
    final bool isComplete = _venue != null && _caterer != null && _photographer != null;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Résumé du bouquet'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Bannière de succès
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    color: accentColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bouquet de fleurs SVG
                        SvgPicture.asset(
                          'assets/images/13.svg',
                          height: 130,
                          width: 130,
                          // Si l'image n'est pas trouvée, afficher une icône de succès
                          placeholderBuilder: (context) => Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 72,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Votre bouquet est créé !',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isComplete 
                            ? 'Tous les prestataires ont été sélectionnés' 
                            : 'Vous pourrez compléter votre sélection plus tard',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Informations du bouquet
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: beige.withOpacity(0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          bouquetName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: grisTexte,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: grisTexte.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              eventDate,
                              style: TextStyle(
                                fontSize: 16,
                                color: grisTexte.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.people,
                              size: 16,
                              color: grisTexte.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$guestCount invités',
                              style: TextStyle(
                                fontSize: 16,
                                color: grisTexte.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Budget total
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Budget total estimé',
                              style: TextStyle(
                                fontSize: 18,
                                color: grisTexte,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${NumberFormat('#,###').format(_totalBudget.toInt())} €',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Résumé des prestataires sélectionnés
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prestataires sélectionnés',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: grisTexte,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Liste des prestataires avec possibilité de modification
                        InkWell(
                          onTap: _navigateToVenueSelection,
                          child: _buildProviderSummaryItem(
                            title: 'Lieu',
                            name: _venue != null ? _venue!['nom_entreprise'] : null,
                            price: _getProviderPrice('lieu'),
                            icon: Icons.location_on,
                            isSelected: _venue != null,
                            onEdit: _navigateToVenueSelection,
                          ),
                        ),
                        const Divider(height: 32),
                        InkWell(
                          onTap: _navigateToCatererSelection,
                          child: _buildProviderSummaryItem(
                            title: 'Traiteur',
                            name: _caterer != null ? _caterer!['nom_entreprise'] : null,
                            price: _getProviderPrice('traiteur'),
                            icon: Icons.restaurant,
                            isSelected: _caterer != null,
                            onEdit: _navigateToCatererSelection,
                          ),
                        ),
                        const Divider(height: 32),
                        InkWell(
                          onTap: _navigateToPhotographerSelection,
                          child: _buildProviderSummaryItem(
                            title: 'Photographe',
                            name: _photographer != null ? _photographer!['nom_entreprise'] : null,
                            price: _getProviderPrice('photographe'),
                            icon: Icons.camera_alt,
                            isSelected: _photographer != null,
                            onEdit: _navigateToPhotographerSelection,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bouton pour contacter tous les prestataires
                  if (_venue != null || _caterer != null || _photographer != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _contactAllProviders,
                          icon: const Icon(Icons.email),
                          label: const Text('Contacter tous les prestataires'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Message de félicitations et instructions
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: beige.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Félicitations !',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Vous retrouverez votre bouquet dans la section "Mes Bouquets". Vous pourrez y accéder à tout moment pour ${isComplete ? 'le consulter ou le modifier.' : 'compléter votre sélection de prestataires.'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: grisTexte,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bouton de retour à l'accueil
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: AnimatedReserveButton(
                        text: 'Retourner à l\'accueil',
                        onPressed: _returnToHome,
                      ),
                    ),
                  ),
                  
                  // Espace en bas
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
  
  double _getProviderPrice(String type) {
    final int guestCount = _bouquetData?['guest_count'] ?? 50;
    bool isWeekend = false;
    
    // Déterminer si la date est un week-end
    if (_bouquetData?['event_date'] != null) {
      try {
        final date = DateTime.parse(_bouquetData!['event_date']);
        isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      } catch (e) {
        // Ignorer les erreurs de parsing de date
      }
    }
    
    // Calculer le prix selon le type de prestataire
    switch (type) {
      case 'lieu':
        if (_venueTarif != null) {
          double basePrice = _venueTarif!['prix_base'] is num 
              ? _venueTarif!['prix_base'].toDouble() 
              : double.tryParse(_venueTarif!['prix_base'].toString()) ?? 0;
              
          if (_venueTarif!['type_prix'] == 'par_personne') {
            basePrice *= guestCount;
          }
          
          if (isWeekend && _venueTarif!['coef_weekend'] != null) {
            double weekendCoef = _venueTarif!['coef_weekend'] is num 
                ? _venueTarif!['coef_weekend'].toDouble() 
                : double.tryParse(_venueTarif!['coef_weekend'].toString()) ?? 1.0;
            basePrice *= weekendCoef;
          }
          
          return basePrice;
        } else if (_venue != null && _venue!.containsKey('prix_base')) {
          final price = _venue!['prix_base'];
          if (price is num) {
            return price.toDouble();
          } else if (price is String) {
            return double.tryParse(price) ?? 0;
          }
        }
        break;
        
      case 'traiteur':
        if (_catererTarif != null) {
          double basePrice = _catererTarif!['prix_base'] is num 
              ? _catererTarif!['prix_base'].toDouble() 
              : double.tryParse(_catererTarif!['prix_base'].toString()) ?? 0;
              
          if (_catererTarif!['type_prix'] == 'par_personne') {
            basePrice *= guestCount;
          }
          
          if (isWeekend && _catererTarif!['coef_weekend'] != null) {
            double weekendCoef = _catererTarif!['coef_weekend'] is num 
                ? _catererTarif!['coef_weekend'].toDouble() 
                : double.tryParse(_catererTarif!['coef_weekend'].toString()) ?? 1.0;
            basePrice *= weekendCoef;
          }
          
          return basePrice;
        } else if (_caterer != null && _caterer!.containsKey('prix_base')) {
          final price = _caterer!['prix_base'];
          if (price is num) {
            return price.toDouble();
          } else if (price is String) {
            return double.tryParse(price) ?? 0;
          }
        }
        break;
        
      case 'photographe':
        if (_photographerTarif != null) {
          double basePrice = _photographerTarif!['prix_base'] is num 
              ? _photographerTarif!['prix_base'].toDouble() 
              : double.tryParse(_photographerTarif!['prix_base'].toString()) ?? 0;
              
          if (_photographerTarif!['type_prix'] == 'par_personne') {
            basePrice *= guestCount;
          }
          
          if (isWeekend && _photographerTarif!['coef_weekend'] != null) {
            double weekendCoef = _photographerTarif!['coef_weekend'] is num 
                ? _photographerTarif!['coef_weekend'].toDouble() 
                : double.tryParse(_photographerTarif!['coef_weekend'].toString()) ?? 1.0;
            basePrice *= weekendCoef;
          }
          
          return basePrice;
        } else if (_photographer != null && _photographer!.containsKey('prix_base')) {
          final price = _photographer!['prix_base'];
          if (price is num) {
            return price.toDouble();
          } else if (price is String) {
            return double.tryParse(price) ?? 0;
          }
        }
        break;
    }
    
    return 0;
  }
  
  Widget _buildProviderSummaryItem({
    required String title,
    String? name,
    required IconData icon,
    required bool isSelected,
    required double price,
    required VoidCallback onEdit,
  }) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final Color grisTexte = Theme.of(context).colorScheme.onSurface;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: grisTexte.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSelected ? name! : 'Non sélectionné',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? grisTexte : Colors.grey,
                ),
              ),
              if (isSelected && price > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${NumberFormat('#,###').format(price.toInt())} €',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Bouton d'édition (utilise l'icône edit si sélectionné, add si non sélectionné)
        IconButton(
          icon: Icon(
            isSelected ? Icons.edit : Icons.add_circle,
            color: isSelected ? accentColor : Colors.grey,
            size: 20,
          ),
          onPressed: onEdit,
          tooltip: isSelected ? 'Modifier' : 'Ajouter',
        ),
      ],
    );
  }
}