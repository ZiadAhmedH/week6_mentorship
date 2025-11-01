import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:week6_task/core/errors/logger.dart';
import 'package:week6_task/core/errors/failure.dart';

import '../../domain/entities/page_movie.dart';
import '../../domain/repo/movie_interface_repo.dart';
import '../data_source/movie_local_source.dart';
import '../data_source/movie_remote_data_source.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remote;
  final MovieLocalDataSource local;
  final AppLogger logger;

  MovieRepositoryImpl({
    required this.remote,
    required this.local,
    required this.logger,
  });

  @override
  Future<Either<Failure, PaginatedMovies>> getPopularMovies({
    int page = 1,
  }) async {
    try {
      // 1) Try cache first (fresh)
      final cached = local.getCachedPage(page);
      if (cached != null && cached['results'] is List) {
        logger.info('MovieRepository: returning cached page $page (fresh)');
        final list = (cached['results'] as List)
            .map(
              (e) => MovieModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ).toEntity(),
            )
            .toList();
        final totalPages = (cached['total_pages'] as num?)?.toInt() ?? 1;
        return Right(
          PaginatedMovies(
            page: page,
            totalPages: totalPages,
            movies: list,
            isFromCache: true,
          ),
        );
      }

      // 2) No fresh cache -> fetch remote
      logger.info('MovieRepository: fetching page $page from network');
      final remoteJson = await remote.fetchPopular(page: page);
      await local.cachePage(page, remoteJson);
      logger.info('MovieRepository: cached page $page after network fetch');

      final results = (remoteJson['results'] as List)
          .map(
            (e) => MovieModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity(),
          )
          .toList();
      final totalPages = (remoteJson['total_pages'] as num?)?.toInt() ?? 1;
      return Right(
        PaginatedMovies(
          page: page,
          totalPages: totalPages,
          movies: results,
          isFromCache: false,
        ),
      );
    } on DioException catch (dioErr, stack) {
      logger.warn(
        'MovieRepository: network error while fetching page $page: ${dioErr.message}',
      );
      // try stale cache fallback (do not delete stale on network error)
      final fallback = local.getCachedPage(page, allowStale: true);
      if (fallback != null && fallback['results'] is List) {
        logger.info(
          'MovieRepository: returning stale cached page $page as fallback (network error)',
        );
        final list = (fallback['results'] as List)
            .map(
              (e) => MovieModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ).toEntity(),
            )
            .toList();
        final totalPages = (fallback['total_pages'] as num?)?.toInt() ?? 1;
        return Right(
          PaginatedMovies(
            page: page,
            totalPages: totalPages,
            movies: list,
            isFromCache: true,
          ),
        );
      }
      logger.error(
        'MovieRepository: network error with no cache fallback',
        error: dioErr,
        stackTrace: stack,
      );
      return Left(Failure('Network error: ${dioErr.message}'));
    } catch (e, stack) {
      logger.error(
        'MovieRepository: unexpected error: $e',
        error: e,
        stackTrace: stack,
      );
      final fallback = local.getCachedPage(page, allowStale: true);
      if (fallback != null && fallback['results'] is List) {
        logger.info(
          'MovieRepository: returning stale cached page $page as fallback (exception)',
        );
        final list = (fallback['results'] as List)
            .map(
              (e) => MovieModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ).toEntity(),
            )
            .toList();
        final totalPages = (fallback['total_pages'] as num?)?.toInt() ?? 1;
        return Right(
          PaginatedMovies(
            page: page,
            totalPages: totalPages,
            movies: list,
            isFromCache: true,
          ),
        );
      }
      return Left(Failure(e.toString()));
    }
  }
}
