import 'movie.dart';

class PaginatedMovies {
  final int page;
  final int totalPages;
  final List<Movie> movies;

  PaginatedMovies({
    required this.page,
    required this.totalPages,
    required this.movies,
  });
}
