import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  void initState() {
    super.initState();
    // Using addPostFrameCallback to safely navigate after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPermission();
    });
  }

  Future<void> _checkInitialPermission() async {
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.photos.request();

    if (mounted) {
      if (status.isGranted || status.isLimited) {
        context.go('/home');
      } else if (status.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'This app needs photo access to function. Please grant permission in app settings.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
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
              ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
