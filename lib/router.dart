import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'home_screen.dart';
import 'swipe_screen.dart';
import 'albums_screen.dart';
import 'album_photos_screen.dart';
import 'photo_viewer_screen.dart';
import 'permissions_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const PermissionsScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: 'swipe',
          builder: (BuildContext context, GoRouterState state) {
            return const SwipeScreen();
          },
        ),
        GoRoute(
          path: 'albums',
          builder: (BuildContext context, GoRouterState state) {
            return const AlbumsScreen();
          },
        ),
        GoRoute(
          path: 'album_photos',
          builder: (BuildContext context, GoRouterState state) {
            final AssetPathEntity album = state.extra as AssetPathEntity;
            return AlbumPhotosScreen(album: album);
          },
        ),
        GoRoute(
          path: 'photo_viewer',
          builder: (BuildContext context, GoRouterState state) {
            final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
            final List<AssetEntity> photos = data['photos'] as List<AssetEntity>;
            final int initialIndex = data['index'] as int;
            return PhotoViewerScreen(photos: photos, initialIndex: initialIndex,);
          },
        ),
      ],
    ),
  ],
);
