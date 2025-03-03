# Mariable - Application de gestion de prestataires de mariage

Mariable est une plateforme web et mobile qui transforme l'organisation d'un mariage en un processus simple et efficace, inspirée du modèle Airbnb.

## Caractéristiques principales

- Recherche simplifiée des prestataires
- Parcours de réservation standardisé
- Assistant virtuel IA 24/7
- Espace centralisé pour documents et suivi
- Création de packages de prestataires

## Installation

1. Assurez-vous que Flutter est installé sur votre machine

flutter doctor

2. Clonez le repository

git clone https://github.com/votre-compte/mariable.git
cd mariable

3. Installez les dépendances

flutter pub get

4. Lancez l'application

flutter run

## Architecture

Ce projet utilise une architecture basée sur des fonctionnalités, avec des dossiers organisés par domaine métier.

## Base de données

Le projet utilise Supabase comme backend. Voir la documentation de la base de données dans `docs/database.md`.

## Contribuer

1. Créez une branche depuis `dev` pour votre fonctionnalité

git checkout -b feature/nom-de-la-fonctionnalite

2. Faites vos modifications et committez

git commit -m "Description claire des changements"

3. Poussez vos modifications et créez une Pull Request vers `dev`

git push origin feature/nom-de-la-fonctionnalite

## License

[MIT](LICENSE)