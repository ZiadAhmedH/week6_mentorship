import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/connectivity/connectivity_service.dart';
import '../cubit/movie_cubit.dart';
import '../cubit/movie_state.dart';
import '../../domain/entities/page_movie.dart';
import 'movie_card.dart'; // added import
import 'package:week6_task/core/service_locator.dart';

class MovieBodyView extends StatefulWidget {
  const MovieBodyView({super.key});

  @override
  State<MovieBodyView> createState() => _MovieBodyViewState();
}

class _MovieBodyViewState extends State<MovieBodyView> {
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription<bool> _connSub;
  bool _isOnline = true;

  // show transient banner when connectivity toggles (1 second)
  bool _showTransientBanner = false;
  Timer? _transientBannerTimer;

  // If service locator didn't provide ConnectivityService, keep a local one to clean up
  ConnectivityService? _localConn;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // listen connectivity changes (use DI instance if registered; otherwise create local)
    final conn = sl.isRegistered<ConnectivityService>()
        ? sl<ConnectivityService>()
        : (ConnectivityService()..initialize());
    if (!sl.isRegistered<ConnectivityService>()) {
      _localConn = conn;
    }
    _isOnline = conn.isOnline;
    _connSub = conn.onStatusChange.listen((online) {
      if (!mounted) return;

      // set online state and show transient banner
      setState(() {
        _isOnline = online;
        _showTransientBanner = true;
      });

      // cancel previous timer and schedule hide after 1 second
      _transientBannerTimer?.cancel();
      _transientBannerTimer = Timer(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _showTransientBanner = false);
      });

      final msg = online
          ? 'Back online — using network'
          : 'Offline — showing cached data';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1), // show snackbar only 1s
        ),
      );
    });
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
    _connSub.cancel();
    _transientBannerTimer?.cancel();
    // dispose local connectivity service if we created one here
    _localConn?.dispose();
    _scrollController.dispose();
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
          // decide banner:
          Widget statusBanner = const SizedBox.shrink();

          // Offline -> persistent amber banner
          if (!_isOnline) {
            statusBanner = Container(
              width: double.infinity,
              color: Colors.amberAccent,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Center(child: Text('Offline — showing cached data')),
            );

            // When online but paginated is from cache, show stale banner only transiently
          } else if ((paginated?.isFromCache ?? false) &&
              _showTransientBanner) {
            statusBanner = Container(
              width: double.infinity,
              color: Colors.blueGrey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Center(child: Text('Showing cached data (stale)')),
            );
          }

          // use statusBanner in the layout
          if (movies.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  statusBanner,
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
                statusBanner,
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
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
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
