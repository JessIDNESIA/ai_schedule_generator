import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../../data/models/schedule.dart';
import '../../../services/gemini_service.dart';
import 'package:uuid/uuid.dart';

/// Provider untuk manage state home screen
/// Handles task management, schedule generation, dan loading states
class HomeProvider extends ChangeNotifier {
  /// Task list
  final List<Task> _tasks = [];

  /// Current schedule
  Schedule? _currentSchedule;

  /// Loading state
  bool _isLoadingSchedule = false;

  /// Error message
  String? _errorMessage;

  /// Get tasks sebagai unmodifiable list
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Get current schedule
  Schedule? get currentSchedule => _currentSchedule;

  /// Get loading state
  bool get isLoadingSchedule => _isLoadingSchedule;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Total duration semua tasks
  int get totalDuration {
    return _tasks.fold(0, (sum, task) => sum + task.duration);
  }

  /// Task count
  int get taskCount => _tasks.length;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Add task
  void addTask({
    required String name,
    required String priority,
    required int duration,
  }) {
    if (name.isEmpty || duration <= 0) {
      _errorMessage = 'Nama task dan durasi harus valid';
      notifyListeners();
      return;
    }

    const uuid = Uuid();
    final task = Task(
      id: uuid.v4(),
      name: name,
      priority: priority,
      duration: duration,
      createdAt: DateTime.now(),
    );

    _tasks.add(task);
    _errorMessage = null;
    notifyListeners();
  }

  /// Update task
  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  /// Delete task by ID
  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  /// Delete all tasks
  void deleteAllTasks() {
    _tasks.clear();
    notifyListeners();
  }

  /// Generate schedule using AI
  Future<void> generateSchedule() async {
    // Validasi
    if (_tasks.isEmpty) {
      _errorMessage = 'Tambahkan minimal satu task sebelum generate jadwal';
      notifyListeners();
      return;
    }

    _isLoadingSchedule = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert tasks to map untuk API
      final taskMaps = _tasks
          .map((task) => {
                'name': task.name,
                'priority': task.priority,
                'duration': task.duration,
              })
          .toList();

      // Call AI service
      final scheduleContent = await GeminiService.generateSchedule(taskMaps);

      // Create schedule object
      const uuid = Uuid();
      _currentSchedule = Schedule(
        id: uuid.v4(),
        taskIds: _tasks.map((t) => t.id).toList(),
        rawContent: scheduleContent,
        formattedContent: scheduleContent, // TODO: Format markdown
        generatedAt: DateTime.now(),
      );

      _isLoadingSchedule = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoadingSchedule = false;
      _errorMessage = 'Error generating schedule: $e';
      notifyListeners();
    }
  }

  /// Reset untuk new schedule creation
  void reset() {
    _tasks.clear();
    _currentSchedule = null;
    _errorMessage = null;
    notifyListeners();
  }
}
