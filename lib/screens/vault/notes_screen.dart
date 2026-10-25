import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../models/note.dart';
import '../../widgets/note_card.dart';
import '../../widgets/empty_state.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final notes = vaultProvider.notes;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.catNotes, style: GoogleFonts.cairo()),
        leading: IconButton(
          icon: Icon(context.isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton.tonalIcon(
              onPressed: () => _openEditor(context, null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.tr.newNote, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: notes.isEmpty
          ? EmptyState(
              icon: Icons.note_alt_rounded,
              title: context.tr.emptyNotesTitle,
              subtitle: context.tr.emptyNotesSub,
              buttonText: context.tr.newNote,
              onButtonPressed: () => _openEditor(context, null),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteCard(
                      note: note,
                      onTap: () => _openEditor(context, note),
                      onLongPress: () => _showNoteOptions(context, vaultProvider, note),
                      onDelete: () => _confirmDeleteNote(context, vaultProvider, note),
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

  void _openEditor(BuildContext context, Note? note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, VaultProvider provider, Note note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isNotEmpty ? note.title : context.tr.catNotes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        tooltip: context.isArabic ? 'إغلاق' : 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(
                    note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                  ),
                  title: Text(
                    note.isPinned ? context.tr.unpinNote : context.tr.pinNote,
                    style: GoogleFonts.cairo(),
                  ),
                  onTap: () {
                    provider.togglePinNote(note);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: Text(
                    context.tr.delete,
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                  onTap: () {
                    provider.deleteNote(note.id);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteNote(BuildContext context, VaultProvider provider, Note note) {
    showDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteNote(note.id);
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
