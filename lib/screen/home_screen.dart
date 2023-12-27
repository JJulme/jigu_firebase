import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/login_page.dart';

import 'package:jigu_firebase/screen/mypage_screen.dart';
import 'package:jigu_firebase/screen/question_screen.dart';
import 'package:jigu_firebase/screen/unite_signup_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  // db 접근은 로그인 페이지로 이동 해야함
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  // 사용자의 정보는 로그인 후 부터 저장 해야함
  FirebaseFirestore db = FirebaseFirestore.instance;

  // bottonNavigatoionBar 화면 리스트
  final List bodyScreen = [
    const QuestionScreen(),
    MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // bottonNavigation 상태 관리 컨트롤러
    Get.put(NavController());
    // 사용자 로그인/로그아웃 상태 받기위해
    return StreamBuilder(
      // 사용자의 로그인/로그아웃 상태 관리
      stream: auth.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> user) {
        // 유저 정보가 없으면 로그인 페이지로 이동
        if (!user.hasData) {
          return LoginPage();
        }
        // 유저 정보가 있다면 로그인
        else {
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
                // 누른 버튼 인덱스 컨트롤러 변수에 전달
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

// bottonNavigation 컨트롤러
class NavController extends GetxController {
  // getter 생성해서 짧은 코드 가능
  static NavController get to => Get.find();
  RxInt currentIndex = 0.obs;
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
