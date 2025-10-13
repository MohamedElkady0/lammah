import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/config/fixed_sizes_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/presentation/views/auth/view/scape_phone_auth.dart';
import 'package:lammah/presentation/views/auth/widget/enter_otp.dart';
import 'package:lammah/presentation/views/auth/widget/input_phone.dart';
import '../widget/app_bar_auth.dart';
import '../widget/button_auth.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double height = ConfigApp.height;
    double width = ConfigApp.width;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthCodeSentSuccess) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) {
              return BlocProvider.value(
                value: BlocProvider.of<AuthCubit>(context),
                child: EnterOTP(otpController: otpController),
              );
            },
          );
        } else if (state is AuthSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ScapePhoneAuth()),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is AuthLoading;
        return SafeArea(
          child: Scaffold(
            appBar: AppBarAuth(title: AuthString.phone),
            backgroundColor: Theme.of(context).colorScheme.primary,
            extendBodyBehindAppBar: true,
            body: Padding(
              padding: AppSpacing.horizontalS,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.1),
                      Image.asset(
                        AuthString.imagePhone,
                        gaplessPlayback: true,
                        width: width * 0.3,
                        height: height * 0.3,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: height * 0.1),
                      InputPhone(phoneController: phoneController),
                      SizedBox(height: height * 0.1),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        ButtonAuth(
                          isW: true,
                          title: AuthString.send,
                          icon: Icons.phone_callback,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              BlocProvider.of<AuthCubit>(context).sendOtp();
                            } else {
                              ScaffoldMessenger.of(context).clearSnackBars();
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
