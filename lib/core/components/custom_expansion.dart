import 'package:flutter/material.dart';
import 'package:lammah/core/function/helpers.dart';

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({super.key});

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ExpansionTile(
            backgroundColor: Colors.blueGrey,
            leading: const Icon(Icons.perm_identity),
            title: const Text('Account'),
            children: [
              const Divider(color: Colors.grey),
              Card(
                color: Colors.grey,
                child: ListTile(
                  leading: const Icon(Icons.add),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Sign Up!'),
                  subtitle: const Text('Where You Can Register An Account'),
                  onTap: () => buildSnackBar(context, () {}),
                ),
              ),
              Card(
                color: Colors.grey,
                child: ListTile(
                  leading: const Icon(Icons.account_circle),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Sign In!'),
                  subtitle: const Text('Where You Can Login With Your Account'),
                  onTap: () => buildSnackBar(context, () {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ExpansionTile(
            backgroundColor: Colors.blueGrey,
            leading: const Icon(Icons.message),
            title: const Text('MoreInfo'),
            children: [
              const Divider(color: Colors.grey),
              Card(
                color: Colors.grey,
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Contact'),
                  subtitle: const Text('Where You Can Call Us'),
                  onTap: () => buildSnackBar(context, () {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
