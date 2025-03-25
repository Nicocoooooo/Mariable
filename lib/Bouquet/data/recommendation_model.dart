class RecommendationModel {
  final String title;
  final String description;
  final Map<String, dynamic>? metadata;

  RecommendationModel({
    required this.title,
    required this.description,
    this.metadata,
  });

  // Conversion en Map pour stockage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'metadata': metadata,
    };
  }

  // Création depuis Map (stockage)
  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      title: map['title'],
      description: map['description'],
      metadata: map['metadata'],
    );
  }
}