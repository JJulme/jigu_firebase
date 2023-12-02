// 공정거래위원회_통신판매사업자 등록현황 제공 조회 서비스
// https://www.data.go.kr/data/15112404/openapi.do
import 'package:dio/dio.dart';

void main(List<String> args) async {
  var data = await FtcBiz().getBiz("1283949844");
  print(data);
  // 결과가 0이면 없는 정보
  print(data["totalCount"]);
  // 주소 확인
  print(data["items"][0]["rnAddr"]);
  // 상호명 확인
  print(data["items"][0]["bzmnNm"]);
}

class FtcBiz {
  String key =
      "CmmFLY04oarFjECTh1yFbILHeLk1S7U%2FxkOTFlK4OZC9pw%2BebOe7tSvXMoH%2FdjkWtnZ0FnPiL%2Byy9p%2BzZtOodQ%3D%3D&pageNo=1&numOfRows=10&resultType=json&brno=";
  BaseOptions options = BaseOptions(
      baseUrl:
          "https://apis.data.go.kr/1130000/MllBs_1Service/getMllBsBiznoInfo_1?serviceKey=");
  getBiz(String taxId) async {
    Dio dio = Dio(options);
    try {
      Response response = await dio.get(key + taxId);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return false;
      }
    } catch (e) {
      Exception(e);
    } finally {
      dio.close();
    }
  }
}
