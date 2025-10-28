class LanguagePrompts {
  static const String _baseSummaryTemplate = '''
You are an expert at creating structured summaries of educational content, lectures, and discussions.

{{action}} a {{format}} in Markdown format with the following structure:
- {{structure}} using ## and ###
- Bullet points for key information using -
- Bold text for important concepts using **text**
- LaTeX formulas for mathematical expressions using \$formula\$
- Organized sections by topic
- Professional and educational tone

Format example:
## Main Topic
- Key point 1
- Key point 2

### Subsection
**Important concept**: Explanation

**Formula**: \$x^2 + y^2 = z^2\$

Focus on:
1. Main topics and themes
2. Key concepts and definitions
3. Important formulas and calculations
4. Action items or assignments
5. Questions or discussions raised

Make the summary comprehensive but concise, highlighting the most important information for future reference.
''';

  static const Map<String, Map<String, String>> _languageVariables = {
    'en': {
      'action': 'Create',
      'format': 'comprehensive summary',
      'structure': 'Clear headings and subheadings',
    },
    'ru': {
      'action': 'Создайте',
      'format': 'краткое изложение',
      'structure': 'Четкие заголовки и подзаголовки',
    },
    'es': {
      'action': 'Cree',
      'format': 'resumen completo',
      'structure': 'Encabezados y subencabezados claros',
    },
    'fr': {
      'action': 'Créez',
      'format': 'résumé complet',
      'structure': 'En-têtes et sous-en-têtes clairs',
    },
    'de': {
      'action': 'Erstellen Sie',
      'format': 'umfassende Zusammenfassung',
      'structure': 'Klare Überschriften und Unterüberschriften',
    },
    'it': {
      'action': 'Crea',
      'format': 'riassunto completo',
      'structure': 'Intestazioni e sottointestazioni chiare',
    },
    'pt': {
      'action': 'Crie',
      'format': 'resumo abrangente',
      'structure': 'Cabeçalhos e subcabeçalhos claros',
    },
    'ja': {
      'action': '作成してください',
      'format': '包括的な要約',
      'structure': '明確な見出しと小見出し',
    },
    'ko': {
      'action': '만들어주세요',
      'format': '포괄적인 요약',
      'structure': '명확한 제목과 부제목',
    },
    'zh': {
      'action': '创建',
      'format': '综合摘要',
      'structure': '清晰的标题和副标题',
    },
    'ar': {
      'action': 'أنشئ',
      'format': 'ملخص شامل',
      'structure': 'عناوين وعناوين فرعية واضحة',
    },
    'hi': {
      'action': 'बनाएं',
      'format': 'व्यापक सारांश',
      'structure': 'स्पष्ट शीर्षक और उपशीर्षक',
    },
    'th': {
      'action': 'สร้าง',
      'format': 'สรุปที่ครอบคลุม',
      'structure': 'หัวข้อและหัวข้อย่อยที่ชัดเจน',
    },
    'vi': {
      'action': 'Tạo',
      'format': 'tóm tắt toàn diện',
      'structure': 'Tiêu đề và tiêu đề phụ rõ ràng',
    },
    'tr': {
      'action': 'Oluşturun',
      'format': 'kapsamlı özet',
      'structure': 'Açık başlıklar ve alt başlıklar',
    },
    'pl': {
      'action': 'Utwórz',
      'format': 'kompleksowe podsumowanie',
      'structure': 'Jasne nagłówki i podnagłówki',
    },
    'nl': {
      'action': 'Maak',
      'format': 'uitgebreide samenvatting',
      'structure': 'Duidelijke koppen en subkoppen',
    },
    'sv': {
      'action': 'Skapa',
      'format': 'omfattande sammanfattning',
      'structure': 'Tydliga rubriker och underrubriker',
    },
    'da': {
      'action': 'Opret',
      'format': 'omfattende resumé',
      'structure': 'Klare overskrifter og underoverskrifter',
    },
    'no': {
      'action': 'Opprett',
      'format': 'omfattende sammendrag',
      'structure': 'Klare overskrifter og underoverskrifter',
    },
    'fi': {
      'action': 'Luo',
      'format': 'kattava yhteenveto',
      'structure': 'Selkeät otsikot ja alaotsikot',
    },
    'el': {
      'action': 'Δημιουργήστε',
      'format': 'περιεκτική περίληψη',
      'structure': 'Σαφείς τίτλοι και υποτίτλοι',
    },
    'he': {
      'action': 'צור',
      'format': 'סיכום מקיף',
      'structure': 'כותרות וכותרות משנה ברורות',
    },
    'uk': {
      'action': 'Створіть',
      'format': 'комплексний підсумок',
      'structure': 'Чіткі заголовки та підзаголовки',
    },
    'bg': {
      'action': 'Създайте',
      'format': 'всеобхватно резюме',
      'structure': 'Ясни заглавия и подзаглавия',
    },
    'hr': {
      'action': 'Stvorite',
      'format': 'sveobuhvatan sažetak',
      'structure': 'Jasni naslovi i podnaslovi',
    },
    'cs': {
      'action': 'Vytvořte',
      'format': 'komplexní shrnutí',
      'structure': 'Jasné nadpisy a podnadpisy',
    },
    'hu': {
      'action': 'Hozzon létre',
      'format': 'átfogó összefoglaló',
      'structure': 'Tiszta címsorok és alcímsorok',
    },
    'ro': {
      'action': 'Creați',
      'format': 'rezumat cuprinzător',
      'structure': 'Titluri și subtitluri clare',
    },
    'sk': {
      'action': 'Vytvorte',
      'format': 'komplexné zhrnutie',
      'structure': 'Jasné nadpisy a podnadpisy',
    },
    'sl': {
      'action': 'Ustvarite',
      'format': 'obsežen povzetek',
      'structure': 'Jasni naslovi in podnaslovi',
    },
    'et': {
      'action': 'Loo',
      'format': 'põhjalik kokkuvõte',
      'structure': 'Selged pealkirjad ja alapealkirjad',
    },
    'lv': {
      'action': 'Izveidojiet',
      'format': 'visaptverošs kopsavilkums',
      'structure': 'Skaidri virsraksti un apakšvirsraksti',
    },
    'lt': {
      'action': 'Sukurkite',
      'format': 'išsamų santrauką',
      'structure': 'Aiškūs antraštės ir paantraštės',
    },
    'id': {
      'action': 'Buat',
      'format': 'ringkasan komprehensif',
      'structure': 'Judul dan subjudul yang jelas',
    },
    'ms': {
      'action': 'Cipta',
      'format': 'ringkasan komprehensif',
      'structure': 'Tajuk dan subtajuk yang jelas',
    },
    'tl': {
      'action': 'Lumikha',
      'format': 'komprehensibong buod',
      'structure': 'Malinaw na mga pamagat at sub-pamagat',
    },
    'ta': {
      'action': 'உருவாக்கவும்',
      'format': 'விரிவான சுருக்கம்',
      'structure': 'தெளிவான தலைப்புகள் மற்றும் துணை தலைப்புகள்',
    },
    'te': {
      'action': 'సృష్టించండి',
      'format': 'సమగ్ర సారాంశం',
      'structure': 'స్పష్టమైన శీర్షికలు మరియు ఉపశీర్షికలు',
    },
    'ml': {
      'action': 'സൃഷ്ടിക്കുക',
      'format': 'വിശാലമായ സംഗ്രഹം',
      'structure': 'വ്യക്തമായ ശീർഷകങ്ങളും ഉപശീർഷകങ്ങളും',
    },
    'kn': {
      'action': 'ರಚಿಸಿ',
      'format': 'ವ್ಯಾಪಕ ಸಾರಾಂಶ',
      'structure': 'ಸ್ಪಷ್ಟ ಶೀರ್ಷಿಕೆಗಳು ಮತ್ತು ಉಪಶೀರ್ಷಿಕೆಗಳು',
    },
    'gu': {
      'action': 'બનાવો',
      'format': 'વ્યાપક સારાંશ',
      'structure': 'સ્પષ્ટ શીર્ષકો અને ઉપશીર્ષકો',
    },
    'mr': {
      'action': 'तयार करा',
      'format': 'व्यापक सारांश',
      'structure': 'स्पष्ट शीर्षके आणि उपशीर्षके',
    },
    'ur': {
      'action': 'بنائیں',
      'format': 'جامع خلاصہ',
      'structure': 'واضح عنوانات اور ذیلی عنوانات',
    },
    'fa': {
      'action': 'ایجاد کنید',
      'format': 'خلاصه جامع',
      'structure': 'عناوین و زیرعناوین واضح',
    },
    'bn': {
      'action': 'তৈরি করুন',
      'format': 'বিস্তৃত সারসংক্ষেপ',
      'structure': 'স্পষ্ট শিরোনাম এবং উপশিরোনাম',
    },
    'pa': {
      'action': 'ਬਣਾਓ',
      'format': 'ਵਿਆਪਕ ਸਾਰ',
      'structure': 'ਸਪਸ਼ਟ ਸਿਰਲੇਖ ਅਤੇ ਉਪ-ਸਿਰਲੇਖ',
    },
    'sw': {
      'action': 'Unda',
      'format': 'muhtasari wa kina',
      'structure': 'Vichwa na vichwa vidogo vya wazi',
    },
    'am': {
      'action': 'ፍጠር',
      'format': 'የሰፊ ማጠቃለያ',
      'structure': 'ግልጽ የሆኑ ርዕሶች እና ንዑስ ርዕሶች',
    },
    'ha': {
      'action': 'Ƙirƙira',
      'format': 'taƙaitaccen bayani',
      'structure': 'Kanun labarai da ƙananan kanun labarai masu haske',
    },
    'yo': {
      'action': 'Ṣẹda',
      'format': 'akopọ gbogbo',
      'structure': 'Awọn akọle ati awọn akọle kekere ti o han',
    },
    'ig': {
      'action': 'Mepụta',
      'format': 'nchịkọta zuru ezu',
      'structure': 'Isiokwu na obere isiokwu doro anya',
    },
    'zu': {
      'action': 'Dala',
      'format': 'isifinye esiphelele',
      'structure': 'Amagama nemagama amancane acacile',
    },
    'xh': {
      'action': 'Yila',
      'format': 'isishwankathelo esipheleleyo',
      'structure': 'Amagama nemagama amancane acacile',
    },
  };

  /// Get language-specific prompt for summary generation
  static String getSummaryPrompt(String language) {
    final variables = _languageVariables[language] ?? _languageVariables['en']!;
    
    String prompt = _baseSummaryTemplate;
    variables.forEach((key, value) {
      prompt = prompt.replaceAll('{{$key}}', value);
    });
    
    return prompt;
  }

  /// Check if language is supported for prompts
  static bool isLanguageSupported(String language) {
    return _languageVariables.containsKey(language);
  }

  /// Get all supported languages for prompts
  static List<String> getSupportedLanguages() {
    return _languageVariables.keys.toList()..sort();
  }

  /// Get fallback language (English)
  static String getFallbackLanguage() {
    return 'en';
  }
}
