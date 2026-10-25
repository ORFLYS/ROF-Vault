import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/drive_permission_dialog.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class PhotosScreen extends StatelessWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photos = vaultProvider.photos;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.catPhotos, style: GoogleFonts.cairo()),
        leading: IconButton(
          icon: Icon(context.isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: photos.isEmpty
          ? EmptyState(
              icon: Icons.photo_library_rounded,
              title: context.tr.emptyPhotosTitle,
              subtitle: context.tr.emptyPhotosSub,
              buttonText: context.tr.uploadPhoto,
              onButtonPressed: () => _pickPhoto(context, vaultProvider),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () async {
                    final file = await vaultProvider.getMediaFile(photo);
                    if (file != null && context.mounted) {
                      _showFullImage(context, file);
                    }
                  },
                  onSecondaryTap: () => _showDeleteDialog(context, vaultProvider, photo),
                  onLongPress: () => _showDeleteDialog(context, vaultProvider, photo),
                  child: Hero(
                    tag: 'photo_${photo.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FutureBuilder<File?>(
                            future: vaultProvider.getMediaFile(photo),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                return Container(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  child: const Icon(Icons.broken_image_rounded),
                                );
                              }
                              return Image.file(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          PositionedDirectional(
                            top: 6,
                            end: 6,
                            child: Tooltip(
                              message: context.tr.delete,
                              child: Material(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _showDeleteDialog(context, vaultProvider, photo),
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
              },
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickPhoto(context, vaultProvider),
        child: const Icon(Icons.add_photo_alternate_rounded),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context, VaultProvider vaultProvider) async {
    if (!vaultProvider.isDriveConnected) {
      final connected = await DrivePermissionDialog.show(
        context,
        customTitle: context.isArabic ? 'ربط Google Drive لرفع الصور' : 'Connect Google Drive to Upload Photos',
        customDescription: context.isArabic
            ? 'لحفظ صورك الشخصية بشكل مشفر وآمن، يتطلب التطبيق ربط مساحتك على Google Drive.\n\nهل ترغب بربط حسابك الآن للمتابعة؟'
            : 'To save your personal photos securely with encryption, Google Drive is required.\n\nWould you like to connect your account now?',
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
              ? 'يطلب التطبيق الإذن لفتح معرض الصور الخاص بك. هل تسمح بذلك؟'
              : 'The app requests permission to open your photo gallery. Allow access?',
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
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      await vaultProvider.uploadFile(File(image.path), 'photo');
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
                context.isArabic ? 'تم رفع الصورة بنجاح' : 'Photo uploaded successfully',
                style: GoogleFonts.cairo(),
              ),
            ),
          );
        }
      }
    }
  }

  void _showFullImage(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VaultProvider provider, dynamic photo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.isArabic ? 'حذف الصورة؟' : 'Delete Photo?',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.isArabic ? 'سيتم نقل الصورة إلى سلة المحذوفات' : 'The photo will be moved to trash',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteFile(photo);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.tr.delete, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
}
