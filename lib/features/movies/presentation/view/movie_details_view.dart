import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/movie.dart';

class MovieDetailsView extends StatefulWidget {
  final Movie movie;
  static const _imageBase = 'https://image.tmdb.org/t/p/';

  const MovieDetailsView({super.key, required this.movie});

  @override
  State<MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<MovieDetailsView> {
  bool _expandedOverview = false;

  Widget _buildMetaRow() {
    return Row(
      children: [
        if (widget.movie.voteAverage != null)
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                (widget.movie.voteAverage ?? 0).toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.movie.voteCount ?? 0})',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        const Spacer(),
        Text(
          widget.movie.releaseDate ?? '-',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final backdropUrl = movie.backdropPath != null
        ? '${MovieDetailsView._imageBase}w780${movie.backdropPath}'
        : null;
    final posterUrl = movie.posterPath != null
        ? '${MovieDetailsView._imageBase}w342${movie.posterPath}'
        : null;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                title: innerBoxIsScrolled
                    ? Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backdropUrl != null)
                        Hero(
                          tag: 'backdrop_${movie.id}',
                          child: CachedNetworkImage(
                            imageUrl: backdropUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.black12),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.black12,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.transparent,
                              Colors.black.withOpacity(0.25),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(blurRadius: 6, color: Colors.black26),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster + quick info card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: posterUrl != null
                          ? Hero(
                              tag: 'poster_${movie.id}',
                              child: CachedNetworkImage(
                                imageUrl: posterUrl,
                                width: 110,
                                height: 165,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 110,
                                  height: 165,
                                  color: Colors.grey.shade200,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 110,
                                  height: 165,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            )
                          : Container(
                              width: 110,
                              height: 165,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.movie),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.originalTitle ?? movie.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildMetaRow(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Play trailer (not implemented)'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play Trailer'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 36),
                                ),
                              ),
                                    ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 14),

                Text('Overview',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                AnimatedCrossFade(
                  firstChild: Text(
                    movie.overview ?? 'No overview available.',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  secondChild: Text(
                    movie.overview ?? 'No overview available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  crossFadeState: _expandedOverview
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _expandedOverview = !_expandedOverview),
                    child: Text(_expandedOverview ? 'Show less' : 'Read more'),
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(),

                Row(
                  children: [
                    Icon(Icons.language, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      movie.originalLanguage ?? '-',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    if (movie.adult == true)
                      Chip(
                        label: const Text('18+'),
                        backgroundColor: Colors.red.shade100,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Popularity: ${movie.popularity?.toStringAsFixed(1) ?? '-'}',
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.how_to_reg, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Votes: ${movie.voteCount ?? 0}'),
                  ],
                ),

                const SizedBox(height: 20),

                Text('Cast & Crew',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => _buildCastPlaceholder(i),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: 6,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCastPlaceholder(int index) {
    return SizedBox(
      width: 82,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Actor ${index + 1}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
