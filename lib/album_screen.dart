import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/album_photos_screen.dart';
import 'package:photo_manager/photo_manager.dart';


class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<AssetPathEntity> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (mounted) {
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    }
  }

  void _showRenameDialog(AssetPathEntity album) {
    final TextEditingController controller = TextEditingController(text: album.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Album'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Rename logic here (not directly supported by photo_manager)
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _albums.isEmpty
              ? const Center(child: Text('No albums found.'))
              : ListView.builder(
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    final album = _albums[index];
                    return ListTile(
                      leading: FutureBuilder<Uint8List?>(
                        future: album.getAssetListRange(start: 0, end: 1).then((assets) => assets.first.thumbnailData),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(snapshot.data!, fit: BoxFit.cover, width: 50, height: 50,);
                          }
                          return const Icon(Icons.photo_album_outlined, size: 50);
                        },
                      ),
                      title: Text(album.name),
                      subtitle: FutureBuilder<int>(
                        future: album.assetCountAsync,
                        builder: (context, snapshot) => Text('${snapshot.data ?? 0} photos'),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlbumPhotosScreen(album: album),
                        ),
                      ),
                      onLongPress: () => _showRenameDialog(album),
                    );
                  },
                ),
    );
  }
}
