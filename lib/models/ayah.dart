class Ayah {
  final int id;
  final int verseNumber;
  final String textUthmani;
  final int surahNumber;
  final String surahName;
  final int pageNumber;

  const Ayah({
    required this.id,
    required this.verseNumber,
    required this.textUthmani,
    required this.surahNumber,
    required this.surahName,
    required this.pageNumber,
  });

  factory Ayah.fromPageJson(Map<String, dynamic> json, String surahName) {
    return Ayah(
      id: json['id'] as int,
      verseNumber: json['verse_number'] as int,
      textUthmani: json['text_uthmani'] as String,
      surahNumber: json['chapter_id'] as int,
      surahName: surahName,
      pageNumber: json['page_number'] as int,
    );
  }

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      id: json['id'] as int,
      verseNumber: json['verse_number'] as int,
      textUthmani: json['text_uthmani'] as String,
      surahNumber: json['surah_number'] as int,
      surahName: json['surah_name'] as String,
      pageNumber: json['page_number'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'verse_number': verseNumber,
        'text_uthmani': textUthmani,
        'surah_number': surahNumber,
        'surah_name': surahName,
        'page_number': pageNumber,
      };
}
