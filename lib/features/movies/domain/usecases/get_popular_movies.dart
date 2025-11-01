import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/movie.dart';
import '../repo/movie_interface_repo.dart';

class GetPopularMovies {
  final MovieRepository repository;
  GetPopularMovies(this.repository);

  Future<Either<Failure, List<Movie>>> call({int page = 1}) {
    return repository.getPopularMovies(page: page);
  }
}
