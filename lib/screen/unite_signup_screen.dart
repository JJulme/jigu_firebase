import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jigu_firebase/api/nts_businessman.dart';
import 'package:jigu_firebase/model/bizinfo_model.dart';
import 'package:jigu_firebase/screen/home_page.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

//https://stackoverflow.com/questions/53424916/textfield-validation-in-flutter

class UniteSignupScreen extends StatelessWidget {
  UniteSignupScreen({super.key});
  // Page Controller
  final PageController _pageController = PageController();
  // Form Controller
  final _phonePagekey = GlobalKey<FormState>();
  final _emailPagekey = GlobalKey<FormState>();
  final _bizPagekey = GlobalKey<FormState>();
  // TextFormField Controller
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _bizIdController = TextEditingController();
  final TextEditingController _bizNameController = TextEditingController();
  final TextEditingController _openingController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  // 전화번호 인증번호 발송시 생성되는 인증키
  late final String _verificationId;
  // 유저 로그인 키
  late final UserCredential userCredential;
  // 사업자등록번호 중복 확인
  bool bizIdCheck = false;
  // 개업일자 선택 변수 초기화
  DateTime _selectedDay = DateTime.parse("2023-01-01");
  // 사업자 등록정보 저장할 모델 생성
  late BizInfo bizInfo;

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
            // 회원가입 도중에 뒤로가기 누를 경우
            onPressed: () async {
              // 전화번호 인증을 했을 경우 (계정이 생성됨)
              if (PhoneSignupController.to.signUpChecker.value) {
                // 회원탈퇴
                await userCredential.user!.delete();
                // Getx Controller로
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
          // 페이지 스크롤 이동 금지
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Page 1
            const Center(
              child: Text("안녕하세요.\n약관 동의 해주세요."),
            ),
            // Page 2
            bizInfoPage(context),
            // Page 3
            phoneSignupPage(context),
            //Page 4
            emailSignupPage(context),
          ],
        ),
        // 화면 아래 고정되는 PageView 컨트롤 버튼
        persistentFooterButtons: [
          // PageCheckController로 관리
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // PageView 이전 버튼
                Flexible(
                  child: previousPageBtn(context, _pageController),
                ),
                // 페이지 번호를 보여줌
                SizedBox(
                  width: 10,
                  child: footerBtn(PageCheckController.to.pageNum.value),
                ),
                // PageView 다음 버튼
                Flexible(
                  child: nextPageBtn(context, _pageController),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 사업자등록정보 입력 페이지
  SingleChildScrollView bizInfoPage(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _bizPagekey,
          child: Column(
            children: [
              // 사업자등록번호 입력
              TextFormField(
                controller: _bizIdController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                // 숫자만 입력 받음
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  errorText: bizIdCheck ? "중복된 사업자등록번호 입니다." : null,
                ),
                validator: (value) {
                  if (value!.length < 10) {
                    return "사업자등록번호를 입력해주세요.";
                  } else if (bizIdCheck) {
                    return "중복된 사업자등록번호 입니다.";
                  }
                  return null;
                },
                // 사업자등록번호 10자를 입력하면 자동으로 중복검사 실행
                onChanged: (value) async {
                  if (value.length == 10) {
                    bizIdCheck = await bizIdDoubleChecker(value);
                  } else {
                    bizIdCheck = false;
                  }
                },
              ),
              const SizedBox(height: 10),
              // 대표자명 입력
              TextFormField(
                controller: _bizNameController,
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
                // 키보드로 입력제한
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
                // 버튼의 기능을 갖도록 설정
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 200,
                          width: 320,
                          // 날짜 선택 팝업
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
                          // 버튼을 누르면 해당 Controller에 값 전달
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
              // 사업자 확인하는 버튼 (중복확인, 진위확인, 상호명/주소 가져오기)
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
                    // 사업자등록번호, 대표자명, 개업일자 작성했는지 확인
                    if (_bizPagekey.currentState!.validate()) {
                      // 개업일자 yyyyMMdd 형식으로 생성
                      String opening =
                          DateFormat("yyyyMMdd").format(_selectedDay);
                      // 올바르게 된 정보유무와 상호명, 사업자주소 가져옴
                      var bizValid = NtsBusinessman().postNts(
                        taxId: _bizIdController.text,
                        name: _bizNameController.text,
                        opening: opening,
                      );
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return FutureBuilder(
                            future: bizValid,
                            builder: (context, snapshot) {
                              // Future 값 기다리는 중
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              // 입력된 사업자 정보가 올바르지 않을 경우
                              else if (!snapshot.data!["valid"]) {
                                return AlertDialog(
                                  title: const Text("등록된 정보가 없습니다."),
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
                              // 입력된 사업자 정보가 일치할 경우
                              else if (snapshot.data!["valid"]) {
                                // 입력한 정보, 가져온 정보를 가진 객체 생성
                                bizInfo = BizInfo(
                                  bizName: _bizNameController.text,
                                  bizTrName: snapshot.data!["bizTrName"],
                                  bizId: _bizIdController.text,
                                  bizAddr: snapshot.data!["bizAddr"],
                                );
                                return AlertDialog(
                                  title: const Text("정보를 확인해주세요."),
                                  content: SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      // Table을 이용해 표처럼 생성
                                      child: Table(
                                        // 표 가운데 정렬
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        // 표 열 비율 설정
                                        columnWidths: const {
                                          0: FractionColumnWidth(0.35)
                                        },
                                        children: [
                                          bizTable("대표자명", bizInfo.bizName),
                                          bizTable("상호명", bizInfo.bizTrName),
                                          bizTable("사업자\n등록번호", bizInfo.bizId),
                                          bizTable("사업자주소", bizInfo.bizAddr,
                                              hight: 90),
                                        ],
                                      )),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      child: const Text("확인"),
                                    )
                                  ],
                                );
                              } else {
                                return const AlertDialog(
                                    title: Text("예기치 못한 오류"));
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

  // 전화번호 인증 페이지
  Container phoneSignupPage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Form(
        key: _phonePagekey,
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

  // 이메일 인증 페이지
  Container emailSignupPage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Form(
        key: _emailPagekey,
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
                  if (_emailPagekey.currentState!.validate()) {
                    try {
                      var emailCredential = EmailAuthProvider.credential(
                        email: _emailController.text,
                        password: _pwController.text,
                      );
                      final userCredential = await auth.currentUser!
                          .linkWithCredential(emailCredential)
                          .then((value) {
                        PhoneSignupController.to.delete();
                        var userBizInfo = {
                          "bizName": bizInfo.bizName,
                          "bizTrName": bizInfo.bizTrName,
                          "bizId": bizInfo.bizId,
                          "bizAddr": bizInfo.bizAddr,
                        };
                        var users =
                            FirebaseFirestore.instance.collection("users");
                        users
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set(userBizInfo);
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

  // PageView 다음 버튼
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

  // PageView 이전 버튼
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

  // 조회된 사업자 정도 AlertDialog에 듸워 보여줌
  TableRow bizTable(String txt1, String txt2, {double hight = 60}) {
    return TableRow(
      children: [
        Container(
          height: hight,
          alignment: Alignment.centerLeft,
          child: Text(
            txt1,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: Text(
            txt2,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  // persistentFooterButtons에 보여줄 위젯
  Widget footerBtn(double page) {
    return Text("${page.toInt()}");
  }
}

// 전화번호로 생성된 아이디가 있는지 상태 기록하는 Controller
class PhoneSignupController extends GetxController {
  // getter 생성해서 짧은 코드 가능
  static PhoneSignupController get to => Get.find();
  // 회원가입 유무를 true/false로 기록
  RxBool signUpChecker = false.obs;
  // 회원가입 했을 경우 true
  void signUp() {
    signUpChecker = true.obs;
  }

  // 회원탈퇴 했을 경우 false로 기록
  void delete() {
    signUpChecker = false.obs;
  }
}

// PageView 상태관리 Controller
class PageCheckController extends GetxController {
  // getter 생성해서 짧은 코드 가능
  static PageCheckController get to => Get.find();
  RxDouble pageNum = 0.0.obs;
  void syncPage(double? page) {
    pageNum.value = page!;
  }
}

// 사업자등록번호 중복확인 함수
Future<bool> bizIdDoubleChecker(String text) async {
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
