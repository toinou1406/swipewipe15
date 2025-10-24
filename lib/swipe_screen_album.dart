import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:photo_manager/photo_manager.dart';

class SwipeScreenAlbum extends StatefulWidget {
  final AssetPathEntity album;

  const SwipeScreenAlbum({super.key, required this.album});

  @override
  State<SwipeScreenAlbum> createState() => _SwipeScreenAlbumState();
}

class _SwipeScreenAlbumState extends State<SwipeScreenAlbum> {
  List<AssetEntity> _photos = [];
  bool _isLoading = true;
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final allPhotos = await PhotoManager.getAssetListPaged(page: 0, pageCount: 1000);
    final albumPhotos = await widget.album.getAssetListRange(start: 0, end: await widget.album.assetCountAsync);
    final albumPhotoIds = albumPhotos.map((p) => p.id).toSet();

    final photosToAdd = allPhotos.where((p) => !albumPhotoIds.contains(p.id)).toList();

    if (mounted) {
      setState(() {
        _photos = photosToAdd;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to ${widget.album.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(child: Text('No new photos to add.'))
              : CardSwiper(
                  controller: _swiperController,
                  cardsCount: _photos.length,
                  onSwipe: _onSwipe,
                  cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
                    final photo = _photos[index];
                    return Stack(
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: photo.originBytes,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.memory(snapshot.data!, fit: BoxFit.contain);
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                        if (horizontalThresholdPercentage > 0)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.add_photo_alternate_outlined, color: Colors.green, size: 100),
                          ),
                      ],
                    );
                  },
                ),
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      _addPhotoToAlbum(_photos[previousIndex]);
    }
    return true;
  }

  Future<void> _addPhotoToAlbum(AssetEntity photo) async {
    try {
      await PhotoManager.editor.copyAssetToPath(asset: photo, pathEntity: widget.album);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to ${widget.album.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add photo: $e')),
        );
      }
    }
  }
}
