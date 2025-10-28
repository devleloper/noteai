import 'package:flutter/material.dart';
import '../../../../domain/entities/summarization_state.dart';
import 'summarization_loading_widget.dart';
import 'summarization_error_widget.dart';
import 'summarization_progress_indicator.dart';
import 'summarization_success_widget.dart';

class SummarizationWidget extends StatelessWidget {
  final SummarizationState? summarizationState;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final VoidCallback? onViewFullSummary;
  final VoidCallback? onCopySummary;
  final VoidCallback? onCancel;

  const SummarizationWidget({
    super.key,
    this.summarizationState,
    this.onRetry,
    this.onDismiss,
    this.onViewFullSummary,
    this.onCopySummary,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (summarizationState == null) {
      return const SizedBox.shrink();
    }

    switch (summarizationState!.status) {
      case SummarizationStatus.pending:
        return SummarizationProgressIndicator(
          message: 'Preparing to summarize...',
          retryAttempts: summarizationState!.retryAttempts,
          onCancel: onCancel,
        );

      case SummarizationStatus.generating:
        return SummarizationProgressIndicator(
          message: 'Summarizing your recording...',
          retryAttempts: summarizationState!.retryAttempts,
          onCancel: onCancel,
        );

      case SummarizationStatus.completed:
        if (summarizationState!.generatedSummary != null) {
          return SummarizationSuccessWidget(
            summary: summarizationState!.generatedSummary!,
            onViewFullSummary: onViewFullSummary,
            onCopySummary: onCopySummary,
          );
        } else {
          // Fallback to loading widget if no summary text
          return SummarizationLoadingWidget(
            message: 'Summary completed',
            retryAttempts: summarizationState!.retryAttempts,
          );
        }

      case SummarizationStatus.failed:
        return SummarizationErrorWidget(
          error: summarizationState!.error ?? 'Unknown error occurred',
          onRetry: onRetry ?? () {},
          onDismiss: onDismiss,
          retryAttempts: summarizationState!.retryAttempts,
          canRetry: summarizationState!.retryAttempts < 5, // Max 5 retries
        );
    }
  }
}

/// Helper widget to show summarization status in a compact format
class SummarizationStatusIndicator extends StatelessWidget {
  final SummarizationState? summarizationState;
  final VoidCallback? onTap;

  const SummarizationStatusIndicator({
    super.key,
    this.summarizationState,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (summarizationState == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    Color color;
    IconData icon;
    String text;

    switch (summarizationState!.status) {
      case SummarizationStatus.pending:
        color = theme.colorScheme.outline;
        icon = Icons.schedule;
        text = 'Pending';
        break;
      case SummarizationStatus.generating:
        color = theme.colorScheme.primary;
        icon = Icons.autorenew;
        text = 'Generating';
        break;
      case SummarizationStatus.completed:
        color = theme.colorScheme.primary;
        icon = Icons.check_circle;
        text = 'Completed';
        break;
      case SummarizationStatus.failed:
        color = theme.colorScheme.error;
        icon = Icons.error;
        text = 'Failed';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (summarizationState!.retryAttempts > 0) ...[
              const SizedBox(width: 4),
              Text(
                '(${summarizationState!.retryAttempts})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
