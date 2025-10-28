import 'package:flutter/material.dart';
import '../../../../domain/entities/summarization_state.dart';
import 'summarization_widget.dart';

/// Demo widget to showcase all summarization UI components
/// This is useful for testing and development
class SummarizationUIDemo extends StatefulWidget {
  const SummarizationUIDemo({super.key});

  @override
  State<SummarizationUIDemo> createState() => _SummarizationUIDemoState();
}

class _SummarizationUIDemoState extends State<SummarizationUIDemo> {
  SummarizationStatus _currentStatus = SummarizationStatus.pending;
  int _retryAttempts = 0;
  String _error = 'Network connection failed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summarization UI Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SummarizationStatus.values.map((status) {
                        return ChoiceChip(
                          label: Text(status.name),
                          selected: _currentStatus == status,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _currentStatus = status;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Retry Attempts: $_retryAttempts'),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _retryAttempts = (_retryAttempts + 1) % 6;
                            });
                          },
                          child: const Text('Increment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Demo widget
            Text(
              'Summarization Widget Demo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            SummarizationWidget(
              summarizationState: _createDemoState(),
              onRetry: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Retry pressed')),
                );
              },
              onDismiss: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dismiss pressed')),
                );
              },
              onViewFullSummary: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View full summary pressed')),
                );
              },
              onCopySummary: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copy summary pressed')),
                );
              },
              onCancel: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cancel pressed')),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Status indicator demo
            Text(
              'Status Indicator Demo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SummarizationStatus.values.map((status) {
                return SummarizationStatusIndicator(
                  summarizationState: SummarizationState(
                    recordingId: 'demo',
                    status: status,
                    retryAttempts: status == SummarizationStatus.failed ? 2 : 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${status.name} indicator tapped')),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  SummarizationState _createDemoState() {
    return SummarizationState(
      recordingId: 'demo-recording',
      status: _currentStatus,
      retryAttempts: _retryAttempts,
      error: _currentStatus == SummarizationStatus.failed ? _error : null,
      generatedSummary: _currentStatus == SummarizationStatus.completed
          ? 'This is a sample summary of the recording. It contains the main points and key insights from the conversation. The summary provides a concise overview of the content.'
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
