import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/drive_permission_dialog.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final videos = vaultProvider.videos;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.catVideos, style: GoogleFonts.cairo()),
        leading: IconButton(
          icon: Icon(context.isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: videos.isEmpty
          ? EmptyState(
              icon: Icons.videocam_rounded,
              title: context.tr.emptyVideosTitle,
              subtitle: context.tr.emptyVideosSub,
              buttonText: context.tr.uploadVideo,
              onButtonPressed: () => _pickVideo(context, vaultProvider),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final video = videos[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.videosAccent)),
                      );
                      final file = await vaultProvider.getMediaFile(video);
                      if (context.mounted) Navigator.pop(context); // close loading
                      if (file != null && context.mounted) {
                        _showFullVideo(context, file);
                      }
                    },
                    onSecondaryTap: () => _showDeleteDialog(context, vaultProvider, video),
                    onLongPress: () => _showDeleteDialog(context, vaultProvider, video),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: AppColors.videosAccent.withValues(alpha: 0.1),
                            ),
                            child: const Icon(
                              Icons.play_circle_filled_rounded,
                              color: AppColors.videosAccent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  video.fileSizeFormatted,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            tooltip: context.tr.delete,
                            onPressed: () => _showDeleteDialog(context, vaultProvider, video),
                          ),
                          Icon(
                            context.isArabic
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            color: isDark ? Colors.white30 : AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickVideo(context, vaultProvider),
        child: const Icon(Icons.video_call_rounded),
      ),
    );
  }

  Future<void> _pickVideo(BuildContext context, VaultProvider vaultProvider) async {
    if (!vaultProvider.isDriveConnected) {
      final connected = await DrivePermissionDialog.show(
        context,
        customTitle: context.isArabic ? 'ربط Google Drive لرفع الفيديوهات' : 'Connect Google Drive to Upload Videos',
        customDescription: context.isArabic
            ? 'لحفظ مقاطع الفيديو الخاصة بك بشكل مشفر وآمن، يتطلب التطبيق ربط مساحتك على Google Drive.\n\nهل ترغب بربط حسابك الآن للمتابعة؟'
            : 'To store your personal videos with secure encryption, Google Drive is required.\n\nWould you like to connect now?',
      );
      if (!connected) return;
    }

    if (!context.mounted) return;

    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.isArabic ? 'إذن الوصول' : 'Access Permission',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.isArabic
              ? 'يطلب التطبيق الإذن لفتح معرض الفيديوهات الخاص بك. هل تسمح بذلك؟'
              : 'The app requests permission to open your video gallery. Allow access?',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.isArabic ? 'السماح ومتابعة' : 'Allow & Continue', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      await vaultProvider.uploadFile(File(video.path), 'video');
      if (context.mounted) {
        if (vaultProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vaultProvider.error!, style: GoogleFonts.cairo()),
              backgroundColor: AppColors.error,
            ),
          );
          vaultProvider.clearError();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.isArabic ? 'تم رفع الفيديو بنجاح' : 'Video uploaded successfully',
                style: GoogleFonts.cairo(),
              ),
            ),
          );
        }
      }
    }
  }

  void _showDeleteDialog(BuildContext context, VaultProvider provider, dynamic video) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.isArabic ? 'حذف الفيديو؟' : 'Delete Video?',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.isArabic ? 'سيتم نقل الفيديو إلى سلة المحذوفات' : 'The video will be moved to trash',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteFile(video);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.tr.delete, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
  void _showFullVideo(BuildContext context, File videoFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoFile: videoFile),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  const VideoPlayerScreen({super.key, required this.videoFile});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _isInit = true;
        });
        _controller.play();
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
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isInit
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.all(12),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          color: Colors.white,
                          size: 64,
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
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
