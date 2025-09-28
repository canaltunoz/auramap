import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';

class ChartsService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> listMine() async {
    final res = await _dio.get('/charts');
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> create({required String name, required String birthDatetime, String? timezone}) async {
    final res = await _dio.post('/charts', data: {
      'name': name,
      'birthDatetime': birthDatetime,
      if (timezone != null) 'timezone': timezone,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }
}

