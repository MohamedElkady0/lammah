import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/theme/themes_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/fetcher/data/service/notification_service.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/domian/notification/notification_cubit.dart';
import 'package:lammah/fetcher/domian/theme/theme_cubit.dart';
import 'package:lammah/fetcher/domian/upload/image_upload_cubit.dart';
import 'package:lammah/fetcher/presentation/views/Introduction/Introduction.dart';
import 'package:lammah/fetcher/presentation/views/auth/view/welcome_page.dart';
import 'package:lammah/fetcher/presentation/views/home/home.dart';
import 'package:lammah/fetcher/presentation/views/splach/splash_view.dart';
import 'package:lammah/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(Lammah(notificationService: notificationService));
}

class Lammah extends StatelessWidget {
  const Lammah({super.key, required this.notificationService});
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<NotificationCubit>(
          create: (context) =>
              NotificationCubit(notificationService)..requestPermissions(),
        ),
        BlocProvider(create: (context) => ImageUploadCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: StringApp.appName,
            themeMode: themeState.themeMode,
            theme: ThemesApp.light,
            darkTheme: ThemesApp.dark,
            home: AppStartDecider(),
          );
        },
      ),
    );
  }
}

class AppStartDecider extends StatelessWidget {
  const AppStartDecider({super.key});

  Future<bool> _checkIfOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(AuthString.keyOfSeenOnboarding) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfOnboardingSeen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashView();
        }

        final bool hasSeenOnboarding = snapshot.data ?? false;

        if (hasSeenOnboarding) {
          return AuthGate();
        } else {
          return Introduction();
        }
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return SplashView();
        } else if (state is AuthSuccess) {
          return HomePage();
        } else {
          return WelcomeScreen();
        }
      },
    );
  }
}
