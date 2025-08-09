import 'package:flutter/material.dart';

class CustmRadio extends StatefulWidget {
  const CustmRadio({super.key});

  @override
  State<CustmRadio> createState() => _CustmRadioState();
}

class _CustmRadioState extends State<CustmRadio> {
  int _radioValue = 0;
  String result = '';
  Color resultColor = Colors.green;

  Widget buildRow(int value) {
    myDialog() {
      var ad = AlertDialog(
        content: SizedBox(
          height: 100,
          child: Column(
            children: [
              Text(result, style: TextStyle(color: resultColor)),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('Answer Is:4'),
              ),
            ],
          ),
        ),
      );
      showDialog(context: context, builder: (BuildContext context) => ad);
    }

    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _radioValue,
          onChanged: (value) {
            setState(() {
              _radioValue = int.parse(value.toString());
              result = value == 4 ? 'Correct Answer!' : 'Wrong Answer!';
              resultColor = value == 4 ? Colors.green : Colors.redAccent;
              myDialog();
            });
          },
        ),
        Text('$value'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            ' Guess The Answer : 2+2=?',
            style: TextStyle(
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          buildRow(3),
          buildRow(4),
          buildRow(5),
        ],
      ),
    );
  }
}
