import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ayah.dart';

class QuranService {
  static const _base = 'https://api.quran.com/api/v4';
  static const _headers = {'Accept': 'application/json'};

  // Кэш страниц
  static final Map<int, List<Ayah>> _pageCache = {};
  // Кэш названий сур (id -> nameArabic)
  static Map<int, String> _surahNames = {};

  Future<void> loadSurahNames() async {
    if (_surahNames.isNotEmpty) return;
    final res = await http.get(
      Uri.parse('$_base/chapters?language=ar'),
      headers: _headers,
    );
    if (res.statusCode != 200) return;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _surahNames = {
      for (final c in data['chapters'] as List)
        (c['id'] as int): c['name_arabic'] as String,
    };
  }

  Future<List<Ayah>> fetchPage(int pageNumber) async {
    if (_pageCache.containsKey(pageNumber)) return _pageCache[pageNumber]!;

    await loadSurahNames();

    final res = await http.get(
      Uri.parse(
          '$_base/verses/by_page/$pageNumber?translations=&fields=text_uthmani,chapter_id,verse_number,page_number&per_page=50'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Failed to load page $pageNumber');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final ayahs = (data['verses'] as List).map((e) {
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
