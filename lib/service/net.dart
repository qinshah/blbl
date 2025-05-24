import 'package:dio/dio.dart';

class Net {
  Net._();

  static final dio = Dio();

  static Future<T> get<T>(
    String url,
  ) async {
    final response = await dio.get(url);
    return response.data;
  }
}
