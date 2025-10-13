import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/data/model/note.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.note_alt_rounded, color: Colors.orange),
        title: Text(
          note.title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        subtitle: note.content != null ? Text(note.content!) : null,
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
          onPressed: () {
            // استدعاء دالة الحذف في الـ Cubit
            context.read<TransactionCubit>().deleteNote(note.id);
            // إظهار رسالة تأكيد (اختياري ولكن موصى به)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم حذف الملاحظة بنجاح'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
