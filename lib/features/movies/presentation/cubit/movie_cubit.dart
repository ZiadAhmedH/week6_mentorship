import 'package:bloc/bloc.dart';
import '../../domain/usecases/movie_paginator.dart';
import 'movie_state.dart';
import '../../domain/entities/page_movie.dart';

class MovieCubit extends Cubit<MovieState> {
  final MoviePaginator paginator;
  MovieCubit({required this.paginator}) : super(MovieInitial());

  Future<void> loadInitial() async {
    emit(MovieLoading());
    paginator.reset();
    final res = await paginator.fetchNext();
    res.fold(
      (f) => emit(MovieError(f.message)),
      (paginated) => emit(MovieLoaded(paginated)),
    );
  }

  Future<void> loadMore() async {
    final currentPaginated = state is MovieLoaded
        ? (state as MovieLoaded).paginated
        : PaginatedMovies(
            page: paginator.currentPage,
            totalPages: paginator.totalPages,
            movies: paginator.items,
            isFromCache: false,
          );

    emit(MovieLoadingMore(currentPaginated));
    final res = await paginator.fetchNext();

    res.fold(
      (f) {
        final msg = f.message;
        // network error -> do not remove cached movies; if we have items, re-emit them as loaded with cache flag and show snackbar
        if (paginator.items.isNotEmpty) {
          emit(
            MovieLoaded(
              PaginatedMovies(
                page: paginator.currentPage,
                totalPages: paginator.totalPages,
                movies: paginator.items,
                isFromCache: true,
              ),
            ),
          );
          // transient message to be displayed as a snackbar
          emit(MovieMessage(msg));
        } else {
          // no cached items: show snackbar message and go back to initial (do not show a dedicated error screen)
          emit(MovieMessage(msg));
          emit(MovieInitial());
        }
      },
      (paginated) {
        emit(MovieLoaded(paginated));
      },
    );
  }

  void reset() {
    paginator.reset();
    emit(MovieInitial());
  }
}
