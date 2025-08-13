import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/config/fixed_sizes_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/presentation/views/auth/view/forget_password_page.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/app_bar_auth.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/button_auth.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/input_field_auth.dart';
import 'package:lammah/fetcher/presentation/views/home/home.dart';
import 'package:lammah/fetcher/presentation/views/splach/splash_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool visibility = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double height = ConfigApp.height;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AuthString.welcomeBack)));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      },
      builder: (context, state) {
        return state is AuthLoading
            ? SplashView()
            : SafeArea(
                child: Scaffold(
                  appBar: AppBarAuth(title: AuthString.login),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  extendBodyBehindAppBar: true,
                  body: Padding(
                    padding: AppSpacing.horizontalM,
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(height: height * 0.2),
                            InputFieldAuth(
                              controller: emailController,
                              title: AuthString.email,
                              icon: Icons.email,
                              obscureText: false,
                              onSaved: (value) => emailController.text =
                                  value ?? AuthString.empty,
                            ),
                            SizedBox(height: height * 0.02),
                            InputFieldAuth(
                              controller: passwordController,
                              title: AuthString.password,
                              icon: visibility
                                  ? Icons.visibility
                                  : Icons.visibility_off,

                              obscureText: visibility,
                              onPressed: () => setState(() {
                                visibility = !visibility;
                              }),
                              onSaved: (value) => passwordController.text =
                                  value ?? AuthString.empty,
                            ),
                            SizedBox(height: height * 0.05),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ForgetPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AuthString.forgotPassword,
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            SizedBox(height: height * 0.1),
                            ButtonAuth(
                              isW: true,
                              title: AuthString.login,
                              icon: Icons.login,
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  BlocProvider.of<AuthCubit>(context).onSignIn(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AuthString.fillAll)),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
