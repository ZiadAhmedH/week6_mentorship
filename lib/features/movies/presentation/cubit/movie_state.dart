import '../../domain/entities/page_movie.dart';

abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoadingMore extends MovieState {
  final PaginatedMovies current;
  MovieLoadingMore(this.current);
}

class MovieLoaded extends MovieState {
  final PaginatedMovies paginated;
  MovieLoaded(this.paginated);
}

class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
}
