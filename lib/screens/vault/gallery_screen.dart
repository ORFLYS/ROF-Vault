import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../providers/vault_provider.dart';
import '../../models/vault_file.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/drive_permission_dialog.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final photos = vaultProvider.photos;
    final videos = vaultProvider.videos;
    final allMedia = vaultProvider.gallery;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.galleryTitle, style: GoogleFonts.cairo()),
        leading: IconButton(
          icon: Icon(context.isArabic
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.galleryAccent.withValues(alpha: 0.15),
                foregroundColor: AppColors.galleryAccent,
              ),
              onPressed: () => _showAddOptions(context, vaultProvider),
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: Text(context.isArabic ? 'إضافة وسائط' : 'Add Media', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.galleryAccent,
          labelColor: AppColors.galleryAccent,
          unselectedLabelColor: isDark ? Colors.white54 : AppColors.textSecondary,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: '${context.tr.tabAll} (${allMedia.length})'),
            Tab(text: '${context.tr.tabPhotos} (${photos.length})'),
            Tab(text: '${context.tr.tabVideos} (${videos.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaGrid(context, vaultProvider, allMedia, isDark, 0),
          _buildMediaGrid(context, vaultProvider, photos, isDark, 1),
          _buildMediaGrid(context, vaultProvider, videos, isDark, 2),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.galleryAccent,
        onPressed: () => _showAddOptions(context, vaultProvider),
        child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildMediaGrid(
    BuildContext context,
    VaultProvider vaultProvider,
    List<VaultFile> items,
    bool isDark,
    int tabIndex,
  ) {
    if (items.isEmpty) {
      String title = context.tr.emptyPhotosTitle;
      String subtitle = context.tr.emptyPhotosSub;
      IconData icon = Icons.photo_library_rounded;

      if (tabIndex == 2) {
        title = context.tr.emptyVideosTitle;
        subtitle = context.tr.emptyVideosSub;
        icon = Icons.videocam_rounded;
      }

      return EmptyState(
        icon: icon,
        title: title,
        subtitle: subtitle,
        buttonText: tabIndex == 2 ? context.tr.uploadVideo : context.tr.uploadPhoto,
        onButtonPressed: () {
          if (tabIndex == 2) {
            _pickVideo(context, vaultProvider);
          } else {
            _pickPhoto(context, vaultProvider);
          }
        },
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final media = items[index];
            return _buildMediaTile(context, vaultProvider, media, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildMediaTile(
    BuildContext context,
    VaultProvider vaultProvider,
    VaultFile media,
    bool isDark,
  ) {
    final isVideo = media.isVideo;

    return GestureDetector(
      onTap: () async {
        if (isVideo) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.galleryAccent),
            ),
          );
          final file = await vaultProvider.getMediaFile(media);
          if (context.mounted) Navigator.pop(context);
          if (file != null && context.mounted) {
            _showFullVideo(context, file, media, vaultProvider);
          }
        } else {
          final file = await vaultProvider.getMediaFile(media);
          if (file != null && context.mounted) {
            _showFullImage(context, file, media, vaultProvider);
          }
        }
      },
      onSecondaryTap: () => _showDeleteDialog(context, vaultProvider, media),
      onLongPress: () => _showDeleteDialog(context, vaultProvider, media),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<File?>(
                future: vaultProvider.getMediaFile(media),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isVideo ? AppColors.videosAccent : AppColors.photosAccent,
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Icon(
                        isVideo ? Icons.videocam_rounded : Icons.broken_image_rounded,
                        color: isDark ? Colors.white38 : Colors.black26,
                        size: 32,
                      ),
                    );
                  }
                  if (isVideo) {
                    return Container(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                      child: Center(
                        child: Icon(
                          Icons.movie_creation_rounded,
                          size: 40,
                          color: AppColors.galleryAccent.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }
                  return Image.file(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                },
              ),
              if (isVideo)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              if (isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              // Video label badge
              if (isVideo)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          media.fileSizeFormatted,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // Delete icon button on tile
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Tooltip(
                  message: context.tr.delete,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showDeleteDialog(context, vaultProvider, media),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context, VaultProvider vaultProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.isArabic ? 'إضافة إلى المعرض' : 'Add to Gallery',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: context.isArabic ? 'إغلاق' : 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  tileColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.photosAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded,
                        color: AppColors.photosAccent),
                  ),
                  title: Text(context.tr.importPhotos,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPhoto(context, vaultProvider);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  tileColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.videosAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.video_library_rounded,
                        color: AppColors.videosAccent),
                  ),
                  title: Text(context.tr.importVideos,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickVideo(context, vaultProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context, VaultProvider vaultProvider) async {
    if (!vaultProvider.isDriveConnected) {
      final connected = await DrivePermissionDialog.show(context);
      if (!connected) return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty && context.mounted) {
      _showUploadSnackbar(context);
      for (final pickedFile in pickedFiles) {
        try {
          await vaultProvider.uploadFile(File(pickedFile.path), 'photo');
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString(), style: GoogleFonts.cairo())),
            );
          }
          break;
        }
      }
    }
  }

  Future<void> _pickVideo(BuildContext context, VaultProvider vaultProvider) async {
    if (!vaultProvider.isDriveConnected) {
      final connected = await DrivePermissionDialog.show(context);
      if (!connected) return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      _showUploadSnackbar(context);
      try {
        await vaultProvider.uploadFile(File(pickedFile.path), 'video');
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString(), style: GoogleFonts.cairo())),
          );
        }
      }
    }
  }

  void _showUploadSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.tr.uploadingFile,
                style: GoogleFonts.cairo(),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showFullImage(
      BuildContext context, File file, VaultFile media, VaultProvider vaultProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (viewerCtx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                tooltip: context.tr.delete,
                onPressed: () => _showDeleteDialog(viewerCtx, vaultProvider, media, onDeleted: () {
                  Navigator.pop(viewerCtx);
                }),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(file),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullVideo(
      BuildContext context, File file, VaultFile media, VaultProvider vaultProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (viewerCtx) => _VideoPlayerModal(
          file: file,
          onDelete: () => _showDeleteDialog(viewerCtx, vaultProvider, media, onDeleted: () {
            Navigator.pop(viewerCtx);
          }),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, VaultProvider provider, VaultFile media,
      {VoidCallback? onDeleted}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr.deleteFile, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text(context.tr.deleteFileConfirm, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteFile(media);
              Navigator.pop(ctx);
              onDeleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              context.tr.delete,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerModal extends StatefulWidget {
  final File file;
  final VoidCallback? onDelete;

  const _VideoPlayerModal({required this.file, this.onDelete});

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              tooltip: 'حذف',
              onPressed: widget.onDelete,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                    Center(
                      child: IconButton(
                        iconSize: 56,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: AppColors.galleryAccent),
      ),
    );
  }
}
