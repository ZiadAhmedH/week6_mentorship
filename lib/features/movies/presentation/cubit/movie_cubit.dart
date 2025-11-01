import 'package:bloc/bloc.dart';

import '../../domain/entities/page_movie.dart';
import '../../domain/usecases/movie_paginator.dart';
import 'movie_state.dart';

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
        : paginator.items.isNotEmpty
        ? PaginatedMovies(
            page: paginator.currentPage,
            totalPages: paginator.totalPages,
            movies: paginator.items,
            isFromCache: false,
          )
        : PaginatedMovies(
            page: 0,
            totalPages: 1,
            movies: [],
            isFromCache: false,
          );

    emit(MovieLoadingMore(currentPaginated));
    final res = await paginator.fetchNext();
    res.fold(
      (f) => emit(MovieError(f.message)),
      (paginated) => emit(MovieLoaded(paginated)),
    );
  }

  void reset() {
    paginator.reset();
    emit(MovieInitial());
  }
}
