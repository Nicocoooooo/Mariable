import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/document_model.dart';
import '../../utils/logger.dart';
import '../models/partner_model.dart';
import '../widgets/partner_sidebar.dart';
import '../widgets/documents/document_card.dart';
import '../widgets/documents/document_filter.dart';
import '../services/document_service.dart';
import 'partner_document_upload_screen.dart';
import 'package:image_picker/image_picker.dart';

class PartnerDocumentsScreen extends StatefulWidget {
  const PartnerDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<PartnerDocumentsScreen> createState() => _PartnerDocumentsScreenState();
}

class _PartnerDocumentsScreenState extends State<PartnerDocumentsScreen> {
  final AuthService _authService = AuthService();
  final DocumentService _documentService = DocumentService();

  PartnerModel? _partner;
  List<DocumentModel> _documents = [];
  List<DocumentModel> _filteredDocuments = [];

  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;
  String? _successMessage;

  // Filtres
  String? _selectedType;
  String? _selectedStatus;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (!_authService.isLoggedIn) {
        context.go('/partner/login');
        return;
      }

      // Vérifier si l'utilisateur est un partenaire
      final isPartner = await _authService.isPartner();
      if (!isPartner) {
        _authService.signOut();
        if (mounted) {
          context.go('/partner/login');
        }
        return;
      }

      // Récupérer les données du partenaire
      final response = await Supabase.instance.client
          .from('presta')
          .select()
          .eq('id', _authService.currentUser!.id)
          .single();

      final partner = PartnerModel.fromMap(response);

      // Récupérer les documents du partenaire
      final documents = await _documentService.getPartnerDocuments(partner.id);

      setState(() {
        _partner = partner;
        _documents = documents;
        _filteredDocuments = documents;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger vos documents. Veuillez réessayer.';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredDocuments = _documents.where((doc) {
        // Filtre par type
        if (_selectedType != null &&
            doc.type.toLowerCase() != _selectedType!.toLowerCase()) {
          return false;
        }

        // Filtre par statut
        if (_selectedStatus != null &&
            doc.statut.toLowerCase() != _selectedStatus!.toLowerCase()) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> _uploadDocument() async {
    final ImagePicker picker = ImagePicker();

    // Ouvrir le sélecteur d'images
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Lire le contenu du fichier
      final fileBytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;

      // Déterminer le type basé sur l'extension
      final fileType = _determineFileType(fileName);

      // Naviguer vers l'écran d'upload
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerDocumentUploadScreen(
              fileName: fileName,
              fileBytes: fileBytes,
              fileType: fileType,
              partnerId: _partner!.id,
              onUploadComplete: () {
                _loadData();
                setState(() {
                  _successMessage = 'Document téléchargé avec succès';
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Erreur lors du téléchargement du document', e);
      setState(() {
        _errorMessage =
            'Une erreur est survenue lors du téléchargement du document';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _determineFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    if (['pdf', 'doc', 'docx'].contains(extension)) {
      return 'contrat';
    } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return 'photo';
    } else {
      return 'autre';
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce document ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _documentService.deleteDocument(documentId);

      setState(() {
        _documents.removeWhere((doc) => doc.id == documentId);
        _applyFilters(); // Mettre à jour les documents filtrés
        _successMessage = 'Document supprimé avec succès';
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du document', e);
      setState(() {
        _errorMessage =
            'Une erreur est survenue lors de la suppression du document';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Mes Documents'),
      drawer: PartnerSidebar(
        selectedIndex: 4, // L'index correspondant à Documents dans le menu
        partner: _partner,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _uploadDocument,
        backgroundColor: PartnerAdminStyles.accentColor,
        child: _isUploading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.upload_file),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des documents...')
          : _errorMessage != null && _documents.isEmpty
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Messages d'état
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

                        // En-tête avec compteur et bouton de filtre
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_filteredDocuments.length} document${_filteredDocuments.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: PartnerAdminStyles.accentColor,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showFilters = !_showFilters;
                                });
                              },
                              icon: Icon(
                                _showFilters
                                    ? Icons.filter_list_off
                                    : Icons.filter_list,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                _showFilters
                                    ? 'Masquer les filtres'
                                    : 'Filtrer',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PartnerAdminStyles.accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section filtres (conditionnelle)
                        if (_showFilters) ...[
                          DocumentFilter(
                            selectedType: _selectedType,
                            selectedStatus: _selectedStatus,
                            onTypeChanged: (type) {
                              setState(() {
                                _selectedType = type;
                                _applyFilters();
                              });
                            },
                            onStatusChanged: (status) {
                              setState(() {
                                _selectedStatus = status;
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Liste des documents
                        if (_filteredDocuments.isEmpty)
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun document trouvé',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _documents.isEmpty
                                        ? 'Commencez par télécharger votre premier document'
                                        : 'Modifiez vos filtres pour voir d\'autres documents',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  if (_documents.isEmpty)
                                    ElevatedButton.icon(
                                      onPressed: _uploadDocument,
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text(
                                        'Télécharger un document',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            PartnerAdminStyles.accentColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredDocuments.length,
                            itemBuilder: (context, index) {
                              final document = _filteredDocuments[index];
                              return DocumentCard(
                                document: document,
                                onDelete: () => _deleteDocument(document.id),
                                onView: () {
                                  // TODO: Naviguer vers la vue détaillée du document
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
