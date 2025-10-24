import 'package:go_router/go_router.dart';
import 'package:myapp/albums_screen.dart';
import 'package:myapp/home_screen.dart';
import 'package:myapp/main_shell.dart';
import 'package:myapp/permissions_screen.dart';
import 'package:myapp/swipe_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/swipe',
          builder: (context, state) => const SwipeScreen(),
        ),
        GoRoute(
          path: '/albums',
          builder: (context, state) => const AlbumsScreen(),
        ),
      ],
    ),
  ],
);
