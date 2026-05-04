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
  String selected(int count) => "Selected: $count";
  String get tapToContinue => "Нажмите, чтобы продолжить";
  String get enterSanaqCount => "Введите количество";
  String get continueBtn => "Продолжить";
  String get audhuTranslation => "Перевод А'узу...";
  String get goalReached => "Цель достигнута!";
  String get openQuran => "Открыть Коран";
  String get sanaqGoal => "Цель Санак";
  String get language => "Язык";
  String get textSize => "Размер текста";
  String get chooseSurah => "Выберите суру";
  String get search => "Поиск";
  String juz(int number) => "Джуз $number";
  // Добавьте сюда другие строки, на которые ругается компилятор
}