import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/vault_file.dart';

class FileTile extends StatelessWidget {
  final VaultFile file;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const FileTile({
    super.key,
    required this.file,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail area
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: file.isPhoto
                      ? CachedNetworkImage(
                          imageUrl: file.downloadUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _buildIconPreview(isDark),
                        )
                      : _buildIconPreview(isDark),
                ),
              ),
              // Info area
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      file.fileSizeFormatted,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconPreview(bool isDark) {
    IconData icon;
    Color color;

    if (file.isVideo) {
      icon = Icons.play_circle_filled_rounded;
      color = const Color(0xFF8B5CF6);
    } else if (file.isDocument) {
      icon = Icons.description_rounded;
      color = const Color(0xFFEF4444);
    } else {
      icon = Icons.image_rounded;
      color = const Color(0xFF3B82F6);
    }

    return Container(
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(icon, size: 40, color: color.withValues(alpha: 0.7)),
      ),
    );
  }
}
