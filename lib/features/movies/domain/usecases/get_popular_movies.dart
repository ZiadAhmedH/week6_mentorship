import 'package:dartz/dartz.dart';
import 'package:week6_task/features/movies/domain/entities/page_movie.dart';
import '../../../../core/errors/failure.dart';
import '../repo/movie_interface_repo.dart';

class GetPopularMovies {
  final MovieRepository repository;
  GetPopularMovies(this.repository);

  Future<Either<Failure, PaginatedMovies>> call({int page = 1}) {
    return repository.getPopularMovies(page: page);
  }
}
