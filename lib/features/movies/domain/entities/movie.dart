class Movie {
  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<int>? genreIds;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final bool? adult;
  final bool? video;
  final String? originalLanguage;

  Movie({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.genreIds,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.adult,
    this.video,
    this.originalLanguage,
  });
}
