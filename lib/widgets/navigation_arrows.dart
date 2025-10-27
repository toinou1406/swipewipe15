import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationArrows extends StatelessWidget {
  final String currentScreen;

  const NavigationArrows({super.key, required this.currentScreen});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (currentScreen != 'albums')
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 30),
              onPressed: () => _navigateToPreviousScreen(context),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        if (currentScreen != 'swipe')
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 30),
              onPressed: () => _navigateToNextScreen(context),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  void _navigateToPreviousScreen(BuildContext context) {
    if (currentScreen == 'home') {
      context.go('/albums');
    } else if (currentScreen == 'swipe') {
      context.go('/home');
    }
  }

  void _navigateToNextScreen(BuildContext context) {
    if (currentScreen == 'albums') {
      context.go('/home');
    } else if (currentScreen == 'home') {
      context.go('/swipe');
    }
  }
}
