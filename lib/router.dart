import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'home_screen.dart';
import 'swipe_screen.dart';
import 'albums_screen.dart';
import 'album_photos_screen.dart';
import 'photo_viewer_screen.dart';
import 'permissions_screen.dart';
import 'main_scaffold.dart'; // Import the new scaffold

// Create a GlobalKey for the navigator to be used by the ShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home', // Start at the home screen
  routes: <RouteBase>[
    // The permissions screen is now a top-level route that redirects.
    // In a real app, you'd likely have a more sophisticated auth flow.
    GoRoute(
      path: '/',
      builder: (context, state) => const PermissionsScreen(),
    ),
    // The main app structure is now a StatefulShellRoute.
    // This allows for a persistent bottom navigation bar.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // The navigationShell is a widget that contains the page for the selected branch.
        return MainScaffold(child: navigationShell);
      },
      branches: [
        // Branch for the Albums tab
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/albums',
              builder: (context, state) => const AlbumsScreen(),
              routes: [
                // Nested route for viewing photos in a specific album
                GoRoute(
                  path: 'album_photos',
                  builder: (context, state) {
                    final AssetPathEntity album = state.extra as AssetPathEntity;
                    return AlbumPhotosScreen(album: album);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch for the Home tab
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch for the Swipe tab
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/swipe',
              builder: (context, state) => const SwipeScreen(),
            ),
          ],
        ),
      ],
    ),
    // This is a top-level route for the photo viewer, so it covers the nav bar.
    GoRoute(
      path: '/photo_viewer',
      parentNavigatorKey: _rootNavigatorKey, // Use the root navigator
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final List<AssetEntity> photos = data['photos'] as List<AssetEntity>;
        final int initialIndex = data['index'] as int;
        return PhotoViewerScreen(photos: photos, initialIndex: initialIndex);
      },
    ),
  ],
);
