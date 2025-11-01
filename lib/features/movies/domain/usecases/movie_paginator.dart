// ...existing code...
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/movie.dart';
import '../entities/page_movie.dart';
import '../repo/movie_interface_repo.dart';

/// Keeps paging state outside the Cubit/UI.
/// Use fetchNext() to load next page; reset() to start over.
class MoviePaginator {
  final MovieRepository repository;

  int _currentPage = 0;
  int _totalPages = 1;
  final List<Movie> _items = [];
  bool _loading = false;

  MoviePaginator(this.repository);

  /// Fetch next page and append to internal list.
  /// Returns cumulative PaginatedMovies on success.
  Future<Either<Failure, PaginatedMovies>> fetchNext() async {
    if (_loading)
      return Right(
        PaginatedMovies(
          page: _currentPage,
          totalPages: _totalPages,
          movies: List.unmodifiable(_items),
        ),
      ); // avoid concurrent calls
    if (_currentPage >= _totalPages)
      return Right(
        PaginatedMovies(
          page: _currentPage,
          totalPages: _totalPages,
          movies: List.unmodifiable(_items),
        ),
      ); // no more pages

    _loading = true;
    final nextPage = _currentPage + 1;
    final Either<Failure, PaginatedMovies> res = (await repository
        .getPopularMovies(page: nextPage)) as Either<Failure, PaginatedMovies>;
    _loading = false;

    return res.fold((f) => Left(f), (paginated) {
      _currentPage = paginated.page;
      _totalPages = paginated.totalPages;
      _items.addAll(paginated.movies);
      return Right(
        PaginatedMovies(
          page: _currentPage,
          totalPages: _totalPages,
          movies: List.unmodifiable(_items),
        ),
      );
    });
  }

  /// Fetch a specific page (does not clear accumulated items by default).
  /// Returns cumulative PaginatedMovies on success.
  Future<Either<Failure, PaginatedMovies>> fetchPage(
    int page, {
    bool clearBefore = false,
  }) async {
    if (_loading)
      return Right(
        PaginatedMovies(
          page: _currentPage,
          totalPages: _totalPages,
          movies: List.unmodifiable(_items),
        ),
      );
    _loading = true;
    final Either<Failure, PaginatedMovies> res = (await repository
        .getPopularMovies(page: page)) as Either<Failure, PaginatedMovies>;
    _loading = false;

    return res.fold((f) => Left(f), (paginated) {
      _currentPage = paginated.page;
      _totalPages = paginated.totalPages;
      if (clearBefore) {
        _items
          ..clear()
          ..addAll(paginated.movies);
      } else {
        _items.addAll(paginated.movies);
      }
      return Right(
        PaginatedMovies(
          page: _currentPage,
          totalPages: _totalPages,
          movies: List.unmodifiable(_items),
        ),
      );
    });
  }

  void reset() {
    _currentPage = 0;
    _totalPages = 1;
    _items.clear();
  }

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  List<Movie> get items => List.unmodifiable(_items);
}
