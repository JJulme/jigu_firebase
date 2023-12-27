import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/sectors_search_screen.dart';

class MypageBasicInfoScreen extends StatelessWidget {
  MypageBasicInfoScreen({super.key});

  final TextEditingController _bizNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              TextFormField(
                controller: _bizNameController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 17,
                  ),
                  hintText: "상호명 설정",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      readOnly: true,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 17,
                        ),
                        hintText: "업종 설정",
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Get.to(() => SectorsSearchScreen());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: TextFormField(
                      readOnly: true,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 17,
                        ),
                        hintText: "동네 설정",
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
