import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/document_model.dart';
import '../../utils/logger.dart';

class DocumentService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  // Récupérer tous les documents d'un partenaire
  Future<List<DocumentModel>> getPartnerDocuments(String partnerId) async {
    try {
      final response = await _client
          .from('documents')
          .select()
          .eq('partner_id', partnerId)
          .order('date_creation', ascending: false);

      return (response as List)
          .map((doc) => DocumentModel.fromMap(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des documents', e);
      rethrow;
    }
  }

  // Récupérer un document par son ID
  Future<DocumentModel> getDocumentById(String documentId) async {
    try {
      final response = await _client
          .from('documents')
          .select()
          .eq('id', documentId)
          .single();

      return DocumentModel.fromMap(response);
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération du document', e);
      rethrow;
    }
  }

  // Télécharger un document
  Future<String> uploadDocument({
    required String partnerId,
    required String fileName,
    required Uint8List fileBytes,
    required String type,
    String? reservationId,
  }) async {
    try {
      // 1. Télécharger le fichier sur Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'documents/$partnerId/$timestamp-$fileName';

      await _client.storage.from('partner-documents').uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // 2. Récupérer l'URL du fichier
      final fileUrl =
          _client.storage.from('partner-documents').getPublicUrl(path);

      // 3. Créer un enregistrement dans la table documents
      final response = await _client.from('documents').insert({
        'partner_id': partnerId,
        'reservation_id': reservationId,
        'type': type,
        'url_fichier': fileUrl,
        'statut': 'active',
        'signe': false,
        'date_creation': DateTime.now().toIso8601String(),
      }).select();

      // Retourner l'ID du document créé
      return response[0]['id'];
    } catch (e) {
      AppLogger.error('Erreur lors du téléchargement du document', e);
      rethrow;
    }
  }

  // Supprimer un document
  Future<void> deleteDocument(String documentId) async {
    try {
      // 1. Récupérer les informations du document
      final document = await getDocumentById(documentId);

      // 2. Supprimer l'enregistrement de la table
      await _client.from('documents').delete().eq('id', documentId);

      // 3. Extraire le chemin du fichier à partir de l'URL
      final uri = Uri.parse(document.urlFichier);
      final pathSegments = uri.pathSegments;

      // Le chemin dans le bucket est généralement après 'object/public/'
      final storagePath = pathSegments
          .skipWhile((segment) => segment != 'object')
          .skip(2)
          .join('/');

      if (storagePath.isNotEmpty) {
        // 4. Supprimer le fichier du storage
        await _client.storage.from('partner-documents').remove([storagePath]);
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du document', e);
      rethrow;
    }
  }

  // Mettre à jour le statut d'un document
  Future<void> updateDocumentStatus(String documentId, String status) async {
    try {
      await _client.from('documents').update({
        'statut': status,
        'date_modification': DateTime.now().toIso8601String(),
      }).eq('id', documentId);
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du statut du document', e);
      rethrow;
    }
  }

  // Marquer un document comme signé
  Future<void> markDocumentAsSigned(String documentId) async {
    try {
      await _client.from('documents').update({
        'signe': true,
        'date_modification': DateTime.now().toIso8601String(),
      }).eq('id', documentId);
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la mise à jour du statut de signature', e);
      rethrow;
    }
  }
}
