import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../models/account_entry.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class AccountEditorScreen extends StatefulWidget {
  final AccountEntry? account;

  const AccountEditorScreen({super.key, this.account});

  @override
  State<AccountEditorScreen> createState() => _AccountEditorScreenState();
}

class _AccountEditorScreenState extends State<AccountEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _websiteUrlController;
  late TextEditingController _notesController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _serviceController =
        TextEditingController(text: widget.account?.serviceName ?? '');
    _usernameController =
        TextEditingController(text: widget.account?.username ?? '');
    _passwordController =
        TextEditingController(text: widget.account?.password ?? '');
    _websiteUrlController =
        TextEditingController(text: widget.account?.websiteUrl ?? '');
    _notesController =
        TextEditingController(text: widget.account?.notes ?? '');
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);

    if (widget.account == null) {
      await vaultProvider.addAccount(
        serviceName: _serviceController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        websiteUrl: _websiteUrlController.text.trim().isEmpty
            ? null
            : _websiteUrlController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      final updated = widget.account!.copyWith(
        serviceName: _serviceController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        websiteUrl: _websiteUrlController.text.trim().isEmpty
            ? null
            : _websiteUrlController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await vaultProvider.updateAccount(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.account == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew ? context.tr.newAccount : context.tr.editAccount,
          style: GoogleFonts.cairo(),
        ),
        leading: IconButton(
          icon: Icon(context.isArabic
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: context.tr.delete,
              onPressed: () async {
                final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
                final nav = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(context.tr.delete, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    content: Text(
                      context.isArabic
                          ? 'هل أنت متأكد من حذف هذا الحساب؟'
                          : 'Are you sure you want to delete this account?',
                      style: GoogleFonts.cairo(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(context.tr.delete, style: GoogleFonts.cairo()),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await vaultProvider.deleteAccount(widget.account!.id);
                  if (mounted) nav.pop();
                }
              },
            ),
          TextButton(
            onPressed: _save,
            child: Text(
              context.tr.save,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service icon preview
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [AppColors.accountsAccent, Color(0xFF059669)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _serviceController.text.isNotEmpty
                          ? _serviceController.text[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Service name
              TextFormField(
                controller: _serviceController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: context.tr.serviceNameLabel,
                  labelStyle: GoogleFonts.cairo(),
                  hintText: context.tr.serviceNameHint,
                  hintStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.apps_rounded),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? (context.isArabic ? 'أدخل اسم الخدمة' : 'Please enter service name') : null,
              ),
              const SizedBox(height: 16),

              // Website URL (Optional)
              TextFormField(
                controller: _websiteUrlController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: context.tr.websiteUrlLabel,
                  labelStyle: GoogleFonts.cairo(),
                  hintText: context.tr.websiteUrlHint,
                  hintStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: context.tr.usernameLabel,
                  labelStyle: GoogleFonts.cairo(),
                  hintText: context.tr.usernameHint,
                  hintStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? (context.isArabic ? 'أدخل اسم المستخدم' : 'Please enter username') : null,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: context.tr.passwordLabel,
                  labelStyle: GoogleFonts.cairo(),
                  hintText: context.tr.passwordHint,
                  hintStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? (context.isArabic ? 'أدخل كلمة المرور' : 'Please enter password') : null,
              ),
              const SizedBox(height: 16),

              // Notes (optional)
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.tr.notesOptional,
                  labelStyle: GoogleFonts.cairo(),
                  hintText: context.tr.notesOptionalHint,
                  hintStyle: GoogleFonts.cairo(),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.note_outlined),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 30),

              // Save button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                    isNew ? (context.isArabic ? 'إضافة الحساب' : 'Add Account') : (context.isArabic ? 'حفظ التعديلات' : 'Save Changes'),
                    style: GoogleFonts.cairo(fontSize: 16),
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
