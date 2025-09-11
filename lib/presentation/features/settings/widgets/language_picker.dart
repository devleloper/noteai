import 'package:flutter/material.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../domain/entities/language.dart';

class LanguagePicker extends StatefulWidget {
  final String selectedLanguageCode;
  final Function(String) onLanguageSelected;

  const LanguagePicker({
    super.key,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  late TextEditingController _searchController;
  List<Language> _filteredLanguages = [];
  List<Language> _popularLanguages = [];
  List<String> _regions = [];
  String _selectedRegion = 'All';
  bool _showOnlyPopular = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadLanguages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadLanguages() {
    _popularLanguages = SupportedLanguages.getPopularLanguages();
    _regions = ['All', ...SupportedLanguages.getAllRegions()];
    _filterLanguages();
  }

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    
    if (_showOnlyPopular) {
      _filteredLanguages = _popularLanguages;
    } else if (_selectedRegion == 'All') {
      _filteredLanguages = SupportedLanguages.getAllLanguages();
    } else {
      _filteredLanguages = SupportedLanguages.getLanguagesByRegion(_selectedRegion);
    }

    if (query.isNotEmpty) {
      _filteredLanguages = SupportedLanguages.searchLanguages(query);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showOnlyPopular ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() {
                _showOnlyPopular = !_showOnlyPopular;
              });
              _filterLanguages();
            },
            tooltip: _showOnlyPopular ? 'Show all languages' : 'Show popular languages',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search languages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterLanguages();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) => _filterLanguages(),
            ),
          ),

          // Region Filter
          if (!_showOnlyPopular && _searchController.text.isEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _regions.length,
                itemBuilder: (context, index) {
                  final region = _regions[index];
                  final isSelected = region == _selectedRegion;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(region),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRegion = region;
                        });
                        _filterLanguages();
                      },
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  );
                },
              ),
            ),

          // Language List
          Expanded(
            child: _filteredLanguages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.language_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No languages found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final language = _filteredLanguages[index];
                      final isSelected = language.code == widget.selectedLanguageCode;
                      
                      return _buildLanguageTile(language, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(Language language, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          child: Text(
            language.nativeName.isNotEmpty ? language.nativeName[0] : language.name[0],
            style: TextStyle(
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          language.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (language.nativeName != language.name)
              Text(
                language.nativeName,
                style: TextStyle(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            Row(
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
                Text(
                  '${language.region} • ${language.script}',
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(Icons.radio_button_unchecked),
        onTap: () {
          widget.onLanguageSelected(language.code);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
