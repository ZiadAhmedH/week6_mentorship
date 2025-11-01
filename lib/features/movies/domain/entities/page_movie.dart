import 'movie.dart';

class PaginatedMovies {
  final int page;
  final int totalPages;
  final List<Movie> movies;
  final bool isFromCache;

  PaginatedMovies({
    required this.page,
    required this.totalPages,
    required this.movies,
    this.isFromCache = false,
  });
}
