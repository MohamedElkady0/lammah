import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/user_info.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this.currentUserId}) : super(SearchInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _debounce;
  // الخطوة 1: أضف متغير لتخزين هوية المستخدم الحالي
  final String currentUserId;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> searchUsers(String query) async {
    print("Cubit's searchUsers called with query: '$query'");
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    // إذا كان هناك مؤقت نشط، قم بإلغائه
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // ابدأ مؤقتًا جديدًا لمدة 500 ميللي ثانية
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // الكود الموجود هنا لن يعمل إلا بعد أن يتوقف المستخدم عن الكتابة

      // نقوم بطباعة الاستعلام الذي سيتم تنفيذه بالفعل
      print("Debounced search executing for query: '$query'");

      if (query.isEmpty) {
        emit(SearchInitial());
        return;
      }

      emit(SearchLoading());
      try {
        final snapshot = await _firestore
            .collection(AuthString.fSUsers) // تأكد من اسم الكولكشن
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            // الخطوة 3: أضف هذا السطر لاستثناء المستخدم الحالي من البحث
            // ملاحظة: هذا يفترض أن document ID لكل مستخدم هو نفسه الـ UID الخاص به من Firebase Auth
            .where(FieldPath.documentId, isNotEqualTo: currentUserId)
            .limit(10)
            .get();

        final users = snapshot.docs
            .map((doc) => UserInfoData.fromJson(doc.data()))
            .toList();

        // تحقق مما إذا كان الـ Cubit لا يزال مفتوحًا قبل إصدار الحالة
        if (!isClosed) {
          emit(SearchSuccess(users));
        }
      } catch (e) {
        if (!isClosed) {
          emit(SearchFailure('حدث خطأ أثناء البحث: ${e.toString()}'));
        }
      }
    });
  }
}
