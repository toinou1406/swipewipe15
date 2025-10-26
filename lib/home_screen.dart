import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_space/storage_space.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StorageSpace? _storageSpace;
  double _freedSpaceThisMonth = 0.0; // In GB, placeholder for now
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initStorage();
    _loadFreedSpace();
  }

  Future<void> _initStorage() async {
    try {
      final space = await getStorageSpace(
        lowOnSpaceThreshold: 10,
        fractionDigits: 1,
      ); 
      if (mounted) {
        setState(() {
          _storageSpace = space;
        });
      }
    } catch (e) {
      // Handle potential errors, e.g., platform not supported
      debugPrint('Error getting storage space: $e');
    } finally {
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Placeholder for loading freed space.
  // In a real app, you would increment this when photos are deleted.
  Future<void> _loadFreedSpace() async {
    final prefs = await SharedPreferences.getInstance();
    // For demonstration, let's just set a mock value.
    // In a real scenario, you'd calculate this.
    setState(() {
      _freedSpaceThisMonth = prefs.getDouble('freedSpace') ?? 2.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Deprecation fix
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Photo Manager Pro',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.headlineLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildStorageInfoCard(),
                    const SizedBox(height: 50),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStorageInfoCard() {
    // Values are in bytes, convert to GB
    final totalSpaceGB = (_storageSpace?.total ?? 0) / (1024 * 1024 * 1024);
    final freeSpaceGB = (_storageSpace?.free ?? 0) / (1024 * 1024 * 1024);
    final usedSpaceGB = totalSpaceGB - freeSpaceGB;
    final usedPercentage = totalSpaceGB > 0 ? (usedSpaceGB / totalSpaceGB) : 0.0;

    // Assuming a monthly goal of 10GB freed
    const monthlyGoalGB = 10.0;
    final freedPercentage = _freedSpaceThisMonth / monthlyGoalGB;

    return Card(
       elevation: 4,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(
                title: 'Storage Used',
                value: usedSpaceGB,
                total: totalSpaceGB,
                percentage: usedPercentage,
                unit: 'GB',
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              _buildProgressBar(
                title: 'Freed This Month',
                value: _freedSpaceThisMonth,
                total: monthlyGoalGB,
                percentage: freedPercentage,
                unit: 'GB',
                color: Colors.green,
              ),
            ],
         ),
       )
    );
  }

  Widget _buildProgressBar({
    required String title,
    required double value,
    required double total,
    required double percentage,
    required String unit,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.lato(textStyle: Theme.of(context).textTheme.titleMedium, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: color.withAlpha(50), // Deprecation fix
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} $unit',
          style: GoogleFonts.lato(textStyle: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

}
