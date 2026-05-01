import 'ayah.dart';

class Surah {
  final int id;
  final String nameArabic;
  final String nameSimple;
  final int versesCount;
  List<Ayah> ayahs;

  Surah({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.versesCount,
    this.ayahs = const [],
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      nameArabic: json['name_arabic'] as String,
      nameSimple: json['name_simple'] as String,
      versesCount: json['verses_count'] as int,
    );
  }
}
