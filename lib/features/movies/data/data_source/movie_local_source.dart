import 'dart:convert';
import 'package:hive/hive.dart';

class MovieLocalDataSource {
  final Box box;
  MovieLocalDataSource(this.box);

  String _key(int page) => 'popular_movies_page_$page';

  Future<void> cachePage(int page, Map<String, dynamic> payload) async {
    final wrapper = {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'data': payload,
    };
    await box.put(_key(page), json.encode(wrapper));
  }

  Map<String, dynamic>? getCachedPage(
    int page, {
    Duration maxAge = const Duration(hours: 1),
  }) {
    final raw = box.get(_key(page)) as String?;
    if (raw == null) return null;
    try {
      final Map<String, dynamic> stored =
          json.decode(raw) as Map<String, dynamic>;
      final ts = DateTime.parse(stored['timestamp'] as String);
      if (DateTime.now().toUtc().difference(ts) > maxAge) {
        box.delete(_key(page));
        return null;
      }
      return Map<String, dynamic>.from(stored['data'] as Map);
    } catch (_) {
      box.delete(_key(page));
      return null;
    }
  }
}
