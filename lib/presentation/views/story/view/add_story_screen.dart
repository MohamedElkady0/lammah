import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/story/story_cubit.dart';

class AddStoryScreen extends StatelessWidget {
  final TextEditingController captionController = TextEditingController();

  // هذه البيانات يفترض أن تأتي من UserInfoData لديك
  final String currentUserId = 'USER_ID_FROM_AUTH';
  final String currentUserName = 'USER_NAME';
  final String currentUserImage = 'USER_IMAGE_URL';

  AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryCubit, StoryStates>(
      listener: (context, state) {
        // 1. حالة النجاح: إغلاق الشاشة وإعلام المستخدم
        if (state is CreateStorySuccessState) {
          Navigator.pop(context); // العودة للصفحة الرئيسية
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم نشر قصتك بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // 2. حالة الخطأ: إظهار سبب المشكلة
        if (state is CreateStoryErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'فشل النشر: ${state.error}',
              ), // state.error يجب تعريفها في الـ State
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = StoryCubit.get(context);
        var mediaFile = cubit.storyMediaFile;

        return Scaffold(
          appBar: AppBar(
            title: Text('إنشاء قصة'),
            actions: [
              // 3. حالة التحميل: تعطيل الزر أو إظهار مؤشر
              if (state is CreateStoryLoadingState)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    if (mediaFile != null) {
                      cubit.uploadStory(
                        uId: currentUserId,
                        name: currentUserName,
                        userImage: currentUserImage,
                        caption: captionController.text,
                      );
                    }
                  },
                  child: Text('نشر', style: TextStyle(color: Colors.blue)),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (state is CreateStoryLoadingState)
                    LinearProgressIndicator(),
                  SizedBox(height: 20),
                  // عرض الصورة المختارة
                  if (mediaFile != null && cubit.mediaType == 'image')
                    Image.file(
                      mediaFile,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  // هنا يمكنك إضافة مشغل فيديو بسيط إذا كان النوع فيديو
                  if (mediaFile != null && cubit.mediaType == 'video')
                    Container(
                      height: 300,
                      color: Colors.black,
                      child: Center(
                        child: Icon(
                          Icons.play_circle,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: captionController,
                    decoration: InputDecoration(
                      hintText: 'أضف وصفاً لقصتك...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
