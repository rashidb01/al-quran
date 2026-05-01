import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah.dart';
import '../services/quran_service.dart';

class AppState extends ChangeNotifier {
  final QuranService _service = QuranService();

  // Первый запуск
  bool isFirstLaunch = true;

  // Санак цель
  int sanaqCount = 0;

  // Страницы мусхафа
  final Map<int, List<Ayah>> _pages = {};
  final Map<int, bool> _loadingPages = {};
  String? error;

  // Выбранные аяты
  final Set<int> selectedAyahIds = {};
  final List<Ayah> selectedAyahs = [];

  // Счётчик
  int counter = 0;
  bool goalShown = false;

  // Последний открытый аят для счётчика
  Ayah? activeAyah;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstLaunch = prefs.getBool('launched') != true;
    if (!isFirstLaunch) {
      sanaqCount = prefs.getInt('sanaqCount') ?? 0;
      counter = prefs.getInt('counter') ?? 0;
    }
    notifyListeners();
  }

  Future<void> setSanaqCount(int v) async {
    sanaqCount = v;
    counter = 0;
    goalShown = false;
    isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('launched', true);
    await prefs.setInt('sanaqCount', v);
    await prefs.setInt('counter', 0);
    notifyListeners();
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
  }

  void removeAyah(Ayah ayah) {
    selectedAyahIds.remove(ayah.id);
    selectedAyahs.removeWhere((a) => a.id == ayah.id);
    notifyListeners();
  }

  void clearAllAyahs() {
    selectedAyahIds.clear();
    selectedAyahs.clear();
    notifyListeners();
  }

  void setActiveAyah(Ayah ayah) {
    activeAyah = ayah;
    notifyListeners();
  }

  Future<void> increment() async {
    counter++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', counter);
    notifyListeners();
  }

  void dismissGoal() {
    goalShown = true;
    notifyListeners();
  }

  Future<void> resetCounter() async {
    counter = 0;
    goalShown = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', 0);
    notifyListeners();
  }
}
