import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/home_page.dart';
import 'package:jigu_firebase/screen/mypromotion_detail_screen.dart';

class MypromotionListScreen2 extends StatelessWidget {
  MypromotionListScreen2({super.key});
  final ListController listController = Get.put(ListController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("나의 홍보글 목록")),
        body: Obx(
          () {
            return FutureBuilder(
              future: listController.promotionList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.black54, height: 1),
                  itemBuilder: (context, index) {
                    Map<String, dynamic> promotionData =
                        snapshot.data![index].data();
                    String promotionId = snapshot.data![index].id;
                    return InkWell(
                      onTap: () => Get.to(() => MypromotionDetailScreen(),
                          arguments: [promotionData, promotionId]),
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promotionData["title"],
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              promotionData["body"],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ));
  }
}

class ListController extends GetxController {
  Future<RxList> promotionList() async {
    late List<QueryDocumentSnapshot<Map<String, dynamic>>> myPromotions;
    await db
        .collection("promotionPosts")
        .where("userId", isEqualTo: auth.currentUser!.uid)
        .orderBy("dataTime", descending: true)
        .get()
        .then((value) {
      myPromotions = value.docs;
    });
    return myPromotions.obs;
  }

  late List<QueryDocumentSnapshot<Map<String, dynamic>>> myPromotions;
}
