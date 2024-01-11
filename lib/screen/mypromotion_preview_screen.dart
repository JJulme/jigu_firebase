import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/api/fb_connect.dart';
import 'package:jigu_firebase/screen/imageview_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_list_screen.dart';
import 'package:photo_manager/photo_manager.dart';

// 게시물 생성시
// 1. FireStore에 title과 body를 보내서 문서ID 생성
// 2. Storage에 promotion/userId/문서ID 경로 생성하고 이미지 전송
// 3. 경로와 이미지 문서 ID에 업데이트

class MypromotionPreviewScreen extends StatelessWidget {
  MypromotionPreviewScreen({super.key});
  // db 접근
  FirebaseFirestore db = FirebaseFirestore.instance;
  // 사용자의 정보
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  final storageRef = FirebaseStorage.instance.ref();
  // 작성한 제목 가져옴
  final String title = Get.arguments[0];
  // 작성한 제목 가져옴
  final String body = Get.arguments[1];
  // 선택한 이미지 리스트 가져옴
  final List<dynamic> imageList = Get.arguments[2];
  // 이미지들의 경로를 가져옴
  late Future<dynamic> imageFiles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // 이미지 업로드 테스트 버튼
          TextButton(
            child: const Text(
              "이미지 업로드",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            onPressed: () async {
              var img64List = [];
              for (var image in imageList) {
                var imgFile = await image.file;
                img64List.add(File(imgFile.path).readAsBytesSync());
              }
              print(img64List[0].toString().length);
              var base64Img = base64Encode(img64List[0]);
              print(base64Img.length);
              Get.defaultDialog(
                  content: SizedBox(
                height: 300,
                width: 300,
                child: Image.memory(base64Decode(base64Img)),
              ));
            },
          ),
          // 게시하기 버튼
          TextButton(
            child: const Text(
              "게시하기",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            // 게시하기 눌렀을 때
            onPressed: () {
              // 이미지들의 경로를 가져옴
              imageFiles = assetEntity2File(imageList);
              imageFiles.then((value) => print(value));
              // 팝업창 생성
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("홍보글을 작성하시겠습니까?"),
                    actions: [
                      TextButton(
                        child: const Text("확인"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future<bool> posting = FsDb().postPromotion2(
                            title: title,
                            body: body,
                            assetImages: imageList,
                          );
                          showDialog(
                            context: context,
                            builder: (context) {
                              return FutureBuilder(
                                future: posting,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else {
                                    return AlertDialog(
                                      title: const Text("게시에 성공했습니다."),
                                      actions: [
                                        TextButton(
                                          child: const Text("확인"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Get.find<ListController>().onInit();
                                            Get.back();
                                            Get.back();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                      TextButton(
                        child: const Text("취소"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 홍보글 제목
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(
                height: 20,
                color: null,
              ),
              // 이미지 보여줌
              ListView.builder(
                itemCount: imageList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      print(imageList);
                      Get.to(
                        () => ImageviewScreen(),
                        arguments: [index, imageList],
                      );
                    },
                    child: Container(
                      height: Get.width / 2,
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      clipBehavior: Clip.hardEdge,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      child: AssetEntityImage(
                        imageList[index],
                        isOriginal: true,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              imageList.isEmpty
                  ? const SizedBox()
                  : const Divider(
                      height: 20,
                      color: null,
                    ),
              // 홍보글 본문 내용
              Text(
                body,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
              const Divider(
                height: 30,
                color: null,
              ),
              // 사용자 정보 샘플
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey,
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "name",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "info",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// AssetEntiry 형식의 이미지를 Image 형식으로 변경
assetEntity2File(List<dynamic> assetImages) async {
  // List<dynamic> imageFiles = assetImages.map((asset) => asset.file).toList();
  // return imageFiles;
  var imageFiles = [];
  for (var image in assetImages) {
    File imagePath = await image.file;
    imageFiles.add(imagePath);
  }
  return imageFiles;
}
