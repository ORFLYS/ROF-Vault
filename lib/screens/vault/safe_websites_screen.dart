import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/vault_provider.dart';
import '../../models/safe_website.dart';
import '../../widgets/empty_state.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class SafeWebsitesScreen extends StatefulWidget {
  const SafeWebsitesScreen({super.key});

  @override
  State<SafeWebsitesScreen> createState() => _SafeWebsitesScreenState();
}

class _SafeWebsitesScreenState extends State<SafeWebsitesScreen> {
  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final websites = vaultProvider.safeWebsites;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.websitesTitle, style: GoogleFonts.cairo()),
        leading: IconButton(
          icon: Icon(context.isArabic
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: websites.isEmpty
          ? EmptyState(
              icon: Icons.language_rounded,
              title: context.tr.emptyWebsitesTitle,
              subtitle: context.tr.emptyWebsitesSub,
              buttonText: context.tr.newWebsite,
              onButtonPressed: () => _showAddEditDialog(context, vaultProvider),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: websites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final website = websites[index];
                    return _buildWebsiteCard(context, website, isDark, vaultProvider);
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, vaultProvider),
        child: const Icon(Icons.add_link_rounded),
      ),
    );
  }

  Widget _buildWebsiteCard(BuildContext context, SafeWebsite website, bool isDark, VaultProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.websitesAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language_rounded, color: AppColors.websitesAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      website.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      website.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showAddEditDialog(context, provider, website: website),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                onPressed: () => _showDeleteDialog(context, provider, website),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.tr.usernameLabel}:',
                      style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textHint),
                    ),
                    Text(
                      website.username,
                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              _buildActionButton(
                icon: Icons.copy_rounded,
                label: context.tr.copyPassword,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: website.password));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr.copiedToClipboard, style: GoogleFonts.cairo()),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.open_in_browser_rounded,
                label: context.tr.openInBrowser,
                onTap: () async {
                  final uri = Uri.parse(website.url.startsWith('http') ? website.url : 'https://${website.url}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: AppColors.websitesAccent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.websitesAccent),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.websitesAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, VaultProvider provider, {SafeWebsite? website}) {
    final nameController = TextEditingController(text: website?.name);
    final urlController = TextEditingController(text: website?.url);
    final userController = TextEditingController(text: website?.username);
    final passController = TextEditingController(text: website?.password);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(website == null ? context.tr.newWebsite : context.tr.editWebsite, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: context.tr.websiteNameLabel),
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: context.tr.websiteUrlLabel),
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userController,
                decoration: InputDecoration(labelText: context.tr.usernameLabel),
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                decoration: InputDecoration(labelText: context.tr.passwordLabel),
                obscureText: true,
                style: GoogleFonts.cairo(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr.cancel, style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || urlController.text.isEmpty) return;
              if (website == null) {
                provider.addSafeWebsite(
                  name: nameController.text,
                  url: urlController.text,
                  username: userController.text,
                  password: passController.text,
                );
              } else {
                provider.updateSafeWebsite(website.copyWith(
                  name: nameController.text,
                  url: urlController.text,
                  username: userController.text,
                  password: passController.text,
                ));
              }
              Navigator.pop(ctx);
            },
            child: Text(context.tr.save, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VaultProvider provider, SafeWebsite website) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr.deleteWebsite, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text(context.tr.deleteWebsiteConfirm, style: GoogleFonts.cairo()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr.cancel, style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () {
              provider.deleteSafeWebsite(website.id);
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
