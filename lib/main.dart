import 'package:firebase_core/firebase_core.dart';
import 'package:jigu_firebase/screen/home_screen2.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/login_page.dart';
import 'package:jigu_firebase/screen/signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Flutter Demo",
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => HomeScreen2()),
        GetPage(name: "/login", page: () => LoginPage()),
        GetPage(name: "/signup", page: () => const SignupPage()),
      ],
    );
  }
}
