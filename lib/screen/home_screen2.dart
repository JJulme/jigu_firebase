import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/login_page.dart';
import 'package:jigu_firebase/screen/mypage_screen.dart';
import 'package:jigu_firebase/screen/question_screen.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore db = FirebaseFirestore.instance;
String userId = auth.currentUser!.uid;

class HomeScreen2 extends StatelessWidget {
  HomeScreen2({super.key});
  final List bodyScreen = [
    const QuestionScreen(),
    const MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(NavController());
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> user) {
        if (!user.hasData) {
          return LoginPage();
        } else {
          return Obx(
            () => Scaffold(
              body: bodyScreen.elementAt(NavController.to.currentIndex.value),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.white,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black54,
                // 버튼 누르면 커지는 효과
                type: BottomNavigationBarType.fixed,
                // 초기 화면 인덱스 설정
                currentIndex: NavController.to.currentIndex.value,
                onTap: (value) {
                  NavController.to.changeIndex(value);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.live_help_rounded),
                    label: "질문",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    label: "내정보",
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class NavController extends GetxController {
  // getter 생성해서 짧은 코드 가능
  static NavController get to => Get.find();
  RxInt currentIndex = 0.obs;
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
