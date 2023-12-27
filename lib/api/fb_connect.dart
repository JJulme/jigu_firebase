import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FsDb {
  FirebaseFirestore db = FirebaseFirestore.instance;
  // 사용자의 정보
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  // 저장소 설정
  final storageRef = FirebaseStorage.instance.ref();
  late String promotionId;

  Future<bool> postPromotion(
      {required String title, required String body, imgList}) async {
    var promotionDb = db.collection("promotionPosts");
    var myPromotion = {
      "userId": userId,
      "title": title,
      "body": body,
      "dataTime": Timestamp.now(),
    };
    print(userId);
    try {
      await promotionDb
          .add(myPromotion)
          .then((value) => promotionId = value.id);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  postImage(List<dynamic> assetImages) async {
    var imageFiles = [];
    int i = 0;
    for (var image in assetImages) {
      Reference mountainsRef =
          storageRef.child("promotions/$userId/promotionId/$i.jpg");
      await mountainsRef.putFile(image.file);
      i++;
    }
    return imageFiles;
  }
}
