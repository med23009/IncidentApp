# Application de Signalement d'Incidents Urbains

Cette application permet aux utilisateurs de signaler divers incidents urbains (incendies, accidents, etc.) en capturant une photo, en fournissant une description et en indiquant la localisation précise.

## Fonctionnalités

### Authentification
- Inscription et connexion sécurisées
- Authentification JWT
- Support de l'authentification biométrique
- Gestion des mots de passe oubliés
- Validation des emails

### Signalement d'Incidents
- Capture de photos avec la caméra
- Description détaillée des incidents
- Géolocalisation précise
- Catégorisation des incidents
- Statut de l'incident (en cours, résolu, etc.)
- Commentaires et mises à jour

### Fonctionnalités Avancées
- Mode hors ligne avec synchronisation automatique
- Notifications en temps réel
- Historique des signalements
- Tableau de bord administrateur
- Export de données
- Rapports statistiques

## Installation

### Prérequis
- Python 3.8 ou supérieur
- Node.js 14 ou supérieur
- Flutter 3.0 ou supérieur
- PostgreSQL (optionnel, SQLite par défaut)

### Backend (Django)

1. Cloner le repository :
```bash
git clone https://github.com/votre-username/IRT42.git
cd IRT42
```

2. Créer et activer l'environnement virtuel :
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

3. Installer les dépendances Python :
```bash
pip install -r requirements.txt
```

4. Configurer les variables d'environnement :
```bash
cp .env.example .env
# Éditer le fichier .env avec vos configurations
```

5. Appliquer les migrations :
```bash
python manage.py migrate
```

6. Créer un superutilisateur :
```bash
python manage.py createsuperuser
```

7. Lancer le serveur de développement :
```bash
python manage.py runserver
```

### Frontend (Flutter)

1. Installer les dépendances Flutter :
```bash
cd ain
flutter pub get
```

2. Configurer les variables d'environnement :
```bash
cp .env.example .env
# Éditer le fichier .env avec vos configurations
```

3. Lancer l'application :
```bash
flutter run
```

## Structure du Projet

### Backend (Django)
```
IRT42/
├── authentication/         # Application d'authentification
│   ├── models/            # Modèles de données
│   ├── views/             # Vues et logique métier
│   ├── serializers/       # Sérialiseurs pour l'API
│   └── tests/             # Tests unitaires
├── incidents/             # Application principale
│   ├── models/            # Modèles de données
│   ├── views/             # Vues et logique métier
│   ├── serializers/       # Sérialiseurs pour l'API
│   └── tests/             # Tests unitaires
├── config/                # Configuration du projet
└── manage.py              # Script de gestion Django
```

