import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/domian/upload/upload_cubit.dart';
import 'package:lammah/domian/upload/upload_state.dart'; // تأكد من استيراد الـ State

class ImageAuth extends StatelessWidget {
  const ImageAuth({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double width = ConfigApp.width;
    final upload = BlocProvider.of<UploadCubit>(context);

    // 1. تغيير الاستماع إلى UploadCubit بدلاً من AuthCubit
    return BlocBuilder<UploadCubit, UploadState>(
      builder: (context, state) {
        File? imageFile;

        // 2. التحقق من الحالة الخاصة بـ UploadState
        // تأكد أن ImagePicked موجودة داخل ملف upload_state.dart
        if (state is ImagePicked) {
          imageFile = state.image;
        }
        // أو قراءة المتغير المخزن في الكيوبت إذا لم تكن الحالة الحالية هي ImagePicked
        else if (upload.img != null) {
          imageFile = upload.img;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () {
            // عند الضغط، نستدعي الدالة فقط، والـ BlocBuilder سيعيد بناء الواجهة تلقائياً
            upload.pickImage(title: 'Gallery');
          },
          child: CircleAvatar(
            radius: width * 0.13,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundImage: imageFile != null ? FileImage(imageFile) : null,
            child: imageFile == null
                ? IconButton(
                    onPressed: () {
                      upload.pickImage(title: 'Camera');
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
