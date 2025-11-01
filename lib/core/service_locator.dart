import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/movies/data/data_source/movie_local_source.dart';
import '../features/movies/data/data_source/movie_remote_data_source.dart';
import '../features/movies/data/repo/movie_reop_impl.dart';
import '../features/movies/domain/usecases/movie_paginator.dart';
import '../features/movies/presentation/cubit/movie_cubit.dart';
import '../features/movies/presentation/cubit/movie_state.dart';
import '../features/movies/domain/repo/movie_interface_repo.dart';
import '../features/movies/domain/usecases/get_popular_movies.dart';

final sl = GetIt.instance;

const String _tmdbBearerToken = '<<access_token>>'; // replace with real token

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
      connectTimeout: Duration(milliseconds: 10000),
      receiveTimeout: Duration(milliseconds: 10000),
    ),
  );
  sl.registerLazySingleton(() => dio);

  // Data sources
  sl.registerLazySingleton(() => MovieRemoteDataSource(client: sl()));
  sl.registerLazySingleton(() => MovieLocalDataSource(box));

  // Repository (returns PaginatedMovies)
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(remote: sl(), local: sl()),
  );

  // Use case / paginator
  sl.registerLazySingleton(() => MoviePaginator(sl()));

  // Cubit now depends on paginator
  sl.registerFactory(() => MovieCubit(paginator: sl()));
}
