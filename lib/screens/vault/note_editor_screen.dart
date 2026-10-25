import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../models/note.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedColor;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? Note.availableColors[0];

    _titleController.addListener(() => _hasChanges = true);
    _contentController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أدخل عنوان الملاحظة', style: GoogleFonts.cairo()),
        ),
      );
      return;
    }

    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);

    if (widget.note == null) {
      await vaultProvider.addNote(
        title: title,
        content: _contentController.text,
        color: _selectedColor,
      );
    } else {
      final updated = widget.note!.copyWith(
        title: title,
        content: _contentController.text,
        color: _selectedColor,
      );
      await vaultProvider.updateNote(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNew = widget.note == null;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isNew ? context.tr.newNote : context.tr.editNote,
            style: GoogleFonts.cairo(),
          ),
          leading: IconButton(
            icon: Icon(context.isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.maybePop(context),
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
                            ? 'هل أنت متأكد من حذف هذه الملاحظة؟'
                            : 'Are you sure you want to delete this note?',
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(context.tr.delete, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await vaultProvider.deleteNote(widget.note!.id);
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
        body: Column(
          children: [
            // Color picker
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: Note.availableColors.length,
                itemBuilder: (context, index) {
                  final color = Note.availableColors[index];
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(color),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 18, color: AppColors.primary)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Title field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: context.tr.noteTitleHint,
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white30 : AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
              ),
            ),

            // Content field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    height: 1.8,
                    color: isDark ? Colors.white70 : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr.noteContentHint,
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 16,
                      color: isDark ? Colors.white30 : AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              context.isArabic ? 'تجاهل التغييرات؟' : 'Discard changes?',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            content: Text(
              context.isArabic
                  ? 'لديك تغييرات غير محفوظة. هل تريد تجاهلها؟'
                  : 'You have unsaved changes. Do you want to discard them?',
              style: GoogleFonts.cairo(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  context.isArabic ? 'متابعة التحرير' : 'Keep Editing',
                  style: GoogleFonts.cairo(),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: Text(
                  context.isArabic ? 'تجاهل' : 'Discard',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
