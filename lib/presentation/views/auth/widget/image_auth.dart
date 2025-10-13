import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';

class ImageAuth extends StatelessWidget {
  const ImageAuth({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double width = ConfigApp.width;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        File? imageFile;
        if (state is AuthImagePicked) {
          imageFile = state.image;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () {
            context.read<AuthCubit>().pickImage(title: 'Gallery');
            imageFile = context.read<AuthCubit>().img;
          },
          child: CircleAvatar(
            radius: width * 0.13,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,

            backgroundImage: imageFile != null ? FileImage(imageFile) : null,
            child: imageFile == null
                ? IconButton(
                    onPressed: () {
                      context.read<AuthCubit>().pickImage(title: 'Camera');
                      imageFile = context.read<AuthCubit>().img;
                    },
                    icon: Icon(
                      Icons.add_a_photo,
                      size: width * 0.1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
