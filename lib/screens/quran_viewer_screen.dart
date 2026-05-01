import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ayah.dart';
import '../providers/app_state.dart';
import 'selected_ayahs_screen.dart';
import 'count_input_screen.dart';

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
    _pageController = PageController();
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
    setState(() => _currentPage = index + 1);
    _preload(index + 1);
  }

  void _goToPage(int page) {
    _pageController.jumpToPage(page - 1);
    setState(() => _currentPage = page);
    _preload(page);
  }

  void _showSurahPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SurahPickerSheet(onSelect: (page) {
        Navigator.pop(context);
        _goToPage(page);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CountInputScreen()),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_book_rounded, color: Color(0xFF2E7D5E)),
              onPressed: () => _showSurahPicker(context),
            ),
          ],
          title: Text(
            'بەت $_currentPage',
            style: const TextStyle(
              fontFamily: 'ScheherazadeNew',
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFF0F0F0)),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: 604,
          onPageChanged: _onPageChanged,
          itemBuilder: (ctx, index) => _QuranPage(pageNumber: index + 1),
        ),
        // Кнопка "Таңдау" снизу — появляется когда есть выбранные аяты
        bottomNavigationBar: state.selectedAyahs.isNotEmpty
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SelectedAyahsScreen()),
                    ),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D5E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D5E).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Таңдау (${state.selectedAyahs.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

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
      context.read<AppState>().loadPage(widget.pageNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ayahs = state.getPage(widget.pageNumber);
    final isLoading = state.isPageLoading(widget.pageNumber);

    if (isLoading || ayahs == null) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF2E7D5E), strokeWidth: 2),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _PageContent(ayahs: ayahs),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${widget.pageNumber}',
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final List<Ayah> ayahs;
  const _PageContent({required this.ayahs});

  String _toArabic(int n) {
    const e = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => e[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final List<Widget> sections = [];
    int? lastSurah;
    List<Ayah> group = [];

    void flush() {
      if (group.isEmpty) return;
      final g = List<Ayah>.from(group);
      sections.add(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            textDirection: TextDirection.rtl,
            children: g.map((ayah) {
              final selected = state.selectedAyahIds.contains(ayah.id);
              return GestureDetector(
                onTap: () => context.read<AppState>().toggleAyah(ayah),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFD4EDDA)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: ayah.textUthmani,
                        style: const TextStyle(
                          fontFamily: 'ScheherazadeNew',
                          fontSize: 22,
                          height: 2.1,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      TextSpan(
                        text: ' ﴿${_toArabic(ayah.verseNumber)}﴾ ',
                        style: TextStyle(
                          fontFamily: 'ScheherazadeNew',
                          fontSize: 18,
                          height: 2.1,
                          color: selected
                              ? const Color(0xFF2E7D5E)
                              : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ]),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
      group = [];
    }

    for (final ayah in ayahs) {
      if (ayah.surahNumber != lastSurah) {
        flush();
        sections.add(_SurahHeader(name: ayah.surahName));
        lastSurah = ayah.surahNumber;
      }
      group.add(ayah);
    }
    flush();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sections,
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  final String name;
  const _SurahHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
              color: const Color(0xFF2E7D5E).withValues(alpha: 0.3)),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'ScheherazadeNew',
          fontSize: 22,
          color: Color(0xFF2E7D5E),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Страницы начала каждой суры (мусхаф Медина, стандарт)
const List<({int surah, String arabic, String kazakh, int page})> _surahPages = [
  (surah: 1,  arabic: 'الفاتحة',    kazakh: 'Фатиха',       page: 1),
  (surah: 2,  arabic: 'البقرة',     kazakh: 'Бақара',        page: 2),
  (surah: 3,  arabic: 'آل عمران',   kazakh: 'Әли Имран',     page: 50),
  (surah: 4,  arabic: 'النساء',     kazakh: 'Ниса',          page: 77),
  (surah: 5,  arabic: 'المائدة',    kazakh: 'Мәида',         page: 106),
  (surah: 6,  arabic: 'الأنعام',    kazakh: 'Анғам',         page: 128),
  (surah: 7,  arabic: 'الأعراف',    kazakh: 'Ағраф',         page: 151),
  (surah: 8,  arabic: 'الأنفال',    kazakh: 'Анфал',         page: 177),
  (surah: 9,  arabic: 'التوبة',     kazakh: 'Тәуба',         page: 187),
  (surah: 10, arabic: 'يونس',       kazakh: 'Юнус',          page: 208),
  (surah: 11, arabic: 'هود',        kazakh: 'Худ',           page: 221),
  (surah: 12, arabic: 'يوسف',       kazakh: 'Жүсіп',         page: 235),
  (surah: 13, arabic: 'الرعد',      kazakh: 'Ражд',          page: 249),
  (surah: 14, arabic: 'إبراهيم',    kazakh: 'Ибраhим',       page: 255),
  (surah: 15, arabic: 'الحجر',      kazakh: 'Хижр',          page: 262),
  (surah: 16, arabic: 'النحل',      kazakh: 'Нахл',          page: 267),
  (surah: 17, arabic: 'الإسراء',    kazakh: 'Исра',          page: 282),
  (surah: 18, arabic: 'الكهف',      kazakh: 'Кахф',          page: 293),
  (surah: 19, arabic: 'مريم',       kazakh: 'Марьям',        page: 305),
  (surah: 20, arabic: 'طه',         kazakh: 'Таха',          page: 312),
  (surah: 21, arabic: 'الأنبياء',   kazakh: 'Анбия',         page: 322),
  (surah: 22, arabic: 'الحج',       kazakh: 'Хаж',           page: 332),
  (surah: 23, arabic: 'المؤمنون',   kazakh: 'Мүминун',       page: 342),
  (surah: 24, arabic: 'النور',      kazakh: 'Нур',           page: 350),
  (surah: 25, arabic: 'الفرقان',    kazakh: 'Фурқан',        page: 359),
  (surah: 26, arabic: 'الشعراء',    kazakh: 'Шуара',         page: 367),
  (surah: 27, arabic: 'النمل',      kazakh: 'Намл',          page: 377),
  (surah: 28, arabic: 'القصص',      kazakh: 'Қасас',         page: 385),
  (surah: 29, arabic: 'العنكبوت',   kazakh: 'Анкабут',       page: 396),
  (surah: 30, arabic: 'الروم',      kazakh: 'Рум',           page: 404),
  (surah: 31, arabic: 'لقمان',      kazakh: 'Луқман',        page: 411),
  (surah: 32, arabic: 'السجدة',     kazakh: 'Сажда',         page: 415),
  (surah: 33, arabic: 'الأحزاب',    kazakh: 'Ахзаб',         page: 418),
  (surah: 34, arabic: 'سبإ',        kazakh: 'Саба',          page: 428),
  (surah: 35, arabic: 'فاطر',       kazakh: 'Фатыр',         page: 434),
  (surah: 36, arabic: 'يس',         kazakh: 'Ясин',          page: 440),
  (surah: 37, arabic: 'الصافات',    kazakh: 'Саффат',        page: 446),
  (surah: 38, arabic: 'ص',          kazakh: 'Сад',           page: 453),
  (surah: 39, arabic: 'الزمر',      kazakh: 'Зумар',         page: 458),
  (surah: 40, arabic: 'غافر',       kazakh: 'Ғафир',         page: 467),
  (surah: 41, arabic: 'فصلت',       kazakh: 'Фуссылат',      page: 477),
  (surah: 42, arabic: 'الشورى',     kazakh: 'Шура',          page: 483),
  (surah: 43, arabic: 'الزخرف',     kazakh: 'Зухруф',        page: 489),
  (surah: 44, arabic: 'الدخان',     kazakh: 'Духан',         page: 496),
  (surah: 45, arabic: 'الجاثية',    kazakh: 'Жасия',         page: 499),
  (surah: 46, arabic: 'الأحقاف',    kazakh: 'Ахқаф',         page: 502),
  (surah: 47, arabic: 'محمد',       kazakh: 'Мухаммад',      page: 507),
  (surah: 48, arabic: 'الفتح',      kazakh: 'Фатх',          page: 511),
  (surah: 49, arabic: 'الحجرات',    kazakh: 'Хужурат',       page: 515),
  (surah: 50, arabic: 'ق',          kazakh: 'Қаф',           page: 518),
  (surah: 51, arabic: 'الذاريات',   kazakh: 'Зарият',        page: 520),
  (surah: 52, arabic: 'الطور',      kazakh: 'Тур',           page: 523),
  (surah: 53, arabic: 'النجم',      kazakh: 'Нажм',          page: 526),
  (surah: 54, arabic: 'القمر',      kazakh: 'Қамар',         page: 528),
  (surah: 55, arabic: 'الرحمن',     kazakh: 'Рахман',        page: 531),
  (surah: 56, arabic: 'الواقعة',    kazakh: 'Уақиа',         page: 534),
  (surah: 57, arabic: 'الحديد',     kazakh: 'Хадид',         page: 537),
  (surah: 58, arabic: 'المجادلة',   kazakh: 'Мужадала',      page: 542),
  (surah: 59, arabic: 'الحشر',      kazakh: 'Хашр',          page: 545),
  (surah: 60, arabic: 'الممتحنة',   kazakh: 'Мумтахина',     page: 549),
  (surah: 61, arabic: 'الصف',       kazakh: 'Саф',           page: 551),
  (surah: 62, arabic: 'الجمعة',     kazakh: 'Жұма',          page: 553),
  (surah: 63, arabic: 'المنافقون',  kazakh: 'Мунафиқун',     page: 554),
  (surah: 64, arabic: 'التغابن',    kazakh: 'Тағабун',       page: 556),
  (surah: 65, arabic: 'الطلاق',     kazakh: 'Талақ',         page: 558),
  (surah: 66, arabic: 'التحريم',    kazakh: 'Тахрим',        page: 560),
  (surah: 67, arabic: 'الملك',      kazakh: 'Мүлк',          page: 562),
  (surah: 68, arabic: 'القلم',      kazakh: 'Қалам',         page: 564),
  (surah: 69, arabic: 'الحاقة',     kazakh: 'Хаққа',         page: 566),
  (surah: 70, arabic: 'المعارج',    kazakh: 'Мағариж',       page: 568),
  (surah: 71, arabic: 'نوح',        kazakh: 'Нух',           page: 570),
  (surah: 72, arabic: 'الجن',       kazakh: 'Жын',           page: 572),
  (surah: 73, arabic: 'المزمل',     kazakh: 'Муззаммил',     page: 574),
  (surah: 74, arabic: 'المدثر',     kazakh: 'Муддасир',      page: 575),
  (surah: 75, arabic: 'القيامة',    kazakh: 'Қиямет',        page: 577),
  (surah: 76, arabic: 'الإنسان',    kazakh: 'Инсан',         page: 578),
  (surah: 77, arabic: 'المرسلات',   kazakh: 'Мурсалат',      page: 580),
  (surah: 78, arabic: 'النبأ',      kazakh: 'Наба',          page: 582),
  (surah: 79, arabic: 'النازعات',   kazakh: 'Назиғат',       page: 583),
  (surah: 80, arabic: 'عبس',        kazakh: 'Абаса',         page: 585),
  (surah: 81, arabic: 'التكوير',    kazakh: 'Таквир',        page: 586),
  (surah: 82, arabic: 'الإنفطار',   kazakh: 'Инфитар',       page: 587),
  (surah: 83, arabic: 'المطففين',   kazakh: 'Мутаффифин',    page: 587),
  (surah: 84, arabic: 'الإنشقاق',   kazakh: 'Иншиқақ',      page: 589),
  (surah: 85, arabic: 'البروج',     kazakh: 'Бурудж',        page: 590),
  (surah: 86, arabic: 'الطارق',     kazakh: 'Тарық',         page: 591),
  (surah: 87, arabic: 'الأعلى',     kazakh: 'Ағла',          page: 591),
  (surah: 88, arabic: 'الغاشية',    kazakh: 'Ғашия',         page: 592),
  (surah: 89, arabic: 'الفجر',      kazakh: 'Фажр',          page: 593),
  (surah: 90, arabic: 'البلد',      kazakh: 'Балад',         page: 594),
  (surah: 91, arabic: 'الشمس',      kazakh: 'Шамс',          page: 595),
  (surah: 92, arabic: 'الليل',      kazakh: 'Ләйл',          page: 595),
  (surah: 93, arabic: 'الضحى',      kazakh: 'Духа',          page: 596),
  (surah: 94, arabic: 'الشرح',      kazakh: 'Инширах',       page: 596),
  (surah: 95, arabic: 'التين',      kazakh: 'Тин',           page: 597),
  (surah: 96, arabic: 'العلق',      kazakh: 'Алақ',          page: 597),
  (surah: 97, arabic: 'القدر',      kazakh: 'Қадр',          page: 598),
  (surah: 98, arabic: 'البينة',     kazakh: 'Баййина',       page: 598),
  (surah: 99, arabic: 'الزلزلة',    kazakh: 'Зилзал',        page: 599),
  (surah: 100, arabic: 'العاديات',  kazakh: 'Адият',         page: 599),
  (surah: 101, arabic: 'القارعة',   kazakh: 'Қариа',         page: 600),
  (surah: 102, arabic: 'التكاثر',   kazakh: 'Такасур',       page: 600),
  (surah: 103, arabic: 'العصر',     kazakh: 'Аср',           page: 601),
  (surah: 104, arabic: 'الهمزة',    kazakh: 'Хумаза',        page: 601),
  (surah: 105, arabic: 'الفيل',     kazakh: 'Фил',           page: 601),
  (surah: 106, arabic: 'قريش',      kazakh: 'Қурайш',        page: 602),
  (surah: 107, arabic: 'الماعون',   kazakh: 'Мағун',         page: 602),
  (surah: 108, arabic: 'الكوثر',    kazakh: 'Кәусар',        page: 602),
  (surah: 109, arabic: 'الكافرون',  kazakh: 'Кафирун',       page: 603),
  (surah: 110, arabic: 'النصر',     kazakh: 'Наср',          page: 603),
  (surah: 111, arabic: 'المسد',     kazakh: 'Масад',         page: 603),
  (surah: 112, arabic: 'الإخلاص',   kazakh: 'Ихлас',         page: 604),
  (surah: 113, arabic: 'الفلق',     kazakh: 'Фалақ',         page: 604),
  (surah: 114, arabic: 'الناس',     kazakh: 'Нас',           page: 604),
];

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
        : _surahPages.where((s) =>
            s.kazakh.toLowerCase().contains(_query.toLowerCase()) ||
            s.arabic.contains(_query) ||
            s.surah.toString() == _query).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Сүре таңдау',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
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
          Container(height: 1, color: const Color(0xFFF0F0F0)),
          // Список сур
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
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7F4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${s.surah}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D5E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            s.kazakh,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Text(
                          s.arabic,
                          style: const TextStyle(
                            fontFamily: 'ScheherazadeNew',
                            fontSize: 20,
                            color: Color(0xFF2E7D5E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${s.page}-б.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
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
