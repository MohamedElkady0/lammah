import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/config/fixed_sizes_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';

class InputPhone extends StatelessWidget {
  const InputPhone({super.key, required this.phoneController});

  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double height = ConfigApp.height;
    return Container(
      padding: AppSpacing.horizontalM,
      height: height * .1,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.radiusM,
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: InternationalPhoneNumberInput(
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        onInputChanged: (PhoneNumber number) {
          BlocProvider.of<AuthCubit>(context).number = number;
          BlocProvider.of<AuthCubit>(
            context,
          ).setPhoneNumber(number.phoneNumber!);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AuthString.enterNum;
          }
          return null;
        },
        onInputValidated: (bool value) {},
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          useBottomSheetSafeArea: true,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.disabled,
        selectorTextStyle: const TextStyle(color: Colors.grey),
        initialValue: BlocProvider.of<AuthCubit>(context).number,
        textFieldController: phoneController,
        formatInput: true,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        inputBorder: const OutlineInputBorder(),
        onSaved: (PhoneNumber number) {
          BlocProvider.of<AuthCubit>(
            context,
          ).getPhoneNumber(number.phoneNumber!);
        },
        inputDecoration: const InputDecoration(
          hintText: AuthString.enterNum,
          hintStyle: TextStyle(color: Colors.grey),
          suffixIcon: Icon(Icons.phone, color: Colors.grey),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 152, 2, 252)),
          ),
        ),
      ),
    );
  }
}
