import 'package:flutter/material.dart';
import '../../../../data/datasources/remote/ai_chat_service.dart';

class ModelSelector extends StatelessWidget {
  final String selectedModel;
  final ValueChanged<String> onModelChanged;

  const ModelSelector({
    Key? key,
    required this.selectedModel,
    required this.onModelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              _getModelDisplayName(selectedModel),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
      onSelected: onModelChanged,
      itemBuilder: (context) => AIChatService.supportedModels.map((model) {
        final config = AIChatService.getModelConfig(model);
        return PopupMenuItem<String>(
          value: model,
          child: Row(
            children: [
              Radio<String>(
                value: model,
                groupValue: selectedModel,
                onChanged: (value) {
                  if (value != null) {
                    onModelChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config?.name ?? model,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (config != null)
                      Text(
                        config.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getModelDisplayName(String model) {
    final config = AIChatService.getModelConfig(model);
    return config?.name ?? model;
  }
}
