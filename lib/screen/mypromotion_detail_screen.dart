import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jigu_firebase/screen/home_page.dart';
import 'package:jigu_firebase/screen/mypromotion_create_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_list_screen.dart';

class MypromotionDetailScreen extends StatelessWidget {
  MypromotionDetailScreen({super.key});
  final Map<String, dynamic> promotionData = Get.arguments[0];
  final String promotionId = Get.arguments[1];

  promotionDelete() async {
    await db
        .collection("promotionPosts")
        .doc(promotionId)
        .update({"userId": "delete"});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var dataTime = DateTime.parse(promotionData["dataTime"].toDate().toString())
        .add(const Duration(hours: 9));
    var createTime = DateFormat("yyyy/MM/dd [HH:mm]").format(dataTime);
    return Scaffold(
      appBar: AppBar(
        title: const Text("나의 홍보글"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text("수정하기"),
                  onTap: () {
                    Get.to(() => MypromotionCreateScreen(), arguments: [
                      promotionData["title"],
                      promotionData["body"]
                    ]);
                  },
                ),
                deleteMenuItem(context),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                promotionData["title"],
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 13),
              Text(
                createTime,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                promotionData["body"],
                style: const TextStyle(fontSize: 23),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<dynamic> deleteMenuItem(BuildContext context) {
    return PopupMenuItem(
      child: const Text("삭제하기"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("삭제 하시겠습니까?"),
              content: const Text("삭제된 내용은 복구되지 않습니다."),
              actions: [
                TextButton(
                  child: const Text("삭제"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return FutureBuilder(
                          future: promotionDelete(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return AlertDialog(
                              title: const Text("삭제 되었습니다."),
                              actions: [
                                TextButton(
                                  child: const Text("확인"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Get.find<ListController>().onInit();
                                    Get.back();
                                  },
                                )
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
