import '../../domain/entities/movie.dart';

class MovieModel {
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

  MovieModel({
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

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      originalTitle: json['original_title'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
      popularity: (json['popularity'] as num?)?.toDouble(),
      adult: json['adult'] as bool?,
      video: json['video'] as bool?,
      originalLanguage: json['original_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'genre_ids': genreIds,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'popularity': popularity,
      'adult': adult,
      'video': video,
      'original_language': originalLanguage,
    };
  }

  // Mapper to domain entity (single responsibility preserved)
  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      originalTitle: originalTitle,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      genreIds: genreIds,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      popularity: popularity,
      adult: adult,
      video: video,
      originalLanguage: originalLanguage,
    );
  }
}
