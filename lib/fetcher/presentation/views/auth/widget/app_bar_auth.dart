import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/text_auth.dart';

class AppBarAuth extends StatelessWidget implements PreferredSizeWidget {
  const AppBarAuth({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextAuth(data: title),
      actions: [Image.asset(AuthString.logo)],

      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      foregroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
