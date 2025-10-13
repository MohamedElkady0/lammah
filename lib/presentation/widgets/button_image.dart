import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:lammah/fetcher/domian/upload/image_upload_cubit.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'dart:typed_data';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:path_provider/path_provider.dart';

class ButtonImage extends StatefulWidget {
  const ButtonImage({super.key});

  @override
  State<ButtonImage> createState() => _ButtonImageState();
}

class _ButtonImageState extends State<ButtonImage> {
  bool _isPickerActive = false;
  late final MultiImagePickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiImagePickerController(
      maxImages: 10,
      images: [],
      picker: (int pickCount, Object? params) async {
        if (_isPickerActive) return [];

        setState(() {
          _isPickerActive = true;
        });

        try {
          final imagePicker = ImagePicker();
          final pickedFiles = await imagePicker.pickMultiImage();

          if (pickedFiles.isEmpty) {
            return [];
          }

          return pickedFiles
              .map(
                (e) => ImageFile(
                  e.path.split('/').last,
                  path: e.path,
                  name: e.name,
                  extension: e.path.split('.').last,
                ),
              )
              .toList();
        } finally {
          setState(() {
            _isPickerActive = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openImageEditor(BuildContext context, ImageFile imageFile) {
    final nav = Navigator.of(context);
    nav.push(
      MaterialPageRoute(
        builder: (context) => ProImageEditor.file(
          File(imageFile.path!),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List editedImageBytes) async {
              final tempDir = await getTemporaryDirectory();
              final newPath =
                  '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
              final newFile = File(newPath);

              await newFile.writeAsBytes(editedImageBytes);

              final newImageFile = ImageFile(
                newPath.split('/').last,
                path: newPath,
                name: newPath,
                extension: 'png',
              );

              final index = controller.images.toList().indexOf(imageFile);
              if (index != -1) {
                final newImages = List<ImageFile>.from(controller.images);
                newImages[index] = newImageFile;
                controller.updateImages(newImages);
              }

              if (!mounted) return;
              nav.pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MultiImagePickerView(
            onDragBoxDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[300]!,
                  blurRadius: 10,
                  spreadRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              shape: BoxShape.rectangle,
              gradient: LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            addMoreButton: InkWell(
              onTap: () {
                controller.pickImages();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha(100),
                ),
                child: const Icon(Icons.add, size: 50, color: Colors.white),
              ),
            ),
            shrinkWrap: true,

            controller: controller,
            padding: const EdgeInsets.all(10),

            builder: (context, imageFile) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _openImageEditor(context, imageFile),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),

                        child: Image.file(
                          File(imageFile.path!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () {
                        controller.removeImage(imageFile);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // const SizedBox(height: 30),
          // ElevatedButton(
          //   onPressed: () {
          //     final images = controller.images;
          //     if (images.isEmpty) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(content: Text('لم يتم اختيار أي صورة بعد!')),
          //       );
          //       return;
          //     }

          //     context.read<ImageUploadCubit>().uploadImages(images.toList());

          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           title: Text('الصور المختارة (${images.length})'),
          //           content: Text(images.map((e) => e.name).join('\n')),
          //           actions: [
          //             TextButton(
          //               onPressed: () => Navigator.pop(context),
          //               child: const Text('حسناً'),
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   },
          //   style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          //     backgroundColor: WidgetStateProperty.all(
          //       Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
          //     ),
          //   ),
          //   child: const Text('تحميل'),
          // ),
        ],
      ),
    );
  }
}
