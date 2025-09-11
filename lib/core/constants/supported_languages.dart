import '../../domain/entities/language.dart';

class SupportedLanguages {
  static const List<Language> _languages = [
    // Popular Languages (Top 10)
    Language(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      region: 'Global',
      script: 'Latin',
      isPopular: true,
      sortOrder: 1,
    ),
    Language(
      code: 'zh',
      name: 'Chinese (Simplified)',
      nativeName: '中文 (简体)',
      region: 'Asia',
      script: 'Han',
      isPopular: true,
      sortOrder: 2,
    ),
    Language(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      region: 'Europe',
      script: 'Latin',
      isPopular: true,
      sortOrder: 3,
    ),
    Language(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      region: 'Asia',
      script: 'Devanagari',
      isPopular: true,
      sortOrder: 4,
    ),
    Language(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      region: 'Middle East',
      script: 'Arabic',
      isPopular: true,
      sortOrder: 5,
    ),
    Language(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      region: 'Europe',
      script: 'Latin',
      isPopular: true,
      sortOrder: 6,
    ),
    Language(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      region: 'Asia',
      script: 'Bengali',
      isPopular: true,
      sortOrder: 7,
    ),
    Language(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      region: 'Europe',
      script: 'Cyrillic',
      isPopular: true,
      sortOrder: 8,
    ),
    Language(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      region: 'Asia',
      script: 'Hiragana',
      isPopular: true,
      sortOrder: 9,
    ),
    Language(
      code: 'pa',
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      region: 'Asia',
      script: 'Gurmukhi',
      isPopular: true,
      sortOrder: 10,
    ),

    // European Languages
    Language(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 11,
    ),
    Language(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 12,
    ),
    Language(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 13,
    ),
    Language(
      code: 'nl',
      name: 'Dutch',
      nativeName: 'Nederlands',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 14,
    ),
    Language(
      code: 'sv',
      name: 'Swedish',
      nativeName: 'Svenska',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 15,
    ),
    Language(
      code: 'da',
      name: 'Danish',
      nativeName: 'Dansk',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 16,
    ),
    Language(
      code: 'no',
      name: 'Norwegian',
      nativeName: 'Norsk',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 17,
    ),
    Language(
      code: 'fi',
      name: 'Finnish',
      nativeName: 'Suomi',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 18,
    ),
    Language(
      code: 'pl',
      name: 'Polish',
      nativeName: 'Polski',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 19,
    ),
    Language(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 20,
    ),
    Language(
      code: 'el',
      name: 'Greek',
      nativeName: 'Ελληνικά',
      region: 'Europe',
      script: 'Greek',
      sortOrder: 21,
    ),
    Language(
      code: 'cs',
      name: 'Czech',
      nativeName: 'Čeština',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 22,
    ),
    Language(
      code: 'hu',
      name: 'Hungarian',
      nativeName: 'Magyar',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 23,
    ),
    Language(
      code: 'ro',
      name: 'Romanian',
      nativeName: 'Română',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 24,
    ),
    Language(
      code: 'bg',
      name: 'Bulgarian',
      nativeName: 'Български',
      region: 'Europe',
      script: 'Cyrillic',
      sortOrder: 25,
    ),
    Language(
      code: 'hr',
      name: 'Croatian',
      nativeName: 'Hrvatski',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 26,
    ),
    Language(
      code: 'sk',
      name: 'Slovak',
      nativeName: 'Slovenčina',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 27,
    ),
    Language(
      code: 'sl',
      name: 'Slovenian',
      nativeName: 'Slovenščina',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 28,
    ),
    Language(
      code: 'et',
      name: 'Estonian',
      nativeName: 'Eesti',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 29,
    ),
    Language(
      code: 'lv',
      name: 'Latvian',
      nativeName: 'Latviešu',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 30,
    ),
    Language(
      code: 'lt',
      name: 'Lithuanian',
      nativeName: 'Lietuvių',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 31,
    ),

    // Asian Languages
    Language(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      region: 'Asia',
      script: 'Hangul',
      sortOrder: 32,
    ),
    Language(
      code: 'th',
      name: 'Thai',
      nativeName: 'ไทย',
      region: 'Asia',
      script: 'Thai',
      sortOrder: 33,
    ),
    Language(
      code: 'vi',
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      region: 'Asia',
      script: 'Latin',
      sortOrder: 34,
    ),
    Language(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      region: 'Asia',
      script: 'Latin',
      sortOrder: 35,
    ),
    Language(
      code: 'ms',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
      region: 'Asia',
      script: 'Latin',
      sortOrder: 36,
    ),
    Language(
      code: 'tl',
      name: 'Filipino',
      nativeName: 'Filipino',
      region: 'Asia',
      script: 'Latin',
      sortOrder: 37,
    ),
    Language(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      region: 'Asia',
      script: 'Tamil',
      sortOrder: 38,
    ),
    Language(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      region: 'Asia',
      script: 'Telugu',
      sortOrder: 39,
    ),
    Language(
      code: 'ml',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      region: 'Asia',
      script: 'Malayalam',
      sortOrder: 40,
    ),
    Language(
      code: 'kn',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      region: 'Asia',
      script: 'Kannada',
      sortOrder: 41,
    ),
    Language(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      region: 'Asia',
      script: 'Gujarati',
      sortOrder: 42,
    ),
    Language(
      code: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      region: 'Asia',
      script: 'Devanagari',
      sortOrder: 43,
    ),
    Language(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      region: 'Asia',
      script: 'Arabic',
      sortOrder: 44,
    ),
    Language(
      code: 'fa',
      name: 'Persian',
      nativeName: 'فارسی',
      region: 'Asia',
      script: 'Arabic',
      sortOrder: 45,
    ),
    Language(
      code: 'he',
      name: 'Hebrew',
      nativeName: 'עברית',
      region: 'Asia',
      script: 'Hebrew',
      sortOrder: 46,
    ),

    // African Languages
    Language(
      code: 'sw',
      name: 'Swahili',
      nativeName: 'Kiswahili',
      region: 'Africa',
      script: 'Latin',
      sortOrder: 47,
    ),
    Language(
      code: 'am',
      name: 'Amharic',
      nativeName: 'አማርኛ',
      region: 'Africa',
      script: 'Ethiopic',
      sortOrder: 48,
    ),
    Language(
      code: 'ha',
      name: 'Hausa',
      nativeName: 'Hausa',
      region: 'Africa',
      script: 'Latin',
      sortOrder: 49,
    ),
    Language(
      code: 'yo',
      name: 'Yoruba',
      nativeName: 'Yorùbá',
      region: 'Africa',
      script: 'Latin',
      sortOrder: 50,
    ),
    Language(
      code: 'ig',
      name: 'Igbo',
      nativeName: 'Igbo',
      region: 'Africa',
      script: 'Latin',
      sortOrder: 51,
    ),
    Language(
      code: 'zu',
      name: 'Zulu',
      nativeName: 'IsiZulu',
      region: 'Africa',
      script: 'Latin',
      sortOrder: 52,
    ),
    Language(
      code: 'xh',
      name: 'Xhosa',
      nativeName: 'IsiXhosa',
      region: 'Africa',
      script: 'Latin',
      sortOrder: 53,
    ),

    // Other Languages
    Language(
      code: 'uk',
      name: 'Ukrainian',
      nativeName: 'Українська',
      region: 'Europe',
      script: 'Cyrillic',
      sortOrder: 54,
    ),
    Language(
      code: 'be',
      name: 'Belarusian',
      nativeName: 'Беларуская',
      region: 'Europe',
      script: 'Cyrillic',
      sortOrder: 55,
    ),
    Language(
      code: 'sr',
      name: 'Serbian',
      nativeName: 'Српски',
      region: 'Europe',
      script: 'Cyrillic',
      sortOrder: 56,
    ),
    Language(
      code: 'mk',
      name: 'Macedonian',
      nativeName: 'Македонски',
      region: 'Europe',
      script: 'Cyrillic',
      sortOrder: 57,
    ),
    Language(
      code: 'sq',
      name: 'Albanian',
      nativeName: 'Shqip',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 58,
    ),
    Language(
      code: 'mt',
      name: 'Maltese',
      nativeName: 'Malti',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 59,
    ),
    Language(
      code: 'is',
      name: 'Icelandic',
      nativeName: 'Íslenska',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 60,
    ),
    Language(
      code: 'ga',
      name: 'Irish',
      nativeName: 'Gaeilge',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 61,
    ),
    Language(
      code: 'cy',
      name: 'Welsh',
      nativeName: 'Cymraeg',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 62,
    ),
    Language(
      code: 'eu',
      name: 'Basque',
      nativeName: 'Euskera',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 63,
    ),
    Language(
      code: 'ca',
      name: 'Catalan',
      nativeName: 'Català',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 64,
    ),
    Language(
      code: 'gl',
      name: 'Galician',
      nativeName: 'Galego',
      region: 'Europe',
      script: 'Latin',
      sortOrder: 65,
    ),
  ];

