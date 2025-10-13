import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/theme/theme_cubit.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notification = false;

  void onNotification(bool value) {
    setState(() {
      notification = value;
    });
  }

  void onTheme(bool value) {
    context.read<ThemeCubit>().toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('الإعدادات')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                inactiveThumbColor: Theme.of(context).colorScheme.primary,
                activeTrackColor: Theme.of(context).colorScheme.error,
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(
                  'تفعيل التنبيهات',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                value: notification,
                onChanged: onNotification,
              ),
              SwitchListTile.adaptive(
                inactiveThumbColor: Theme.of(context).colorScheme.primary,
                activeTrackColor: Theme.of(context).colorScheme.error,
                activeColor: Theme.of(context).colorScheme.primary,

                title: Text(
                  context.read<ThemeCubit>().themeModeSwitch ? 'Dark' : 'Light',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                value: context.read<ThemeCubit>().themeModeSwitch,
                onChanged: onTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