### Frontend (Flutter)
```
ain/
├── lib/
│   ├── core/                      # Code commun et configuration
│   │   ├── bindings/             # Liaisons GetX
│   │   │   └── initial_bindings.dart  # Liaisons initiales de l'application
│   │   │
│   │   ├── constants/            # Constantes de l'application
│   │   │   └── constants.dart    # Constantes globales
│   │   │
│   │   ├── middleware/           # Middleware pour les routes
│   │   │   └── auth_middleware.dart  # Middleware d'authentification
│   │   │
│   │   ├── models/               # Modèles de base
│   │   │   ├── settings_model.dart   # Modèle des paramètres
│   │   │   ├── incident_model.dart   # Modèle des incidents
│   │   │   └── user_model.dart       # Modèle utilisateur
│   │   │
│   │   ├── routes/               # Configuration des routes
│   │   │   ├── app_pages.dart    # Définition des pages
│   │   │   └── app_routes.dart   # Définition des routes
│   │   │
│   │   ├── services/             # Services partagés
│   │   │   ├── biometric_service.dart  # Service biométrique
│   │   │   ├── api_service.dart        # Service API
│   │   │   ├── auth_service.dart       # Service d'authentification
│   │   │   ├── settings_service.dart   # Service des paramètres
│   │   │   ├── storage_service.dart    # Service de stockage
│   │   │   └── theme_service.dart      # Service de thème
│   │   │
│   │   └── theme/                # Thème de l'application
│   │       ├── theme_service.dart  # Service de gestion du thème
│   │       ├── app_colors.dart     # Couleurs de l'application
│   │       └── app_theme.dart      # Configuration du thème
│   │
│   ├── features/                 # Fonctionnalités de l'application
│   │   ├── auth/                 # Authentification
│   │   │   ├── data/            # Couche données
│   │   │   │   └── services/    # Services d'authentification
│   │   │   │       └── auth_service.dart  # Service d'authentification
│   │   │   │
│   │   │   ├── domain/          # Couche domaine
│   │   │   │   └── models/      # Modèles d'authentification
│   │   │   │       ├── auth_response.dart    # Réponse d'authentification
│   │   │   │       ├── register_request.dart # Requête d'inscription
│   │   │   │       └── auth_request.dart     # Requête d'authentification
│   │   │   │
│   │   │   └── presentation/    # Couche présentation
│   │   │       ├── controllers/
│   │   │       │   └── auth_controller.dart  # Contrôleur d'authentification
│   │   │       └── pages/
│   │   │           ├── login_page.dart       # Page de connexion
│   │   │           ├── register_page.dart    # Page d'inscription
│   │   │           └── reset_password_page.dart  # Page de réinitialisation
│   │   │
│   │   ├── incidents/            # Gestion des incidents
│   │   │   ├── data/            # Couche données
│   │   │   ├── domain/          # Couche domaine
│   │   │   │   └── models/      # Modèles des incidents
│   │   │   │       └── incident.dart  # Modèle d'incident
│   │   │   └── presentation/    # Couche présentation
│   │   │       ├── controllers/ # Contrôleurs des incidents
│   │   │       │   ├── incident_controller.dart  # Contrôleur des incidents
│   │   │       │   └── location_controller.dart  # Contrôleur de localisation
│   │   │       ├── pages/       # Pages des incidents
│   │   │       │   ├── home_page.dart           # Page d'accueil
│   │   │       │   ├── incident_detail_page.dart # Page de détail d'incident
│   │   │       │   └── report_incident_page.dart # Page de signalement
│   │   │       └── widgets/     # Widgets des incidents
│   │   │           ├── incident_card.dart    # Carte d'incident
│   │   │           └── incident_filter.dart  # Filtre d'incidents
│   │   │
│   │   └── settings/             # Paramètres de l'application
│   │       └── presentation/     # Couche présentation
│   │           └── pages/        # Pages des paramètres
│   │               └── settings_page.dart  # Page des paramètres
│   │
│   └── main.dart                 # Point d'entrée de l'application
│
└── pubspec.yaml                  # Dépendances Flutter
```

## Dépendances Flutter

### Principales dépendances
- **State Management**: GetX (^4.6.6)
- **HTTP Client**: Dio (^5.3.2)
- **Local Storage**: 
  - shared_preferences (^2.2.2)
  - hive (^2.2.3)
  - hive_flutter (^1.1.0)
- **Location**:
  - geolocator (^10.1.0)
  - google_maps_flutter (^2.5.3)
- **Image Picker**: image_picker (^1.0.4)
- **Audio Recording**: record (^5.0.4)
- **JWT**: jwt_decoder (^2.0.1)
- **Biometric Authentication**: local_auth (^2.1.8)
- **UI Components**:
  - flutter_svg (^2.0.9)
  - cached_network_image (^3.3.1)
  - shimmer (^3.0.0)
- **Form Validation**:
  - flutter_form_builder (^9.1.1)
  - form_builder_validators (^11.1.2)
- **Utils**:
  - intl (^0.19.0)
  - path_provider (^2.1.1)
  - permission_handler (^11.1.0)
  - flutter_secure_storage (^9.0.0)
  - flutter_local_notifications (^19.1.0)

### Dépendances de développement
- flutter_lints (^2.0.0)
- build_runner (^2.4.8)
- hive_generator (^2.0.1)

## API Endpoints

### Authentification
- `POST /api/auth/register/` - Inscription
- `POST /api/auth/login/` - Connexion
- `POST /api/auth/logout/` - Déconnexion
- `POST /api/auth/refresh/` - Rafraîchir le token
- `POST /api/auth/reset-password/` - Réinitialiser le mot de passe

### Incidents
- `GET /api/incidents/` - Liste des incidents
- `POST /api/incidents/` - Créer un incident
- `GET /api/incidents/{id}/` - Détails d'un incident
- `PUT /api/incidents/{id}/` - Mettre à jour un incident
- `DELETE /api/incidents/{id}/` - Supprimer un incident

### Utilisateurs
- `GET /api/users/me/` - Profil de l'utilisateur
- `PUT /api/users/me/` - Mettre à jour le profil
- `GET /api/users/{id}/` - Détails d'un utilisateur

## Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Contact

Pour toute question ou suggestion, n'hésitez pas à nous contacter à [votre-email@example.com](mailto:votre-email@example.com) 