import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import './comparison_provider.dart';
import '../DetailsScreen/PrestaireDetailScreen.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final prestataires = comparisonProvider.prestatairesToCompare;
    
    // Vérifier s'il y a assez de prestataires à comparer
    if (prestataires.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Comparaison'),
          backgroundColor: const Color(0xFF524B46),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Aucun prestataire à comparer. Ajoutez des lieux pour les comparer.'),
        ),
      );
    }

    // S'il n'y a qu'un seul prestataire, afficher un message
    if (prestataires.length == 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Comparaison'),
          backgroundColor: const Color(0xFF524B46),
          foregroundColor: Colors.white,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Ajoutez un autre lieu pour comparer avec ${prestataires[0]['nom_entreprise']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retour à la recherche'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                comparisonProvider.clearComparison();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF524B46),
              ),
              child: const Text('Vider la sélection'),
            ),
          ],
        ),
      );
    }

    // Construction de l'écran de comparaison avec 2 prestataires
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Comparison'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              comparisonProvider.clearComparison();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Images et noms
            _buildImagesAndNames(prestataires, context),
            
            // Caractéristiques principales
            _buildMainFeatures(prestataires),
            
            // Capacité
            _buildComparisonSection(
              'Capacité maximale', 
              prestataires, 
              (p) => _getCapaciteMax(p).toString() + ' invités',
            ),
            
            // Budget
            _buildComparisonSection(
              'Budget type', 
              prestataires, 
              (p) => _getBudgetType(p),
            ),
            
            // Superficie intérieure
            _buildComparisonSection(
              'Superficie intérieure', 
              prestataires, 
              (p) => (_getSuperficieInterieur(p) > 0 ? '${_getSuperficieInterieur(p)} m²' : 'Non spécifié'),
            ),
            
            // Superficie extérieure
            _buildComparisonSection(
              'Superficie extérieure', 
              prestataires, 
              (p) => (_getSuperficieExterieur(p) > 0 ? '${_getSuperficieExterieur(p)} m²' : 'Non spécifié'),
            ),
            
            // Hébergement
            _buildComparisonSection(
              'Capacité hébergement', 
              prestataires, 
              (p) => _getHebergementInfo(p),
            ),
            
            // Services principaux
            _buildBooleanComparisonSection(
              'Services', 
              prestataires, 
              [
                {'label': 'Wifi', 'key': 'wifi'},
                {'label': 'Parking', 'key': 'parking'},
                {'label': 'Espace extérieur', 'key': 'espace_exterieur'},
                {'label': 'Piscine', 'key': 'piscine'},
                {'label': 'Exclusivité', 'key': 'exclusivite'},
                {'label': 'Climatisation', 'key': 'climatisation'},
              ]
            ),
            
            // Équipements
            _buildBooleanComparisonSection(
              'Équipements', 
              prestataires, 
              [
                {'label': 'Tables fournies', 'key': 'tables_fournies'},
                {'label': 'Chaises fournies', 'key': 'chaises_fournies'},
                {'label': 'Nappes fournies', 'key': 'nappes_fournies'},
                {'label': 'Vaisselle fournie', 'key': 'vaisselle_fournie'},
                {'label': 'Sonorisation', 'key': 'sonorisation'},
                {'label': 'Éclairage', 'key': 'eclairage'},
              ]
            ),
            
            // Espaces
            _buildBooleanComparisonSection(
              'Espaces', 
              prestataires, 
              [
                {'label': 'Jardin', 'key': 'jardin'},
                {'label': 'Parc', 'key': 'parc'},
                {'label': 'Terrasse', 'key': 'terrasse'},
                {'label': 'Cour', 'key': 'cour'},
                {'label': 'Espace cérémonie', 'key': 'espace_ceremonie'},
                {'label': 'Espace cocktail', 'key': 'espace_cocktail'},
              ]
            ),
            
            // Services supplémentaires
            _buildBooleanComparisonSection(
              'Services supplémentaires', 
              prestataires, 
              [
                {'label': 'Coordinateur sur place', 'key': 'coordinateur_sur_place'},
                {'label': 'Vestiaire', 'key': 'vestiaire'},
                {'label': 'Voiturier', 'key': 'voiturier'},
                {'label': 'Espace enfants', 'key': 'espace_enfants'},
                {'label': 'Accessibilité PMR', 'key': 'accessibilite_pmr'},
                {'label': 'Feu d\'artifice autorisé', 'key': 'feu_artifice'},
              ]
            ),
            
            // Boutons d'action
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToDetails(context, prestataires[0]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF524B46),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Voir ${prestataires[0]['nom_entreprise']}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToDetails(context, prestataires[1]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF524B46),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Voir ${prestataires[1]['nom_entreprise']}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget pour les images et noms des prestataires
  Widget _buildImagesAndNames(List<Map<String, dynamic>> prestataires, BuildContext context) {
    return Row(
      children: prestataires.map((prestataire) {
        return Expanded(
          child: Column(
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: _getImageUrl(prestataire),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.business, size: 50),
                ),
              ),
              
              // Nom et région
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      prestataire['nom_entreprise'] ?? 'Sans nom',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prestataire['region'] ?? 'Région non spécifiée',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Prix (si disponible)
                    if (_getPrixBase(prestataire) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${_getPrixBase(prestataire)}€',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF524B46),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  // Widget pour les caractéristiques principales
  Widget _buildMainFeatures(List<Map<String, dynamic>> prestataires) {
    return Column(
      children: [
        _buildComparisonRow(
          prestataires,
          (p) => _getNoteDisplay(p),
        ),
        _buildComparisonRow(
          prestataires,
          (p) => _getVerifiedBadge(p),
        ),
      ],
    );
  }
  
  // Widget pour une section de comparaison
  Widget _buildComparisonSection(String title, List<Map<String, dynamic>> prestataires, String Function(Map<String, dynamic>) valueGetter) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          children: prestataires.map((p) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Text(
                  valueGetter(p),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  // Widget pour une ligne de comparaison
  Widget _buildComparisonRow(List<Map<String, dynamic>> prestataires, Widget Function(Map<String, dynamic>) contentBuilder) {
    return Row(
      children: prestataires.map((p) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: contentBuilder(p)),
          ),
        );
      }).toList(),
    );
  }
  
  // Widget pour les caractéristiques booléennes
  Widget _buildBooleanComparisonSection(String title, List<Map<String, dynamic>> prestataires, List<Map<String, String>> features) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ...features.map((feature) {
          return Row(
            children: [
              // Label de la caractéristique
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    feature['label']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              
              // Valeurs pour chaque prestataire
              ...prestataires.map((p) {
                return Expanded(
                  flex: 1,
                  child: Center(
                    child: _getBooleanValue(p, feature['key']!) 
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      : const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  // Helper pour récupérer l'URL de l'image
  String _getImageUrl(Map<String, dynamic> prestataire) {
    // Image du lieu si disponible
    if (prestataire.containsKey('lieux') && prestataire['lieux'] != null) {
      var lieuxData = prestataire['lieux'];
      
      if (lieuxData is List && lieuxData.isNotEmpty) {
        var lieuItem = lieuxData[0];
        if (lieuItem is Map && 
            lieuItem.containsKey('image_url') && 
            lieuItem['image_url'] != null &&
            lieuItem['image_url'].toString().isNotEmpty) {
          return lieuItem['image_url'];
        }
      } else if (lieuxData is Map && 
                 lieuxData.containsKey('image_url') && 
                 lieuxData['image_url'] != null &&
                 lieuxData['image_url'].toString().isNotEmpty) {
        return lieuxData['image_url'];
      }
    }
    
    // Image du prestataire si disponible
    if (prestataire.containsKey('image_url') && 
        prestataire['image_url'] != null && 
        prestataire['image_url'].toString().isNotEmpty) {
      return prestataire['image_url'];
    }
    
    // Image par défaut
    return 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2940&auto=format&fit=crop';
  }
  
  // Helper pour récupérer la note
  Widget _getNoteDisplay(Map<String, dynamic> prestataire) {
    final double? rating = prestataire['note_moyenne'] != null 
        ? (prestataire['note_moyenne'] is double 
            ? prestataire['note_moyenne'] 
            : double.tryParse(prestataire['note_moyenne'].toString()))
        : null;
        
    if (rating == null) {
      return Text('Pas de note', style: TextStyle(color: Colors.grey[600]));
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: 18),
        SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  // Helper pour afficher le badge vérifié
  Widget _getVerifiedBadge(Map<String, dynamic> prestataire) {
    final bool isVerified = prestataire['verifie'] == true || prestataire['is_verified'] == true;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? Color(0xFF1A4D2E) : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isVerified ? 'Vérifié' : 'Non vérifié',
        style: TextStyle(
          color: isVerified ? Colors.white : Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Helper pour le prix de base
  double _getPrixBase(Map<String, dynamic> prestataire) {
    // Essayer de récupérer le prix à partir de tarifs
    if (prestataire.containsKey('tarifs') && 
        prestataire['tarifs'] is List && 
        prestataire['tarifs'].isNotEmpty) {
      
      var lowestPrice = double.infinity;
      for (var tarif in prestataire['tarifs']) {
        if (tarif is Map && tarif.containsKey('prix_base')) {
          double? price = tarif['prix_base'] is double 
              ? tarif['prix_base'] 
              : double.tryParse(tarif['prix_base'].toString());
              
          if (price != null && price < lowestPrice) {
            lowestPrice = price;
          }
        }
      }
      
      if (lowestPrice != double.infinity) {
        return lowestPrice;
      }
    }
    
    // Prix de base direct
    if (prestataire.containsKey('prix_base') && prestataire['prix_base'] != null) {
      return prestataire['prix_base'] is double 
          ? prestataire['prix_base'] 
          : (double.tryParse(prestataire['prix_base'].toString()) ?? 0.0);
    }
    
    return 0.0;
  }
  
  // Helper pour la capacité max
  int _getCapaciteMax(Map<String, dynamic> prestataire) {
    if (prestataire.containsKey('lieux')) {
      var lieuxData = prestataire['lieux'];
      
      if (lieuxData is List && lieuxData.isNotEmpty) {
        var lieu = lieuxData[0];
        if (lieu is Map && lieu.containsKey('capacite_max') && lieu['capacite_max'] != null) {
          return lieu['capacite_max'] is int 
              ? lieu['capacite_max'] 
              : (int.tryParse(lieu['capacite_max'].toString()) ?? 0);
        }
      } else if (lieuxData is Map && 
                 lieuxData.containsKey('capacite_max') && 
                 lieuxData['capacite_max'] != null) {
        return lieuxData['capacite_max'] is int 
            ? lieuxData['capacite_max'] 
            : (int.tryParse(lieuxData['capacite_max'].toString()) ?? 0);
      }
    }
    
    return 0;
  }
  
  // Helper pour le type de budget
  String _getBudgetType(Map<String, dynamic> prestataire) {
    if (prestataire.containsKey('type_budget')) {
      String budget = prestataire['type_budget'].toString().toLowerCase();
      
      switch (budget) {
        case 'abordable':
          return 'Abordable';
        case 'premium':
          return 'Premium';
        case 'luxe':
          return 'Luxe';
        default:
          return budget.substring(0, 1).toUpperCase() + budget.substring(1);
      }
    }
    
    return 'Non spécifié';
  }
  
  // Helper pour la superficie intérieure
  double _getSuperficieInterieur(Map<String, dynamic> prestataire) {
    if (prestataire.containsKey('lieux')) {
      var lieuxData = prestataire['lieux'];
      
      if (lieuxData is List && lieuxData.isNotEmpty) {
        var lieu = lieuxData[0];
        if (lieu is Map && lieu.containsKey('superficie_interieur') && lieu['superficie_interieur'] != null) {
          return lieu['superficie_interieur'] is double 
              ? lieu['superficie_interieur'] 
              : (double.tryParse(lieu['superficie_interieur'].toString()) ?? 0.0);
        }
      } else if (lieuxData is Map && 
                 lieuxData.containsKey('superficie_interieur') && 
                 lieuxData['superficie_interieur'] != null) {
        return lieuxData['superficie_interieur'] is double 
            ? lieuxData['superficie_interieur'] 
            : (double.tryParse(lieuxData['superficie_interieur'].toString()) ?? 0.0);
      }
    }
    
    return 0.0;
  }
  
  // Helper pour la superficie extérieure
  double _getSuperficieExterieur(Map<String, dynamic> prestataire) {
    if (prestataire.containsKey('lieux')) {
      var lieuxData = prestataire['lieux'];
      
      if (lieuxData is List && lieuxData.isNotEmpty) {
        var lieu = lieuxData[0];
        if (lieu is Map && lieu.containsKey('superficie_exterieur') && lieu['superficie_exterieur'] != null) {
          return lieu['superficie_exterieur'] is double 
              ? lieu['superficie_exterieur'] 
              : (double.tryParse(lieu['superficie_exterieur'].toString()) ?? 0.0);
        }
      } else if (lieuxData is Map && 
                 lieuxData.containsKey('superficie_exterieur') && 
                 lieuxData['superficie_exterieur'] != null) {
        return lieuxData['superficie_exterieur'] is double 
            ? lieuxData['superficie_exterieur'] 
            : (double.tryParse(lieuxData['superficie_exterieur'].toString()) ?? 0.0);
      }
    }
    
    return 0.0;
  }
  
  // Helper pour les informations d'hébergement
  String _getHebergementInfo(Map<String, dynamic> prestataire) {
    bool hasHebergement = false;
    int capaciteHebergement = 0;
    int nombreChambres = 0;
    
    if (prestataire.containsKey('lieux')) {
      var lieuxData = prestataire['lieux'];
      
      if (lieuxData is List && lieuxData.isNotEmpty) {
        var lieu = lieuxData[0];
        if (lieu is Map) {
          if (lieu.containsKey('hebergement') && lieu['hebergement'] != null) {
            hasHebergement = lieu['hebergement'] is bool 
                ? lieu['hebergement'] 
                : lieu['hebergement'].toString().toLowerCase() == 'true';
          }
          
          if (lieu.containsKey('capacite_hebergement') && lieu['capacite_hebergement'] != null) {
            capaciteHebergement = lieu['capacite_hebergement'] is int 
                ? lieu['capacite_hebergement'] 
                : (int.tryParse(lieu['capacite_hebergement'].toString()) ?? 0);
          }
          
          if (lieu.containsKey('nombre_chambres') && lieu['nombre_chambres'] != null) {
            nombreChambres = lieu['nombre_chambres'] is int 
                ? lieu['nombre_chambres'] 
                : (int.tryParse(lieu['nombre_chambres'].toString()) ?? 0);
          }
        }
      } else if (lieuxData is Map) {
        if (lieuxData.containsKey('hebergement') && lieuxData['hebergement'] != null) {
          hasHebergement = lieuxData['hebergement'] is bool 
              ? lieuxData['hebergement'] 
              : lieuxData['hebergement'].toString().toLowerCase() == 'true';
        }
        
        if (lieuxData.containsKey('capacite_hebergement') && lieuxData['capacite_hebergement'] != null) {
          capaciteHebergement = lieuxData['capacite_hebergement'] is int 
              ? lieuxData['capacite_hebergement'] 
              : (int.tryParse(lieuxData['capacite_hebergement'].toString()) ?? 0);
        }
        
        if (lieuxData.containsKey('nombre_chambres') && lieuxData['nombre_chambres'] != null) {
          nombreChambres = lieuxData['nombre_chambres'] is int 
              ? lieuxData['nombre_chambres'] 
              : (int.tryParse(lieuxData['nombre_chambres'].toString()) ?? 0);
        }
      }
    }
    
    if (!hasHebergement) {
      return 'Non disponible';
    }
    
    if (capaciteHebergement > 0 && nombreChambres > 0) {
      return '$capaciteHebergement personnes ($nombreChambres chambres)';
    } else if (capaciteHebergement > 0) {
      return '$capaciteHebergement personnes';
    } else if (nombreChambres > 0) {
      return '$nombreChambres chambres';
    }
    
    return 'Disponible';
  }
  
  // Helper pour récupérer une valeur booléenne
  bool _getBooleanValue(Map<String, dynamic> prestataire, String key) {
    // Vérifier dans la table lieux
    if (prestataire.containsKey('lieux')) {
      var lieuxData = prestataire['lieux'];
      
      if (lieuxData is List && lieuxData.isNotEmpty) {
        var lieu = lieuxData[0];
        if (lieu is Map && lieu.containsKey(key) && lieu[key] != null) {
          return lieu[key] is bool ? lieu[key] : lieu[key].toString().toLowerCase() == 'true';
        }
      } else if (lieuxData is Map && lieuxData.containsKey(key) && lieuxData[key] != null) {
        return lieuxData[key] is bool ? lieuxData[key] : lieuxData[key].toString().toLowerCase() == 'true';
      }
    }
    
    // Vérifier directement dans le prestataire
    if (prestataire.containsKey(key) && prestataire[key] != null) {
      return prestataire[key] is bool ? prestataire[key] : prestataire[key].toString().toLowerCase() == 'true';
    }
    
    return false;
  }
  
  // Naviguer vers la page de détails d'un prestataire
  void _navigateToDetails(BuildContext context, Map<String, dynamic> prestataire) {
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