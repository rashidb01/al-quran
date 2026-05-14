enum AppLocale { kk, ru, en }

class L10n {
  final AppLocale locale;
  L10n(this.locale);

  String get label {
    switch (locale) {
      case AppLocale.kk: return "Қазақша";
      case AppLocale.ru: return "Русский";
      case AppLocale.en: return "English";
    }
  }

  String selected(int count) {
    switch (locale) {
      case AppLocale.kk: return "Таңдалды: $count";
      case AppLocale.ru: return "Выбрано: $count";
      case AppLocale.en: return "Selected: $count";
    }
  }

  String get tapToContinue {
    switch (locale) {
      case AppLocale.kk: return "Жалғастыру үшін басыңыз";
      case AppLocale.ru: return "Нажмите, чтобы продолжить";
      case AppLocale.en: return "Tap to continue";
    }
  }

  String get enterSanaqCount {
    switch (locale) {
      case AppLocale.kk: return "Санақ мөлшерін енгізіңіз";
      case AppLocale.ru: return "Введите количество";
      case AppLocale.en: return "Enter count";
    }
  }

  String get continueBtn {
    switch (locale) {
      case AppLocale.kk: return "Жалғастыру";
      case AppLocale.ru: return "Продолжить";
      case AppLocale.en: return "Continue";
    }
  }

  String get audhuTranslation {
    switch (locale) {
      case AppLocale.kk: return "Алланың атымен қуылған шайтаннан сақтанамын";
      case AppLocale.ru: return "Прибегаю к защите Аллаха от шайтана";
      case AppLocale.en: return "I seek refuge in Allah from Satan";
    }
  }

  String get goalReached {
    switch (locale) {
      case AppLocale.kk: return "Мақсатқа жеттіңіз!";
      case AppLocale.ru: return "Цель достигнута!";
      case AppLocale.en: return "Goal reached!";
    }
  }

  String get openQuran {
    switch (locale) {
      case AppLocale.kk: return "Құранды ашу";
      case AppLocale.ru: return "Открыть Коран";
      case AppLocale.en: return "Open Quran";
    }
  }

  String get sanaqGoal {
    switch (locale) {
      case AppLocale.kk: return "Санақ мақсаты";
      case AppLocale.ru: return "Цель Санак";
      case AppLocale.en: return "Sanaq Goal";
    }
  }

  String get language {
    switch (locale) {
      case AppLocale.kk: return "Тіл";
      case AppLocale.ru: return "Язык";
      case AppLocale.en: return "Language";
    }
  }

  String get textSize {
    switch (locale) {
      case AppLocale.kk: return "Мәтін өлшемі";
      case AppLocale.ru: return "Размер текста";
      case AppLocale.en: return "Text size";
    }
  }

  String get chooseSurah {
    switch (locale) {
      case AppLocale.kk: return "Сүрені таңдаңыз";
      case AppLocale.ru: return "Выберите суру";
      case AppLocale.en: return "Choose surah";
    }
  }

  String get search {
    switch (locale) {
      case AppLocale.kk: return "Іздеу";
      case AppLocale.ru: return "Поиск";
      case AppLocale.en: return "Search";
    }
  }

  String juz(int number) {
    switch (locale) {
      case AppLocale.kk: return "Жүз $number";
      case AppLocale.ru: return "Джуз $number";
      case AppLocale.en: return "Juz $number";
    }
  }

  String get divideByPages {
    switch (locale) {
      case AppLocale.kk: return "Бөлу";
      case AppLocale.ru: return "Разделить на";
      case AppLocale.en: return "Divide by";
    }
  }

  String get notifTitle {
    switch (locale) {
      case AppLocale.kk: return "Санақ Құран";
      case AppLocale.ru: return "Санак Куран";
      case AppLocale.en: return "Sanaq Quran";
    }
  }

  String notifBody({
    required int remaining,
    required int total,
    required int perStep,
    String? nextTime,
  }) {
    final next = nextTime != null ? ' в $nextTime' : '';
    switch (locale) {
      case AppLocale.kk:
        final kNext = nextTime != null ? ' $nextTime-де' : '';
        return "Қалғаны: $remaining\nМақсатқа жету үшін ($total) келесі хабарламаға дейін$kNext $perStep рет жасаңыз";
      case AppLocale.ru:
        return "Остаток: $remaining\nЧтобы достичь цели ($total), сделайте $perStep повторений до следующего уведомления$next";
      case AppLocale.en:
        final eNext = nextTime != null ? ' at $nextTime' : '';
        return "Remaining: $remaining\nTo reach your goal ($total), complete $perStep repetitions before the next notification$eNext";
    }
  }
}
