# Photo Manager Pro Blueprint

## Overview

A Flutter application designed to provide a comprehensive and user-friendly experience for managing and browsing photos on a mobile device. The app is built with a focus on a clean, modern design, and intuitive navigation.

## Style, Design, and Features

### General
- **Theming:** A custom theme is implemented using `ThemeData` with a modern color palette based on a seed color (`#4A6572`).
- **Typography:** The app uses custom fonts from `google_fonts` (`Poppins` for headlines and `Lato` for body text) to create a clear and readable text hierarchy.
- **Navigation:** All navigation is handled by the `go_router` package, providing a declarative and robust routing solution.

### Screens
- **Permissions Screen:** The initial screen of the application. It checks for and requests permission to access the user's photo library.
- **Home Screen:** The main hub of the application. It now features:
    - Two progress bars showing the used storage space and the space freed this month.
    - Two prominent buttons for navigating to the "Swipe & Clean" and "View Albums" screens.
- **Swipe Screen:** A fun, tinder-like interface for swiping through photos. It uses the `flutter_card_swiper` package.
- **Albums Screen:** Displays a grid of all photo albums on the device. Each album is presented as a card with a thumbnail, the album name, and the number of photos.
- **Album Photos Screen:** Shows a grid of all photos within a selected album.
- **Photo Viewer Screen:** A full-screen photo viewer that allows users to zoom in and out of photos and swipe between them. It leverages the `photo_view` package.

### Packages Used
- `go_router`: For navigation.
- `google_fonts`: For custom typography.
- `photo_manager`: To access and manage photos from the device gallery.
- `photo_view`: For the full-screen photo viewer.
- `flutter_card_swiper`: For the tinder-like swipe interface.
- `permission_handler`: (Implicitly used by `photo_manager`) For handling permissions.
- `storage_space`: To get device storage information.
- `shared_preferences`: To persist simple data (like freed space).

## Current Plan

The initial request was to continue the development of the application. I have completed the following steps:

1.  **Code Review:** I conducted a thorough review of the entire codebase to understand its structure, features, and dependencies.
2.  **Navigation Correction:** I identified and fixed inconsistencies in the navigation implementation. The app now exclusively uses `go_router` for all screen transitions.
3.  **Dependency Verification:** I confirmed that all necessary dependencies are listed in the `pubspec.yaml` file.
4.  **Home Screen Redesign:** I have completely redesigned the Home Screen to be more informative and user-friendly, adding storage progress bars and clear navigation buttons.
5.  **Blueprint Update:** I have updated this `blueprint.md` file to reflect the new home screen design and added dependencies.
