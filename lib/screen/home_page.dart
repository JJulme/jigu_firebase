import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/login_page.dart';
import 'package:jigu_firebase/screen/mypromotion_list_screen.dart';
import 'package:jigu_firebase/screen/mypromotion_list_screen2.dart';
import 'package:jigu_firebase/screen/promotion_screen.dart';
import 'package:jigu_firebase/screen/signup_screen.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore db = FirebaseFirestore.instance;
String userId = auth.currentUser!.uid;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> user) {
        if (!user.hasData) {
          return LoginPage();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Firebase Home"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_outlined),
                  onPressed: () async {
                    await auth.signOut().then((_) => Get.toNamed("/login"));
                  },
                ),
              ],
            ),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("로그인 성공"),
                  Text(auth.currentUser!.email.toString()),
                  Text(auth.currentUser!.uid),
                  ElevatedButton(
                    onPressed: () {
                      final users = db.collection("users");
                      final promotionPosts = db.collection("promotionPosts");
                      final user = {
                        "userID": auth.currentUser!.uid,
                        "name": "jjulmezzz",
                        "address": "Seoul",
                        "age": 28,
                      };
                      final promotionPost = {
                        "title": "제목글",
                        "body": "안녕하세요",
                      };
                      users.doc(auth.currentUser!.uid).set(user);
                      promotionPosts
                          .doc(auth.currentUser!.uid)
                          .set(promotionPost);
                    },
                    child: const Text("data gogo"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final docRef =
                          db.collection("users").doc(auth.currentUser!.uid);
                      docRef.get().then((DocumentSnapshot doc) {
                        final data = doc.data();
                        print(data);
                      });
                      db
                          .collection("users")
                          .where("name", isEqualTo: "jjulme")
                          .get()
                          .then(
                        (value) {
                          print("데이터 가져오기");
                          for (var docSnapshot in value.docs) {
                            print("${docSnapshot.id}=> ${docSnapshot.data()}");
                          }
                          print(value.docs);
                        },
                      );
                    },
                    child: const Text("show data"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => PromotionScreen());
                    },
                    child: const Text("홍보글 작성"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => MypromotionListScreen());
                    },
                    child: const Text("나의 홍보글 리스트"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => MypromotionListScreen2());
                    },
                    child: const Text("나의 홍보글 리스트2"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => SignupScreen());
                    },
                    child: const Text("회원가입"),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
