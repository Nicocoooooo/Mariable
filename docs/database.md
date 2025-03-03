# Documentation Technique Base de Données Mariable

## Table des matières
1. [Vue d'ensemble](#vue-densemble)
2. [Structure détaillée](#structure-détaillée)
3. [Politiques de sécurité](#politiques-de-sécurité)
4. [Performances](#performances)
5. [Fonctions et vues](#fonctions-et-vues)
6. [Exemples d'utilisation](#exemples-dutilisation)

## Vue d'ensemble

### Objectif
Base de données PostgreSQL pour la plateforme Mariable, gérée via Supabase. Conçue pour gérer les prestataires de mariage, les réservations et les interactions utilisateurs.

### Technologies
- PostgreSQL 14+
- Extensions : PostGIS, uuid-ossp
- Hébergement : Supabase
- Authentification : auth.users (Supabase)

### Types personnalisés
```sql
user_status: ENUM ('prospect', 'client')
vendor_type: ENUM ('lieu', 'traiteur', 'photographe')
budget_type: ENUM ('abordable', 'premium', 'luxe')
media_type: ENUM ('image', 'brochure', 'video')
link_type: ENUM ('instagram', 'website', 'facebook')

Structure détaillée
Tables principales
PROFILES (liée à auth.users)
id UUID PRIMARY KEY REFERENCES auth.users(id)
email VARCHAR(255) NOT NULL
prenom VARCHAR(100)
nom VARCHAR(100)
prenom_conjoint VARCHAR(100)
nom_conjoint VARCHAR(100)
email_conjoint VARCHAR(255)
telephone_conjoint VARCHAR(20)
date_debut_mariage TIMESTAMP WITH TIME ZONE
date_fin_mariage TIMESTAMP WITH TIME ZONE
budget_total DECIMAL(10,2)
region VARCHAR(100)
nombre_invites INTEGER
status user_status
created_at TIMESTAMP WITH TIME ZONE
updated_at TIMESTAMP WITH TIME ZONE

PRESTA

id UUID PRIMARY KEY
type_presta vendor_type NOT NULL
type_budget budget_type NOT NULL
nom_entreprise VARCHAR(255) NOT NULL
nom_contact VARCHAR(200) NOT NULL
email VARCHAR(255) NOT NULL UNIQUE
telephone VARCHAR(20) NOT NULL
telephone_secondaire VARCHAR(20)
adresse VARCHAR(255) NOT NULL
region VARCHAR(100) NOT NULL
description TEXT NOT NULL
note_moyenne DECIMAL(2,1)
location geometry(Point, 4326)
verifie BOOLEAN DEFAULT false
actif BOOLEAN DEFAULT true
created_at TIMESTAMP WITH TIME ZONE
updated_at TIMESTAMP WITH TIME ZONE

LIEUX

id UUID PRIMARY KEY
presta_id UUID REFERENCES presta(id)
type_lieu VARCHAR(50) NOT NULL
description_salles JSONB NOT NULL
capacite_max INTEGER
espace_exterieur BOOLEAN NOT NULL
piscine BOOLEAN NOT NULL
parking BOOLEAN NOT NULL
hebergement BOOLEAN NOT NULL
capacite_hebergement INTEGER
exclusivite BOOLEAN NOT NULL
feu_artifice BOOLEAN NOT NULL
equipements_inclus JSONB NOT NULL

TRAITEURS

id UUID PRIMARY KEY
presta_id UUID REFERENCES presta(id)
type_cuisine JSONB NOT NULL
max_invites INTEGER
equipements_inclus BOOLEAN NOT NULL
details_equipements JSONB
personnel_inclus BOOLEAN NOT NULL
installation_incluse BOOLEAN NOT NULL
type_degustation VARCHAR(50)

PHOTOGRAPHES

id UUID PRIMARY KEY
presta_id UUID REFERENCES presta(id)
style JSONB NOT NULL
options_duree JSONB NOT NULL
type_livraison JSONB NOT NULL
drone BOOLEAN NOT NULL
limite_deplacement INTEGER

Tables intermédiaires
RESERVATIONS

id UUID PRIMARY KEY
utilisateur_id UUID REFERENCES auth.users(id)
presta_id UUID REFERENCES presta(id)
tarif_id UUID REFERENCES tarifs(id)
date_evenement TIMESTAMP WITH TIME ZONE NOT NULL
nombre_invites INTEGER NOT NULL
prix_total DECIMAL(10,2) NOT NULL
montant_acompte DECIMAL(10,2) NOT NULL
statut VARCHAR(20) CHECK (statut IN ('en_attente', 'confirme', 'annule'))

CONVERSATIONS et MESSAGES

-- CONVERSATIONS
id UUID PRIMARY KEY
created_at TIMESTAMP WITH TIME ZONE

-- MESSAGES
id UUID PRIMARY KEY
conversation_id UUID REFERENCES conversations(id)
expediteur_id UUID REFERENCES auth.users(id)
destinataire_id UUID REFERENCES auth.users(id)
contenu TEXT NOT NULL
lu BOOLEAN NOT NULL DEFAULT false
message_ia BOOLEAN NOT NULL DEFAULT false

