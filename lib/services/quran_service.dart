import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ayah.dart';

class QuranService {
  static Map<int, String> _surahNames = {};
  static final Map<int, List<Ayah>> _pageCache = {};
  static Map<String, dynamic>? _rawPages;

  static Future<void> _load() async {
    if (_rawPages != null) return;
    final json = await rootBundle.loadString('assets/data/quran.json');
    final data = jsonDecode(json) as Map<String, dynamic>;
    _surahNames = (data['surah_names'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(int.parse(k), v as String));
    _rawPages = data['pages'] as Map<String, dynamic>;
  }

  Future<List<Ayah>> fetchPage(int pageNumber) async {
    if (_pageCache.containsKey(pageNumber)) return _pageCache[pageNumber]!;
    await _load();
    final verses = _rawPages!['$pageNumber'] as List;
    final ayahs = verses.map((e) {
      final chapterId = e['chapter_id'] as int;
      return Ayah.fromPageJson(
        e as Map<String, dynamic>,
        _surahNames[chapterId] ?? '',
      );
    }).toList();
    _pageCache[pageNumber] = ayahs;
    return ayahs;
  }
}
