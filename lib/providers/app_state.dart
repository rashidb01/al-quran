import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah.dart';
import '../services/quran_service.dart';
import '../services/notification_service.dart';
import '../l10n.dart';

class AppState extends ChangeNotifier {
  final QuranService _service = QuranService();

  // Первый запуск
  bool isFirstLaunch = true;

  // Санак цель
  int sanaqCount = 0;
  int dividerCount = 0;

  // Страницы мусхафа
  final Map<int, List<Ayah>> _pages = {};
  final Map<int, bool> _loadingPages = {};
  String? error;

  // Выбранные аяты
  final Set<int> selectedAyahIds = {};
  final List<Ayah> selectedAyahs = [];

  // Счётчик
  int counter = 0;
  bool goalReached = false; // Изменено: теперь управляет показом баннера

  // Последний открытый аят для счётчика
  Ayah? activeAyah;

  // Dark mode
  bool isDarkMode = false;

  // Locale
  AppLocale locale = AppLocale.kk;

  // Quran font size
  double quranFontSize = 24.0;

  late final Future<void> initFuture;

  AppState() {
    initFuture = init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstLaunch = prefs.getBool('launched') != true;
    isDarkMode = prefs.getBool('darkMode') ?? false;
    final localeStr = prefs.getString('locale') ?? 'kk';
    locale = AppLocale.values.firstWhere((e) => e.name == localeStr, orElse: () => AppLocale.kk);
    quranFontSize = prefs.getDouble('quranFontSize') ?? 24.0;
    if (!isFirstLaunch) {
      sanaqCount = prefs.getInt('sanaqCount') ?? 0;
      dividerCount = prefs.getInt('dividerCount') ?? 0;
      counter = prefs.getInt('counter') ?? 0;
      final raw = prefs.getString('selectedAyahs');
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          final ayah = Ayah.fromJson(item as Map<String, dynamic>);
          selectedAyahIds.add(ayah.id);
          selectedAyahs.add(ayah);
        }
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(AppLocale l) async {
    locale = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', l.name);
    notifyListeners();
  }

  Future<void> setQuranFontSize(double size) async {
    quranFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quranFontSize', size);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    isDarkMode = !isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    notifyListeners();
  }

  Future<void> _saveSelectedAyahs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'selectedAyahs',
      jsonEncode(selectedAyahs.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> setSanaqCount(int v, {int divider = 0}) async {
    sanaqCount = v;
    dividerCount = divider;
    counter = 0;
    goalReached = false;
    isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('launched', true);
    await prefs.setInt('sanaqCount', v);
    await prefs.setInt('dividerCount', divider);
    await prefs.setInt('counter', 0);
    notifyListeners();
    if (divider > 0) {
      await NotificationService.scheduleReminders(
        totalCount: v,
        currentCounter: 0,
        divider: divider,
        locale: locale,
      );
    } else {
      await NotificationService.cancelAll();
    }
  }

  List<Ayah>? getPage(int page) => _pages[page];
  bool isPageLoading(int page) => _loadingPages[page] ?? false;

  Future<void> loadPage(int page) async {
    if (_pages.containsKey(page) || _loadingPages[page] == true) return;
    _loadingPages[page] = true;
    notifyListeners();
    try {
      _pages[page] = await _service.fetchPage(page);
    } catch (e) {
      error = e.toString();
    }
    _loadingPages[page] = false;
    notifyListeners();
  }

  void toggleAyah(Ayah ayah) {
    if (selectedAyahIds.contains(ayah.id)) {
      selectedAyahIds.remove(ayah.id);
      selectedAyahs.removeWhere((a) => a.id == ayah.id);
    } else {
      selectedAyahIds.add(ayah.id);
      selectedAyahs.add(ayah);
    }
    notifyListeners();
    _saveSelectedAyahs();
  }

  void removeAyah(Ayah ayah) {
    selectedAyahIds.remove(ayah.id);
    selectedAyahs.removeWhere((a) => a.id == ayah.id);
    notifyListeners();
    _saveSelectedAyahs();
  }

  void clearAllAyahs() {
    selectedAyahIds.clear();
    selectedAyahs.clear();
    notifyListeners();
    _saveSelectedAyahs();
  }

  void setActiveAyah(Ayah ayah) {
    activeAyah = ayah;
    notifyListeners();
  }

  Future<void> increment() async {
    counter++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', counter);

    // Измененное условие: 
    // Баннер покажется ТОЛЬКО если counter в точности равен sanaqCount 
    // или если это первое достижение цели в этой сессии.
    if (sanaqCount > 0 && counter == sanaqCount && !goalReached) {
      goalReached = true;
      notifyListeners();

      // Автоматически скрываем через 3 секунды
      Future.delayed(const Duration(seconds: 3), () {
        goalReached = false;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
    if (dividerCount > 0) {
      NotificationService.rescheduleWithNewRemaining(
        totalCount: sanaqCount,
        currentCounter: counter,
        locale: locale,
      );
    }
  }

  // Метод для ручного закрытия баннера[cite: 1]
  void dismissGoal() {
    goalReached = false;
    notifyListeners();
  }

  Future<void> resetCounter() async {
    counter = 0;
    goalReached = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', 0);
    notifyListeners();
    await NotificationService.cancelAll();
  }
}