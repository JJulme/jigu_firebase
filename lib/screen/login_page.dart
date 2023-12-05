import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/unite_signup_screen.dart';
// https://totally-developer.tistory.com/113

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("사장님 로그인"),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Center(
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    emailInput(),
                    const SizedBox(height: 15),
                    passwordInput(),
                    const SizedBox(height: 15),
                    loginButton(),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Get.to(() => UniteSignupScreen()),
                      child: const Text("이메일 전화번호 회원가입"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      validator: (value) {
        if (value!.isEmpty) {
          return "이메일을 입력해주세요.";
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "이메일을 입력해주세요.",
          labelText: "이메일",
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          )),
    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwController,
      validator: (value) {
        if (value!.isEmpty) {
          return "비밀번호를 입력해주세요.";
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "비밀번호를 입력해주세요.",
          labelText: "비밀번호",
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          )),
    );
  }

  ElevatedButton loginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                  email: _emailController.text,
                  password: _pwController.text,
                )
                .then((_) => Get.offAndToNamed("/"));
          } on FirebaseAuthException catch (e) {
            if (e.code == "user-not-found") {
              print("잘못된 이메일입니다.");
            } else if (e.code == "wrong-password") {
              print("이메일, 비밀번호가 다릅니다.");
            } else if (e.code == "invalid-credential") {
              print("아이디 또는 비밀번호가 일치하지 않습니다.");
            } else {
              print("false");
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(15),
        child: const Text(
          "Login",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
