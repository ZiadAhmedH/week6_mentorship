import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1});
}
