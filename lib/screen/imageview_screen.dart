import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageviewScreen extends StatelessWidget {
  ImageviewScreen({super.key});
  // 선택한 이미지의 인덱스를 가져옴
  var imageIndex = Get.arguments[0];
  // 전체 이미지의 목록을 가져옴
  List<dynamic> imageList = Get.arguments[1];

  @override
  Widget build(BuildContext context) {
    Get.put(ImgIndexController());
    ImgIndexController.to.changeIndex(Get.arguments[0]);
    return Scaffold(
      appBar: AppBar(
          // 상단 숫자 가운데 정렬
          centerTitle: true,
          // 앱바 배경 검은색으로 변경
          backgroundColor: Colors.black,
          // 이미지 전체 개수와 보고있는 순서 보여줌
          title: Obx(
            () => Text(
                "${ImgIndexController.to.imgIndex.value + 1}/${imageList.length}"),
          )),
      body: Container(
          child: Obx(
        () => PhotoViewGallery.builder(
          itemCount: imageList.length,
          pageController:
              PageController(initialPage: ImgIndexController.to.imgIndex.value),
          onPageChanged: (index) {
            ImgIndexController.to.changeIndex(index);
          },
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: AssetEntityImageProvider(imageList[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 1.8,
            );
          },
        ),
      )),
    );
  }
}

class ImgIndexController extends GetxController {
  static ImgIndexController get to => Get.find();
  RxInt imgIndex = 0.obs;
  void changeIndex(int index) {
    imgIndex.value = index;
  }
}
