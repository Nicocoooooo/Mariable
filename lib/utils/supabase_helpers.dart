// Classe d'aide pour créer des filtres de canal pour Supabase
class ChannelFilter {
  final String event;
  final String schema;
  final String table;
  final String filter;

  ChannelFilter({
    required this.event,
    required this.schema,
    required this.table,
    required this.filter,
  });

  Map<String, String> toMap() {
    return {
      'event': event,
      'schema': schema,
      'table': table,
      'filter': filter,
    };
  }
}

// Helper pour les types d'écoute en temps réel avec Supabase
class RealtimeListenTypes {
  static const String postgresChanges = 'postgres_changes';
}
