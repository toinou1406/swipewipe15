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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                          numberOfCardsDisplayed: 2,
                          isLoop: false, // Don't loop through the deck
                          scale: 0.95, // Scale down the back card slightly
                          backCardOffset: const Offset(0, 15), // Adjust the back card's position
                          allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true, vertical: true),
                          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                            final photo = _photos[index];
                            return ClipRRect( // Add rounded corners to the image itself
                              borderRadius: BorderRadius.circular(16.0),
                              child: FutureBuilder<Uint8List?>(
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
                            ));
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.close,
          color: Colors.red,
          onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
        ),
        _buildActionButton(
          icon: Icons.undo,
          color: Colors.amber,
          size: 24, // Smaller icon for a secondary action
          onPressed: () => _swiperController.undo(),
        ),
        _buildActionButton(
          icon: Icons.photo_album_outlined,
          color: Colors.blue,
          size: 24,
          onPressed: () => _swiperController.swipe(CardSwiperDirection.bottom),
        ),
        _buildActionButton(
          icon: Icons.favorite,
          color: Colors.green,
          onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 32,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
        iconSize: size,
        splashRadius: size * 0.7,
      ),
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