  /// Get all supported languages
  static List<Language> getAllLanguages() {
    return List.from(_languages);
  }

  /// Get popular languages (top 10)
  static List<Language> getPopularLanguages() {
    return _languages.where((lang) => lang.isPopular).toList();
  }

  /// Get languages by region
  static List<Language> getLanguagesByRegion(String region) {
    return _languages.where((lang) => lang.region == region).toList();
  }

  /// Get languages by script
  static List<Language> getLanguagesByScript(String script) {
    return _languages.where((lang) => lang.script == script).toList();
  }

  /// Get language by code
  static Language? getLanguageByCode(String code) {
    try {
      return _languages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Search languages by name or native name
  static List<Language> searchLanguages(String query) {
    if (query.isEmpty) return getAllLanguages();
    
    final lowercaseQuery = query.toLowerCase();
    return _languages.where((lang) {
      return lang.name.toLowerCase().contains(lowercaseQuery) ||
             lang.nativeName.toLowerCase().contains(lowercaseQuery) ||
             lang.code.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get all unique regions
  static List<String> getAllRegions() {
    return _languages.map((lang) => lang.region).toSet().toList()..sort();
  }

  /// Get all unique scripts
  static List<String> getAllScripts() {
    return _languages.map((lang) => lang.script).toSet().toList()..sort();
  }

  /// Check if language code is supported
  static bool isLanguageSupported(String code) {
    return _languages.any((lang) => lang.code == code);
  }

  /// Get default language (English)
  static Language getDefaultLanguage() {
    return getLanguageByCode('en')!;
  }
}
