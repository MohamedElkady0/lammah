import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/fetcher/presentation/views/notes/view/add_note.dart';

class NoteBottomSheet extends StatelessWidget {
  const NoteBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> pathNote = ['txt', 'رسم', 'تذكر', 'py'];
    List<String> pathNote2 = ['wep', 'dart', 'kt', 'cs'];
    ConfigApp.initConfig(context);
    var screenW = ConfigApp.width;
    return BottomSheet(
      elevation: 3,
      shadowColor: Colors.black45,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,

      onClosing: () {},
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < 4; i++)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => AddNote()),
                        );
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        width: screenW * 0.2,
                        height: 50,
                        child: Center(
                          child: Text(
                            pathNote[i],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 5,
                                  offset: Offset(1, 1),
                                ),
                              ],
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < 4; i++)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => AddNote()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        width: screenW * 0.2,
                        height: 50,
                        child: Center(
                          child: Text(
                            pathNote2[i],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 5,
                                  offset: Offset(1, 1),
                                ),
                              ],
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
