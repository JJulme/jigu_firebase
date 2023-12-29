import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/mypromotion_create_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_detail_screen.dart';

class MypromotionListScreen extends StatelessWidget {
  MypromotionListScreen({super.key});
  // db 접근은 로그인 페이지로 이동 해야함
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  // 사용자의 정보는 로그인 후 부터 저장 해야함
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Controller 사용을 위해 설정
    Get.put(ListController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text("홍보글 설정"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 홍보글 만들기 버튼
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: () {
                  // 수정이 필요함
                  Get.to(() => MypromotionCreateScreen(), arguments: ["", ""]);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 30),
                    Text(
                      "홍보글 만들기",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.black54, height: 1, thickness: 1.2),
            // Getx Controller에 의해 변경되는 위젯
            Obx(() => mypromotionList()),
          ],
        ),
      ),
    );
  }

  // 홍보글 리스트를 보여주는 위젯
  Widget mypromotionList() {
    // 작성된 홍보글이 없을 경우
    if (ListController.to.promotionId.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text(
          "작성된 홍보글이 없습니다.",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      );
    }
    // 작성된 홍보글이 있을 경우
    else {
      return ListView.separated(
        // 크기 제한
        shrinkWrap: true,
        // 스크롤 제한
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ListController.to.promotionId.length,
        // 구분선 설정
        separatorBuilder: (context, index) => const Divider(
          color: Colors.black54,
          height: 10,
          thickness: 1.2,
        ),
        itemBuilder: (context, index) {
          // 본문의 연속된 줄바꿈 반복문으로 제거
          String body = ListController.to.promotionData[index]["body"];
          while (body.contains("\n\n")) {
            body = body.replaceAll("\n\n", "\n");
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              // 홍보글 제목
              title: Text(
                ListController.to.promotionData[index]["title"],
                style: const TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 홍보글 본문
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      body,
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                  // 홍보글 이미지
                  mypromotionImage(index),
                ],
              ),
              onTap: () {
                // promotionId, promotionData 전달
                Get.to(() => MypromotionDetailScreen(), arguments: [
                  ListController.to.promotionData[index],
                  ListController.to.promotionId[index],
                ]);
              },
            ),
          );
        },
      );
    }
  }

  // 홍보글 이미지를 보여주는 위젯
  Widget mypromotionImage(int index) {
    // 홍보글에 이미지가 없을 경우
    if (ListController.to.promotionData[index]["images"].isEmpty) {
      return const SizedBox();
    }
    // 홍보글의 이미지가 1개인 경우
    else if (ListController.to.promotionData[index]["images"].length == 1) {
      return Container(
        height: Get.width / 2,
        width: Get.width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: Image.memory(
          base64Decode(ListController.to.promotionData[index]["images"][0]),
          fit: BoxFit.cover,
        ),
      );
    }
    // 홍보글의 이미지가 1개 이상인 경우
    else {
      return Container(
        height: Get.width / 2,
        width: Get.width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        // 두개의 이미지를 Flexible을 이용해 동일한 너비로 나눔
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Image.memory(
                base64Decode(
                    ListController.to.promotionData[index]["images"][0]),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              fit: FlexFit.tight,
              child: Image.memory(
                base64Decode(
                    ListController.to.promotionData[index]["images"][1]),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      );
    }
  }
}

// 홍보글을 가져오는 Controller
class ListController extends GetxController {
  static ListController get to => Get.find();

  RxList<dynamic> promotionId = [].obs;
  RxList<dynamic> promotionData = [].obs;

  // Controller 초기 실행 함수 - 따로 실행 가능
  @override
  void onInit() async {
    super.onInit();
    print("ListController oninit");
    // 시간역순으로 자신이 작성한 홍보글을 가져옴
    QuerySnapshot<Map<String, dynamic>> queryList = await FirebaseFirestore
        .instance
        .collection("promotionPosts")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("dataTime", descending: true)
        .get();
    // 홍보글 각각의 ID를 리스트에 저장
    promotionId.value = queryList.docs.map((value) => value.id).toList();
    // 홍보글의 Data를 리스트에 저장
    promotionData.value = queryList.docs.map((value) => value.data()).toList();
  }
}
