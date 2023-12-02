import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jigu_firebase/api/ftc_biz.dart';
import 'package:jigu_firebase/api/nts_businessman.dart';
import 'package:jigu_firebase/screen/home_page.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

//https://stackoverflow.com/questions/53424916/textfield-validation-in-flutter

class UniteSignupScreen extends StatelessWidget {
  UniteSignupScreen({super.key});
  final PageController _pageController = PageController();
  final _key2 = GlobalKey<FormState>();
  final _key3 = GlobalKey<FormState>();
  final _key4 = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _openingController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  late final String _verificationId;
  late final UserCredential userCredential;
  bool taxIdCheck = false;
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // 전화번호 로그인 상태관리 controller 등록
    Get.put(PhoneSignupController());
    Get.put(PageCheckController());
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () async {
              if (PhoneSignupController.to.signUpChecker.value) {
                await userCredential.user!.delete();
                print("회원 탈퇴");
                PhoneSignupController.to.delete();
                Get.back();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Page 1
            const Center(
              child: Text("안녕하세요.\n약관 동의 해주세요."),
            ),
            // Page 2
            phoneSignupPage(context),
            // Page 3
            taxIdInfoPage(context),
            //Page 4
            emailSignupPage(context),
          ],
        ),
        persistentFooterButtons: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: previousPageBtn(context, _pageController),
                  ),
                  SizedBox(
                    width: 10,
                    child: footerBtn(PageCheckController.to.pageNum.value),
                  ),
                  Flexible(
                    child: nextPageBtn(context, _pageController),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Container phoneSignupPage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Form(
        key: _key2,
        child: Obx(
          () => Column(
            children: [
              TextFormField(
                enabled: !PhoneSignupController.to.signUpChecker.value,
                controller: _phoneController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 17,
                  ),
                  hintText: "010 - 0000 - 0000",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "번호를 입력해주세요.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: PhoneSignupController.to.signUpChecker.value
                      ? null
                      : () async {
                          if (_phoneController.text.isEmpty) {
                            print("번호를 입력해주세요.");
                          } else {
                            await auth.verifyPhoneNumber(
                              // timeout: const Duration(minutes: 1),
                              phoneNumber:
                                  "+82${_phoneController.text.substring(1)}",
                              verificationCompleted: (phoneAuthCredential) {
                                print("전송 성공!");
                              },
                              verificationFailed: (error) {
                                print("전송 실패");
                                print(error.code);
                              },
                              codeSent: (verificationId, forceResendingToken) {
                                // 권한 아디디 설정
                                _verificationId = verificationId;
                                print("코드 전송");
                              },
                              codeAutoRetrievalTimeout: (verificationId) {
                                print("시간초과");
                              },
                            );
                          }
                        },
                  child: const Text(
                    "인증번호 전송",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                enabled: !PhoneSignupController.to.signUpChecker.value,
                controller: _smsCodeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 17,
                  ),
                  hintText: "000000",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: PhoneSignupController.to.signUpChecker.value
                      ? null
                      : () async {
                          final phoneCredential = PhoneAuthProvider.credential(
                            verificationId: _verificationId,
                            smsCode: _smsCodeController.text,
                          );
                          try {
                            userCredential = await auth
                                .signInWithCredential(phoneCredential);
                            PhoneSignupController.to.signUp();
                            print(PhoneSignupController.to.signUpChecker.value);
                            FocusScope.of(context).unfocus();
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == "invalid-verification-code") {
                              print("인증번호가 다릅니다.");
                            }
                          }
                        },
                  child: const Text(
                    "인증번호 확인",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SingleChildScrollView taxIdInfoPage(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _key4,
          child: Column(
            children: [
              // 사업자등록번호 입력
              TextFormField(
                controller: _taxIdController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 17,
                  ),
                  hintText: "사업자등록번호 10자리",
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  errorText: taxIdCheck ? "중복된 사업자등록번호 입니다." : null,
                ),
                validator: (value) {
                  if (value!.length < 10) {
                    return "사업자등록번호를 입력해주세요.";
                  } else if (taxIdCheck) {
                    return "중복된 사업자등록번호 입니다.";
                  }
                  return null;
                },
                onChanged: (value) async {
                  if (value.length == 10) {
                    taxIdCheck = await taxIdDoubleChecker(value);
                  } else {
                    taxIdCheck = false;
                  }
                },
              ),
              const SizedBox(height: 10),
              // 대표자 성명 입력
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 17,
                  ),
                  hintText: "대표자 성명",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "대표자 성명을 입력해주세요.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // 개업일자 입력
              TextFormField(
                controller: _openingController,
                showCursor: false,
                readOnly: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 17,
                  ),
                  hintText: "개업일자",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 200,
                          width: 320,
                          child: ScrollDatePicker(
                            selectedDate: _selectedDay,
                            locale: const Locale("ko"),
                            scrollViewOptions:
                                const DatePickerScrollViewOptions(
                                    year: ScrollViewDetailOptions(
                                      label: '년',
                                      margin: EdgeInsets.only(right: 8),
                                    ),
                                    month: ScrollViewDetailOptions(
                                      label: '월',
                                      margin: EdgeInsets.only(right: 8),
                                    ),
                                    day: ScrollViewDetailOptions(
                                      label: '일',
                                    )),
                            onDateTimeChanged: (value) {
                              _selectedDay = value;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                _openingController.text =
                                    DateFormat("yyyy년 M월 d일")
                                        .format(_selectedDay);
                                Navigator.pop(context);
                              },
                              child: const Text("확인"))
                        ],
                      );
                    },
                  );
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "개업일자를 선택해주세요.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // 사업자 확인하는 버튼 (중복확인, 진위확인)
              // taxId: "1283949844", name: "박효진", bNm: "팩토리팩", opening: "20140407"
              Container(
                height: 55,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  child: const Text(
                    "사업자 확인",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () async {
                    if (_key4.currentState!.validate()) {
                      print("check");
                      String opening =
                          DateFormat("yyyyMMdd").format(_selectedDay);
                      var bizValid = NtsBusinessman().postNts(
                        taxId: _taxIdController.text,
                        name: _nameController.text,
                        opening: opening,
                      );
                      var bizInfo =
                          await FtcBiz().getBiz(_taxIdController.text);
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return FutureBuilder(
                            future: bizValid,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.data!["data"][0]["valid"] ==
                                  "02") {
                                return AlertDialog(
                                  title: const Text("등록된 정보가 없습니다."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text("확인"),
                                    )
                                  ],
                                );
                              } else {
                                return AlertDialog(
                                  title: const Text("일치하는 정보를 확인 했습니다."),
                                  content: SizedBox(
                                    height: 300,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("대표자명"),
                                            Text(_nameController.text),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("상호명"),
                                            Text(bizInfo["items"][0]["bzmnNm"]),
                                          ],
                                        ),
                                        const Text("사업자등록번호",
                                            style: TextStyle(fontSize: 18)),
                                        Text(_taxIdController.text),
                                        const Text("사업자주소"),
                                        Text(bizInfo["items"][0]["rnAddr"]),
                                      ],
                                    ),
                                  ),
                                  // Column(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     Row(
                                  //       children: [
                                  //         const Text("대표자명"),
                                  //         Text(_nameController.text),
                                  //       ],
                                  //     ),
                                  //     const Text("대표자명"),
                                  //     const Text("상호명"),
                                  //     const Text("사업자등록번호"),
                                  //     const Text("사업지주소"),
                                  //     Text(_taxIdController.text),
                                  //     Text(bizInfo["items"][0]["bzmnNm"]),
                                  //     Text(bizInfo["items"][0]["rnAddr"]),
                                  //   ],
                                  // ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("확인"),
                                    )
                                  ],
                                );
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container emailSignupPage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Form(
        key: _key3,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 17,
                ),
                hintText: "abd@abc.com",
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _pwController,
              keyboardType: TextInputType.visiblePassword,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 17,
                ),
                hintText: "000000",
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 55,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (_key3.currentState!.validate()) {
                    try {
                      var emailCredential = EmailAuthProvider.credential(
                        email: _emailController.text,
                        password: _pwController.text,
                      );
                      final userCredential = await auth.currentUser!
                          .linkWithCredential(emailCredential)
                          .then((value) {
                        PhoneSignupController.to.delete();
                        Get.toNamed("/");
                      });
                    } on FirebaseAuthException catch (e) {
                      if (e.code == "weak-password") {
                        print("6자 이상의 비밀번호를 설정해주세요.");
                      } else if (e.code == "email-already-in-use") {
                        print("이미 존재하는 이메일입니다.");
                      }
                    } catch (e) {
                      print(e.toString());
                      print("오류오류");
                    }
                  }
                },
                child: const Text(
                  "이메일, 비밀번호 확인",
                  style: TextStyle(fontSize: 20),
                ),
              ),
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
      onPressed: () async {
        print(controller.page);
        FocusScope.of(context).unfocus();
        await controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        PageCheckController.to.syncPage(_pageController.page);
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
      onPressed: () async {
        print(controller.page);
        FocusScope.of(context).unfocus();
        await controller.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        PageCheckController.to.syncPage(_pageController.page);
      },
    );
  }

  Widget footerBtn(double page) {
    return Text("${page.toInt()}");
  }
}

class PhoneSignupController extends GetxController {
  // getter 생성해서 짧은 코드 가능
  static PhoneSignupController get to => Get.find();
  RxBool signUpChecker = false.obs;
  void signUp() {
    signUpChecker = true.obs;
  }

  void delete() {
    signUpChecker = false.obs;
  }
}

class PageCheckController extends GetxController {
  // getter 생성해서 짧은 코드 가능
  static PageCheckController get to => Get.find();
  RxDouble pageNum = 0.0.obs;
  void syncPage(double? page) {
    pageNum.value = page!;
  }
}

Future<bool> taxIdDoubleChecker(String text) async {
  late List<dynamic> taxIdList;
  await db
      .collection("users")
      .where("taxId", isEqualTo: text)
      .get()
      .then((value) {
    taxIdList = value.docs;
  });
  if (taxIdList.isEmpty) {
    return false;
  } else {
    return true;
  }
}
