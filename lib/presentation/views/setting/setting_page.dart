import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/service/backup_service.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
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

                title: Text(
                  context.read<ThemeCubit>().themeModeSwitch ? 'Dark' : 'Light',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                value: context.read<ThemeCubit>().themeModeSwitch,
                onChanged: onTheme,
              ),

              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.cloud_upload),
                title: Text("نسخ احتياطي للبيانات"),
                onTap: () async {
                  var message = ScaffoldMessenger.of(context);
                  final userId =
                      context.read<AuthCubit>().currentUserInfo?.userId ?? '';
                  await BackupService().backupDatabase(userId);
                  message.showSnackBar(
                    SnackBar(content: Text("تم النسخ بنجاح")),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.cloud_download),
                title: Text("استعادة البيانات"),
                onTap: () async {
                  // تحذير المستخدم بأن البيانات الحالية ستحذف
                  final userId =
                      context.read<AuthCubit>().currentUserInfo?.userId ?? '';
                  await BackupService().restoreDatabase(userId);
                  // اطلب من المستخدم إعادة تشغيل التطبيق
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
