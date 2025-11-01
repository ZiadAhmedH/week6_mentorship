import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/movie_cubit.dart';
import '../cubit/movie_state.dart';
import '../../domain/entities/page_movie.dart';
import 'movie_card.dart'; // added import

class MovieBodyView extends StatefulWidget {
  const MovieBodyView({super.key});

  @override
  State<MovieBodyView> createState() => _MovieBodyViewState();
}

class _MovieBodyViewState extends State<MovieBodyView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final cubit = BlocProvider.of<MovieCubit>(context);
    final state = cubit.state;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (state is MovieLoaded || state is MovieMessage) {
        cubit.loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    final cubit = BlocProvider.of<MovieCubit>(context);
    cubit.reset();
    await cubit.loadInitial();
  }

  @override
  void dispose() {
    _scrollController..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MovieCubit, MovieState>(
      listener: (context, state) {
        if (state is MovieMessage) {
          final snack = SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
        }
      },
      child: BlocBuilder<MovieCubit, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          PaginatedMovies? paginated;
          bool isLoadingMore = false;

          if (state is MovieLoaded) {
            paginated = state.paginated;
          } else if (state is MovieLoadingMore) {
            paginated = state.current;
            isLoadingMore = true;
          } else if (state is MovieMessage && state.paginated != null) {
            paginated = state.paginated;
          }

          final movies = paginated?.movies ?? [];

          final showCachedBanner = paginated?.isFromCache ?? false;

          if (movies.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (showCachedBanner)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: ColoredBox(
                          color: Colors.amberAccent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text('Offline — showing cached data'),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                  const Center(child: Text('No movies found')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                if (showCachedBanner)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: ColoredBox(
                        color: Colors.amberAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text('Offline — showing cached data'),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: movies.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= movies.length) {
                        return const Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        );
                      }
                      final m = movies[index];
                      return MovieCard(movie: m);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
