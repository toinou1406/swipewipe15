import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      if (mounted) {
        setState(() => _hasPermission = true);
        context.go('/home');
      }
    } else {
      if (mounted) {
        setState(() => _hasPermission = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.photo_library_outlined,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Photo Manager Pro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'To get started, please grant permission to access your photo library.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              _hasPermission
                  ? ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Continue to App'),
                    )
                  : ElevatedButton(
                      onPressed: _checkPermissions, // Re-check permission on tap
                      child: const Text('Grant Permission'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
