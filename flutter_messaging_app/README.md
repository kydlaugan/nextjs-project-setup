# Flutter Messaging App

Une application Flutter moderne pour l'envoi de messages avec une interface élégante et des fonctionnalités complètes.

## Fonctionnalités

### ✅ Fonctionnalités principales
- **Envoi de messages** en temps réel
- **Interface de chat** moderne avec bulles de messages
- **Liste de contacts** avec statut en ligne/hors ligne
- **Persistance des messages** via SharedPreferences
- **Indicateurs de statut** (envoyé, reçu, lu)
- **Support multi-plateforme** (mobile, tablette, desktop)

### ✅ Interface utilisateur
- **Design moderne** avec Material Design 3
- **Mode responsive** qui s'adapte à toutes les tailles d'écran
- **Animations fluides** et transitions élégantes
- **Thème personnalisé** avec couleurs harmonieuses

### ✅ Fonctionnalités avancées
- **Recherche de contacts** par nom ou email
- **Indicateur de frappe** (typing indicator)
- **Marquage des messages comme lus**
- **Formatage intelligent** des dates et heures
- **Support des emojis** (prêt pour l'intégration)

## Structure du projet

```
flutter_messaging_app/
├── lib/
│   ├── main.dart                 # Point d'entrée de l'application
│   ├── models/
│   │   ├── user.dart            # Modèle utilisateur
│   │   └── message.dart         # Modèle message
│   ├── providers/
│   │   └── chat_provider.dart   # Gestion d'état avec Provider
│   ├── services/
│   │   └── message_service.dart # Service de persistance
│   ├── screens/
│   │   ├── contacts_screen.dart # Écran liste des contacts
│   │   └── chat_screen.dart     # Écran de conversation
│   └── widgets/
│       ├── contact_card.dart    # Carte de contact
│       ├── message_bubble.dart  # Bulle de message
│       └── message_input.dart   # Champ de saisie
├── pubspec.yaml                 # Configuration du projet
└── README.md                    # Documentation
```

## Installation et lancement

### Prérequis
- Flutter SDK (3.0.0 ou supérieur)
- Dart SDK (2.17.0 ou supérieur)

### Installation

1. **Cloner ou télécharger le projet**
```bash
cd flutter_messaging_app
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Lancer l'application**
```bash
# Pour Android/iOS
flutter run

# Pour web
flutter run -d chrome

# Pour desktop (Windows/Mac/Linux)
flutter run -d windows  # ou macos/linux
```

## Utilisation

### Navigation
- **Écran principal** : Liste des contacts avec leurs derniers messages
- **Écran de chat** : Conversation avec un contact spécifique
- **Recherche** : Rechercher des contacts par nom ou email

### Envoyer un message
1. Sélectionner un contact dans la liste
2. Tapez votre message dans le champ en bas
3. Appuyez sur le bouton "Envoyer" ou sur Entrée

### Fonctionnalités de chat
- **Statut des messages** : Les icônes indiquent l'état (✓ envoyé, ✓✓ reçu, ✓✓ lu)
- **Heures** : Affichage de l'heure d'envoi pour chaque message
- **Réponses automatiques** : Le système simule des réponses pour la démonstration

## Personnalisation

### Ajouter de nouveaux contacts
Les contacts sont actuellement définis dans `chat_provider.dart`. Pour ajouter des contacts réels, vous pouvez :

1. Connecter à une API backend
2. Intégrer Firebase Auth pour l'authentification
3. Utiliser une base de données locale

### Thèmes et couleurs
Le thème est défini dans `main.dart`. Vous pouvez personnaliser :
- Couleurs principales et secondaires
- Police de caractères
- Espacements et bordures

### Ajouter des fonctionnalités
- **Images** : Support pour l'envoi d'images
- **Fichiers** : Partage de documents
- **Appels** : Intégration d'appels audio/vidéo
- **Groupes** : Création de groupes de discussion

## Développement futur

### Prochaines fonctionnalités
- [ ] Authentification utilisateur
- [ ] Synchronisation en temps réel avec Firebase
- [ ] Support des images et fichiers
- [ ] Notifications push
- [ ] Mode sombre
- [ ] Chiffrement des messages
- [ ] Groupes de discussion
- [ ] Réactions aux messages

## Support

Pour toute question ou problème, n'hésitez pas à ouvrir une issue ou à contribuer au projet.

## Licence

Ce projet est open source et disponible sous licence MIT.
