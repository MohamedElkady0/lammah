import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/config/fixed_sizes_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/upload/upload_cubit.dart';
import 'package:lammah/presentation/views/auth/widget/fun_service.dart';
import 'package:lammah/presentation/views/auth/widget/image_auth.dart';
import 'package:lammah/presentation/views/home/home.dart';
import 'package:lammah/presentation/views/splach/splash_view.dart';

import '../widget/app_bar_auth.dart';
import '../widget/button_auth.dart';
import '../widget/input_field_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool visibility = false;
  bool visibilityConfirm = false;
  bool agree = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double height = ConfigApp.height;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome ${state.userInfo.name}')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
      builder: (context, state) {
        return state is AuthLoading
            ? SplashView()
            : SafeArea(
                child: Scaffold(
                  appBar: AppBarAuth(title: AuthString.register),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  extendBodyBehindAppBar: true,
                  body: Padding(
                    padding: AppSpacing.horizontalS,
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(height: height * 0.15),
                            ImageAuth(),
                            SizedBox(height: height * 0.02),
                            InputFieldAuth(
                              controller: nameController,
                              title: AuthString.name,
                              icon: FontAwesomeIcons.person,
                              obscureText: false,
                              onSaved: (value) {
                                nameController.text = value ?? AuthString.empty;
                              },
                            ),
                            SizedBox(height: height * 0.02),
                            InputFieldAuth(
                              controller: emailController,
                              title: AuthString.email,
                              icon: Icons.email,
                              obscureText: false,
                              onSaved: (value) {
                                emailController.text =
                                    value ?? AuthString.empty;
                              },
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
                              onSaved: (value) {
                                passwordController.text =
                                    value ?? AuthString.empty;
                              },
                            ),
                            SizedBox(height: height * 0.02),
                            InputFieldAuth(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AuthString.enterConfirmPassword;
                                } else if (value != passwordController.text) {
                                  return AuthString.passwordNotMatch;
                                }
                                return null;
                              },
                              controller: confirmPasswordController,
                              title: AuthString.confirmPassword,
                              icon: visibilityConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,

                              obscureText: visibilityConfirm,
                              onPressed: () => setState(() {
                                visibilityConfirm = !visibilityConfirm;
                              }),
                              onSaved: (value) =>
                                  confirmPasswordController.text =
                                      value ?? AuthString.empty,
                            ),
                            SizedBox(height: height * 0.02),

                            SizedBox(height: height * 0.05),
                            ButtonAuth(
                              isW: true,
                              title: AuthString.register,
                              icon: Icons.person_add,

                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();

                                  final authCubit = BlocProvider.of<AuthCubit>(
                                    context,
                                  );
                                  final image = context.read<UploadCubit>().img;
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);

                                  final bool? didAgree = await funService(
                                    context,
                                    initialAgreeValue: agree,
                                  );

                                  if (didAgree == true) {
                                    setState(() {
                                      agree = true;
                                    });
                                    if (!mounted) return;

                                    authCubit.onSignUp(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      imageFile: image,
                                    );
                                  } else {
                                    scaffoldMessenger.clearSnackBars();
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(AuthString.agree),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(AuthString.filedIsRequired),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: height * 0.02),
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
