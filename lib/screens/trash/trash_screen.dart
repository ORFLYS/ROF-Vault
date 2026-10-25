import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/empty_state.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trashItems = vaultProvider.trashItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.trashTitle, style: GoogleFonts.cairo()),
        actions: [
          if (trashItems.isNotEmpty)
            TextButton(
              onPressed: () => _showEmptyTrashDialog(context, vaultProvider),
              child: Text(
                context.isArabic ? 'إفراغ' : 'Empty',
                style: GoogleFonts.cairo(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: trashItems.isEmpty
          ? EmptyState(
              icon: Icons.delete_outline_rounded,
              title: context.tr.emptyTrashStateTitle,
              subtitle: context.tr.trashNotice,
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: trashItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = trashItems[index];
                    return Material(
                      color: Colors.transparent,
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
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: _getTypeColor(item.originalType)
                                    .withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                _getTypeIcon(item.originalType),
                                color: _getTypeColor(item.originalType),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemNameLocalized(context.isArabic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    context.isArabic
                                        ? '${item.typeLabelLocalized(true)} • متبقي ${item.daysRemaining} يوم'
                                        : '${item.typeLabelLocalized(false)} • ${item.daysRemaining} days left',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Restore button
                            IconButton(
                              onPressed: () => vaultProvider.restoreFromTrash(item),
                              icon: const Icon(Icons.restore_rounded),
                              color: AppColors.success,
                              tooltip: context.tr.restoreItem,
                            ),
                            // Delete permanently
                            IconButton(
                              onPressed: () => _showPermanentDeleteDialog(
                                  context, vaultProvider, item.id),
                              icon: const Icon(Icons.delete_forever_rounded),
                              color: AppColors.error,
                              tooltip: context.tr.permanentDelete,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'note':
        return Icons.note_alt_rounded;
      case 'file':
        return Icons.insert_drive_file_rounded;
      case 'account':
        return Icons.key_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'identity':
        return Icons.badge_rounded;
      case 'website':
        return Icons.language_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'note':
        return AppColors.notesAccent;
      case 'file':
        return AppColors.photosAccent;
      case 'account':
        return AppColors.accountsAccent;
      case 'card':
        return AppColors.cardsAccent;
      case 'identity':
        return AppColors.identitiesAccent;
      case 'website':
        return AppColors.websitesAccent;
      default:
        return AppColors.primary;
    }
  }

  void _showPermanentDeleteDialog(
      BuildContext context, VaultProvider provider, String trashId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr.permanentDelete,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.tr.permanentDeleteConfirm,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.permanentDeleteFromTrash(trashId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.tr.permanentDelete, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showEmptyTrashDialog(BuildContext context, VaultProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr.emptyTrashConfirmTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.tr.emptyTrashConfirmMsg,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.emptyTrash();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.tr.emptyTrashBtn, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
}
