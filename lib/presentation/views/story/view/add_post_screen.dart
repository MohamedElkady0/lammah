import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/post/post_cubit.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  var textController = TextEditingController();
  File? _postImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _postImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // نحصل على بيانات المستخدم الحالي
    final user = context.read<AuthCubit>().currentUserInfo;

    return BlocConsumer<PostCubit, PostStates>(
      listener: (context, state) {
        if (state is CreatePostSuccessState) {
          Navigator.pop(context); // إغلاق الشاشة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم نشر المنشور بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          appBar: AppBar(
            title: const Text('إنشاء منشور'),
            actions: [
              TextButton(
                onPressed: () {
                  if (textController.text.isNotEmpty || _postImage != null) {
                    PostCubit.get(context).createPost(
                      uId: user?.userId ?? '',
                      name: user?.name ?? 'User',
                      userImage: user?.image ?? '',
                      text: textController.text,
                      postImageFile: _postImage, // مررنا الملف هنا
                    );
                  }
                },
                child: const Text('نشر', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (state is CreatePostLoadingState)
                  const LinearProgressIndicator(),
                if (state is CreatePostLoadingState) const SizedBox(height: 10),

                // معلومات المستخدم
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(user?.image ?? ''),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        user?.name ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                // حقل الكتابة
                Expanded(
                  child: TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'بم تفكر الآن؟',
                      border: InputBorder.none,
                    ),
                    maxLines: null, // متعدد الأسطر
                  ),
                ),

                // عرض الصورة المختارة (إن وجدت)
                if (_postImage != null)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: FileImage(_postImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _postImage = null;
                          });
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // أزرار إضافة صورة/فيديو
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image, color: Colors.blue),
                        label: const Text('إضافة صورة'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // منطق إضافة فيديو
                        },
                        icon: const Icon(Icons.videocam, color: Colors.red),
                        label: const Text('فيديو'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
