import 'package:dio/dio.dart';

class Net {
  Net._();

  static final dio = Dio();

  static Future<T> resDataByGet<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(headers: headers);
    final response = await dio.get(url, queryParameters: queryParameters, options: options);
    return response.data;
  }
}
