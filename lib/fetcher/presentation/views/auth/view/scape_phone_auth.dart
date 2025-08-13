import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/button_auth.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/fun_service.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/image_auth.dart';
import 'package:lammah/fetcher/presentation/views/auth/widget/input_field_auth.dart';
import 'package:lammah/fetcher/presentation/views/home/home.dart';
import 'package:lammah/fetcher/presentation/views/splach/splash_view.dart';

class ScapePhoneAuth extends StatefulWidget {
  const ScapePhoneAuth({super.key});

  @override
  State<ScapePhoneAuth> createState() => _ScapePhoneAuthState();
}

class _ScapePhoneAuthState extends State<ScapePhoneAuth> {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool agree = false;

  @override
  void dispose() {
    nameController.dispose();
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: formKey,

                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              MediaQuery.of(context).size.height -
                              kToolbarHeight -
                              MediaQuery.of(context).padding.top,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: height * 0.1),
                            ImageAuth(),
                            SizedBox(height: height * 0.08),
                            InputFieldAuth(
                              controller: nameController,
                              title: AuthString.name,
                              icon: Icons.person,
                              obscureText: false,
                            ),

                            SizedBox(height: height * 0.3),

                            ButtonAuth(
                              isW: false,
                              title: AuthString.next,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();

                                  final authCubit = BlocProvider.of<AuthCubit>(
                                    context,
                                  );
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);

                                  final bool? didAgree = await funService(
                                    context,
                                    initialAgreeValue: agree,
                                  );

                                  if (!mounted) return;

                                  if (didAgree == true) {
                                    setState(() {
                                      agree = true;
                                    });

                                    authCubit.uploadAndUpdateProfileImage();

                                    authCubit.updateName(nameController.text);
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
                              icon: Icons.save,
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
