import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/notes/widgets/no_note_yet.dart';
import 'package:lammah/fetcher/presentation/views/notes/widgets/note_bottom_sheet.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) {
                return NoteBottomSheet();
              },
            );
          },
          child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),

              DatePicker(
                DateTime.now(),
                height: 120,
                monthTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                ),
                dayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                ),
                dateTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),

                initialSelectedDate: DateTime.now(),
                selectionColor: Theme.of(context).colorScheme.onPrimary,
                selectedTextColor: Theme.of(context).colorScheme.primary,
                onDateChange: (date) {
                  // New date selected
                },
              ),
              SizedBox(height: 20),
              NoNoteYet(),
            ],
          ),
        ),
      ),
    );
  }
}
