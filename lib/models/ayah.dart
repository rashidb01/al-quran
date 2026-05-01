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
}
