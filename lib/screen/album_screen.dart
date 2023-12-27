import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jigu_firebase/model/album.dart';
import 'package:photo_manager/photo_manager.dart';

// 앨범에 이미지가 없을 경우 예외처리

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  // 모든 파일 정보
  List<AssetPathEntity>? _paths;
  // 드롭다운 앨범 목록
  List<Album> _albums = [];
  // 앨범의 이미지 목록
  late List<AssetEntity> _images;
  // 현재 페이지
  int _currentPage = 0;
  // 드롭다운 선택된 앨범
  late Album _currentAlbum;
  // 선택된 이미지 추가
  final _selectImages = [];

  // 파일 접근에 대한 권한 확인
  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  // 권한 확인
  Future<void> checkPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // 권한 수락 - 앨범 스크린 이동
      await getAlbum();
    } else {
      // 권한 거절 - 설정페이지 접근
      await PhotoManager.openSetting();
    }
  }

  // 앨범 목록 리스트 만들기
  Future<void> getAlbum() async {
    // 모든 이미지 파일의 경로를 불러오기
    _paths = await PhotoManager.getAssetPathList(type: RequestType.image);
    _albums = _paths!.map((e) {
      return Album(id: e.id, name: e.isAll ? "모든사진" : e.name);
    }).toList();
    await getPhotos(_albums[0], albumChange: true);
  }

  // 이미지 가져오기
  Future<void> getPhotos(Album album, {bool albumChange = false}) async {
    _currentAlbum = album;
    albumChange ? _currentPage = 0 : _currentPage++;
    final loadImages = await _paths!
        .singleWhere((AssetPathEntity e) => e.id == album.id)
        .getAssetListPaged(page: _currentPage, size: 20);
    setState(() {
      if (albumChange) {
        _images = loadImages;
      } else {
        _images.addAll(loadImages);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Get.back(result: _selectImages);
          },
        ),
        title: Container(
            child: _albums.isNotEmpty
                ? DropdownButton(
                    value: _currentAlbum,
                    items: _albums
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            ))
                        .toList(),
                    onChanged: (Album? value) =>
                        getPhotos(value!, albumChange: true),
                  )
                : const SizedBox()),
        actions: [
          TextButton(
            onPressed: () {
              if (_selectImages.isEmpty) {
                // Fluttertoast.showToast(
                //   msg: "선택된 사진이 없습니다.",
                //   toastLength: Toast.LENGTH_SHORT,
                // );
                Get.snackbar("Error", "선택된 사진이 없습니다.");
              } else {
                Get.back(result: _selectImages);
              }
            },
            child: const Text(
              "확인",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        // 경로가 비었다면 로딩, 경로 설정이 되었다면 이미지 보여줌
        child: _paths == null
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                // 이미지 개수 알려주기
                itemCount: _images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // 1개의 행에 보여줄 item 개수
                  crossAxisCount: 3,
                  //item의 가로 세로 비율
                  childAspectRatio: 1,
                ),
                // 앨범 내 이미지 보여줌
                itemBuilder: (context, index) {
                  // 이미지가 리스트에 있는지 확인, 기본값 false
                  bool selectCheck = !_selectImages.contains(_images[index]);
                  return InkWell(
                    // 눌렀을 때 실행
                    onTap: () {
                      setState(() {
                        // 이미지가 선택이 안된 상태 - 리스트에 추가
                        if (selectCheck) {
                          if (_selectImages.length == 5) {
                            // Fluttertoast.showToast(
                            //   msg: "사진은 최대 5개 선택 가능합니다.",
                            //   toastLength: Toast.LENGTH_SHORT,
                            // );
                            Get.snackbar("Error", "사진은 최대 5개 선택 가능합니다.");
                          } else {
                            _selectImages.add(_images[index]);
                          }
                        } else {
                          _selectImages.remove(_images[index]);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: selectCheck
                            ? Border.all()
                            : Border.all(
                                color: Colors.blue,
                                width: 5,
                              ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AssetEntityImage(
                            _images[index],
                            isOriginal: false,
                            fit: BoxFit.cover,
                          ),
                          selectCheck
                              ? const SizedBox()
                              : Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 3,
                                      ),
                                    ),
                                    child: Text(
                                      "${_selectImages.indexOf(_images[index]) + 1}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
