import 'package:equatable/equatable.dart';

/// Représente un document dans le système de gestion documentaire
class DocumentModel extends Equatable {
  final String id;
  final String? reservationId;
  final String partnerId;
  final String type;
  final String urlFichier;
  final String statut;
  final bool signe;
  final DateTime dateCreation;
  final DateTime? dateModification;

  const DocumentModel({
    required this.id,
    this.reservationId,
    required this.partnerId,
    required this.type,
    required this.urlFichier,
    required this.statut,
    this.signe = false,
    required this.dateCreation,
    this.dateModification,
  });

  /// Crée un DocumentModel à partir d'une Map (généralement depuis Supabase)
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'],
      reservationId: map['reservation_id'],
      partnerId: map['partner_id'],
      type: map['type'] ?? '',
      urlFichier: map['url_fichier'] ?? '',
      statut: map['statut'] ?? '',
      signe: map['signe'] ?? false,
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : DateTime.now(),
      dateModification: map['date_modification'] != null
          ? DateTime.parse(map['date_modification'])
          : null,
    );
  }

  /// Convertit en Map (généralement pour envoyer à Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'partner_id': partnerId,
      'type': type,
      'url_fichier': urlFichier,
      'statut': statut,
      'signe': signe,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        reservationId,
        partnerId,
        type,
        urlFichier,
        statut,
        signe,
        dateCreation,
        dateModification
      ];
}
