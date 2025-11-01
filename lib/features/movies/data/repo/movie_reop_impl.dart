import 'package:dartz/dartz.dart';
import 'package:week6_task/core/errors/failure.dart';
import '../../domain/entities/movie.dart';

import '../../domain/repo/movie_interface_repo.dart';
import '../data_source/movie_local_source.dart';
import '../data_source/movie_remote_data_source.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remote;
  final MovieLocalDataSource local;

  MovieRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async {
    try {
      final cached = local.getCachedPage(page);
      if (cached != null && cached['results'] is List) {
        final list = (cached['results'] as List)
            .map(
              (e) => MovieModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ).toEntity(),
            )
            .toList();
        return Right(list);
      }

      final remoteJson = await remote.fetchPopular(page: page);
      await local.cachePage(page, remoteJson);

      final results = (remoteJson['results'] as List)
          .map(
            (e) => MovieModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity(),
          )
          .toList();
      return Right(results);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
