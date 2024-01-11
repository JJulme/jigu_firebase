import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jigu_firebase/screen/home_page.dart';
import 'package:jigu_firebase/screen/imageview_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_create_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_list_screen.dart';
import 'package:photo_view/photo_view_gallery.dart';

//https://stackoverflow.com/questions/57613017/flutter-horizontal-list-view-dot-indicator

class MypromotionDetailScreen extends StatelessWidget {
  MypromotionDetailScreen({super.key});

  // 홍보글의 정보 받아옴
  final Map<String, dynamic> promotionData = Get.arguments[0];
  final String promotionId = Get.arguments[1];

  // 홍보글을 삭제하는 것이 아닌 유저 이름만 바꿔서 못가져오게 함
  promotionDelete() async {
    await db
        .collection("promotionPosts")
        .doc(promotionId)
        .update({"userId": "delete"});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Get.put(IndicatorController());
    // TimeStamp 변환, 우리나라 시간으로 설정 +9H
    DateTime dataTime =
        DateTime.parse(promotionData["dataTime"].toDate().toString())
            .add(const Duration(hours: 9));
    // 보여지는 시간 형식 설정
    String createTime = DateFormat("yyyy/MM/dd [HH:mm]").format(dataTime);
    return Scaffold(
      appBar: AppBar(
        title: const Text("나의 홍보글"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text("수정하기"),
                  onTap: () {
                    Get.to(() => MypromotionCreateScreen(), arguments: [
                      promotionData["title"],
                      promotionData["body"]
                    ]);
                  },
                ),
                deleteMenuItem(context),
              ];
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
              const SizedBox(height: 10),
              // 홍보글 제목
              Text(
                promotionData["title"],
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 13),
              // 홍보글 생성 시간
              Text(
                createTime,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 13),
              // 홍보글 이미지
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  imageBox(),
                  // 이미지 인디케이터
                  imgIndicator(),
                ],
              ),
              const SizedBox(height: 13),
              // 홍보글 내용
              Text(
                promotionData["body"],
                style: const TextStyle(fontSize: 23),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 홍보글을 삭제 해주는 다이얼로그
  PopupMenuItem<dynamic> deleteMenuItem(BuildContext context) {
    return PopupMenuItem(
      child: const Text("삭제하기"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("삭제 하시겠습니까?"),
              content: const Text("삭제된 내용은 복구되지 않습니다."),
              actions: [
                // 삭제 버튼
                TextButton(
                  child: const Text("삭제"),
                  onPressed: () {
                    // 기존의 다이얼로그 닫고 새로운 다이얼로그 열기
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return FutureBuilder(
                          future: promotionDelete(),
                          builder: (context, snapshot) {
                            // Future 값을 기다리는 중
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            // Future 값이 나왔을 때 - 삭제 실패 예외 추가 필요
                            return AlertDialog(
                              title: const Text("삭제 되었습니다."),
                              actions: [
                                TextButton(
                                  child: const Text("확인"),
                                  onPressed: () {
                                    // 다이얼로그와 홍보글 작성 화면 제거
                                    Navigator.of(context).pop();
                                    // 홍보글 리스트 reload
                                    Get.find<ListController>().onInit();
                                    Get.back();
                                  },
                                )
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                // 취소 버튼
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
    );
  }

  // 홍보글의 이미지를 보여줌
  Widget imageBox() {
    // 이미지가 없다면 아무것도 안보여줌
    if (promotionData["images"].isEmpty) {
      return const SizedBox();
    }
    // 이미지가 있다면 이미지 스크롤뷰 보여줌
    else {
      return SizedBox(
        height: Get.width,
        width: Get.width,
        child: PhotoViewGallery.builder(
          itemCount: promotionData["images"].length,
          onPageChanged: (index) {
            IndicatorController.to.changeIndex(index);
          },
          builder: (context, index) {
            Image img = Image.memory(
              base64Decode(promotionData["images"][index]),
            );
            return PhotoViewGalleryPageOptions.customChild(
              onTapUp: (context, details, controllerValue) {
                Get.to(
                  () => ImageviewScreen(),
                  arguments: [index, promotionData["images"]],
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: img.image,
                  fit: BoxFit.cover,
                )),
              ),
            );
          },
        ),
      );
    }
  }

  // 이미지 인디케이터
  Widget imgIndicator() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: promotionData["images"].map<Widget>((image) {
          int index = promotionData["images"].indexOf(image);
          return Obx(
            () => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: IndicatorController.to.imgIndex.value == index
                    ? const Color.fromRGBO(255, 255, 255, 1)
                    : const Color.fromRGBO(255, 255, 255, 0.6),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class IndicatorController extends GetxController {
  static IndicatorController get to => Get.find();
  RxInt imgIndex = 0.obs;
  void changeIndex(int index) {
    imgIndex.value = index;
  }
}
