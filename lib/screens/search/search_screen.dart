import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../models/note.dart';
import '../../models/vault_file.dart';
import '../../models/account_entry.dart';
import '../../models/payment_card.dart';
import '../../models/identity_card.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Map<String, List<dynamic>> _results = {};
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = {};
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
    final results = await vaultProvider.searchAll(query.trim());

    setState(() {
      _results = results;
      _isSearching = false;
      _hasSearched = true;
    });
  }

  int get _totalResults {
    int total = 0;
    for (final list in _results.values) {
      total += list.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.navSearch, style: GoogleFonts.cairo()),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                if (v.length >= 2) _search(v);
              },
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: context.tr.searchPlaceholder,
                hintStyle: GoogleFonts.cairo(),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = {};
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Results
          if (_isSearching)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_hasSearched && _totalResults == 0)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: isDark ? Colors.white24 : AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr.noSearchResults,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Notes results
                  if (_results['notes']?.isNotEmpty ?? false) ...[
                    _buildSectionHeader(context.tr.catNotes, Icons.note_alt_rounded,
                        _results['notes']!.length),
                    ..._results['notes']!.map((item) {
                      final note = item as Note;
                      return _buildResultTile(
                        title: note.title,
                        subtitle: note.content.length > 60
                            ? '${note.content.substring(0, 60)}...'
                            : note.content,
                        icon: Icons.note_alt_rounded,
                        color: AppColors.notesAccent,
                        isDark: isDark,
                      );
                    }),
                  ],

                  // Files results
                  if (_results['files']?.isNotEmpty ?? false) ...[
                    _buildSectionHeader(context.isArabic ? 'الملفات' : 'Files', Icons.folder_rounded,
                        _results['files']!.length),
                    ..._results['files']!.map((item) {
                      final file = item as VaultFile;
                      return _buildResultTile(
                        title: file.fileName,
                        subtitle: '${file.fileType} • ${file.fileSizeFormatted}',
                        icon: file.isPhoto
                            ? Icons.image_rounded
                            : file.isVideo
                                ? Icons.videocam_rounded
                                : Icons.description_rounded,
                        color: file.isPhoto
                            ? AppColors.photosAccent
                            : file.isVideo
                                ? AppColors.videosAccent
                                : AppColors.documentsAccent,
                        isDark: isDark,
                      );
                    }),
                  ],

                  // Accounts results
                  if (_results['accounts']?.isNotEmpty ?? false) ...[
                    _buildSectionHeader(context.tr.catAccounts, Icons.key_rounded,
                        _results['accounts']!.length),
                    ..._results['accounts']!.map((item) {
                      final account = item as AccountEntry;
                      return _buildResultTile(
                        title: account.serviceName,
                        subtitle: account.username,
                        icon: Icons.key_rounded,
                        color: AppColors.accountsAccent,
                        isDark: isDark,
                      );
                    }),
                  ],

                  // Payment Cards results
                  if (_results['cards']?.isNotEmpty ?? false) ...[
                    _buildSectionHeader(context.tr.cardsTitle, Icons.credit_card_rounded,
                        _results['cards']!.length),
                    ..._results['cards']!.map((item) {
                      final card = item as PaymentCard;
                      return _buildResultTile(
                        title: '${card.cardType} - ${card.cardHolderName}',
                        subtitle: card.maskedCardNumber,
                        icon: Icons.credit_card_rounded,
                        color: AppColors.cardsAccent,
                        isDark: isDark,
                      );
                    }),
                  ],

                  // Identities results
                  if (_results['identities']?.isNotEmpty ?? false) ...[
                    _buildSectionHeader(context.tr.identitiesTitle, Icons.badge_rounded,
                        _results['identities']!.length),
                    ..._results['identities']!.map((item) {
                      final idCard = item as IdentityCard;
                      return _buildResultTile(
                        title: idCard.title,
                        subtitle: '${idCard.fullName} • ${idCard.idNumber}',
                        icon: Icons.badge_rounded,
                        color: AppColors.identitiesAccent,
                        isDark: isDark,
                      );
                    }),
                  ],
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$title ($count)',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
