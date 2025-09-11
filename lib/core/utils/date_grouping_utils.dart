import 'package:flutter/material.dart';
import '../../domain/entities/recording.dart';

/// Utility class for grouping recordings by date
class DateGroupingUtils {
  /// Groups recordings by date and returns a list of grouped items
  static List<GroupedRecordingItem> groupRecordingsByDate(List<Recording> recordings) {
    if (recordings.isEmpty) return [];

    // Sort recordings by date (newest first)
    final sortedRecordings = List<Recording>.from(recordings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<Recording>> groupedMap = {};
    
    for (final recording in sortedRecordings) {
      final dateKey = _getDateKey(recording.createdAt);
      groupedMap.putIfAbsent(dateKey, () => []).add(recording);
    }

    final List<GroupedRecordingItem> groupedItems = [];
    
    // Convert to list maintaining chronological order (newest first)
    final sortedKeys = groupedMap.keys.toList()
      ..sort((a, b) => _parseDateKey(b).compareTo(_parseDateKey(a)));
    
    for (final dateKey in sortedKeys) {
      final recordings = groupedMap[dateKey]!;
      groupedItems.add(GroupedRecordingItem.dateHeader(
        date: _parseDateKey(dateKey),
        displayText: _formatDateForDisplay(_parseDateKey(dateKey)),
      ));
      
      for (final recording in recordings) {
        groupedItems.add(GroupedRecordingItem.recording(recording));
      }
    }
    
    return groupedItems;
  }

  /// Gets a date key for grouping (YYYY-MM-DD format)
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parses a date key back to DateTime
  static DateTime _parseDateKey(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]), // year
      int.parse(parts[1]), // month
      int.parse(parts[2]), // day
    );
  }

  /// Formats a date for display (Today, Yesterday, or formatted date)
  static String _formatDateForDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "Monday, Jan 15" or similar
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      final weekday = weekdays[date.weekday - 1];
      final month = months[date.month - 1];
      final day = date.day;
      
      return '$weekday, $month $day';
    }
  }
}

/// Represents an item in the grouped recordings list
abstract class GroupedRecordingItem {
  const GroupedRecordingItem();

  /// Creates a date header item
  factory GroupedRecordingItem.dateHeader({
    required DateTime date,
    required String displayText,
  }) = DateHeaderItem;

  /// Creates a recording item
  factory GroupedRecordingItem.recording(Recording recording) = RecordingItem;

  /// Returns true if this is a date header
  bool get isDateHeader => this is DateHeaderItem;

  /// Returns true if this is a recording
  bool get isRecording => this is RecordingItem;
}

/// Date header item in the grouped list
class DateHeaderItem extends GroupedRecordingItem {
  final DateTime date;
  final String displayText;

  const DateHeaderItem({
    required this.date,
    required this.displayText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateHeaderItem &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          displayText == other.displayText;

  @override
  int get hashCode => date.hashCode ^ displayText.hashCode;
}

/// Recording item in the grouped list
class RecordingItem extends GroupedRecordingItem {
  final Recording recording;

  const RecordingItem(this.recording);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingItem &&
          runtimeType == other.runtimeType &&
          recording == other.recording;

  @override
  int get hashCode => recording.hashCode;
}
