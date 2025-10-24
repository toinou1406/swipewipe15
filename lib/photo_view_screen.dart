import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoViewScreen extends StatelessWidget {
  final AssetEntity imageAsset;

  const PhotoViewScreen({super.key, required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: InteractiveViewer(
        child: FutureBuilder<dynamic>(
          future: imageAsset.originBytes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return Center(
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.contain,
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
