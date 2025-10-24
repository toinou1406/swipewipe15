# Blueprint de l'Application de Tri de Photos v3

## Aperçu

Une application mobile complète pour Android et iOS, conçue pour un tri de photos rapide, intuitif et efficace. L'application s'articule autour d'une barre de navigation inférieure et propose des outils de gestion d'albums, le tout dans une interface moderne avec des thèmes clair et sombre dynamiques.

## Architecture et Structure

*   **State Management**: `provider` pour la gestion d'état et l'injection de dépendances, notamment pour le thème.
*   **Navigation**: `go_router` pour une navigation déclarative et robuste entre les écrans.
*   **Structure de Navigation**: Un `Scaffold` avec une `BottomNavigationBar` pour la navigation principale entre les écrans "Swipe" et "Albums".
*   **Permissions**: `photo_manager` pour gérer l'accès à la galerie et `permission_handler` pour une gestion fine des permissions.
*   **UI**: Des composants Material 3 modernes et une typographie soignée avec `google_fonts`.
*   **Thèmes**: Gestion centralisée des thèmes clair/sombre via un `ThemeProvider` et `ChangeNotifier`.

## Flux de l'Application et Écrans

1.  **Écran de Permissions (`PermissionScreen`)**:
    *   Premier écran lancé.
    *   Vérifie et demande les autorisations nécessaires (accès aux photos, notifications).
    *   Affiche des explications claires sur la nécessité des permissions.
    *   Une fois les autorisations accordées, redirige vers l'écran principal.

2.  **Structure de Navigation Principale (`MainShell`)**:
    *   Contient le `Scaffold` principal avec l' `AppBar` et la `BottomNavigationBar`.
    *   L'AppBar contient des boutons pour basculer entre les thèmes clair, sombre et système.
    *   La `BottomNavigationBar` permet de naviguer entre `SwipeScreen` et `AlbumsScreen`.

3.  **Écran d'Accueil (`HomeScreen`)**:
    *   Actuellement utilisé comme une page de bienvenue simple, mais pourrait être fusionné ou rediriger directement vers la vue "Swipe". Pour l'instant, la route `/` redirige vers `/swipe`.

4.  **Écran de Tri (`SwipeScreen`)**:
    *   L'écran principal pour le tri des photos.
    *   Affiche les photos de la galerie sous forme de cartes empilées.
    *   L'utilisateur peut balayer à droite pour "aimer" (garder) ou à gauche pour "supprimer".
    *   Utilisera le package `flutter_card_swiper` pour l'animation de balayage.

5.  **Gestion des Albums**:
    *   **Vue Principale des Albums (`AlbumsScreen`)**:
        *   Affiche la liste de tous les albums photo existants sur l'appareil.
        *   Affiche une miniature, le nom de l'album et le nombre de photos.
        *   **Action au clic**: Naviguer vers l'écran `AlbumPhotosScreen` correspondant.
    *   **Vue Mosaïque de l'Album (`AlbumPhotosScreen`)**:
        *   Affiche les photos de l'album sélectionné en grille.
        *   Permet la visualisation en plein écran au clic sur une photo.

## Plan de Développement Actuel

- **Terminé** : Mise en place de la structure de base avec `go_router` et `provider`.
- **Terminé** : Création d'un écran de permissions robuste.
- **Terminé** : Implémentation d'un système de thème dynamique (clair/sombre/système).
- **Terminé** : Correction de la navigation et de la `BottomNavigationBar`.
- **En cours** : Remplacer la logique de création d'albums spécifique à Darwin par une approche multiplateforme.
- **À faire** : Implémenter la fonctionnalité de tri sur l'écran `SwipeScreen` avec `flutter_card_swiper`.
- **À faire** : Affiner l'interface utilisateur pour une expérience "commercialisable".
