import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("사장님 회원가입"),
      ),
      body: Container(
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
                submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      autofocus: true,
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
      autofocus: true,
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

  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            final credential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: _emailController.text, password: _pwController.text)
                .then((_) => Get.toNamed("/"));
          } on FirebaseAuthException catch (e) {
            if (e.code == "weak-password") {
              print("암호의 보안이 취약합니다.");
            } else if (e.code == "email-already-in-use") {
              print("이미 존재하는 이메일입니다.");
            }
          } catch (e) {
            print(e.toString());
            print("오류오류");
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(15),
        child: const Text(
          "회원가입",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
