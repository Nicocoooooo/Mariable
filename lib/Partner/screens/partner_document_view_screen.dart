// lib/Partner/screens/partner_document_view_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/models/document_model.dart';
import '../../utils/logger.dart';
import '../services/document_service.dart';
import 'package:intl/intl.dart';

class PartnerDocumentViewScreen extends StatefulWidget {
  final String documentId;

  const PartnerDocumentViewScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<PartnerDocumentViewScreen> createState() =>
      _PartnerDocumentViewScreenState();
}

class _PartnerDocumentViewScreenState extends State<PartnerDocumentViewScreen> {
  final DocumentService _documentService = DocumentService();

  DocumentModel? _document;
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final document =
          await _documentService.getDocumentById(widget.documentId);

      setState(() {
        _document = document;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement du document', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger le document. Veuillez réessayer.';
      });
    }
  }

  // Ouvrir le document dans le navigateur
  Future<void> _openDocument() async {
    if (_document == null || _document!.urlFichier.isEmpty) return;

    final Uri url = Uri.parse(_document!.urlFichier);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.warning('Impossible d\'ouvrir l\'URL: $url');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir le document')),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'ouverture du document', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  // Marquer un document comme signé
  Future<void> _markAsSigned() async {
    if (_document == null) return;

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      await _documentService.markDocumentAsSigned(_document!.id);

      await _loadDocument(); // Recharger le document

      setState(() {
        _successMessage = 'Document marqué comme signé';
      });
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la mise à jour du statut de signature', e);
      setState(() {
        _errorMessage =
            'Une erreur est survenue lors de la mise à jour du document';
        _isLoading = false;
      });
    }
  }

  // Mettre à jour le statut d'un document
  Future<void> _updateStatus(String status) async {
    if (_document == null) return;

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      await _documentService.updateDocumentStatus(_document!.id, status);

      await _loadDocument(); // Recharger le document

      setState(() {
        _successMessage = 'Statut du document mis à jour';
      });
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du statut', e);
      setState(() {
        _errorMessage =
            'Une erreur est survenue lors de la mise à jour du document';
        _isLoading = false;
      });
    }
  }

  // Formatter pour la date
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Détails du document',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement du document...')
          : _errorMessage != null && _document == null
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadDocument,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),

                      if (_successMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _successMessage!,
                            style: TextStyle(color: Colors.green.shade800),
                          ),
                        ),

                      // En-tête avec type et icône
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getDocumentColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                _getDocumentIcon(),
                                color: _getDocumentColor(),
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _document!.type.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: PartnerAdminStyles.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _document!.urlFichier.split('/').last,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section d'informations
                      const Text(
                        'Informations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PartnerAdminStyles.accentColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Détails dans une card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildInfoRow('Statut', _getStatusLabel(),
                                  _getStatusColor()),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Signé',
                                _document!.signe ? 'Oui' : 'Non',
                                _document!.signe ? Colors.green : Colors.grey,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Date de création',
                                _formatDate(_document!.dateCreation),
                                null,
                              ),
                              if (_document!.dateModification != null) ...[
                                const Divider(height: 24),
                                _buildInfoRow(
                                  'Dernière modification',
                                  _formatDate(_document!.dateModification!),
                                  null,
                                ),
                              ],
                              if (_document!.reservationId != null) ...[
                                const Divider(height: 24),
                                _buildInfoRow(
                                  'Réservation associée',
                                  _document!.reservationId!,
                                  null,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Actions principales
                      const Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PartnerAdminStyles.accentColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bouton pour ouvrir le document
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openDocument,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('OUVRIR LE DOCUMENT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PartnerAdminStyles.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Actions secondaires
                      Row(
                        children: [
                          // Bouton pour marquer comme signé
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _document!.signe ? null : _markAsSigned,
                              icon: const Icon(Icons.verified),
                              label: const Text('MARQUER COMME SIGNÉ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Menu déroulant pour changer le statut
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.green),
                                            title: const Text('Actif'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _updateStatus('active');
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.edit_note,
                                                color: Colors.orange),
                                            title: const Text('Brouillon'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _updateStatus('draft');
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                                Icons.archive_outlined,
                                                color: Colors.grey),
                                            title: const Text('Archivé'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _updateStatus('archived');
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PartnerAdminStyles.accentColor,
                                side: const BorderSide(
                                    color: PartnerAdminStyles.accentColor),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('CHANGER LE STATUT'),
                                  SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  // Formatage de l'affichage du document
  IconData _getDocumentIcon() {
    switch (_document!.type.toLowerCase()) {
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

  Color _getDocumentColor() {
    switch (_document!.type.toLowerCase()) {
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

  String _getStatusLabel() {
    switch (_document!.statut.toLowerCase()) {
      case 'draft':
        return 'Brouillon';
      case 'active':
        return 'Actif';
      case 'archived':
        return 'Archivé';
      default:
        return _document!.statut;
    }
  }

  Color _getStatusColor() {
    switch (_document!.statut.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? PartnerAdminStyles.textColor,
          ),
        ),
      ],
    );
  }
}
