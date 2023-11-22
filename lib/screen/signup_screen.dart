import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        controller: controller,
        children: [
          const Center(
            child: Text("핸드폰 실명인증"),
          ),
          const Center(
            child: Text("사업자 인증"),
          ),
          const Center(
            child: Text("비밀번호 설정"),
          ),
          Scaffold(
            body: const Center(
              child: Text("가입완료"),
            ),
            persistentFooterButtons: [
              Container(
                height: 60,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
///
///회원가입시
///핸드폰 실명인증
///사업자 인증 - 사업자 번호로 로그인
///비밀번호 설정
///
///