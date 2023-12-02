import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/home_page.dart';
import 'package:jigu_firebase/screen/mypromotion_detail_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_list_screen2.dart';

class MypromotionListScreen extends StatelessWidget {
  MypromotionListScreen({super.key});
  final Future<QuerySnapshot<Map<String, dynamic>>> promotionList = db
      .collection("promotionPosts")
      .where("userId", isEqualTo: userId)
      .orderBy("dataTime", descending: true)
      .get();
  // final Rx<Future<QuerySnapshot<Map<String, dynamic>>>> promotionList = db
  // .collection("promotionPosts")
  // .where("userId", isEqualTo: auth.currentUser!.uid)
  // .orderBy("dataTime", descending: true)
  // .get().obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("나의 홍보글 목록"),
        actions: [
          IconButton(
            onPressed: () {
              var myPromotions = ListController().promotionList();
              print(myPromotions);
            },
            icon: const Icon(Icons.abc),
          )
        ],
      ),
      body: FutureBuilder(
        future: promotionList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.black54, height: 1),
            itemBuilder: (context, index) {
              Map<String, dynamic> promotionData =
                  snapshot.data!.docs[index].data();
              String promotionId = snapshot.data!.docs[index].id;
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
      ),
    );
  }
}
