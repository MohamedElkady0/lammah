import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';

class EnterOTP extends StatelessWidget {
  const EnterOTP({super.key, required this.otpController});
  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.close),
      ),
      backgroundColor: Colors.grey,
      title: const Text(AuthString.checkForOTP),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: otpController,

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AuthString.requiredOTP;
              }
              if (value.length < 6) {
                return AuthString.validNumSix;
              }
              return null;
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: AuthString.enterOTP),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              final otpCode = otpController.text.trim();
              if (otpCode.isNotEmpty) {
                BlocProvider.of<AuthCubit>(context).setOtp(otpCode);

                BlocProvider.of<AuthCubit>(context).verifyOtp();
              }
            },
            child: Text(AuthString.check),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              BlocProvider.of<AuthCubit>(context).sendOtp();
            },
            child: Text(
              AuthString.sendOTBagain,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
