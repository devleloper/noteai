import 'package:equatable/equatable.dart';

class Language extends Equatable {
  final String code;
  final String name;
  final String nativeName;
  final String region;
  final String script;
  final String? countryEmoji;
  final bool isPopular;
  final int sortOrder;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.region,
    required this.script,
    this.countryEmoji,
    this.isPopular = false,
    this.sortOrder = 0,
  });

  @override
  List<Object> get props => [
        code,
        name,
        nativeName,
        region,
        script,
        countryEmoji ?? '',
        isPopular,
        sortOrder,
      ];

  Language copyWith({
    String? code,
    String? name,
    String? nativeName,
    String? region,
    String? script,
    String? countryEmoji,
    bool? isPopular,
    int? sortOrder,
  }) {
    return Language(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      region: region ?? this.region,
      script: script ?? this.script,
      countryEmoji: countryEmoji ?? this.countryEmoji,
      isPopular: isPopular ?? this.isPopular,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    return 'Language(code: $code, name: $name, nativeName: $nativeName, region: $region, script: $script, countryEmoji: $countryEmoji, isPopular: $isPopular, sortOrder: $sortOrder)';
  }
}
