import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/theme/themes_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/data/service/notification_service.dart';
import 'package:lammah/data/service/presence_manager.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/chat/chat_cubit.dart';
import 'package:lammah/domian/location/location_cubit.dart';
import 'package:lammah/domian/notification/notification_cubit.dart';
import 'package:lammah/domian/post/post_cubit.dart';
import 'package:lammah/domian/search/search_cubit.dart';
import 'package:lammah/domian/story/story_cubit.dart';
import 'package:lammah/domian/tasks/tasks_cubit.dart';
import 'package:lammah/domian/theme/theme_cubit.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';
import 'package:lammah/domian/updateuser/updateuser_cubit.dart';
import 'package:lammah/domian/upload/upload_cubit.dart';
import 'package:lammah/presentation/views/Introduction/Introduction.dart';
import 'package:lammah/presentation/views/auth/view/welcome_page.dart';
import 'package:lammah/presentation/views/home/home.dart';
import 'package:lammah/presentation/views/splach/splash_view.dart';
import 'package:lammah/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timeago/timeago.dart' as timeago;

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  await initializeDateFormatting('ar', null);

  final notificationService = NotificationService();
  await notificationService.init();
  timeago.setLocaleMessages('ar', timeago.ArMessages());

  runApp(Lammah(notificationService: notificationService));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Lammah extends StatelessWidget {
  const Lammah({super.key, required this.notificationService});
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

        BlocProvider<LocationCubit>(create: (context) => LocationCubit()),
        BlocProvider(
          create: (context) =>
              UpdateUserCubit(locationCubit: context.read<LocationCubit>()),
        ),
        BlocProvider<UploadCubit>(
          create: (context) => UploadCubit(
            updateCubit: BlocProvider.of<UpdateUserCubit>(context),
          ),
        ),
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(uploadCubit: BlocProvider.of<UploadCubit>(context)),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) =>
              NotificationCubit(notificationService)..requestPermissions(),
        ),
        BlocProvider<TransactionCubit>(create: (context) => TransactionCubit()),
        BlocProvider<SearchCubit>(
          create: (context) {
            // نتحقق إذا كان المستخدم موجوداً، وإلا نرسل نصاً فارغاً (سيتم تحديثه لاحقاً)
            final user = FirebaseAuth.instance.currentUser;
            final String currentUserId = user != null ? user.uid : '';

            return SearchCubit(currentUserId: currentUserId);
          },
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(
            user: BlocProvider.of<AuthCubit>(context),
            upload: BlocProvider.of<UploadCubit>(context),
            locationCubit: BlocProvider.of<LocationCubit>(context),
          ),
        ),
        BlocProvider(create: (context) => StoryCubit()..getStories()),
        BlocProvider(create: (context) => PostCubit()..getPosts()),
        BlocProvider(create: (context) => TasksCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return PresenceManager(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: StringApp.appName,
              themeMode: themeState.themeMode,
              theme: ThemesApp.light,
              darkTheme: ThemesApp.dark,
              home: const AppStartDecider(),
            ),
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
          return const SplashView();
        } else if (state is AuthSuccess) {
          return const HomePage();
        } else if (state is AuthFailure) {
          // --- هذا الجزء الجديد سيكشف لك سبب المشكلة ---
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "حدث خطأ أثناء استرجاع بياناتك",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.message, // اقرأ رسالة الخطأ التي ستظهر هنا
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // زر لإعادة المحاولة أو تسجيل الخروج لحل التعليق
                        context.read<AuthCubit>().signOut();
                      },
                      child: const Text("تسجيل الخروج والمحاولة مجدداً"),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}

// End of file
