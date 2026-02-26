import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/home_controller.dart';

// Sheet height constants
const double _kMinChild = 0.48;
const double _kInitialChild = 0.62;
const double _kMaxChild = 0.92;

class MediaPickerSheet extends GetView<HomeController> {
  const MediaPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _kInitialChild,
      minChildSize: _kMinChild,
      maxChildSize: _kMaxChild,
      snap: true,
      snapSizes: const [_kInitialChild, _kMaxChild],
      builder: (ctx, scrollController) {
        return _PickerContent(scrollController: scrollController);
      },
    );
  }
}

class _PickerContent extends GetView<HomeController> {
  final ScrollController scrollController;
  const _PickerContent({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    // Load more when near the end
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 400) {
        controller.loadMoreAssets();
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C2B24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _Header(),
          Expanded(child: _PhotoGrid(scrollController: scrollController)),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────
class _Header extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          Row(
            children: [
              // Close button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                onPressed: Get.back,
                splashRadius: 20,
              ),

              // Album selector (center)
              Expanded(
                child: GestureDetector(
                  onTap: () => _showAlbumList(context),
                  child: Obx(() {
                    final name =
                        controller.currentAlbum.value?.name ?? 'Gallery';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // Send / Select button
              Obx(() {
                final asset = controller.selectedAsset.value;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: asset == null
                      ? const SizedBox(width: 48)
                      : GestureDetector(
                          key: const ValueKey('send'),
                          onTap: () => controller.confirmAsset(asset),
                          child: Container(
                            width: 72,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.send_rounded,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              }),
            ],
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
        ],
      ),
    );
  }

  void _showAlbumList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AlbumListSheet(),
    );
  }
}

// ── Photo Grid ─────────────────────────────────────────────────────────────
class _PhotoGrid extends GetView<HomeController> {
  final ScrollController scrollController;
  const _PhotoGrid({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingAssets.value && controller.assets.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2,
          ),
        );
      }

      // +1 for camera tile at index 0
      final totalCount = controller.assets.length + 1;

      return GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: totalCount,
        itemBuilder: (ctx, idx) {
          if (idx == 0) return _CameraTile();
          final asset = controller.assets[idx - 1];
          return _PhotoTile(asset: asset, index: idx - 1);
        },
      );
    });
  }
}

// ── Camera Tile ────────────────────────────────────────────────────────────
class _CameraTile extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.openCamera,
      child: Container(
        color: const Color(0xFF0D1F16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3D2A),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Camera',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo Tile ─────────────────────────────────────────────────────────────
class _PhotoTile extends GetView<HomeController> {
  final AssetEntity asset;
  final int index;

  const _PhotoTile({required this.asset, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedAsset.value?.id == asset.id) {
          controller.selectedAsset.value = null;
        } else {
          controller.selectedAsset.value = asset;
        }
      },
      child: Obx(() {
        final isSelected = controller.selectedAsset.value?.id == asset.id;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            _AssetThumbnail(asset: asset, size: const ThumbnailSize.square(300)),

            // Video duration badge
            if (asset.type == AssetType.video)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(asset.videoDuration),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),

            // Selection overlay
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                color: AppTheme.primary.withValues(alpha: 0.25),
              ),
            ),

            // Selection indicator (top-right circle)
            Positioned(
              top: 6,
              right: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.white.withValues(alpha: 0.7),
                    width: isSelected ? 0 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 6,
                          )
                        ]
                      : [],
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.black, size: 15)
                    : null,
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Album List Sheet ───────────────────────────────────────────────────────
class _AlbumListSheet extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final albums = controller.albums;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Albums',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: albums.length,
                itemBuilder: (_, idx) {
                  final album = albums[idx];
                  final isCurrent =
                      controller.currentAlbum.value?.id == album.id;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: _AlbumThumb(album: album),
                    title: Text(
                      album.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: FutureBuilder<int>(
                      future: album.assetCountAsync,
                      builder: (_, snap) => Text(
                        snap.hasData ? '${snap.data} photos' : '',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: isCurrent
                        ? Icon(Icons.check_rounded, color: AppTheme.primary, size: 20)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      controller.selectAlbum(album);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }
}

class _AlbumThumb extends StatelessWidget {
  final AssetPathEntity album;
  const _AlbumThumb({required this.album});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetEntity>>(
      future: album.getAssetListRange(start: 0, end: 1),
      builder: (_, snap) {
        if (!snap.hasData || snap.data!.isEmpty) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.photo, color: Colors.white24, size: 22),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: _AssetThumbnail(
              asset: snap.data!.first,
              size: const ThumbnailSize.square(96),
            ),
          ),
        );
      },
    );
  }
}

class _AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final ThumbnailSize size;
  const _AssetThumbnail({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(size),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Container(
            color: AppTheme.card,
            child: const Icon(Icons.broken_image, color: Colors.white24),
          );
        }
        return Image.memory(bytes, fit: BoxFit.cover);
      },
    );
  }
}
