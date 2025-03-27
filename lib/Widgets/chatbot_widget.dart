import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

class ChatMessage {
  final String text;
  final bool isUserMessage;
  
  ChatMessage({required this.text, required this.isUserMessage});
}

class ResponseMatch {
  final String text;
  final double relevance;
  
  ResponseMatch(this.text, this.relevance);
}

class ChatbotWidget extends StatefulWidget {
  final String prestaId;
  final String prestaName;
  final String? prestaEmail;
  
  const ChatbotWidget({
    super.key, 
    required this.prestaId,
    required this.prestaName,
    this.prestaEmail,
  });

  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  bool _isChatbotAvailable = false;
  String? _prestaDocument;
  
  @override
  void initState() {
    super.initState();
    _fetchPrestaDocument();
    
    // Ajouter un message de bienvenue
    _addBotMessage("Bonjour ! Je suis l'assistant virtuel de ${widget.prestaName}. Comment puis-je vous aider ?");
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  

  
  Future<void> _fetchPrestaDocument() async {
    try {
      final response = await Supabase.instance.client
          .from('presta')
          .select('chatbot_document')
          .eq('id', widget.prestaId)
          .single();
          
      setState(() {
        _prestaDocument = response['chatbot_document'];
        _isLoading = false;
        _isChatbotAvailable = _prestaDocument != null && _prestaDocument!.isNotEmpty;
      });
      
      if (!_isChatbotAvailable) {
        _addBotMessage("Je suis désolé, je n'ai pas suffisamment d'informations pour répondre à vos questions.");
        if (widget.prestaEmail != null && widget.prestaEmail!.isNotEmpty) {
          _addBotMessage("Pour toute question, veuillez contacter directement ${widget.prestaName} à l'adresse: ${widget.prestaEmail}");
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isChatbotAvailable = false;
      });
      _addBotMessage("Je suis désolé, une erreur est survenue. Veuillez réessayer plus tard.");
    }
  }
  
  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isUserMessage: true));
    });
    _scrollToBottom();
  }
  
  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isUserMessage: false));
    });
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    // Attendre que le widget se reconstruise avant de défiler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _addUserMessage(text);
    
    if (!_isChatbotAvailable) {
      _addBotMessage("Je suis désolé, je n'ai pas suffisamment d'informations pour répondre à vos questions.");
      if (widget.prestaEmail != null && widget.prestaEmail!.isNotEmpty) {
        _addBotMessage("Pour toute question, veuillez contacter directement ${widget.prestaName} à l'adresse: ${widget.prestaEmail}");
      }
      return;
    }
    
    // Rechercher une réponse correspondante
    String response = _findResponse(text);
    _addBotMessage(response);
  }
  
  String _findResponse(String question) {
  // Normalisation de la question
  String normalizedQuestion = question.toLowerCase()
    .replaceAll(RegExp(r'[^\w\s]'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
    
  // Liste de mots-clés pour chercher des sections pertinentes dans le document
  Map<String, List<String>> keywordSections = {
    'présentation': ['présentation', 'château', 'domaine', 'cadre', 'orangerie', 'jardins', 'raffiné', 'romantique', 'élégant', 'historique', 'xviiie', 'siècle', 'événement', 'décor', 'rêve', 'mariage', 'parc', 'hectares', 'bourgogne', 'qui êtes vous', 'c\'est quoi', 'c\'est qui', 'qui est'],
  
    'prix': ['prix', 'tarif', 'coût', 'budget', 'paiement', 'combien', 'montant', 'euros', '€', 'cher', 'abordable', 'haute saison', 'basse saison', '7900', '6900', '5900', '4900', '3900', 'weekend', 'samedi', 'dimanche', 'vendredi', 'semaine', 'supplément', 'acompte', 'caution', '2000', 'prix total', 'ça coûte', 'ca coute'],
  
    'capacité': ['capacité', 'accueillir', 'personnes', 'invités', 'minimum', '180', '250', 'banquet', 'cocktail', 'configuration', 'maximum', 'taille', 'groupe', 'nombre', 'combien de personnes', 'combien d\'invités', 'nombre max', 'nombre maximum', 'place', 'places'],
  
    'espaces': ['espaces', 'orangerie', 'salon', 'grand salon', 'salon bleu', 'jardins', 'parc', 'salle', 'espace', 'cérémonie', 'baies', 'vitrées', 'cocktail', 'soirée', 'dansante', 'vin d\'honneur', 'plein air', 'm²', 'mètres', 'superficie', 'salle de réception', 'extérieur', 'intérieur'],
  
    'location': ['location', 'comprend', 'inclus', 'mobilier', 'tables', 'chaises', 'nettoyage', 'coordinateur', 'utilisation', 'réserver', 'réservation', 'disponibilité', 'disponible', 'date', 'min', 'compris', 'incluse', 'louer', 'loue', 'prestation'],
  
    'cérémonie': ['cérémonie', 'organisation', 'jardins', 'chaises', 'arche', 'fleurie', 'sonorisation', 'tapis', 'blanc', 'plein air', 'extérieur', 'supplément', '1200', 'laïque', 'mariage civil', 'célébration', 'échanger vœux'],
  
    'hébergement': ['hébergement', 'dormir', 'nuit', 'chambre', 'suite', 'logement', 'couchage', 'lit', 'petit-déjeuner', 'nuptiale', 'double', 'familiale', '180', '250', '350', '42', '18', 'check-in', 'check-out', '15h', '11h', 'chambre des mariés', 'dortoir', 'gîte'],
  
    'restauration': ['restauration', 'traiteur', 'menu', 'repas', 'nourriture', 'manger', 'cuisine', 'partenaires', 'saveurs', 'festive', 'délices', 'création', '85', 'personne', 'gastronomie', 'plat', 'dîner', 'déjeuner', 'brunch', 'buffet', 'banquet', 'dînatoire'],
  
    'boisson': ['boisson', 'alcool', 'champagne', 'vin', 'cocktail', 'bière', 'spiritueux', 'apéritif', 'open bar', 'droit de bouchon', 'formule', 'forfait', '22', '29', '15', '35', '12', 'bouteille', 'soft', 'à boire', 'liquides'],
  
    'horaires': ['horaire', 'heure', 'durée', 'temps', 'jusqu\'à quelle heure', 'fermeture', 'ouverture', '9h', '5h', '4h', 'matin', 'musique', 'limite', 'check-in', 'check-out', '15h', '11h', 'tard', 'fin', 'commencer', 'début', 'commence', 'finit'],
  
    'services': ['services', 'prestations', 'coordination', 'wedding planner', 'dj', 'photographe', 'fleuriste', 'baby-sitter', 'brunch', 'sonorisation', 'gardiennage', 'visites', 'espace enfants', 'lounge', 'vestiaire', '2500', '1200', '1800', '38', '450', 'option', 'inclus', 'propose', 'proposez', 'offre', 'options'],
  
    'accessibilité': ['accessibilité', 'pmr', 'mobilité réduite', 'rampe', 'ascenseur', 'chambres adaptées', 'toilettes', 'handicap', 'fauteuil roulant', 'accessible', 'aménagement', 'handicapé'],
  
    'paiement': ['paiement', 'acompte', 'versement', 'solde', 'caution', 'total', '30%', '40%', '2000', 'restitution', 'montant', 'réservation', 'jours', 'événement', 'payer', 'arrhes', 'virement', 'chèque', 'carte', 'régler'],
  
    'annulation': ['annulation', 'annuler', 'remboursement', 'politique', '12 mois', '6 mois', '30%', '50%', '100%', 'conservé', 'conditions', 'reporter', 'changement', 'annulé', 'remboursé', 'report'],
  
    'emplacement': ['emplacement', 'adresse', 'où', 'lieu', 'situé', 'localisation', 'accès', 'dijon', 'paris', 'tgv', 'route des étoiles', 'marsannay-la-côte', 'autoroute', 'a31', 'sortie', 'navettes', 'minutes', '2h15', '25', 'village', 'ville', 'proche', 'centre'],
  
    'parking': ['parking', 'stationnement', 'garer', 'voiture', 'véhicule', 'navette', 'valet', 'voiturier', 'privé', 'sécurisé', '150', 'option', 'gratuit', '350', 'place de parking', 'places de stationnement', 'auto', 'cars'],
  
    'restrictions': ['restrictions', 'feu d\'artifice', 'lanternes', 'confettis', 'drone', 'animaux', 'chien', 'assistance', 'autorisé', 'interdit', 'biodégradable', 'préalable', 'demande', 'règles', 'limitation', 'permis', 'autorisations', 'interdit', 'défendu', 'permis']
  };
  
  // Mapping de questions fréquentes à des sections spécifiques
  Map<String, String> commonQuestions = {
    "qui êtes vous": "présentation",
    "parle moi du lieu": "présentation",
    "comment ca marche": "location",
    "est ce que je peux": "restrictions",
    "est-ce que je peux": "restrictions",
    "puis-je": "restrictions",
    "y a-t-il": "services",
    "y a t il": "services",
    "avez vous": "services",
    "y a des": "services",
    "combien ca coute": "prix",
    "combien ça coûte": "prix",
    "prix total": "prix",
    "coûte combien": "prix",
    "c'est où": "emplacement",
    "où se trouve": "emplacement",
    "comment venir": "emplacement",
    "se garer": "parking",
    "jusqu'à quelle heure": "horaires",
    "jusqu'à quand": "horaires",
    "quand faut-il partir": "horaires",
    "pour manger": "restauration",
    "pour dormir": "hébergement",
    "chambres": "hébergement",
    "annuler": "annulation",
    "reporte": "annulation"
  };
  
  // Vérifier d'abord les questions fréquentes
  for (var question in commonQuestions.keys) {
    if (normalizedQuestion.contains(question)) {
      // Utiliser la section prédéfinie pour cette question courante
      return _getResponseFromSection(commonQuestions[question]!, keywordSections);
    }
  }

  // Si aucune question fréquente n'est détectée, poursuivre avec l'analyse par mots-clés
  
  // Système de score pour déterminer la section la plus pertinente
  Map<String, double> sectionScores = {};
  
  for (var section in keywordSections.keys) {
    double score = 0;
    List<String> keywordsFound = [];
    
    for (var keyword in keywordSections[section]!) {
      if (normalizedQuestion.contains(keyword)) {
        // Donner un score plus élevé pour les correspondances exactes ou les mots complets
        if (_isExactMatch(normalizedQuestion, keyword)) {
          score += 3.0;
        } else {
          score += 1.0;
        }
        keywordsFound.add(keyword);
      }
    }
    
    // Bonus pour les sections avec plusieurs mots-clés correspondants
    if (keywordsFound.length > 1) {
      score *= 1.5;
    }
    
    // Bonus pour les mots-clés trouvés près du début de la question
    for (var keyword in keywordsFound) {
      int position = normalizedQuestion.indexOf(keyword);
      if (position < normalizedQuestion.length / 3) {
        score += 0.5;
      }
    }
    
    if (score > 0) {
      sectionScores[section] = score;
    }
  }
  
  if (sectionScores.isEmpty) {
    return _getDefaultResponse();
  }
  
  // Trouver la section avec le score le plus élevé
  String mostRelevantSection = '';
  double highestScore = 0;
  
  sectionScores.forEach((section, score) {
    if (score > highestScore) {
      highestScore = score;
      mostRelevantSection = section;
    }
  });
  
  return _getResponseFromSection(mostRelevantSection, keywordSections);
}

// Vérifie si le mot-clé est une correspondance exacte dans la question
bool _isExactMatch(String normalizedQuestion, String keyword) {
  // Ajouter des espaces avant et après pour s'assurer que c'est un mot complet
  String paddedQuestion = " $normalizedQuestion ";
  String paddedKeyword = " $keyword ";
  return paddedQuestion.contains(paddedKeyword);
}

// Obtenir une réponse basée sur la section déterminée
String _getResponseFromSection(String section, Map<String, List<String>> keywordSections) {
  // Mapper les sections aux titres du document
  Map<String, String> sectionToDocumentTitle = {
    'présentation': 'Présentation',
    'prix': 'Prix et formules',
    'capacité': 'Capacité',
    'espaces': 'Espaces disponibles',
    'location': 'Location et réservation',
    'cérémonie': 'Cérémonie',
    'hébergement': 'Hébergement',
    'restauration': 'Restauration',
    'boisson': 'Boissons',
    'horaires': 'Horaires',
    'services': 'Services et options',
    'accessibilité': 'Accessibilité PMR',
    'paiement': 'Réservation et paiement',
    'annulation': 'Politique d\'annulation',
    'emplacement': 'Emplacement et accès',
    'parking': 'Parking',
    'restrictions': 'Restrictions et règles'
  };
  
  String sectionTitle = sectionToDocumentTitle[section] ?? section.substring(0, 1).toUpperCase() + section.substring(1);
  
  // Créer une regex qui recherche la section avec ##
  RegExp sectionRegex = RegExp(r'## ' + sectionTitle + r'.*?(?=## |\Z)', dotAll: true);
  
  final match = sectionRegex.firstMatch(_prestaDocument!);
  if (match != null) {
    String sectionText = match.group(0)!;
    // Enlever le titre de section pour une réponse plus naturelle
    sectionText = sectionText.replaceFirst('## $sectionTitle', '').trim();
    
    // Formater et améliorer la réponse
    return _formatResponse(sectionText, section);
  }
  
  // Si la section exacte n'est pas trouvée, chercher des phrases avec les mots-clés pertinents
  List<String> keywordsForSection = keywordSections[section]!;
  
  // Prioriser les mots-clés principaux de la section
  List<String> priorityKeywords = keywordsForSection.take(math.min(5, keywordsForSection.length)).toList();
  String keywordPattern = priorityKeywords.join('|');
  
  // Rechercher des phrases complètes contenant le mot-clé
  final RegExp sentenceRegex = RegExp(
    r'([^.!?\n]*(' + keywordPattern + r')[^.!?\n]*[.!?])',
    caseSensitive: false
  );
  
  final matches = sentenceRegex.allMatches(_prestaDocument!);
  if (matches.isNotEmpty) {
    List<String> relevantSentences = [];
    for (var match in matches.take(3)) { // Prendre jusqu'à 3 phrases pertinentes
      if (match.group(0) != null) {
        relevantSentences.add(match.group(0)!.trim());
      }
    }
    
    String response = relevantSentences.join(' ');
    return _formatResponse(response, section);
  }
  
  // Si toujours rien trouvé, élargir la recherche avec tous les mots-clés
  keywordPattern = keywordsForSection.join('|');
  final RegExp wideSentenceRegex = RegExp(
    r'([^.!?\n]*(' + keywordPattern + r')[^.!?\n]*[.!?])',
    caseSensitive: false
  );
  
  final wideMatches = wideSentenceRegex.allMatches(_prestaDocument!);
  if (wideMatches.isNotEmpty) {
    List<String> relevantSentences = [];
    for (var match in wideMatches.take(2)) {
      if (match.group(0) != null) {
        relevantSentences.add(match.group(0)!.trim());
      }
    }
    
    String response = relevantSentences.join(' ');
    return _formatResponse(response, section);
  }
  
  // Si toujours aucune correspondance
  return "Je n'ai pas trouvé d'information spécifique sur ${sectionTitle.toLowerCase()}. N'hésitez pas à poser une question plus précise ou à contacter directement ${widget.prestaName} pour plus de détails.";
}

// Formater et améliorer les réponses
String _formatResponse(String rawResponse, String section) {
  if (rawResponse.isEmpty) {
    return "Je n'ai pas trouvé d'information sur ce sujet.";
  }
  
  // Limiter la longueur de la réponse
  if (rawResponse.length > 500) {
    rawResponse = '${rawResponse.substring(0, 497)}...';
  }
  
  // Nettoyer la réponse
  rawResponse = rawResponse
    .replaceAll('\n\n', ' ')
    .replaceAll('  ', ' ')
    .trim();
  
  // Ajouter des phrases d'introduction personnalisées selon la section
  Map<String, List<String>> introductions = {
    'prix': [
      "Concernant les tarifs, ",
      "Pour le prix, ",
      "Voici nos formules tarifaires : "
    ],
    'hébergement': [
      "Pour l'hébergement, ",
      "Concernant les options de logement, ",
      "Voici les informations sur l'hébergement : "
    ],
    'restauration': [
      "Concernant la restauration, ",
      "Pour vos repas, ",
      "Voici nos options de restauration : "
    ],
    'capacité': [
      "À propos de la capacité d'accueil, ",
      "Le domaine peut accueillir ",
      "Concernant le nombre d'invités, "
    ],
    'présentation': [
      "${widget.prestaName} est ",
      "Pour vous présenter notre lieu, ",
      "Bienvenue au "
    ]
  };
  
  // Ajouter une introduction si disponible pour cette section
  if (introductions.containsKey(section)) {
    List<String> possibleIntros = introductions[section]!;
    String intro = possibleIntros[DateTime.now().millisecond % possibleIntros.length];
    
    // Éviter de dupliquer l'intro si la réponse commence déjà par un texte similaire
    bool shouldAddIntro = true;
    for (var introText in possibleIntros) {
      if (rawResponse.toLowerCase().startsWith(introText.toLowerCase().substring(0, math.min(introText.length, 10)))) {
        shouldAddIntro = false;
        break;
      }
    }
    
    if (shouldAddIntro) {
      return intro + rawResponse;
    }
  }
  
  return rawResponse;
}

// Réponse par défaut quand aucune correspondance n'est trouvée
String _getDefaultResponse() {
  List<String> defaultResponses = [
    "Je n'ai pas bien compris votre question. Pourriez-vous la reformuler? Je peux vous renseigner sur les prix, l'hébergement, la restauration, les services et bien d'autres aspects du ${widget.prestaName}.",
    "Désolé, je ne suis pas sûr de comprendre votre demande. N'hésitez pas à poser des questions sur nos tarifs, notre localisation, nos services ou nos options d'hébergement.",
    "Je n'ai pas trouvé d'information précise pour répondre à votre question. Vous pouvez me demander des détails sur nos espaces, nos formules ou notre capacité d'accueil."
  ];
  
  return defaultResponses[DateTime.now().second % defaultResponses.length];
}

  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête du chatbot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF524B46),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(
                    Icons.chat,
                    color: Color(0xFF524B46),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Assistant de ${widget.prestaName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          // Corps du chatbot avec les messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(_messages[index]);
                    },
                  ),
          ),
          
          // Zone de saisie de message
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Posez votre question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      enabled: _isChatbotAvailable,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _handleSubmit,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF524B46),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isChatbotAvailable
                        ? () => _handleSubmit(_textController.text)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageItem(ChatMessage message) {
    return Align(
      alignment: message.isUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUserMessage
              ? const Color(0xFF524B46)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUserMessage
                ? Colors.white
                : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// Widget flottant pour ouvrir le chatbot
class ChatbotFloatingButton extends StatelessWidget {
  final String prestaId;
  final String prestaName;
  final String? prestaEmail;
  final bool isDocumentAvailable;
  
  const ChatbotFloatingButton({
    super.key,
    required this.prestaId,
    required this.prestaName,
    this.prestaEmail,
    required this.isDocumentAvailable,
  });

  @override
  Widget build(BuildContext context) {
    // Ne pas afficher le bouton si aucun document n'est disponible
    if (!isDocumentAvailable) return const SizedBox.shrink();
    
    return Positioned(
      right: 20,
      bottom: 80, // Au-dessus des boutons d'action du bas
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF524B46),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () {
          _showChatbotModal(context);
        },
      ),
    );
  }
  
  void _showChatbotModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          margin: const EdgeInsets.all(16),
          child: ChatbotWidget(
            prestaId: prestaId,
            prestaName: prestaName,
            prestaEmail: prestaEmail,
          ),
        );
      },
    );
  }
}