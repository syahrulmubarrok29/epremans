import 'package:dio/dio.dart';

/// Abstraction for communicating with the Laravel backend.
/// Currently a skeleton setup for Phase 2.
class RemoteDataSource {
  RemoteDataSource(this._dio);

  // ignore: unused_field
  final Dio _dio;

  // Example skeleton method for future API integration.
  // Future<dynamic> fetchSomething() async {
  //   try {
  //     final response = await _dio.get('/api/v1/endpoint');
  //     return response.data;
  //   } on DioException catch (e) {
  //     // Parse and throw ServerException
  //     throw Exception(e.message);
  //   }
  // }
}
