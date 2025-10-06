import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/widgets/drop2.dart';
import 'package:lammah/fetcher/presentation/widgets/input_new_item2.dart';

class Money extends StatefulWidget {
  const Money({super.key});

  @override
  State<Money> createState() => _MoneyState();
}

class _MoneyState extends State<Money> {
  List<String> drop = ['+ add', '- sub'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              InputNewItem2(title: 'title'),
              SizedBox(height: 5),
              InputNewItem2(title: 'description'),
              SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: InputNewItem2(title: 'money')),
                  SizedBox(width: 10),
                  Expanded(child: MyCustomDropdown(items: drop)),
                ],
              ),
              SizedBox(height: 5),
              ExpansionTile(
                trailing: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                title: Text(
                  'Add Category',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: InputNewItem2(title: 'category')),
                      SizedBox(width: 10),
                      Expanded(child: MyCustomDropdown(items: drop)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
