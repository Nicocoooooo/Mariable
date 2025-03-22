import 'package:equatable/equatable.dart';

/// Représente une offre/formule tarifaire proposée par un partenaire
class TarifModel extends Equatable {
  final String id;
  final String prestaId;
  final String nomFormule;
  final double prixBase;
  final String typePrix; // 'fixe' ou 'par_personne'
  final int? minInvites;
  final int? maxInvites;
  final double? coefWeekend;
  final double? coefHauteSaison;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVisible; // Champ pour la visibilité de l'offre

  const TarifModel({
    required this.id,
    required this.prestaId,
    required this.nomFormule,
    required this.prixBase,
    required this.typePrix,
    this.minInvites,
    this.maxInvites,
    this.coefWeekend,
    this.coefHauteSaison,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.isVisible = true,
  });

  /// Crée un TarifModel à partir d'une Map (généralement depuis Supabase)
  factory TarifModel.fromMap(Map<String, dynamic> map) {
    return TarifModel(
      id: map['id'],
      prestaId: map['presta_id'],
      nomFormule: map['nom_formule'] ?? 'Formule sans nom',
      prixBase: (map['prix_base'] is num)
          ? (map['prix_base'] as num).toDouble()
          : double.tryParse(map['prix_base'].toString()) ?? 0.0,
      typePrix: map['type_prix'] ?? 'fixe',
      minInvites: map['min_invites'],
      maxInvites: map['max_invites'],
      coefWeekend: map['coef_weekend'] != null
          ? (map['coef_weekend'] is double
              ? map['coef_weekend']
              : double.tryParse(map['coef_weekend'].toString()))
          : null,
      coefHauteSaison: map['coef_haute_saison'] != null
          ? (map['coef_haute_saison'] is double
              ? map['coef_haute_saison']
              : double.tryParse(map['coef_haute_saison'].toString()))
          : null,
      description: map['description'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isVisible: map['actif'] ?? true,
    );
  }

  /// Convertit le modèle en Map pour insertion/mise à jour dans Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'presta_id': prestaId,
      'nom_formule': nomFormule,
      'prix_base': prixBase,
      'type_prix': typePrix,
      'min_invites': minInvites,
      'max_invites': maxInvites,
      'coef_weekend': coefWeekend,
      'coef_haute_saison': coefHauteSaison,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'actif': isVisible,
    };
  }

  /// Crée une copie du modèle avec les champs spécifiés modifiés
  TarifModel copyWith({
    String? id,
    String? prestaId,
    String? nomFormule,
    double? prixBase,
    String? typePrix,
    int? minInvites,
    int? maxInvites,
    double? coefWeekend,
    double? coefHauteSaison,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
  }) {
    return TarifModel(
      id: id ?? this.id,
      prestaId: prestaId ?? this.prestaId,
      nomFormule: nomFormule ?? this.nomFormule,
      prixBase: prixBase ?? this.prixBase,
      typePrix: typePrix ?? this.typePrix,
      minInvites: minInvites ?? this.minInvites,
      maxInvites: maxInvites ?? this.maxInvites,
      coefWeekend: coefWeekend ?? this.coefWeekend,
      coefHauteSaison: coefHauteSaison ?? this.coefHauteSaison,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// Calcule le prix pour une date et un nombre d'invités donnés
  double calculatePrice({
    required DateTime date,
    int? nombreInvites,
  }) {
    // Prix de base
    double calculatedPrice = prixBase;

    // Appliquer le coefficient weekend si applicable
    final bool isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    if (isWeekend && coefWeekend != null) {
      calculatedPrice *= coefWeekend!;
    }

    // Appliquer le coefficient haute saison si applicable
    final bool isHauteSaison = _isHauteSaison(date);
    if (isHauteSaison && coefHauteSaison != null) {
      calculatedPrice *= coefHauteSaison!;
    }

    // Appliquer le prix par personne si applicable
    if (typePrix == 'par_personne' && nombreInvites != null) {
      calculatedPrice *= nombreInvites;
    }

    return calculatedPrice;
  }

  /// Vérifie si la date est en haute saison (mai à septembre)
  bool _isHauteSaison(DateTime date) {
    return date.month >= 5 && date.month <= 9;
  }

  @override
  List<Object?> get props => [
        id,
        prestaId,
        nomFormule,
        prixBase,
        typePrix,
        minInvites,
        maxInvites,
        coefWeekend,
        coefHauteSaison,
        description,
        createdAt,
        updatedAt,
        isVisible,
      ];
}
