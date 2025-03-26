import 'package:equatable/equatable.dart';

/// Modèle de prestataire générique avec les propriétés communes
class PrestataireModel extends Equatable {
  final String id;
  final String nomEntreprise;
  final String description;
  final String? photoUrl;
  final double? prixBase;
  final double? noteAverage;
  final Map<String, dynamic>? formuleChoisie;
  final String region; // Propriété région ajoutée pour tous les prestataires
  
  const PrestataireModel({
    required this.id,
    required this.nomEntreprise,
    required this.description,
    required this.region,
    this.photoUrl,
    this.prixBase,
    this.noteAverage,
    this.formuleChoisie,
  });
  
  @override
  List<Object?> get props => [id, nomEntreprise, description, photoUrl, prixBase, noteAverage, formuleChoisie, region];
  
  /// Crée une copie du modèle avec des champs mis à jour
  PrestataireModel copyWith({
    String? id,
    String? nomEntreprise,
    String? description,
    String? photoUrl,
    double? prixBase,
    double? noteAverage,
    Map<String, dynamic>? formuleChoisie,
    String? region,
  }) {
    return PrestataireModel(
      id: id ?? this.id,
      nomEntreprise: nomEntreprise ?? this.nomEntreprise,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      prixBase: prixBase ?? this.prixBase,
      noteAverage: noteAverage ?? this.noteAverage,
      formuleChoisie: formuleChoisie ?? this.formuleChoisie,
      region: region ?? this.region,
    );
  }
  
  /// Factory pour créer un modèle à partir d'un Map
  factory PrestataireModel.fromMap(Map<String, dynamic> map) {
    return PrestataireModel(
      id: map['id'].toString(),
      nomEntreprise: map['nom_entreprise'] ?? '',
      description: map['description'] ?? '',
      region: map['region'] ?? '',
      photoUrl: map['photo_url'],
      prixBase: map['prix_base'] != null ? (map['prix_base'] as num).toDouble() : null,
      noteAverage: map['note_moyenne'] != null ? (map['note_moyenne'] as num).toDouble() : null,
    );
  }
  
  /// Convertit le modèle en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_entreprise': nomEntreprise,
      'description': description,
      'photo_url': photoUrl,
      'prix_base': prixBase,
      'note_moyenne': noteAverage,
      'formule_choisie': formuleChoisie,
      'region': region,
    };
  }
}

/// Modèle pour le lieu
class LieuModel extends PrestataireModel {
  final String? typeLieu;
  final int? capaciteMax;
  final bool? espaceExterieur;
  final bool? hebergement;
  
  const LieuModel({
    required super.id,
    required super.nomEntreprise,
    required super.description,
    required super.region,
    super.photoUrl,
    super.prixBase,
    super.noteAverage,
    super.formuleChoisie,
    this.typeLieu,
    this.capaciteMax,
    this.espaceExterieur,
    this.hebergement,
  });
  
  @override
  List<Object?> get props => [
    ...super.props,
    typeLieu,
    capaciteMax,
    espaceExterieur,
    hebergement,
  ];
  
  /// Factory pour créer un modèle à partir d'un Map
  factory LieuModel.fromMap(Map<String, dynamic> map) {
    return LieuModel(
      id: map['id'].toString(),
      nomEntreprise: map['nom_entreprise'] ?? '',
      description: map['description'] ?? '',
      region: map['region'] ?? '',
      photoUrl: map['photo_url'],
      prixBase: map['prix_base'] != null ? (map['prix_base'] as num).toDouble() : null,
      noteAverage: map['note_moyenne'] != null ? (map['note_moyenne'] as num).toDouble() : null,
      typeLieu: map['type_lieu'],
      capaciteMax: map['capacite_max'],
      espaceExterieur: map['espace_exterieur'],
      hebergement: map['hebergement'],
    );
  }
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'type_lieu': typeLieu,
      'capacite_max': capaciteMax,
      'espace_exterieur': espaceExterieur,
      'hebergement': hebergement,
    });
    return map;
  }
}

/// Modèle pour le traiteur
class TraiteurModel extends PrestataireModel {
  final List<String>? typeCuisine;
  final int? maxInvites;
  final bool? equipementsInclus;
  final bool? personnelInclus;
  
  const TraiteurModel({
    required super.id,
    required super.nomEntreprise,
    required super.description,
    required super.region,
    super.photoUrl,
    super.prixBase,
    super.noteAverage,
    super.formuleChoisie,
    this.typeCuisine,
    this.maxInvites,
    this.equipementsInclus,
    this.personnelInclus,
  });
  
  @override
  List<Object?> get props => [
    ...super.props,
    typeCuisine,
    maxInvites,
    equipementsInclus,
    personnelInclus,
  ];
  
  /// Factory pour créer un modèle à partir d'un Map
  factory TraiteurModel.fromMap(Map<String, dynamic> map) {
    List<String>? typeCuisineList;
    if (map['type_cuisine'] != null) {
      if (map['type_cuisine'] is List) {
        typeCuisineList = (map['type_cuisine'] as List).map((e) => e.toString()).toList();
      } else if (map['type_cuisine'] is Map) {
        typeCuisineList = (map['type_cuisine'] as Map).values.map((e) => e.toString()).toList();
      }
    }
    
    return TraiteurModel(
      id: map['id'].toString(),
      nomEntreprise: map['nom_entreprise'] ?? '',
      description: map['description'] ?? '',
      region: map['region'] ?? '',
      photoUrl: map['photo_url'],
      prixBase: map['prix_base'] != null ? (map['prix_base'] as num).toDouble() : null,
      noteAverage: map['note_moyenne'] != null ? (map['note_moyenne'] as num).toDouble() : null,
      typeCuisine: typeCuisineList,
      maxInvites: map['max_invites'],
      equipementsInclus: map['equipements_inclus'],
      personnelInclus: map['personnel_inclus'],
    );
  }
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'type_cuisine': typeCuisine,
      'max_invites': maxInvites,
      'equipements_inclus': equipementsInclus,
      'personnel_inclus': personnelInclus,
    });
    return map;
  }
}

