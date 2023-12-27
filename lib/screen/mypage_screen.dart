import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/mypage_basicInfo_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_list_screen.dart';

class MypageScreen extends StatelessWidget {
  MypageScreen({super.key});
  // db 접근은 로그인 페이지로 이동 해야함
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  // 사용자의 정보는 로그인 후 부터 저장 해야함
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            child: const Icon(Icons.logout_outlined),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text("로그아웃"),
                  onTap: () async {
                    await auth
                        .signOut()
                        .then((_) => Get.offAndToNamed("/login"));
                  },
                ),
                PopupMenuItem(
                  child: const Text("회원탈퇴"),
                  onTap: () {
                    Get.defaultDialog(
                      title: "회원탈퇴?",
                      content: const SizedBox(),
                      textConfirm: "delete",
                      textCancel: "cancel",
                      onConfirm: () async {
                        // 회원탈퇴
                        // 유저 정보 삭제
                        await db
                            .collection("users")
                            .doc(auth.currentUser!.uid)
                            .delete();
                        // 유저 가입 기록 삭제
                        await auth.currentUser!.delete();
                        Get.back;
                        Get.offAndToNamed("/login");
                      },
                      onCancel: () {
                        Get.back;
                      },
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text("정보조회"),
                  onTap: () async {
                    print(auth.currentUser);
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
          margin: const EdgeInsets.all(15),
          child: ListView(
            children: [
              mypageTab(
                "매장 기본정보 설정",
                MypageBasicInfoScreen(),
              ),
              mypageTab(
                "홍보글 설정",
                MypromotionListScreen(),
              ),
            ],
          )),
    );
  }

  Widget mypageTab(String text, dynamic page) {
    return Column(
      children: [
        ListTile(
          title: Text(text),
          onTap: () {
            Get.to(page);
          },
        ),
        const Divider(
          color: Colors.black54,
        ),
      ],
    );
  }
}
