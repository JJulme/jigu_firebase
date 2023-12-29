import 'dart:convert';
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

  // 홍보글 작성 시 내용 서버에 업로드
  // 이미지는 Storage로 이동
  // 그 외 정보는 FireStore로 이동
  // Future<bool> postPromotion({
  //   required String title,
  //   required String body,
  //   required List<dynamic> assetImages,
  // }) async {
  //   var promotionDb = db.collection("promotionPosts");
  //   var myPromotion = {
  //     "userId": userId,
  //     "title": title,
  //     "body": body,
  //     "dataTime": Timestamp.now(),
  //     "imageUpload": false,
  //   };
  //   try {
  //     if (assetImages.isNotEmpty) {
  //       myPromotion["imageUpload"] = true;
  //       await promotionDb
  //           .add(myPromotion)
  //           .then((value) => promotionId = value.id);
  //       int i = 0;
  //       for (var image in assetImages) {
  //         Reference mountainsRef = storageRef
  //             .child("promotions/$userId/$promotionId/${i.toString()}.jpg");
  //         await mountainsRef.putFile(await image.file);
  //         i++;
  //       }
  //     } else {
  //       await promotionDb.add(myPromotion);
  //     }
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  // 홍보글 작성시
  // userId, 제목, 내용, 시간, 이미지(byte 변환)
  Future<bool> postPromotion2({
    required String title,
    required String body,
    required List<dynamic> assetImages,
  }) async {
    var promotionDb = db.collection("promotionPosts");
    var myPromotion = {
      "userId": userId,
      "title": title,
      "body": body,
      "dataTime": Timestamp.now(),
      "images": [],
    };
    try {
      // 홍보글 이미지가 있을 경우
      if (assetImages.isNotEmpty) {
        var img64List = [];
        // 가져온 이미지를 File > Uint8List > base64 문자열로 변환
        for (var image in assetImages) {
          var imgFile = await image.file;
          var byteImg = File(imgFile.path).readAsBytesSync();
          img64List.add(base64Encode(byteImg));
        }
        // 이미지 변환 후 리스트에 모아 저장
        myPromotion["images"] = img64List;
        await promotionDb.add(myPromotion);
      } else {
        await promotionDb.add(myPromotion);
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