/// Modèle pour le photographe
class PhotographeModel extends PrestataireModel {
  final List<String>? style;
  final Map<String, dynamic>? optionsDuree;
  final bool? drone;
  
  const PhotographeModel({
    required super.id,
    required super.nomEntreprise,
    required super.description,
    required super.region,
    super.photoUrl,
    super.prixBase,
    super.noteAverage,
    super.formuleChoisie,
    this.style,
    this.optionsDuree,
    this.drone,
  });
  
  @override
  List<Object?> get props => [
    ...super.props,
    style,
    optionsDuree,
    drone,
  ];
  
  /// Factory pour créer un modèle à partir d'un Map
  factory PhotographeModel.fromMap(Map<String, dynamic> map) {
    List<String>? styleList;
    if (map['style'] != null) {
      if (map['style'] is List) {
        styleList = (map['style'] as List).map((e) => e.toString()).toList();
      } else if (map['style'] is Map) {
        styleList = (map['style'] as Map).values.map((e) => e.toString()).toList();
      }
    }
    
    return PhotographeModel(
      id: map['id'].toString(),
      nomEntreprise: map['nom_entreprise'] ?? '',
      description: map['description'] ?? '',
      region: map['region'] ?? '',
      photoUrl: map['photo_url'],
      prixBase: map['prix_base'] != null ? (map['prix_base'] as num).toDouble() : null,
      noteAverage: map['note_moyenne'] != null ? (map['note_moyenne'] as num).toDouble() : null,
      style: styleList,
      optionsDuree: map['options_duree'],
      drone: map['drone'],
    );
  }
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'style': style,
      'options_duree': optionsDuree,
      'drone': drone,
    });
    return map;
  }
}

/// Modèle pour le bouquet complet
class BouquetModel extends Equatable {
  final String? id;
  final String? nom;
  final DateTime? dateCreation;
  final DateTime? dateEvenement;
  final LieuModel? lieu;
  final TraiteurModel? traiteur;
  final PhotographeModel? photographe;
  final double? prixTotal;
  
  const BouquetModel({
    this.id,
    this.nom,
    this.dateCreation,
    this.dateEvenement,
    this.lieu,
    this.traiteur,
    this.photographe,
    this.prixTotal,
  });
  
  @override
  List<Object?> get props => [
    id,
    nom,
    dateCreation,
    dateEvenement,
    lieu,
    traiteur,
    photographe,
    prixTotal,
  ];
  
  /// Crée une copie du modèle avec des champs mis à jour
  BouquetModel copyWith({
    String? id,
    String? nom,
    DateTime? dateCreation,
    DateTime? dateEvenement,
    LieuModel? lieu,
    TraiteurModel? traiteur,
    PhotographeModel? photographe,
    double? prixTotal,
  }) {
    return BouquetModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      dateCreation: dateCreation ?? this.dateCreation,
      dateEvenement: dateEvenement ?? this.dateEvenement,
      lieu: lieu ?? this.lieu,
      traiteur: traiteur ?? this.traiteur,
      photographe: photographe ?? this.photographe,
      prixTotal: prixTotal ?? this.prixTotal,
    );
  }
  
  /// Calcule le prix total du bouquet
  double calculerPrixTotal() {
    double total = 0;
    
    // Prix du lieu
    if (lieu?.prixBase != null) {
      total += lieu!.prixBase!;
    }
    if (lieu?.formuleChoisie != null && lieu!.formuleChoisie!['prix'] != null) {
      total += lieu!.formuleChoisie!['prix'];
    }
    
    // Prix du traiteur
    if (traiteur?.prixBase != null) {
      total += traiteur!.prixBase!;
    }
    if (traiteur?.formuleChoisie != null && traiteur!.formuleChoisie!['prix'] != null) {
      total += traiteur!.formuleChoisie!['prix'];
    }
    
    // Prix du photographe
    if (photographe?.prixBase != null) {
      total += photographe!.prixBase!;
    }
    if (photographe?.formuleChoisie != null && photographe!.formuleChoisie!['prix'] != null) {
      total += photographe!.formuleChoisie!['prix'];
    }
    
    return total;
  }
  
  /// Factory pour créer un modèle à partir d'un Map
  factory BouquetModel.fromMap(Map<String, dynamic> map) {
    return BouquetModel(
      id: map['id'],
      nom: map['nom'],
      dateCreation: map['date_creation'] != null ? DateTime.parse(map['date_creation']) : null,
      dateEvenement: map['date_evenement'] != null ? DateTime.parse(map['date_evenement']) : null,
      lieu: map['lieu'] != null ? LieuModel.fromMap(map['lieu']) : null,
      traiteur: map['traiteur'] != null ? TraiteurModel.fromMap(map['traiteur']) : null,
      photographe: map['photographe'] != null ? PhotographeModel.fromMap(map['photographe']) : null,
      prixTotal: map['prix_total'] != null ? (map['prix_total'] as num).toDouble() : null,
    );
  }
  
  /// Convertit le modèle en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'date_creation': dateCreation?.toIso8601String(),
      'date_evenement': dateEvenement?.toIso8601String(),
      'lieu': lieu?.toMap(),
      'traiteur': traiteur?.toMap(),
      'photographe': photographe?.toMap(),
      'prix_total': prixTotal ?? calculerPrixTotal(),
    };
  }
}