import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ayah.dart';
import '../providers/app_state.dart';
import '../theme.dart';

// ─── Juz by page (Medina standard) ───────────────────────────────────────────
int _juzForPage(int page) {
  const starts = [
    1, 22, 42, 62, 82, 102, 121, 142, 162, 182,
    201, 221, 241, 261, 281, 301, 321, 341, 361, 381,
    401, 421, 441, 461, 481, 501, 521, 541, 561, 581,
  ];
  int juz = 1;
  for (int i = 0; i < starts.length; i++) {
    if (page >= starts[i]) juz = i + 1;
  }
  return juz;
}

bool _isSpecialPage(int page) => page == 1 || page == 2;

const _pageColor = Color(0xFFF9F7F2);

// ─── Main viewer ─────────────────────────────────────────────────────────────
class QuranViewerScreen extends StatefulWidget {
  const QuranViewerScreen({super.key});

  @override
  State<QuranViewerScreen> createState() => _QuranViewerScreenState();
}

class _QuranViewerScreenState extends State<QuranViewerScreen> {
  late final PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // Устанавливаем initialPage: 0, чтобы при reverse: true 
    // приложение открывалось на 1-й странице (которая будет справа)
    _pageController = PageController(initialPage: 0); 
    WidgetsBinding.instance.addPostFrameCallback((_) => _preload(1));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _preload(int page) {
    final state = context.read<AppState>();
    for (int p = page; p <= (page + 1).clamp(1, 604); p++) {
      state.loadPage(p);
    }
  }

  void _onPageChanged(int index) {
    // При reverse: true и начальном индексе 0, 
    // страница вычисляется просто как индекс + 1
    final page = index + 1;
    setState(() => _currentPage = page);
    _preload(page);
  }

  void _goToPage(int page) {
    // Переходим на индекс страницы (номер - 1)
    _pageController.jumpToPage(page - 1);
    setState(() => _currentPage = page);
    _preload(page);
  }

