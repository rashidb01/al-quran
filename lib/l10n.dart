enum AppLocale { kk, ru, en }

class L10n {
  final AppLocale locale;
  const L10n(this.locale);

  String get label {
    switch (locale) {
      case AppLocale.kk: return 'ҚАЗ';
      case AppLocale.ru: return 'РУС';
      case AppLocale.en: return 'ENG';
    }
  }

  String get enterSanaqCount {
    switch (locale) {
      case AppLocale.kk: return 'Санақ санын енгізіңіз';
      case AppLocale.ru: return 'Введите цель санака';
      case AppLocale.en: return 'Enter sanaq count';
    }
  }

  String get continueBtn {
    switch (locale) {
      case AppLocale.kk: return 'Жалғастыру';
      case AppLocale.ru: return 'Продолжить';
      case AppLocale.en: return 'Continue';
    }
  }

  String get openQuran {
    switch (locale) {
      case AppLocale.kk: return 'Құранды оқу';
      case AppLocale.ru: return 'Открыть Куран';
      case AppLocale.en: return 'Open Quran';
    }
  }

  String selected(int count) {
    switch (locale) {
      case AppLocale.kk: return 'Таңдалған ($count)';
      case AppLocale.ru: return 'Выбрано ($count)';
      case AppLocale.en: return 'Selected ($count)';
    }
  }

  String get goalReached {
    switch (locale) {
      case AppLocale.kk: return '✓ Мақсат орындалды';
      case AppLocale.ru: return '✓ Цель достигнута';
      case AppLocale.en: return '✓ Goal reached';
    }
  }

  String get tapToContinue {
    switch (locale) {
      case AppLocale.kk: return 'жалғастыру үшін түртіңіз';
      case AppLocale.ru: return 'нажмите чтобы продолжить';
      case AppLocale.en: return 'tap to continue';
    }
  }

  String get audhuTranslation {
    switch (locale) {
      case AppLocale.kk: return 'Мен қуылған шайтаннан Аллаhқа паналаймын';
      case AppLocale.ru: return 'Прибегаю к защите Аллаха от шайтана, побиваемого камнями';
      case AppLocale.en: return 'I seek refuge in Allah from the accursed Satan';
    }
  }

  String juz(int n) {
    switch (locale) {
      case AppLocale.kk: return 'джүз $n';
      case AppLocale.ru: return 'джуз $n';
      case AppLocale.en: return 'juz $n';
    }
  }

  String get chooseSurah {
    switch (locale) {
      case AppLocale.kk: return 'Сүре таңдау';
      case AppLocale.ru: return 'Выбор суры';
      case AppLocale.en: return 'Choose surah';
    }
  }

  String get search {
    switch (locale) {
      case AppLocale.kk: return 'Іздеу...';
      case AppLocale.ru: return 'Поиск...';
      case AppLocale.en: return 'Search...';
    }
  }

  String get textSize {
    switch (locale) {
      case AppLocale.kk: return 'Мәтін өлшемі';
      case AppLocale.ru: return 'Размер текста';
      case AppLocale.en: return 'Text size';
    }
  }

  String get language {
    switch (locale) {
      case AppLocale.kk: return 'Тіл';
      case AppLocale.ru: return 'Язык';
      case AppLocale.en: return 'Language';
    }
  }

  String get sanaqGoal {
    switch (locale) {
      case AppLocale.kk: return 'Санақ саны';
      case AppLocale.ru: return 'Цель санак';
      case AppLocale.en: return 'Sanaq goal';
    }
  }

  String get settings {
    switch (locale) {
      case AppLocale.kk: return 'Баптаулар';
      case AppLocale.ru: return 'Настройки';
      case AppLocale.en: return 'Settings';
    }
  }
}
