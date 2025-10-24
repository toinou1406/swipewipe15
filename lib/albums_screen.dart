import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

import 'album_photos_screen.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  List<AssetPathEntity> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    final FilterOptionGroup filterOption = FilterOptionGroup()
      ..addOrderOption(const OrderOption(type: OrderOptionType.updateDate, asc: false));

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image, filterOption: filterOption);
    if (mounted) {
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _albums.isEmpty
              ? const Center(child: Text('No albums found.'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    final album = _albums[index];
                    return FutureBuilder<Uint8List?>(
                      future: album.getAssetListRange(start: 0, end: 1).then((assets) async {
                        if (assets.isEmpty) return null;
                        return assets.first.thumbnailDataWithSize(const ThumbnailSize(200, 200));
                      }),
                      builder: (context, snapshot) {
                        Widget albumCover = const Icon(Icons.photo_album_outlined, size: 80, color: Colors.grey,);
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                          albumCover = Image.memory(snapshot.data!, fit: BoxFit.cover,);
                        }

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumPhotosScreen(album: album),
                            ),
                          ),
                          child: GridTile(
                            footer: GridTileBar(
                              backgroundColor: Colors.black45,
                              title: Text(album.name, overflow: TextOverflow.ellipsis,),
                              subtitle: FutureBuilder<int>(
                                future: album.assetCountAsync,
                                builder: (context, countSnapshot) => Text('${countSnapshot.data ?? 0} photos'),
                              ),
                            ),
                            child: albumCover,
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
