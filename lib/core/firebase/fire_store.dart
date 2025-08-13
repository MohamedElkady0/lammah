import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lammah/fetcher/data/model/user_info.dart';

import 'package:uuid/uuid.dart';

class Story {
  Future<UserInfoData> create({required userId}) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .get();
    return UserInfoData.fromJson(snap.data() as Map<String, dynamic>);
  }

  addPost({required Map<String, dynamic> post}) async {
    if (post['like'].toString().contains(
      FirebaseAuth.instance.currentUser!.uid,
    )) {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(post['postId'])
          .update({
            'like': FieldValue.arrayRemove([
              FirebaseAuth.instance.currentUser!.uid,
            ]),
          });
    } else {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(post['postId'])
          .update({
            'like': FieldValue.arrayUnion([
              FirebaseAuth.instance.currentUser!.uid,
            ]),
          });
    }
  }

  removePost({required Map<String, dynamic> post}) async {
    if (FirebaseAuth.instance.currentUser!.uid == post['uid']) {
      FirebaseFirestore.instance
          .collection('post')
          .doc(post['postId'])
          .delete();
    }
  }

  addComment({
    required String comment,
    required postId,
    required uId,
    required userImage,
    required String userName,
  }) async {
    final uuid = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('post')
        .doc(postId)
        .collection('comment')
        .doc(uuid)
        .set({
          'comment': comment,
          'postId': postId,
          'uId': uId,
          'userImage': userImage,
          'commentId': uuid,
          'userName': userName,
          'date': Timestamp.now(),
        });
  }

  followUser({required userId}) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'following': FieldValue.arrayUnion(userId)});

    await FirebaseFirestore.instance.collection('user').doc(userId).update({
      'followers': FieldValue.arrayUnion([
        FirebaseAuth.instance.currentUser!.uid,
      ]),
    });
  }

  unFollowUser({required userId}) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'following': FieldValue.arrayRemove(userId)});

    await FirebaseFirestore.instance.collection('user').doc(userId).update({
      'followers': FieldValue.arrayRemove([
        FirebaseAuth.instance.currentUser!.uid,
      ]),
    });
  }

  removeStory({required Map story}) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(story['userId'])
        .update({
          'story': FieldValue.arrayRemove([story]),
        });
  }

  removeStory24h({required Map story}) {
    Duration dif = DateTime.now().difference(story['date'].toDate());
    if (dif.inHours > 24) {
      removeStory(story: story);
    }
  }
}
