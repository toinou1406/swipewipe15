import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'photo_view_screen.dart';
import 'swipe_screen_album.dart';

class AlbumPhotosScreen extends StatefulWidget {
  final AssetPathEntity album;

  const AlbumPhotosScreen({super.key, required this.album});

  @override
  State<AlbumPhotosScreen> createState() => _AlbumPhotosScreenState();
}

class _AlbumPhotosScreenState extends State<AlbumPhotosScreen> {
  List<AssetEntity> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final photos = await widget.album.getAssetListPaged(page: 0, size: 200);
    if (mounted) {
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    }
  }

  Future<void> _removePhotoFromAlbum(AssetEntity photo) async {
    if (Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removing from album is not supported on Android.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Album'),
        content: const Text('Are you sure you want to remove this photo from the album?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PhotoManager.editor.darwin.removeAssetsInAlbum([photo], widget.album);
        _fetchPhotos(); // Refresh photos
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove photo: $e')),
          );
        }
      }
    }
  }

  Future<void> _deletePhotoFromDevice(AssetEntity photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: const Text('Are you sure you want to permanently delete this photo? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PhotoManager.editor.deleteWithIds([photo.id]);
        _fetchPhotos(); // Refresh photos
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete photo: $e')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoViewScreen(imageAsset: photo),
                        ),
                      ),
                      child: FutureBuilder<Uint8List?>(
                        future: photo.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(snapshot.data!, fit: BoxFit.cover);
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _deletePhotoFromDevice(photo),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 14,
                          child: Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                     Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhotoFromAlbum(photo),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 14,
                          child: Icon(Icons.delete_outline, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SwipeScreenAlbum(album: widget.album),
          ),
        ).then((_) => _fetchPhotos()), // Refresh on return
        label: const Text('Add to Album'),
        icon: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }
}
