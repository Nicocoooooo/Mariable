import 'package:equatable/equatable.dart';

/// Modèle pour le type de prestataire
class PrestaTypeModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final String? imageUrl;
  
  const PrestaTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.imageUrl,
  });
  
  @override
  List<Object?> get props => [id, name, description, iconName, imageUrl];
  
  /// Factory pour créer un modèle à partir d'un Map
  factory PrestaTypeModel.fromMap(Map<String, dynamic> map) {
    return PrestaTypeModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'],
      iconName: map['icon_name'],
      imageUrl: map['image_url'],
    );
  }
  
  /// Convertit le modèle en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'image_url': imageUrl,
    };
  }
}