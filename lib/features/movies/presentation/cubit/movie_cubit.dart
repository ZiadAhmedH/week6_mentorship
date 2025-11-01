import 'package:bloc/bloc.dart';

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
      (list) => emit(MovieLoaded(list.movies)),
    );
  }

  Future<void> loadMore() async {
    // Cubit does not implement how paging works — it just asks paginator for next chunk.
    emit(
      MovieLoadingMore(
        state is MovieLoaded ? (state as MovieLoaded).movies : [],
      ),
    );
    final res = await paginator.fetchNext();
    res.fold(
      (f) => emit(MovieError(f.message)),
      (list) => emit(MovieLoaded(list.movies)),
    );
  }

  // optional: expose reset
  void reset() {
    paginator.reset();
    emit(MovieInitial());
  }
}
