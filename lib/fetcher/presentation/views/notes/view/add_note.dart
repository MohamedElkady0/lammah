import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/widgets/button_style.dart';
import 'package:lammah/fetcher/presentation/widgets/input_new_item2.dart';

class AddNote extends StatelessWidget {
  const AddNote({super.key});

  @override
  Widget build(BuildContext context) {
    List<Color> c = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.black,
      Colors.white,
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Image.asset('assets/images/notes.png', height: 100),
              InputNewItem2(title: 'title'),
              SizedBox(height: 10),
              InputNewItem2(title: 'description', maxLines: 5),
              SizedBox(height: 10),
              InputNewItem2(
                title: 'Date',
                icon: IconButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                  },
                  icon: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InputNewItem2(
                      title: 'Start Time',
                      icon: IconButton(
                        onPressed: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                        },
                        icon: Icon(
                          Icons.watch_later,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InputNewItem2(
                      title: 'End Time',
                      icon: IconButton(
                        onPressed: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                        },
                        icon: Icon(
                          Icons.watch_later,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Colors',

                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var color in c)
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(50),
                          border: Border.symmetric(
                            horizontal: BorderSide(color: color, width: 2),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: CircleAvatar(backgroundColor: color),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              ButtonAppStyle(
                title: 'تذكير',
                icon: Icons.safety_check,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
