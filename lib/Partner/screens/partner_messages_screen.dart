import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/services/auth_service.dart';
import '../../utils/logger.dart';
import '../models/partner_model.dart';
import '../models/data/conversation_model.dart';
import '../widgets/partner_sidebar.dart';
import '../services/message_service.dart';
import '../widgets/messages/conversation_card.dart';
import 'partner_conversation_screen.dart';

class PartnerMessagesScreen extends StatefulWidget {
  const PartnerMessagesScreen({super.key});

  @override
  State<PartnerMessagesScreen> createState() => _PartnerMessagesScreenState();
}

class _PartnerMessagesScreenState extends State<PartnerMessagesScreen> {
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();

  PartnerModel? _partner;
  List<ConversationModel> _conversations = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

      // Récupérer les conversations du partenaire
      final conversations =
          await _messageService.getPartnerConversations(partner.id);

      setState(() {
        _partner = partner;
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des données', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger vos messages. Veuillez réessayer.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Messagerie',
      ),
      drawer: PartnerSidebar(
        selectedIndex: 3, // L'index correspondant à Messages dans le menu
        partner: _partner,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des conversations...')
          : _errorMessage != null && _conversations.isEmpty
              ? ErrorView(
                  message: _errorMessage!,
                  actionLabel: 'Réessayer',
                  onAction: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _conversations.isEmpty
                      ? _buildEmptyState()
                      : _buildConversationsList(),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_chat_unread_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Aucun message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Vous n\'avez pas encore de conversation. Les messages de vos clients apparaîtront ici.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return ConversationCard(
          conversation: conversation,
          onTap: () => _openConversation(conversation),
        );
      },
    );
  }

  void _openConversation(ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerConversationScreen(
          conversationId: conversation.id,
          clientId: conversation.clientId,
          clientName: conversation.clientName ?? 'Client',
          partnerId: _partner!.id,
          partnerName: _partner!.nomEntreprise,
          onConversationUpdated: _loadData,
        ),
      ),
    );
  }
}
