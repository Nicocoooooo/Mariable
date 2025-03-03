# Guide d'utilisation du dépôt Git pour le projet Mariable

## Structure des branches

Notre projet Mariable utilise une structure de branches inspirée de GitFlow pour organiser le développement:

- **`main`**: Contient le code de production stable. Seul le code testé et validé y est fusionné.
- **`dev`**: Branche de développement principale où les fonctionnalités terminées sont fusionnées.
- **Branches de fonctionnalités**: Préfixées par `feature/`, elles sont créées à partir de `dev` pour développer des fonctionnalités spécifiques.

## Workflow de développement

### 1. Commencer à travailler sur une fonctionnalité

Avant de commencer à travailler, assurez-vous d'avoir la dernière version de la branche `dev`:

```bash
git checkout dev
git pull origin dev
```

Créez ensuite votre branche de fonctionnalité:

```bash
git checkout -b feature/nom-de-votre-fonctionnalite
```

Utilisez un nom descriptif qui reflète clairement ce que vous développez (ex: `feature/authentification-email`).

### 2. Développement et commits

Pendant le développement:

- Faites des commits fréquents avec des messages clairs et descriptifs
- Essayez de garder chaque commit focalisé sur une tâche spécifique

```bash
git add .
git commit -m "Description claire de vos changements"
```

### 3. Synchronisation avec le dépôt distant

Poussez régulièrement vos changements vers le dépôt distant:

```bash
git push origin feature/nom-de-votre-fonctionnalite
```

Pour récupérer les derniers changements de la branche `dev` (et résoudre d'éventuels conflits localement):

```bash
git checkout dev
git pull origin dev
git checkout feature/nom-de-votre-fonctionnalite
git merge dev
```

### 4. Finaliser une fonctionnalité

Lorsque votre fonctionnalité est terminée:

1. Assurez-vous que tous vos changements sont commités et poussés
2. Créez une Pull Request (PR) depuis votre branche de fonctionnalité vers la branche `dev`
3. Demandez une revue de code à vos collègues
4. Une fois la PR approuvée, fusionnez-la dans `dev`

## Branches existantes et responsabilités

Nous avons déjà créé les branches de fonctionnalités suivantes pour organiser notre travail:

- **`feature/auth`**: Système d'authentification et gestion des utilisateurs
- **`feature/recherche`**: Interface de recherche des prestataires et filtres
- **`feature/reservation`**: Processus de réservation et gestion du panier
- **`feature/chat`**: Assistant virtuel et messagerie
- **`feature/dashboard`**: Tableau de bord utilisateur et gestion des documents

## Structure du projet

Le code source est organisé de la manière suivante:

```
lib/
├── api/                  # Interactions avec Supabase
├── config/               # Configuration de l'application
├── core/                 # Fonctionnalités de base
├── features/             # Fonctionnalités par domaine
│   ├── auth/             # Authentification
│   ├── prestataires/     # Recherche et affichage
│   ├── reservation/      # Processus de réservation
│   ├── chat/             # Chat et IA
│   └── dashboard/        # Tableau de bord utilisateur
├── models/               # Modèles de données
├── services/             # Services partagés
├── theme/                # Thème de l'application
├── utils/                # Utilitaires
├── widgets/              # Widgets réutilisables
├── main.dart             # Point d'entrée
└── routes.dart           # Routes de navigation
```

## Bonnes pratiques

1. **Ne jamais commiter directement sur `main` ou `dev`**
2. **Gardez vos branches à jour** en synchronisant régulièrement avec `dev`
3. **Testez votre code** avant de créer une Pull Request
4. **Résolvez les conflits** dans votre branche de fonctionnalité, pas dans `dev`
5. **Revue de code**: chaque PR doit être revue par au moins un autre développeur
6. **Documentation**: commentez votre code et mettez à jour la documentation si nécessaire

## Commandes Git utiles

```bash
# Voir l'état de vos fichiers
git status

# Voir l'historique des commits
git log --oneline

# Annuler les modifications non commitées
git checkout -- .

# Voir les branches existantes
git branch -a

# Supprimer une branche locale
git branch -d nom-de-la-branche

# Créer et se déplacer vers une nouvelle branche
git checkout -b nom-de-la-branche

# Résoudre un conflit
# 1. Ouvrez les fichiers avec des conflits 
# 2. Modifiez-les pour résoudre les conflits
# 3. Ajoutez-les et commitez
git add .
git commit -m "Résolution des conflits"
```

## Aide

Si vous rencontrez des problèmes avec Git ou le workflow, n'hésitez pas à contacter le responsable technique du projet.