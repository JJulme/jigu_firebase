import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/home_page.dart';

class PromotionScreen extends StatelessWidget {
  PromotionScreen({super.key});
  final _key = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("홍보글 작성"),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  titleTextFormField(),
                  const SizedBox(height: 15),
                  bodyTextFormField()
                ],
              ),
            ),
          ),
        ),
        persistentFooterButtons: [
          postingBtn(context),
        ],
      ),
    );
  }

  TextFormField titleTextFormField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: "제목을 입력해주세요.",
        labelText: "제목",
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: (value) {
        if (value!.length < 5) {
          return "제목을 5자 이상 입력해주세요.";
        }
        return null;
      },
    );
  }

  TextFormField bodyTextFormField() {
    return TextFormField(
      controller: _bodyController,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: "내용을 입력해주세요.",
        labelText: "홍보 내용",
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: (value) {
        if (value!.length < 5) {
          return "내용을 5자 이상 입력해주세요.";
        }
        return null;
      },
    );
  }

  Container postingBtn(BuildContext context) {
    return Container(
      height: 68,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () {
          if (_key.currentState!.validate()) {
            final promotionPosts = db.collection("promotionPosts");
            final promotionPost = {
              "userId": userId,
              "dataTime": Timestamp.now(),
              "title": _titleController.text,
              "body": _bodyController.text,
            };
            Future<dynamic> posting = promotionPosts.add(promotionPost);
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return AlertDialog(
                  content: const Text("홍보글을 게시 하시겠습니까?"),
                  actions: [
                    TextButton(
                      child: const Text("확인"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return FutureBuilder(
                              future: posting,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return AlertDialog(
                                  content: const Text("작성이 완료되었습니다."),
                                  actions: [
                                    TextButton(
                                      child: const Text("확인"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Get.back();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    TextButton(
                      child: const Text("취소"),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              },
            );
          }
        },
        child: const Text(
          "작성하기",
          style: TextStyle(fontSize: 23),
        ),
      ),
    );
  }
}
