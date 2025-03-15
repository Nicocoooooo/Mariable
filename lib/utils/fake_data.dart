import '../Filtre/data/models/avis_model.dart';

class FakeData {
  // Liste d'avis fictifs pour les lieux/prestataires
  static List<AvisModel> getFakeAvis(String prestataireId) {
    return [
      AvisModel(
        id: '1',
        prestataireId: prestataireId,
        userId: 'user1',
        note: 5.0,
        commentaire: 'Un lieu magnifique pour notre mariage ! L\'équipe était très professionnelle et attentionnée.',
        createdAt: DateTime(2023, 7, 15),
        profile: {'prenom': 'Sophie', 'nom': 'Thomas'},
      ),
      AvisModel(
        id: '2',
        prestataireId: prestataireId,
        userId: 'user2',
        note: 4.0,
        commentaire: 'Cadre exceptionnel, mais quelques petits soucis d\'organisation.',
        createdAt: DateTime(2023, 9, 10),
        profile: {'prenom': 'Marie', 'nom': 'Jean'},
      ),
      AvisModel(
        id: '3',
        prestataireId: prestataireId,
        userId: 'user3',
        note: 5.0,
        commentaire: 'Tout était parfait ! Des prestataires à l\'écoute qui ont su s\'adapter à toutes nos demandes. Nous recommandons vivement.',
        createdAt: DateTime(2024, 2, 22),
        profile: {'prenom': 'Julie', 'nom': 'Marc'},
      ),
      AvisModel(
        id: '4',
        prestataireId: prestataireId,
        userId: 'user4',
        note: 4.5,
        commentaire: 'Très belle expérience, les invités ont adoré le lieu. Petit bémol sur l\'acoustique de la salle principale.',
        createdAt: DateTime(2024, 1, 8),
        profile: {'prenom': 'Thomas', 'nom': 'Claire'},
      ),
      AvisModel(
        id: '5',
        prestataireId: prestataireId,
        userId: 'user5',
        note: 3.5,
        commentaire: 'Le cadre est magnifique mais le rapport qualité-prix est un peu élevé. Service correct mais sans plus.',
        createdAt: DateTime(2023, 11, 30),
        profile: {'prenom': 'Alexandre', 'nom': 'Émilie'},
      ),
    ];
  }
}
