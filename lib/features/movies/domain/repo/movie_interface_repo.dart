import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/page_movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, PaginatedMovies>> getPopularMovies({int page = 1});
}
