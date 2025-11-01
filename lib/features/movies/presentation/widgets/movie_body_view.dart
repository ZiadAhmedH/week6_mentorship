import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/movie_cubit.dart';
import '../cubit/movie_state.dart';
import '../../domain/entities/movie.dart';

class MovieBodyView extends StatefulWidget {
  const MovieBodyView({super.key});

  @override
  State<MovieBodyView> createState() => _MovieBodyViewState();
}

class _MovieBodyViewState extends State<MovieBodyView> {
  final ScrollController _scrollController = ScrollController();
  static const _imageBase = 'https://image.tmdb.org/t/p/w342';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final cubit = context.read<MovieCubit>();
    final state = cubit.state;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // only request loadMore when not already loading
      if (state is MovieLoaded || state is MovieError) {
        cubit.loadMore();
      }
      if (state is MovieLoadingMore) {
        // already loading more - skip
      }
    }
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<MovieCubit>();
    cubit.reset();
    await cubit.loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Widget _movieCard(Movie m) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: m.posterPath != null
                ? Image.network(
                    '$_imageBase${m.posterPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image)),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  )
                : const Center(child: Icon(Icons.movie, size: 48)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (m.voteAverage != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text((m.voteAverage ?? 0).toStringAsFixed(1)),
                        ],
                      ),
                    const Spacer(),
                    Text(
                      m.releaseDate ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        if (state is MovieLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MovieError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<MovieCubit>().loadInitial(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Loaded or loading more
        final List<Movie> movies;
        final bool isLoadingMore = state is MovieLoadingMore;
        if (state is MovieLoaded) {
          movies = state.movies;
        } else if (state is MovieLoadingMore) {
          movies = state.current;
        } else {
          movies = [];
        }

        if (movies.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(child: Text('No movies found')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: movies.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= movies.length) {
                // bottom loading indicator
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final m = movies[index];
              return _movieCard(m);
            },
          ),
        );
      },
    );
  }
}
