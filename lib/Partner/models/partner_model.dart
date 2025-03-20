import 'package:equatable/equatable.dart';

/// Représente un partenaire (prestataire) dans l'application
class PartnerModel extends Equatable {
  final String id;
  final String nomEntreprise;
  final String nomContact;
  final String email;
  final String telephone;
  final String? telephoneSecondaire;
  final String adresse;
  final String region;
  final String description;
  final double? noteMoyenne;
  final int? prestaTypeId;
  final int? lieuxTypeId;
  final String? imageUrl;
  final String typeBudget;
  final bool isVerified;
  final bool actif;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  const PartnerModel({
    required this.id,
    required this.nomEntreprise,
    required this.nomContact,
    required this.email,
    required this.telephone,
    this.telephoneSecondaire,
    required this.adresse,
    required this.region,
    required this.description,
    this.noteMoyenne,
    this.prestaTypeId,
    this.lieuxTypeId,
    this.imageUrl,
    required this.typeBudget,
    this.isVerified = false,
    this.actif = true,
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  /// Crée un PartnerModel à partir d'une Map (généralement depuis Supabase)
  factory PartnerModel.fromMap(Map<String, dynamic> map) {
    return PartnerModel(
      id: map['id'],
      nomEntreprise: map['nom_entreprise'] ?? '',
      nomContact: map['nom_contact'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      telephoneSecondaire: map['telephone_secondaire'],
      adresse: map['adresse'] ?? '',
      region: map['region'] ?? '',
      description: map['description'] ?? '',
      noteMoyenne: map['note_moyenne'] != null
          ? (map['note_moyenne'] is double
              ? map['note_moyenne']
              : double.tryParse(map['note_moyenne'].toString()))
          : null,
      prestaTypeId: map['presta_type_id'],
      lieuxTypeId: map['lieux_type_id'],
      imageUrl: map['image_url'],
      typeBudget: map['type_budget'] ?? 'abordable',
      isVerified: map['is_verified'] ?? false,
      actif: map['actif'] ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      lastLogin:
          map['last_login'] != null ? DateTime.parse(map['last_login']) : null,
    );
  }

  /// Convertit en Map (généralement pour envoyer à Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_entreprise': nomEntreprise,
      'nom_contact': nomContact,
      'email': email,
      'telephone': telephone,
      'telephone_secondaire': telephoneSecondaire,
      'adresse': adresse,
      'region': region,
      'description': description,
      'note_moyenne': noteMoyenne,
      'presta_type_id': prestaTypeId,
      'lieux_type_id': lieuxTypeId,
      'image_url': imageUrl,
      'type_budget': typeBudget,
      'is_verified': isVerified,
      'actif': actif,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Crée une copie de ce PartnerModel avec les champs spécifiés remplacés
  PartnerModel copyWith({
    String? id,
    String? nomEntreprise,
    String? nomContact,
    String? email,
    String? telephone,
    String? telephoneSecondaire,
    String? adresse,
    String? region,
    String? description,
    double? noteMoyenne,
    int? prestaTypeId,
    int? lieuxTypeId,
    String? imageUrl,
    String? typeBudget,
    bool? isVerified,
    bool? actif,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      nomEntreprise: nomEntreprise ?? this.nomEntreprise,
      nomContact: nomContact ?? this.nomContact,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      telephoneSecondaire: telephoneSecondaire ?? this.telephoneSecondaire,
      adresse: adresse ?? this.adresse,
      region: region ?? this.region,
      description: description ?? this.description,
      noteMoyenne: noteMoyenne ?? this.noteMoyenne,
      prestaTypeId: prestaTypeId ?? this.prestaTypeId,
      lieuxTypeId: lieuxTypeId ?? this.lieuxTypeId,
      imageUrl: imageUrl ?? this.imageUrl,
      typeBudget: typeBudget ?? this.typeBudget,
      isVerified: isVerified ?? this.isVerified,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nomEntreprise,
        nomContact,
        email,
        telephone,
        telephoneSecondaire,
        adresse,
        region,
        description,
        noteMoyenne,
        prestaTypeId,
        lieuxTypeId,
        imageUrl,
        typeBudget,
        isVerified,
        actif,
        createdAt,
        updatedAt,
        lastLogin
      ];
}
