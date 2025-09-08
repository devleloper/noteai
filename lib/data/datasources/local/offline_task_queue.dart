import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/exceptions.dart';

enum TaskType {
  transcribe,
  summarize,
  sync,
}

enum TaskStatus {
  pending,
  processing,
  completed,
  failed,
}

class OfflineTask {
  final String id;
  final TaskType type;
  final Map<String, dynamic> data;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;

  OfflineTask({
    required this.id,
    required this.type,
    required this.data,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'error': error,
    };
  }

  factory OfflineTask.fromJson(Map<String, dynamic> json) {
    return OfflineTask(
      id: json['id'],
      type: TaskType.values.firstWhere((e) => e.name == json['type']),
      data: json['data'],
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      error: json['error'],
    );
  }

  OfflineTask copyWith({
    String? id,
    TaskType? type,
    Map<String, dynamic>? data,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? error,
  }) {
    return OfflineTask(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
    );
  }
}

class OfflineTaskQueue {
  static const String _tasksKey = 'offline_tasks';
  static final OfflineTaskQueue _instance = OfflineTaskQueue._internal();
  factory OfflineTaskQueue() => _instance;
  OfflineTaskQueue._internal();

  List<OfflineTask> _tasks = [];
  bool _isProcessing = false;

  List<OfflineTask> get tasks => List.unmodifiable(_tasks);
  List<OfflineTask> get pendingTasks => _tasks.where((task) => task.status == TaskStatus.pending).toList();
  List<OfflineTask> get failedTasks => _tasks.where((task) => task.status == TaskStatus.failed).toList();

  Future<void> initialize() async {
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];
      _tasks = tasksJson.map((json) => OfflineTask.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      throw CacheException('Failed to load offline tasks: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _tasks.map((task) => jsonEncode(task.toJson())).toList();
      await prefs.setStringList(_tasksKey, tasksJson);
    } catch (e) {
      throw CacheException('Failed to save offline tasks: $e');
    }
  }

  Future<String> addTask(TaskType type, Map<String, dynamic> data) async {
    try {
      final taskId = DateTime.now().millisecondsSinceEpoch.toString();
      final task = OfflineTask(
        id: taskId,
        type: type,
        data: data,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
      );

      _tasks.add(task);
      await _saveTasks();

      // Start processing if not already running
      if (!_isProcessing) {
        _processTasks();
      }

      return taskId;
    } catch (e) {
      throw CacheException('Failed to add offline task: $e');
    }
  }

  Future<void> _processTasks() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final pendingTasks = this.pendingTasks;
      for (final task in pendingTasks) {
        await _processTask(task);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processTask(OfflineTask task) async {
    try {
      // Update task status to processing
      await _updateTaskStatus(task.id, TaskStatus.processing);

      // Process based on task type
      switch (task.type) {
        case TaskType.transcribe:
          await _processTranscribeTask(task);
          break;
        case TaskType.summarize:
          await _processSummarizeTask(task);
          break;
        case TaskType.sync:
          await _processSyncTask(task);
          break;
      }

      // Mark as completed
      await _updateTaskStatus(task.id, TaskStatus.completed, completedAt: DateTime.now());
    } catch (e) {
      // Mark as failed
      await _updateTaskStatus(task.id, TaskStatus.failed, error: e.toString());
    }
  }

  Future<void> _processTranscribeTask(OfflineTask task) async {
    // This would integrate with OpenAI API for transcription
    // For now, we'll simulate the process
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real implementation, this would:
    // 1. Call OpenAI Whisper API
    // 2. Save transcript to database
    // 3. Update recording status
  }

  Future<void> _processSummarizeTask(OfflineTask task) async {
    // This would integrate with OpenAI API for summarization
    // For now, we'll simulate the process
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real implementation, this would:
    // 1. Call OpenAI GPT API
    // 2. Save summary to database
    // 3. Update recording status
  }

  Future<void> _processSyncTask(OfflineTask task) async {
    // This would sync data with Firebase
    // For now, we'll simulate the process
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real implementation, this would:
    // 1. Check network connectivity
    // 2. Sync recordings with Firebase
    // 3. Update sync status
  }

  Future<void> _updateTaskStatus(String taskId, TaskStatus status, {DateTime? completedAt, String? error}) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        status: status,
        completedAt: completedAt,
        error: error,
      );
      await _saveTasks();
    }
  }

  Future<void> retryFailedTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        status: TaskStatus.pending,
        error: null,
      );
      await _saveTasks();
      
      if (!_isProcessing) {
        _processTasks();
      }
    }
  }

  Future<void> removeTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((task) => task.status == TaskStatus.completed);
    await _saveTasks();
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _saveTasks();
  }
}
