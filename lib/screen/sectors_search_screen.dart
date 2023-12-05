import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/screen/home_page.dart';

class SectorsSearchScreen extends StatelessWidget {
  SectorsSearchScreen({super.key});

  final TextEditingController _sectorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(SectorController());
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            title: SizedBox(
              child: TextField(
                controller: _sectorController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  hintText: "업종 설정",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (value) {
                  SectorController.to.changeSector(value);
                },
              ),
            ),
          ),
        ),
        body: Obx(
          () {
            var result = serchSectorList(SectorController.to.sector.value);
            return FutureBuilder(
              future: result,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class SectorController extends GetxController {
  static SectorController get to => Get.find();
  RxString sector = "".obs;
  void changeSector(String text) {
    sector.value = text;
  }
}

serchSectorList(String search) async {
  var result = db.collection("sectors").doc(search);
  return result;
}
