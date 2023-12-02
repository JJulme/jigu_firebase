// 국세청_사업자등록정보 진위확인 및 상태조회 서비스
// https://www.data.go.kr/data/15081808/openapi.do
import 'package:dio/dio.dart';

class NtsBusinessman {
  String key =
      "CmmFLY04oarFjECTh1yFbILHeLk1S7U%2FxkOTFlK4OZC9pw%2BebOe7tSvXMoH%2FdjkWtnZ0FnPiL%2Byy9p%2BzZtOodQ%3D%3D";
  BaseOptions options = BaseOptions(
      baseUrl:
          "http://api.odcloud.kr/api/nts-businessman/v1/validate?serviceKey=");
  Future<Map<String, dynamic>> postNts({
    required String taxId,
    required String name,
    required String opening,
  }) async {
    var data = {
      "businesses": [
        {
          "b_no": taxId,
          "start_dt": opening,
          "p_nm": name,
        }
      ]
    };
    Dio dio = Dio(options);
    try {
      Response response = await dio.post(key, data: data);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {"valid": false};
      }
    } catch (e) {
      Exception(e);
      return {"error": e};
    } finally {
      dio.close();
    }
  }
}