  void _showSurahPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SurahPickerSheet(onSelect: (page) {
        Navigator.pop(ctx);
        _goToPage(page);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final isDark = state.isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.quranPage(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(isDark),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: AppTheme.tertiary(isDark),
          ),
          onPressed: () => context.read<AppState>().toggleDarkMode(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book_rounded,
                color: AppTheme.tertiary(isDark), size: 20),
            onPressed: () => _showSurahPicker(context),
          ),
        ],
        centerTitle: true,
        title: Text(
          '$_currentPage',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.tertiary(isDark),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider(isDark)),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 604,
        // reverse: true обеспечивает движение страниц справа налево[cite: 1]
        reverse: true, 
        onPageChanged: _onPageChanged,
        // Передаем корректный номер страницы для отображения контента[cite: 1]
        itemBuilder: (ctx, index) => _QuranPage(pageNumber: index + 1),
      ),
      bottomNavigationBar: state.selectedAyahs.isNotEmpty
          ? SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bg(isDark),
                    border: Border(
                        top: BorderSide(color: AppTheme.divider(isDark))),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 11, color: AppTheme.tertiary(isDark)),
                      const SizedBox(width: 6),
                      Text(
                        'Таңдалған (${state.selectedAyahs.length})',
                        style: TextStyle(
                            fontSize: 15, color: AppTheme.secondary(isDark)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// ─── One mushaf page ──────────────────────────────────────────────────────────
class _QuranPage extends StatefulWidget {
  final int pageNumber;
  const _QuranPage({required this.pageNumber});

  @override
  State<_QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<_QuranPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().loadPage(widget.pageNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ayahs = state.getPage(widget.pageNumber);
    final isLoading = state.isPageLoading(widget.pageNumber);

    final isDark = state.isDarkMode;

    if (isLoading || ayahs == null) {
      return Center(
        child: CircularProgressIndicator(
            color: AppTheme.tertiary(isDark), strokeWidth: 1.5),
      );
    }

    final juz = _juzForPage(widget.pageNumber);
    final firstSurahArabic = ayahs.isNotEmpty ? ayahs.first.surahName : '';
    final firstSurahKazakh = _surahPages
            .where((s) => s.arabic == firstSurahArabic)
            .firstOrNull
            ?.kazakh ??
        '';

    return Container(
      color: AppTheme.quranPage(isDark),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
            child: Row(
              children: [
                Text('джуз $juz',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.tertiary(isDark))),
                const Spacer(),
                Text('$firstSurahKazakh  ',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.tertiary(isDark))),
                Text(
                  firstSurahArabic,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 14,
                    color: AppTheme.tertiary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: AppTheme.divider(isDark)),
          Expanded(
            child: _isSpecialPage(widget.pageNumber)
                ? _SpecialPageContent(ayahs: ayahs, pageNumber: widget.pageNumber, isDark: isDark)
                : _LinesContainer(ayahs: ayahs, isDark: isDark),
          ),
          Container(height: 0.5, color: AppTheme.divider(isDark)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '${widget.pageNumber}',
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 15,
                color: AppTheme.secondary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lines container (quran.com style) ───────────────────────────────────────
class _LinesContainer extends StatelessWidget {
  final List<Ayah> ayahs;
  final bool isDark;
  const _LinesContainer({required this.ayahs, required this.isDark});

  String _toArabicNum(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final groups = <_AyahGroup>[];
    int? lastSurah;
    List<Ayah> cur = [];

    void flush(String name) {
      if (cur.isEmpty) return;
      groups.add(_AyahGroup(surahName: name, ayahs: List.from(cur)));
      cur = [];
    }

    String lastName = '';
    for (final ayah in ayahs) {
      if (ayah.surahNumber != lastSurah) {
        flush(lastName);
        lastSurah = ayah.surahNumber;
        lastName = ayah.surahName;
      }
      cur.add(ayah);
    }
    flush(lastName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int gi = 0; gi < groups.length; gi++) ...[
              if (gi > 0) _MidPageBanner(surahName: groups[gi].surahName, isDark: isDark),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text.rich(
                  TextSpan(
                    children: [
                      for (var ayah in groups[gi].ayahs) ...[
                        TextSpan(
                          text: ayah.textUthmani,
                          style: TextStyle(
                            fontFamily: 'ScheherazadeNew',
                            fontSize: 24,
                            height: 2.2,
                            color: AppTheme.quranText(isDark),
                            backgroundColor: state.selectedAyahIds.contains(ayah.id)
                                ? AppTheme.selected(isDark)
                                : Colors.transparent,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.read<AppState>().toggleAyah(ayah),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () => context.read<AppState>().toggleAyah(ayah),
                            child: _VerseMarker(
                              number: ayah.verseNumber,
                              toArabic: _toArabicNum,
                              selected: state.selectedAyahIds.contains(ayah.id),
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AyahGroup {
  final String surahName;
  final List<Ayah> ayahs;
  const _AyahGroup({required this.surahName, required this.ayahs});
}

// ─── Ornamental verse-end marker ─────────────────────────────────────────────
class _VerseMarker extends StatelessWidget {
  final int number;
  final String Function(int) toArabic;
  final bool selected;
  final bool isDark;
  const _VerseMarker(
      {required this.number,
      required this.toArabic,
      required this.selected,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? const Color(0xFFB8A060) : const Color(0xFF8B6914);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        toArabic(number),
        style: TextStyle(
          fontFamily: 'ScheherazadeNew',
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Mid-page surah banner ────────────────────────────────────────────────────
class _MidPageBanner extends StatelessWidget {
  final String surahName;
  final bool isDark;
  const _MidPageBanner({required this.surahName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            surahName,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 22,
              color: AppTheme.quranText(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 16,
              color: AppTheme.secondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Special pages 1 & 2 ─────────────────────────────────────────────────────
class _SpecialPageContent extends StatelessWidget {
  final List<Ayah> ayahs;
  final int pageNumber;
  final bool isDark;
  const _SpecialPageContent(
      {required this.ayahs, required this.pageNumber, required this.isDark});

  String _toArabicNum(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final surahName = ayahs.isNotEmpty ? ayahs.first.surahName : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      child: Column(
        children: [
          Column(
            children: [
              Text(
                surahName,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 26,
                  color: AppTheme.quranText(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 18,
                  color: AppTheme.secondary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...ayahs.map((ayah) {
            final sel = state.selectedAyahIds.contains(ayah.id);
            return GestureDetector(
              onTap: () => context.read<AppState>().toggleAyah(ayah),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.selected(isDark) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    Flexible(
                      child: Text(
                        ayah.textUthmani,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ScheherazadeNew',
                          fontSize: 28,
                          height: 2.4,
                          color: AppTheme.quranText(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _VerseMarker(
                      number: ayah.verseNumber,
                      toArabic: _toArabicNum,
                      selected: sel,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Surah list ───────────────────────────────────────────────────────────────
const List<({int surah, String arabic, String kazakh, int page})>
    _surahPages = [
  (surah: 1, arabic: 'الفاتحة', kazakh: 'Аль-Фатиха', page: 1),
  (surah: 2, arabic: 'البقرة', kazakh: 'Аль-Бакара', page: 2),
  (surah: 3, arabic: 'آل عمران', kazakh: 'Әли Имран', page: 50),
  (surah: 4, arabic: 'النساء', kazakh: 'Ан-Ниса', page: 77),
  (surah: 5, arabic: 'المائدة', kazakh: 'Аль-Мәида', page: 106),
  (surah: 6, arabic: 'الأنعام', kazakh: 'Аль-Анғам', page: 128),
  (surah: 7, arabic: 'الأعراف', kazakh: 'Аль-Ағраф', page: 151),
  (surah: 8, arabic: 'الأنفال', kazakh: 'Аль-Анфал', page: 177),
  (surah: 9, arabic: 'التوبة', kazakh: 'Ат-Тәуба', page: 187),
  (surah: 10, arabic: 'يونس', kazakh: 'Юнус', page: 208),
  (surah: 11, arabic: 'هود', kazakh: 'Худ', page: 221),
  (surah: 12, arabic: 'يوسف', kazakh: 'Жүсіп', page: 235),
  (surah: 13, arabic: 'الرعد', kazakh: 'Ар-Ражд', page: 249),
  (surah: 14, arabic: 'إبراهيم', kazakh: 'Ибраhим', page: 255),
  (surah: 15, arabic: 'الحجر', kazakh: 'Аль-Хижр', page: 262),
  (surah: 16, arabic: 'النحل', kazakh: 'Ан-Нахл', page: 267),
  (surah: 17, arabic: 'الإسراء', kazakh: 'Аль-Исра', page: 282),
  (surah: 18, arabic: 'الكهф', kazakh: 'Аль-Кахф', page: 293),
  (surah: 19, arabic: 'مريم', kazakh: 'Марьям', page: 305),
  (surah: 20, arabic: 'طه', kazakh: 'Таха', page: 312),
  (surah: 21, arabic: 'الأنبياء', kazakh: 'Аль-Анбия', page: 322),
  (surah: 22, arabic: 'الحج', kazakh: 'Аль-Хаж', page: 332),
  (surah: 23, arabic: 'المؤمنون', kazakh: 'Аль-Мүминун', page: 342),
  (surah: 24, arabic: 'النور', kazakh: 'Ан-Нур', page: 350),
  (surah: 25, arabic: 'الفرقان', kazakh: 'Аль-Фурқан', page: 359),
  (surah: 26, arabic: 'الشعراء', kazakh: 'Аш-Шуара', page: 367),
  (surah: 27, arabic: 'النمل', kazakh: 'Ан-Намл', page: 377),
  (surah: 28, arabic: 'القصص', kazakh: 'Аль-Қасас', page: 385),
  (surah: 29, arabic: 'العنكبوت', kazakh: 'Аль-Анкабут', page: 396),
  (surah: 30, arabic: 'الروم', kazakh: 'Ар-Рум', page: 404),
  (surah: 31, arabic: 'لقمان', kazakh: 'Луқман', page: 411),
  (surah: 32, arabic: 'السجدة', kazakh: 'Ас-Сажда', page: 415),
  (surah: 33, arabic: 'الأحزاب', kazakh: 'Аль-Ахзаб', page: 418),
  (surah: 34, arabic: 'سبإ', kazakh: 'Саба', page: 428),
  (surah: 35, arabic: 'فاطر', kazakh: 'Фатыр', page: 434),
  (surah: 36, arabic: 'يس', kazakh: 'Ясин', page: 440),
  (surah: 37, arabic: 'الصافات', kazakh: 'Ас-Саффат', page: 446),
  (surah: 38, arabic: 'ص', kazakh: 'Сад', page: 453),
  (surah: 39, arabic: 'الزمر', kazakh: 'Аз-Зумар', page: 458),
  (surah: 40, arabic: 'غافر', kazakh: 'Ғафир', page: 467),
  (surah: 41, arabic: 'فصلत', kazakh: 'Фуссылат', page: 477),
  (surah: 42, arabic: 'الشورى', kazakh: 'Аш-Шура', page: 483),
  (surah: 43, arabic: 'الزخرف', kazakh: 'Аз-Зухруф', page: 489),
  (surah: 44, arabic: 'الدخان', kazakh: 'Ад-Духан', page: 496),
  (surah: 45, arabic: 'الجاثية', kazakh: 'Аль-Жасия', page: 499),
  (surah: 46, arabic: 'الأحقاف', kazakh: 'Аль-Ахқаф', page: 502),
  (surah: 47, arabic: 'محمد', kazakh: 'Мухаммад', page: 507),
  (surah: 48, arabic: 'الفتح', kazakh: 'Аль-Фатх', page: 511),
  (surah: 49, arabic: 'الحجرات', kazakh: 'Аль-Хужурат', page: 515),
  (surah: 50, arabic: 'ق', kazakh: 'Қаф', page: 518),
  (surah: 51, arabic: 'الذاريات', kazakh: 'Аз-Зарият', page: 520),
  (surah: 52, arabic: 'الطور', kazakh: 'Ат-Тур', page: 523),
  (surah: 53, arabic: 'النجم', kazakh: 'Ан-Нажм', page: 526),
  (surah: 54, arabic: 'القمر', kazakh: 'Аль-Қамар', page: 528),
  (surah: 55, arabic: 'الرحمن', kazakh: 'Ар-Рахман', page: 531),
  (surah: 56, arabic: 'الواقعة', kazakh: 'Аль-Уақиа', page: 534),
  (surah: 57, arabic: 'الحديد', kazakh: 'Аль-Хадид', page: 537),
  (surah: 58, arabic: 'المجادلة', kazakh: 'Аль-Мужадала', page: 542),
  (surah: 59, arabic: 'الحشر', kazakh: 'Аль-Хашр', page: 545),
  (surah: 60, arabic: 'المмтахна', kazakh: 'Аль-Мумтахина', page: 549),
  (surah: 61, arabic: 'الصف', kazakh: 'Ас-Саф', page: 551),
  (surah: 62, arabic: 'الجمعة', kazakh: 'Аль-Жұма', page: 553),
  (surah: 63, arabic: 'المнафиқун', kazakh: 'Аль-Мунафиқун', page: 554),
  (surah: 64, arabic: 'التغابن', kazakh: 'Ат-Тағабун', page: 556),
  (surah: 65, arabic: 'الطلاق', kazakh: 'Ат-Талақ', page: 558),
  (surah: 66, arabic: 'التحريم', kazakh: 'Ат-Тахрим', page: 560),
  (surah: 67, arabic: 'الملк', kazakh: 'Аль-Мүлк', page: 562),
  (surah: 68, arabic: 'القلم', kazakh: 'Аль-Қалам', page: 564),
  (surah: 69, arabic: 'الحاقة', kazakh: 'Аль-Хаққа', page: 566),
  (surah: 70, arabic: 'المعارج', kazakh: 'Аль-Мағариж', page: 568),
  (surah: 71, arabic: 'نوح', kazakh: 'Нух', page: 570),
  (surah: 72, arabic: 'الجن', kazakh: 'Аль-Жын', page: 572),
  (surah: 73, arabic: 'المزمل', kazakh: 'Аль-Муззаммил', page: 574),
  (surah: 74, arabic: 'المدثر', kazakh: 'Аль-Муддасир', page: 575),
  (surah: 75, arabic: 'القيامة', kazakh: 'Аль-Қиямет', page: 577),
  (surah: 76, arabic: 'الإنسان', kazakh: 'Аль-Инсан', page: 578),
  (surah: 77, arabic: 'المرسلات', kazakh: 'Аль-Мурсалат', page: 580),
  (surah: 78, arabic: 'النبأ', kazakh: 'Ан-Наба', page: 582),
  (surah: 79, arabic: 'الназиғат', kazakh: 'Ан-Назиғат', page: 583),
  (surah: 80, arabic: 'عبس', kazakh: 'Абаса', page: 585),
  (surah: 81, arabic: 'التكوير', kazakh: 'Ат-Таквир', page: 586),
  (surah: 82, arabic: 'الинфитар', kazakh: 'Аль-Инфитар', page: 587),
  (surah: 83, arabic: 'المطففين', kazakh: 'Аль-Мутаффифин', page: 587),
  (surah: 84, arabic: 'الإنшиқақ', kazakh: 'Аль-Иншиқақ', page: 589),
  (surah: 85, arabic: 'البروج', kazakh: 'Аль-Бурудж', page: 590),
  (surah: 86, arabic: 'الطارق', kazakh: 'Ат-Тарық', page: 591),
  (surah: 87, arabic: 'الأعلى', kazakh: 'Аль-Ағла', page: 591),
  (surah: 88, arabic: 'الغاشية', kazakh: 'Аль-Ғашия', page: 592),
  (surah: 89, arabic: 'الفجر', kazakh: 'Аль-Фажр', page: 593),
  (surah: 90, arabic: 'البلд', kazakh: 'Аль-Балад', page: 594),
  (surah: 91, arabic: 'الشمس', kazakh: 'Аш-Шамс', page: 595),
  (surah: 92, arabic: 'الليل', kazakh: 'Аль-Ләйл', page: 595),
  (surah: 93, arabic: 'الضحى', kazakh: 'Ад-Духа', page: 596),
  (surah: 94, arabic: 'الشرح', kazakh: 'Аль-Инширах', page: 596),
  (surah: 95, arabic: 'التين', kazakh: 'Ат-Тин', page: 597),
  (surah: 96, arabic: 'العلق', kazakh: 'Аль-Алақ', page: 597),
  (surah: 97, arabic: 'القدر', kazakh: 'Аль-Қадр', page: 598),
  (surah: 98, arabic: 'البينة', kazakh: 'Аль-Баййина', page: 598),
  (surah: 99, arabic: 'الزلзле', kazakh: 'Аз-Зилзал', page: 599),
  (surah: 100, arabic: 'العاديات', kazakh: 'Аль-Адият', page: 599),
  (surah: 101, arabic: 'القارعة', kazakh: 'Аль-Қариа', page: 600),
  (surah: 102, arabic: 'التكاثر', kazakh: 'Ат-Такасур', page: 600),
  (surah: 103, arabic: 'العصر', kazakh: 'Аль-Аср', page: 601),
  (surah: 104, arabic: 'الهمزة', kazakh: 'Аль-Хумаза', page: 601),
  (surah: 105, arabic: 'الفيل', kazakh: 'Аль-Фил', page: 601),
  (surah: 106, arabic: 'قريش', kazakh: 'Қурайш', page: 602),
  (surah: 107, arabic: 'الماعون', kazakh: 'Аль-Мағун', page: 602),
  (surah: 108, arabic: 'الكوثر', kazakh: 'Аль-Кәусар', page: 602),
  (surah: 109, arabic: 'الكافرون', kazakh: 'Аль-Кафирун', page: 603),
  (surah: 110, arabic: 'النصر', kazakh: 'Ан-Наср', page: 603),
  (surah: 111, arabic: 'المسд', kazakh: 'Аль-Масад', page: 603),
  (surah: 112, arabic: 'الإخلاص', kazakh: 'Аль-Ихлас', page: 604),
  (surah: 113, arabic: 'الفلق', kazakh: 'Аль-Фалақ', page: 604),
  (surah: 114, arabic: 'الناس', kazakh: 'Ан-Нас', page: 604),
];

// ─── Surah picker bottom sheet ────────────────────────────────────────────────
class _SurahPickerSheet extends StatefulWidget {
  final void Function(int page) onSelect;
  const _SurahPickerSheet({required this.onSelect});

  @override
  State<_SurahPickerSheet> createState() => _SurahPickerSheetState();
}

class _SurahPickerSheetState extends State<_SurahPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _surahPages
        : _surahPages
            .where((s) =>
                s.kazakh.toLowerCase().contains(_query.toLowerCase()) ||
                s.arabic.contains(_query) ||
                s.surah.toString() == _query)
            .toList();

    final isDark = context.watch<AppState>().isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.bg(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Сүре таңдау',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary(isDark),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Іздеу...',
                  hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Color(0xFFBBBBBB), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: AppTheme.divider(isDark)),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final s = filtered[i];
                return InkWell(
                  onTap: () => widget.onSelect(s.page),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text('${s.surah}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.tertiary(isDark))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(s.kazakh,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.primary(isDark))),
                        ),
                        Text(s.arabic,
                            style: TextStyle(
                              fontFamily: 'ScheherazadeNew',
                              fontSize: 20,
                              color: AppTheme.primary(isDark),
                            )),
                        const SizedBox(width: 12),
                        Text('${s.page}',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.tertiary(isDark))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}