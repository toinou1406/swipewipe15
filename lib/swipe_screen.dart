import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:photo_manager/photo_manager.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final List<AssetEntity> _photos = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _pageSize = 20; // Load 20 photos at a time
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    if (albums.isNotEmpty) {
      final photos = await albums.first.getAssetListPaged(page: _currentPage, size: _pageSize);
      if (mounted) {
        setState(() {
          _photos.addAll(photos);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMorePhotos() async {
    _currentPage++;
    await _fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(child: Text('No photos to swipe.'))
              : Column(
                  children: [
                    Flexible(
                      child: Container(
                        color: Colors.black,
                        child: CardSwiper(
                          controller: _swiperController,
                          cardsCount: _photos.length,
                          onSwipe: _onSwipe,
                          padding: EdgeInsets.zero, // Remove padding
                          numberOfCardsDisplayed: 2,
                          allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true, vertical: true),
                          backCardOffset: const Offset(10, 20),
                          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                            final photo = _photos[index];
                            return FutureBuilder<Uint8List?>(
                              future: photo.originBytes, // Use original image for better quality
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.contain, // Fit the whole image
                                  );
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSwipeButtons(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSwipeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red, size: 40),
          onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
          tooltip: 'Discard',
        ),
        IconButton(
            icon: const Icon(Icons.undo, size: 30),
            onPressed: () => _swiperController.undo(),
            tooltip: 'Undo'),
        IconButton(
          icon: const Icon(Icons.photo_album_outlined, size: 30),
          onPressed: () => _swiperController.swipe(CardSwiperDirection.bottom),
          tooltip: 'Add to Album',
        ),
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.green, size: 40),
          onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
          tooltip: 'Keep',
        ),
      ],
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    HapticFeedback.lightImpact();
    debugPrint('Swiped $direction on photo $previousIndex');

    final photo = _photos[previousIndex];

    if (direction == CardSwiperDirection.left) {
      _deletePhoto(photo);
    } else if (direction == CardSwiperDirection.bottom) {
      _showAlbumSelection(photo);
    }

    // Load more photos when we are near the end
    if (currentIndex != null && _photos.length - currentIndex < 5) {
      _loadMorePhotos();
    }
    return true;
  }

  Future<void> _deletePhoto(AssetEntity photo) async {
    try {
      await PhotoManager.editor.deleteWithIds([photo.id]);
      debugPrint('Photo ${photo.id} deleted');
    } catch (e) {
      debugPrint('Failed to delete photo: $e');
    }
  }

  void _showAlbumSelection(AssetEntity photo) {
    showModalBottomSheet(
      context: context,
      builder: (builderContext) {
        return FutureBuilder<List<AssetPathEntity>>(
          future: PhotoManager.getAssetPathList(type: RequestType.image),
          builder: (futureContext, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data!.isEmpty) {
              return const Center(child: Text('Could not load albums.'));
            }

            final albums = snapshot.data!;

            return ListView.builder(
              itemCount: albums.length,
              itemBuilder: (itemContext, index) {
                final album = albums[index];
                return ListTile(
                  leading: FutureBuilder<Uint8List?>(
                    future: album.getAssetListRange(start: 0, end: 1).then((assets) async {
                       if (assets.isEmpty) return null;
                       return assets.first.thumbnailDataWithSize(const ThumbnailSize(100, 100));
                    }),
                    builder: (context, thumbSnapshot) {
                      if (thumbSnapshot.hasData && thumbSnapshot.data != null) {
                        return Image.memory(thumbSnapshot.data!, width: 56, height: 56, fit: BoxFit.cover,);
                      }
                      return const Icon(Icons.photo_album, size: 56,);
                    }
                  ),
                  title: Text(album.name),
                  subtitle: FutureBuilder<int>(
                      future: album.assetCountAsync,
                      builder: (context, countSnapshot) {
                        return Text('${countSnapshot.data ?? 0} items');
                      }),
                  onTap: () async {
                    Navigator.of(builderContext).pop();
                    try {
                      await PhotoManager.editor.copyAssetToPath(asset: photo, pathEntity: album);
                      debugPrint('Photo ${photo.id} added to album ${album.name}');
                    } catch (e) {
                      debugPrint('Failed to add photo: $e');
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
