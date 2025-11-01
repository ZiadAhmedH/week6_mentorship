
import 'package:dio/dio.dart';

class MovieRemoteDataSource {
  final Dio client;

  MovieRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> fetchPopular({int page = 1}) async {
    final response = await client.get(
      '/3/discover/movie',
      queryParameters: {
        'include_adult': 'false',
        'include_video': 'false',
        'language': 'en-US',
        'page': page.toString(),
        'sort_by': 'popularity.desc',
      },
    );

    if (response.statusCode == 200) {
      return (response.data as Map).cast<String, dynamic>();
    } else {
      throw Exception('Remote error: ${response.statusCode}');
    }
  }
}
