import 'package:equatable/equatable.dart';

/// Represents a lieu (venue) type in the application
class LieuTypeModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;

  const LieuTypeModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  /// Create a LieuTypeModel from a Map (usually from Supabase response)
  factory LieuTypeModel.fromMap(Map<String, dynamic> map) {
    return LieuTypeModel(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  /// Convert to a Map (usually for sending to Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, description, imageUrl];
}