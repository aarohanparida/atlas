
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'create_memory_screen.dart';

class PhotoDiscoveryScreen extends StatefulWidget {
  const PhotoDiscoveryScreen({super.key});

  @override
  State<PhotoDiscoveryScreen> createState() =>
      _PhotoDiscoveryScreenState();
}

class _PhotoDiscoveryScreenState extends State<PhotoDiscoveryScreen> {
  static const int _pageSize = 150;

  final ScrollController _scrollController = ScrollController();
  final List<AssetEntity> _photos = [];
  final Set<AssetEntity> _selected = {};

  AssetPathEntity? _album;

  int _nextPage = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPhotos();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 600) {
      _loadMorePhotos();
    }
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final permission = await PhotoManager.requestPermissionExtend();

      if (!permission.hasAccess) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _error =
              'Atlas needs photo-library access to display your photos. '
              'Please enable access in your iPhone Settings.';
        });
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        if (!mounted) return;

        setState(() {
          _photos.clear();
          _hasMore = false;
          _loading = false;
        });
        return;
      }

      final album = albums.first;

      final firstBatch = await album.getAssetListPaged(
        page: 0,
        size: _pageSize,
      );

      final totalCount = await album.assetCountAsync;

      if (!mounted) return;

      setState(() {
        _album = album;
        _photos
          ..clear()
          ..addAll(firstBatch);

        _nextPage = 1;
        _hasMore = _photos.length < totalCount;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load your photos. Please try again.';
      });
    }
  }

  Future<void> _loadMorePhotos() async {
    if (_loading ||
        _loadingMore ||
        !_hasMore ||
        _album == null) {
      return;
    }

    setState(() {
      _loadingMore = true;
    });

    try {
      final morePhotos = await _album!.getAssetListPaged(
        page: _nextPage,
        size: _pageSize,
      );

      final totalCount = await _album!.assetCountAsync;

      if (!mounted) return;

      setState(() {
        _photos.addAll(morePhotos);
        _nextPage++;

        _hasMore = _photos.length < totalCount &&
            morePhotos.isNotEmpty;

        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load more photos. Scroll down to retry.',
          ),
        ),
      );
    }
  }

  void _toggleSelection(AssetEntity photo) {
    setState(() {
      if (!_selected.add(photo)) {
        _selected.remove(photo);
      }
    });
  }

  void _continueToCreateMemory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMemoryScreen(
          discoveredAssets: _selected.toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Discovery'),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : _continueToCreateMemory,
            child: Text('Continue (${_selected.length})'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(colors),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _continueToCreateMemory,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    'Create Memory (${_selected.length} selected)',
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadPhotos,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No photos found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Photos from your library will appear here.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadPhotos,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select photos for your memory.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${_photos.length} loaded',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(4),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _photos.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _photos.length) {
                return Center(
                  child: _loadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                );
              }

              final photo = _photos[index];
              final isSelected = _selected.contains(photo);

              return GestureDetector(
                onTap: () => _toggleSelection(photo),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AssetEntityImage(
                      photo,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize(300, 300),
                      fit: BoxFit.cover,
                    ),
                    if (isSelected)
                      Container(
                        color: colors.primary.withValues(alpha: 0.35),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (!_hasMore)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'You’ve reached the end of your library.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
