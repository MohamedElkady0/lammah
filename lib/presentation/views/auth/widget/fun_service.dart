import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/presentation/views/auth/widget/check_service.dart';

Future<bool?> funService(
  BuildContext context, {
  required bool initialAgreeValue,
}) {
  bool agree = initialAgreeValue;
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          return CheckService(
            value: agree,
            onChanged: (val) {
              dialogSetState(() {
                agree = val!;
              });
            },

            onPressed: () {
              if (agree) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AuthString.okService)),
                );
              }
            },

            onCancel: () {
              Navigator.of(context).pop(false);
            },
          );
        },
      );
    },
  );
}
