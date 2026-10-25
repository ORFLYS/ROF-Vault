import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:uuid/uuid.dart';
import '../../providers/vault_provider.dart';
import '../../models/identity_card.dart';
import '../../widgets/empty_state.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class IdentitiesScreen extends StatelessWidget {
  const IdentitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final identities = vaultProvider.identities;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.identitiesTitle, style: GoogleFonts.cairo()),
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
              onPressed: () => _openIdentityDialog(context, null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.tr.newIdentity, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: identities.isEmpty
          ? EmptyState(
              icon: Icons.badge_rounded,
              title: context.tr.emptyIdentitiesTitle,
              subtitle: context.tr.emptyIdentitiesSub,
              buttonText: context.tr.newIdentity,
              onButtonPressed: () => _openIdentityDialog(context, null),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: identities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = identities[index];
                    return _buildIdentityCard(context, vaultProvider, item, isDark);
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.identitiesAccent,
        onPressed: () => _openIdentityDialog(context, null),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildIdentityCard(
    BuildContext context,
    VaultProvider provider,
    IdentityCard item,
    bool isDark,
  ) {
    final dateFormat = DateFormat('yyyy/MM/dd');

    // Status badge
    Widget statusBadge;
    if (item.isExpired) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          context.tr.statusExpired,
          style: GoogleFonts.cairo(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (item.isExpiringSoon) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          context.tr.statusExpiringSoon,
          style: GoogleFonts.cairo(
            color: AppColors.warning,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (item.expiryDate != null) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          context.tr.statusValid,
          style: GoogleFonts.cairo(
            color: AppColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      statusBadge = const SizedBox.shrink();
    }

    // ID Type Icon
    IconData typeIcon = Icons.badge_rounded;
    if (item.idType == 'passport') typeIcon = Icons.flight_takeoff_rounded;
    if (item.idType == 'driver_license') typeIcon = Icons.drive_eta_rounded;
    if (item.idType == 'residency') typeIcon = Icons.home_work_rounded;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Title + Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.identitiesAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(typeIcon, color: AppColors.identitiesAccent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item.fullName,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                statusBadge,
              ],
            ),
            const SizedBox(height: 16),

            // ID Number pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pin_rounded, size: 18, color: AppColors.identitiesAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.idNumber,
                      style: GoogleFonts.chivoMono(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: AppColors.identitiesAccent,
                    tooltip: context.tr.copyIdNumber,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.idNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.tr.copiedToClipboard,
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Dates
            if (item.issueDate != null || item.expiryDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.issueDate != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_rounded,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(item.issueDate!),
                            style: GoogleFonts.chivoMono(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (item.expiryDate != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.event_busy_rounded,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(item.expiryDate!),
                            style: GoogleFonts.chivoMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: item.isExpired
                                  ? AppColors.error
                                  : (item.isExpiringSoon
                                      ? AppColors.warning
                                      : (isDark ? Colors.white60 : AppColors.textSecondary)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],

            // Photos attachment previews (Front & Back)
            if (item.frontImagePath != null || item.backImagePath != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  if (item.frontImagePath != null)
                    Expanded(
                      child: _buildPhotoThumbnail(
                        context,
                        item.frontImagePath!,
                        context.tr.frontImageLabel,
                        isDark,
                      ),
                    ),
                  if (item.frontImagePath != null && item.backImagePath != null)
                    const SizedBox(width: 12),
                  if (item.backImagePath != null)
                    Expanded(
                      child: _buildPhotoThumbnail(
                        context,
                        item.backImagePath!,
                        context.tr.backImageLabel,
                        isDark,
                      ),
                    ),
                ],
              ),
            ],

            // Notes (if present)
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                item.notes!,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Card actions: Edit / Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openIdentityDialog(context, item),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(context.tr.edit, style: GoogleFonts.cairo()),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirm(context, provider, item),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                  label: Text(
                    context.tr.delete,
                    style: GoogleFonts.cairo(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(
      BuildContext context, String path, String label, bool isDark) {
    final file = File(path);
    final exists = file.existsSync();

    return GestureDetector(
      onTap: () {
        if (exists) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  title: Text(label, style: GoogleFonts.cairo()),
                ),
                body: Center(
                  child: InteractiveViewer(
                    child: Image.file(file),
                  ),
                ),
              ),
            ),
          );
        }
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: exists
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(file, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                ),
              ),
      ),
    );
  }

  void _openIdentityDialog(BuildContext context, IdentityCard? existing) {
    showDialog(
      context: context,
      builder: (ctx) => _IdentityFormBottomSheet(identity: existing),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, VaultProvider provider, IdentityCard item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr.deleteIdentity, style: GoogleFonts.cairo()),
        content: Text(context.tr.deleteIdentityConfirm, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () {
              provider.deleteIdentity(item.id);
              Navigator.pop(ctx);
            },
            child: Text(
              context.tr.delete,
              style: GoogleFonts.cairo(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityFormBottomSheet extends StatefulWidget {
  final IdentityCard? identity;

  const _IdentityFormBottomSheet({this.identity});

  @override
  State<_IdentityFormBottomSheet> createState() => _IdentityFormBottomSheetState();
}

class _IdentityFormBottomSheetState extends State<_IdentityFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _fullNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _notesController;

  String _idType = 'national_id';
  DateTime? _issueDate;
  DateTime? _expiryDate;
  String? _frontImagePath;
  String? _backImagePath;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.identity?.title ?? '');
    _fullNameController =
        TextEditingController(text: widget.identity?.fullName ?? '');
    _idNumberController =
        TextEditingController(text: widget.identity?.idNumber ?? '');
    _notesController =
        TextEditingController(text: widget.identity?.notes ?? '');
    _idType = widget.identity?.idType ?? 'national_id';
    _issueDate = widget.identity?.issueDate;
    _expiryDate = widget.identity?.expiryDate;
    _frontImagePath = widget.identity?.frontImagePath;
    _backImagePath = widget.identity?.backImagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _idNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _frontImagePath = picked.path;
        } else {
          _backImagePath = picked.path;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<VaultProvider>(context, listen: false);
    final now = DateTime.now();

    if (widget.identity == null) {
      final newId = IdentityCard(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        idType: _idType,
        fullName: _fullNameController.text.trim(),
        idNumber: _idNumberController.text.trim(),
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        frontImagePath: _frontImagePath,
        backImagePath: _backImagePath,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await provider.addIdentity(newId);
    } else {
      final updated = widget.identity!.copyWith(
        title: _titleController.text.trim(),
        idType: _idType,
        fullName: _fullNameController.text.trim(),
        idNumber: _idNumberController.text.trim(),
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        frontImagePath: _frontImagePath,
        backImagePath: _backImagePath,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: now,
      );
      await provider.updateIdentity(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.identity == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.identitiesAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.badge_rounded, color: AppColors.identitiesAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isNew ? context.tr.newIdentity : context.tr.editIdentity,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: context.isArabic ? 'إغلاق' : 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.tr.idTitleLabel,
                  hintText: context.tr.idTitleHint,
                  prefixIcon: const Icon(Icons.bookmark_outline_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr.idTitleLabel : null,
              ),
              const SizedBox(height: 14),

              // Document Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _idType,
                decoration: InputDecoration(
                  labelText: context.tr.idTypeLabel,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'national_id',
                    child: Text(context.tr.idTypeNationalId,
                        style: GoogleFonts.cairo()),
                  ),
                  DropdownMenuItem(
                    value: 'passport',
                    child: Text(context.tr.idTypePassport,
                        style: GoogleFonts.cairo()),
                  ),
                  DropdownMenuItem(
                    value: 'driver_license',
                    child: Text(context.tr.idTypeDriverLicense,
                        style: GoogleFonts.cairo()),
                  ),
                  DropdownMenuItem(
                    value: 'residency',
                    child: Text(context.tr.idTypeResidency,
                        style: GoogleFonts.cairo()),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text(context.tr.idTypeOther,
                        style: GoogleFonts.cairo()),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _idType = val);
                },
              ),
              const SizedBox(height: 14),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: context.tr.idFullNameLabel,
                  hintText: context.tr.idFullNameHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr.idFullNameLabel : null,
              ),
              const SizedBox(height: 14),

              // ID Number
              TextFormField(
                controller: _idNumberController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: context.tr.idNumberLabel,
                  hintText: context.tr.idNumberHint,
                  prefixIcon: const Icon(Icons.pin_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr.idNumberLabel : null,
              ),
              const SizedBox(height: 14),

              // Issue Date & Expiry Date pickers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _issueDate ?? DateTime.now(),
                          firstDate: DateTime(1970),
                          lastDate: DateTime(2050),
                        );
                        if (picked != null) setState(() => _issueDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(
                        _issueDate == null
                            ? context.tr.issueDateLabel
                            : dateFormat.format(_issueDate!),
                        style: GoogleFonts.cairo(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate ??
                              DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime(1970),
                          lastDate: DateTime(2050),
                        );
                        if (picked != null) setState(() => _expiryDate = picked);
                      },
                      icon: const Icon(Icons.event_busy_rounded, size: 16),
                      label: Text(
                        _expiryDate == null
                            ? context.tr.idExpiryDateLabel
                            : dateFormat.format(_expiryDate!),
                        style: GoogleFonts.cairo(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Photos attachment buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(true),
                      icon: Icon(_frontImagePath != null
                          ? Icons.check_circle_rounded
                          : Icons.add_a_photo_outlined),
                      label: Text(
                        _frontImagePath != null
                            ? context.tr.changePhoto
                            : context.tr.frontImageLabel,
                        style: GoogleFonts.cairo(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(false),
                      icon: Icon(_backImagePath != null
                          ? Icons.check_circle_rounded
                          : Icons.add_a_photo_outlined),
                      label: Text(
                        _backImagePath != null
                            ? context.tr.changePhoto
                            : context.tr.backImageLabel,
                        style: GoogleFonts.cairo(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.tr.notesOptional,
                  prefixIcon: const Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.identitiesAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _save,
                  child: Text(
                    isNew ? context.tr.add : context.tr.save,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
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
}
