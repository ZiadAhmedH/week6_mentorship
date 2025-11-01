import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/movie.dart';
import '../view/movie_details_view.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  static const _imageBase = 'https://image.tmdb.org/t/p/w342';

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MovieDetailsView(movie: movie)),
        );
      },
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: movie.posterPath != null
                  ? Hero(
                      tag: 'poster_${movie.id}',
                      child: CachedNetworkImage(
                        imageUrl: '$_imageBase${movie.posterPath}',
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (ctx, url, error) =>
                            const Center(child: Icon(Icons.broken_image)),
                      ),
                    )
                  : const Center(child: Icon(Icons.movie, size: 48)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (movie.voteAverage != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text((movie.voteAverage ?? 0).toStringAsFixed(1)),
                          ],
                        ),
                      const Spacer(),
                      Text(
                        movie.releaseDate ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
