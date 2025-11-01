import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/movies/data/data_source/movie_local_source.dart';
import '../features/movies/data/data_source/movie_remote_data_source.dart';
import '../features/movies/data/repo/movie_reop_impl.dart';
import '../features/movies/domain/usecases/movie_paginator.dart';
import '../features/movies/presentation/cubit/movie_cubit.dart';
import '../features/movies/domain/repo/movie_interface_repo.dart';
import 'errors/logger.dart';
import '../core/theme/cubit/theme_cubit.dart';

final sl = GetIt.instance;

final String _tmdbBearerToken = dotenv.env['TMDB_BEARER_TOKEN'] ?? '';

Future<void> init() async {
  // Hive
  await Hive.initFlutter();
  final box = await Hive.openBox('moviesBox');

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org',
      headers: {
        'Authorization': 'Bearer $_tmdbBearerToken',
        'accept': 'application/json',
      },
      receiveTimeout: Duration(milliseconds: 10000),
    ),
  );
  sl.registerLazySingleton(() => dio);

  // Register AppLogger
  sl.registerLazySingleton(() => AppLogger());

  // Data sources
  sl.registerLazySingleton(() => MovieRemoteDataSource(client: sl()));
  sl.registerLazySingleton(() => MovieLocalDataSource(box));

  // Repository (inject AppLogger)
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(remote: sl(), local: sl(), logger: sl()),
  );

  // Use case / paginator
  sl.registerLazySingleton(() => MoviePaginator(sl()));

  // Cubit now depends on paginator
  sl.registerFactory(() => MovieCubit(paginator: sl()));

  // Theme cubit
  sl.registerFactory(() => ThemeCubit());
}
