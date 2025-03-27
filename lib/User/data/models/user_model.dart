import 'package:equatable/equatable.dart';

/// Représente un utilisateur dans l'application
class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final DateTime? weddingDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? favoritePrestataires;
  final Map<String, dynamic>? preferences;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.weddingDate,
    required this.createdAt,
    this.updatedAt,
    this.favoritePrestataires,
    this.preferences,
  });

  /// Crée un UserModel à partir d'une Map (généralement depuis Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phone: map['phone'],
      weddingDate: map['wedding_date'] != null 
          ? DateTime.parse(map['wedding_date']) 
          : null,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
      favoritePrestataires: map['favorite_prestataires'] != null 
          ? List<String>.from(map['favorite_prestataires']) 
          : null,
      preferences: map['preferences'],
    );
  }

  /// Convertit en Map (généralement pour envoyer à Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'wedding_date': weddingDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'favorite_prestataires': favoritePrestataires,
      'preferences': preferences,
    };
  }

  /// Crée une copie de l'utilisateur avec certains champs modifiés
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    DateTime? weddingDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? favoritePrestataires,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      weddingDate: weddingDate ?? this.weddingDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favoritePrestataires: favoritePrestataires ?? this.favoritePrestataires,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    email, 
    fullName, 
    phone, 
    weddingDate, 
    createdAt, 
    updatedAt, 
    favoritePrestataires, 
    preferences
  ];
}