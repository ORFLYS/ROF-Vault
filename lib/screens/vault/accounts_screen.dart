import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/vault_provider.dart';
import '../../models/account_entry.dart';
import '../../widgets/account_card.dart';
import '../../widgets/empty_state.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';
import 'account_editor_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final accounts = vaultProvider.accounts;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.accountsTitle, style: GoogleFonts.cairo()),
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
              onPressed: () => _openEditor(context, null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.tr.newAccount, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: accounts.isEmpty
          ? EmptyState(
              icon: Icons.key_rounded,
              title: context.tr.emptyAccountsTitle,
              subtitle: context.tr.emptyAccountsSub,
              buttonText: context.tr.newAccount,
              onButtonPressed: () => _openEditor(context, null),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return AccountCard(
                      account: account,
                      onTap: () => _showAccountDetails(context, vaultProvider, account),
                      onDelete: () => _confirmDeleteAccount(context, vaultProvider, account),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, null),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openEditor(BuildContext context, AccountEntry? account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountEditorScreen(account: account),
      ),
    );
  }

  void _showAccountDetails(
      BuildContext context, VaultProvider provider, AccountEntry account) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      // Service icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [AppColors.accountsAccent, Color(0xFF059669)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accountsAccent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            account.serviceInitial,
                            style: GoogleFonts.cairo(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: context.isArabic ? 'إغلاق' : 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    account.serviceName,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Username
                  _buildDetailRow(
                    context,
                    context.tr.usernameLabel,
                    account.username,
                    Icons.person_outline_rounded,
                    () {
                      Clipboard.setData(ClipboardData(text: account.username));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr.copiedToClipboard, style: GoogleFonts.cairo())),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  _buildDetailRow(
                    context,
                    context.tr.passwordLabel,
                    '••••••••',
                    Icons.lock_outline_rounded,
                    () {
                      Clipboard.setData(ClipboardData(text: account.password));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr.copiedToClipboard, style: GoogleFonts.cairo())),
                      );
                    },
                  ),

                  if (account.websiteUrl != null && account.websiteUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      context.tr.websiteUrlLabel,
                      account.websiteUrl!,
                      Icons.link_rounded,
                      () {
                        Clipboard.setData(ClipboardData(text: account.websiteUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr.copiedToClipboard, style: GoogleFonts.cairo())),
                        );
                      },
                      trailingAction: IconButton(
                        icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                        color: AppColors.primary,
                        tooltip: context.tr.openInBrowser,
                        onPressed: () async {
                          var urlStr = account.websiteUrl!;
                          if (!urlStr.startsWith('http://') && !urlStr.startsWith('https://')) {
                            urlStr = 'https://$urlStr';
                          }
                          final uri = Uri.tryParse(urlStr);
                          if (uri != null) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                  ],

                  if (account.notes != null && account.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      context.tr.notesOptional,
                      account.notes!,
                      Icons.note_outlined,
                      null,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openEditor(context, account);
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: Text(context.tr.edit, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            provider.deleteAccount(account.id);
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: Text(context.tr.delete, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback? onCopy, {
    Widget? trailingAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ?trailingAction,
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, size: 20),
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(
      BuildContext context, VaultProvider provider, AccountEntry account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr.delete, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text(
          context.isArabic
              ? 'هل أنت متأكد من حذف حساب "${account.serviceName}"؟'
              : 'Are you sure you want to delete account "${account.serviceName}"?',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteAccount(account.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(context.tr.delete, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
