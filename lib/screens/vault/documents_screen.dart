import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/drive_permission_dialog.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final docs = vaultProvider.documents;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.catDocuments, style: GoogleFonts.cairo()),
        leading: IconButton(
          icon: Icon(context.isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: docs.isEmpty
          ? EmptyState(
              icon: Icons.folder_rounded,
              title: context.tr.emptyDocsTitle,
              subtitle: context.tr.emptyDocsSub,
              buttonText: context.tr.uploadDocument,
              onButtonPressed: () => _pickDocument(context, vaultProvider),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onSecondaryTap: () => _showDeleteDialog(context, vaultProvider, doc),
                    onLongPress: () => _showDeleteDialog(context, vaultProvider, doc),
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
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: _getDocColor(doc.fileExtension).withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: Text(
                                doc.fileExtension.toUpperCase(),
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _getDocColor(doc.fileExtension),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  doc.fileSizeFormatted,
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
                            onPressed: () => _showDeleteDialog(context, vaultProvider, doc),
                          ),
                          Icon(
                            Icons.download_rounded,
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
        onPressed: () => _pickDocument(context, vaultProvider),
        child: const Icon(Icons.upload_file_rounded),
      ),
    );
  }

  Future<void> _pickDocument(BuildContext context, VaultProvider vaultProvider) async {
    if (!vaultProvider.isDriveConnected) {
      final connected = await DrivePermissionDialog.show(
        context,
        customTitle: context.isArabic ? 'ربط Google Drive لرفع المستندات' : 'Connect Google Drive to Upload Documents',
        customDescription: context.isArabic
            ? 'لحفظ مستنداتك وملفاتك الخاصة بشكل مشفر وآمن، يتطلب التطبيق ربط مساحتك على Google Drive.\n\nهل ترغب بربط حسابك الآن للمتابعة؟'
            : 'To save your documents securely with encryption, Google Drive is required.\n\nWould you like to connect now?',
      );
      if (!connected) return;
    }

    if (!context.mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await vaultProvider.uploadFile(file, 'document');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic ? 'تم رفع المستند بنجاح' : 'Document uploaded successfully',
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      }
    }
  }

  Color _getDocColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'doc':
      case 'docx':
        return const Color(0xFF3B82F6);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF22C55E);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFF59E0B);
      case 'txt':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  void _showDeleteDialog(BuildContext context, VaultProvider provider, dynamic doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.isArabic ? 'حذف المستند؟' : 'Delete Document?',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.isArabic ? 'سيتم نقل المستند إلى سلة المحذوفات' : 'The document will be moved to trash',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteFile(doc);
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
