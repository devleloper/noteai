import 'package:flutter/material.dart';
import '../../../../core/utils/date_grouping_utils.dart';

/// Widget for displaying date headers in the recordings list
class DateHeaderWidget extends StatelessWidget {
  final DateHeaderItem dateHeader;

  const DateHeaderWidget({
    Key? key,
    required this.dateHeader,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        dateHeader.displayText,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
