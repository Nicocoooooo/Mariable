import 'package:equatable/equatable.dart';

/// Représente un administrateur dans l'application
class AdminModel extends Equatable {
  final String id;
  final String email;
  final String nom;
  final String? role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AdminModel({
    required this.id,
    required this.email,
    required this.nom,
    this.role = 'admin',
    required this.createdAt,
    this.lastLogin,
  });

  /// Crée un AdminModel à partir d'une Map (généralement depuis Supabase)
  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'],
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      role: map['role'] ?? 'admin',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      lastLogin:
          map['last_login'] != null ? DateTime.parse(map['last_login']) : null,
    );
  }

  /// Convertit en Map (généralement pour envoyer à Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, email, nom, role, createdAt, lastLogin];
}
