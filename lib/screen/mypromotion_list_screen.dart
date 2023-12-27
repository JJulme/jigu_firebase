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
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: () {
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
            const Divider(color: Colors.black54, height: 1),
            Obx(() => mypromotionList()),
            const Divider(color: Colors.black54, height: 1),
          ],
        ),
      ),
    );
  }

  Widget mypromotionList() {
    if (ListController.to.promotionId.isEmpty) {
      return const Text("작성된 홍보글이 없습니다.");
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ListController.to.promotionId.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.black54, height: 1),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                ListController.to.promotionData[index]["title"],
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                height: 85,
                child: Text(
                  ListController.to.promotionData[index]["body"],
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.fade,
                ),
              ),
              onTap: () {
                // promotionId 전달
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
}

class ListController extends GetxController {
  static ListController get to => Get.find();

  RxList<dynamic> promotionId = [].obs;
  RxList<dynamic> promotionData = [].obs;

  @override
  void onInit() async {
    super.onInit();
    print("ListController oninit");
    QuerySnapshot<Map<String, dynamic>> queryList = await FirebaseFirestore
        .instance
        .collection("promotionPosts")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("dataTime", descending: true)
        .get();
    promotionId.value = queryList.docs.map((value) => value.id).toList();
    promotionData.value = queryList.docs.map((value) => value.data()).toList();
  }
}
