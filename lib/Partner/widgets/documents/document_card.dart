import 'package:flutter/material.dart';
import '../../../shared/models/document_model.dart';
import '../../../shared/constants/style_constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onDelete;
  final VoidCallback? onView;
  final Function(String)? onStatusChange;

  const DocumentCard({
    Key? key,
    required this.document,
    this.onDelete,
    this.onView,
    this.onStatusChange,
  }) : super(key: key);

  // Fonction pour obtenir l'icône selon le type de document
  IconData _getDocumentIcon() {
    switch (document.type.toLowerCase()) {
      case 'contrat':
        return Icons.description;
      case 'facture':
        return Icons.receipt;
      case 'devis':
        return Icons.request_quote;
      case 'photo':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Fonction pour obtenir la couleur selon le type de document
  Color _getDocumentColor() {
    switch (document.type.toLowerCase()) {
      case 'contrat':
        return Colors.blue;
      case 'facture':
        return Colors.green;
      case 'devis':
        return Colors.orange;
      case 'photo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Fonction pour obtenir le libellé du statut
  String _getStatusLabel() {
    switch (document.statut.toLowerCase()) {
      case 'draft':
        return 'Brouillon';
      case 'active':
        return 'Actif';
      case 'archived':
        return 'Archivé';
      default:
        return document.statut;
    }
  }

  // Formatter pour la date
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);
  }

  // Ouvrir le document dans le navigateur
  Future<void> _openDocument() async {
    if (document.urlFichier.isEmpty) return;

    final Uri url = Uri.parse(document.urlFichier);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Logger l'erreur
        print('Impossible d\'ouvrir l\'URL: $url');
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture du document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getDocumentColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onView ?? _openDocument,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec type et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getDocumentIcon(),
                        color: _getDocumentColor(),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        document.type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PartnerAdminStyles.textColor,
                        ),
                      ),
                    ],
                  ),
                  // Badge de statut
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: document.statut.toLowerCase() == 'active'
                          ? Colors.green.withOpacity(0.2)
                          : document.statut.toLowerCase() == 'draft'
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: document.statut.toLowerCase() == 'active'
                            ? Colors.green.shade800
                            : document.statut.toLowerCase() == 'draft'
                                ? Colors.orange.shade800
                                : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // URL du fichier (tronquée)
              Text(
                'Fichier: ${document.urlFichier.split('/').last}',
                style: const TextStyle(
                  fontSize: 14,
                  color: PartnerAdminStyles.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Informations temporelles
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Créé le ${_formatDate(document.dateCreation)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              if (document.dateModification != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.update,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Modifié le ${_formatDate(document.dateModification!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Badge de signature
              if (document.signe)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Signé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bouton de téléchargement/visualisation
                  OutlinedButton.icon(
                    onPressed: _openDocument,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Ouvrir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PartnerAdminStyles.accentColor,
                      side: const BorderSide(
                          color: PartnerAdminStyles.accentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Bouton de suppression
                  if (onDelete != null)
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
