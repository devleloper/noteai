import 'package:flutter/material.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../domain/entities/language.dart';
import 'language_picker.dart';

class LanguageTile extends StatelessWidget {
  final String selectedLanguageCode;
  final Function(String) onLanguageChanged;

  const LanguageTile({
    super.key,
    required this.selectedLanguageCode,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final language = SupportedLanguages.getLanguageByCode(selectedLanguageCode) ??
        SupportedLanguages.getDefaultLanguage();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            language.nativeName.isNotEmpty ? language.nativeName[0] : language.name[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: const Text('Summary Language'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (language.nativeName != language.name)
              Text(
                language.nativeName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (language.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _showLanguagePicker(context),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LanguagePicker(
          selectedLanguageCode: selectedLanguageCode,
          onLanguageSelected: onLanguageChanged,
        ),
      ),
    );
  }
}
