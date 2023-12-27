import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/model/sectors.dart';

class SectorsSearchScreen extends StatelessWidget {
  SectorsSearchScreen({super.key});

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(SearchController());
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            title: SizedBox(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  hintText: "검색어를 입력해주세요.",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (value) {
                  SearchController.to.changeSecrchText(value);
                },
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () {
                  return resultContainer();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget resultContainer() {
    if (SearchController.to.searchText.isEmpty) {
      return const Center(child: Text("검색어를 입력해주세요"));
    } else {
      return Center(
          child: serchSectorList(SearchController.to.searchText.value));
    }
  }

  serchSectorList(String search) async {
    var sectorsData = sectors;
    for (String mainSector in sectorsData.keys) {
      if (mainSector.contains(search)) {
        print(sectorsData[mainSector]);
        return Text(sectorsData[mainSector]);
      } else {
        return null;
      }
    }
  }
}

class SearchController extends GetxController {
  static SearchController get to => Get.find();
  RxString searchText = "".obs;
  void changeSecrchText(String text) {
    searchText.value = text;
  }
}
