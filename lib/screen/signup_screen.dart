import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jigu_firebase/screen/home_page.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});
  final PageController _pageController = PageController();
  final _key = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Scaffold(
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(15),
                  child: const Column(
                    children: [
                      Text("대충 환영 인사"),
                      Text("약관동의 체크"),
                    ],
                  ),
                ),
              ),
              persistentFooterButtons: [
                nextPageBtn(context, _pageController),
              ],
            ),
            Scaffold(
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(15),
                  child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 60,
                              child: TextField(
                                enabled: false,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 17.5,
                                  ),
                                  labelText: "010",
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              fit: FlexFit.loose,
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(8),
                                ],
                                style: const TextStyle(fontSize: 18),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 17,
                                  ),
                                  hintText: "0000 - 0000",
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 57,
                              width: 80,
                              child: ElevatedButton(
                                child: const Text(
                                  "인 증",
                                  style: TextStyle(fontSize: 20),
                                ),
                                onPressed: () async {
                                  if (_key.currentState!.validate()) {
                                    try {
                                      await auth.verifyPhoneNumber(
                                        phoneNumber:
                                            "+8210${_phoneController.text}",
                                        verificationCompleted:
                                            (phoneAuthCredential) {},
                                        verificationFailed:
                                            (FirebaseAuthException e) {
                                          print(e);
                                        },
                                        codeSent:
                                            (verificationId, resendToken) {},
                                        codeAutoRetrievalTimeout:
                                            (verificationId) {},
                                      );
                                    } catch (e) {
                                      print(e.toString());
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              persistentFooterButtons: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: previousPageBtn(context, _pageController),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: nextPageBtn(context, _pageController),
                    ),
                  ],
                )
              ],
            ),
            Scaffold(
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(15),
                  child: const Column(
                    children: [
                      Text("사업자 인증"),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              persistentFooterButtons: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: previousPageBtn(context, _pageController),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: nextPageBtn(context, _pageController),
                    ),
                  ],
                )
              ],
            ),
            Scaffold(
              body: const Center(
                child: Text("가입완료"),
              ),
              persistentFooterButtons: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: previousPageBtn(context, _pageController),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: nextPageBtn(context, _pageController),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton nextPageBtn(context, PageController controller) {
    return ElevatedButton(
      child: Container(
        height: 55,
        width: double.infinity,
        alignment: Alignment.center,
        child: const Text(
          "다   음",
          style: TextStyle(fontSize: 22),
        ),
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
    );
  }

  OutlinedButton previousPageBtn(context, PageController controller) {
    return OutlinedButton(
      child: Container(
        height: 55,
        width: double.infinity,
        alignment: Alignment.center,
        child: const Text(
          "이  전",
          style: TextStyle(fontSize: 22),
        ),
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        controller.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
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