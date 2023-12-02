import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/home_page.dart';

class SignupPhoneScreen extends StatefulWidget {
  const SignupPhoneScreen({super.key});

  @override
  State<SignupPhoneScreen> createState() => _SignupPhoneScreenState();
}

class _SignupPhoneScreenState extends State<SignupPhoneScreen> {
  final _key = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _codeController = TextEditingController();

  bool _codeSent = false;

  late String _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: const EdgeInsets.all(15),
        alignment: Alignment.center,
        child: Form(
          key: _key,
          child: Column(
            children: [
              phoneNumberInput(),
              const SizedBox(height: 10),
              _codeSent ? const SizedBox.shrink() : submitBtn(),
              const SizedBox(height: 10),
              _codeSent ? codeInput() : const SizedBox.shrink(),
              const SizedBox(height: 10),
              _codeSent ? verifyBtn() : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField phoneNumberInput() {
    return TextFormField(
      controller: _phoneController,
      validator: (value) {
        if (value!.isEmpty) {
          return "휴대폰 번호를 입력해 주세요.";
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "휴대폰 번호를 입력해주세요.",
        labelText: "휴대폰 번호",
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  TextFormField codeInput() {
    return TextFormField(
      controller: _codeController,
      validator: (value) {
        if (value!.isEmpty) {
          return "코드 번호를 입력해 주세요.";
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "코드 번호를 입력해주세요.",
        labelText: "코드 번호",
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ElevatedButton submitBtn() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          await auth.verifyPhoneNumber(
            phoneNumber: _phoneController.text,
            verificationCompleted: (credential) async {
              await auth
                  .signInWithCredential(credential)
                  .then((_) => Get.toNamed("/"));
            },
            verificationFailed: (e) {
              if (e.code == "invalid-phone-number") {
                print("존재하지 않는 전화번호 입니다.");
              }
            },
            codeSent: (verificationId, forceResendingToken) {
              String code = _codeController.text;
              setState(() {
                _codeSent = true;
                _verificationId = verificationId;
              });
            },
            codeAutoRetrievalTimeout: (verificationId) {
              print("시간초과");
            },
          );
        }
      },
      child: const Text("인증코드 발송"),
    );
  }

  ElevatedButton verifyBtn() {
    return ElevatedButton(
      onPressed: () async {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _codeController.text,
        );
        await auth
            .signInWithCredential(credential)
            .then((_) => Get.toNamed("/"));
      },
      child: const Text("인증 번호 확인"),
    );
  }
}
