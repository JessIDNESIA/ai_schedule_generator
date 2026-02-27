import '../features/home/data/models/task.dart';
import '../features/home/data/models/schedule.dart';
import '../features/home/data/models/task_completion.dart';

/// Abstract interface untuk semua operasi penyimpanan data
/// Implementation dapat menggunakan Hive, SQLite, atau backend API
abstract class PersistenceService {
  /// ===== TASK OPERATIONS =====

  /// Simpan satu task
  Future<void> saveTask(Task task);

  /// Simpan multiple tasks
  Future<void> saveTasks(List<Task> tasks);

  /// Get task by ID
  Future<Task?> getTask(String id);

  /// Get semua tasks
  Future<List<Task>> getAllTasks();

  /// Update task
  Future<void> updateTask(Task task);

  /// Delete task by ID
  Future<void> deleteTask(String id);

  /// Delete semua tasks
  Future<void> deleteAllTasks();

  /// ===== SCHEDULE OPERATIONS =====

  /// Simpan schedule
  Future<void> saveSchedule(Schedule schedule);

  /// Get schedule by ID
  Future<Schedule?> getSchedule(String id);

  /// Get latest schedule
  Future<Schedule?> getLatestSchedule();

  /// Get semua schedules
  Future<List<Schedule>> getAllSchedules();

  /// Delete schedule by ID
  Future<void> deleteSchedule(String id);

  /// ===== TASK COMPLETION OPERATIONS =====

  /// Simpan task completion record
  Future<void> saveTaskCompletion(TaskCompletion completion);

  /// Get completions untuk task ID
  Future<List<TaskCompletion>> getCompletionsForTask(String taskId);

  /// Get completions pada date
  Future<List<TaskCompletion>> getCompletionsOnDate(DateTime date);

  /// Delete completion record
  Future<void> deleteTaskCompletion(String id);

  /// ===== SETTINGS OPERATIONS =====

  /// Save key-value setting
  Future<void> saveSetting(String key, dynamic value);

  /// Get setting value
  Future<dynamic> getSetting(String key, {dynamic defaultValue});

  /// Delete setting
  Future<void> deleteSetting(String key);

  /// ===== UTILITY OPERATIONS =====

  /// Clear semua data (reset app)
  Future<void> clearAll();

  /// Check if storage sudah initialized
  Future<bool> isInitialized();

  /// Initialize storage
  Future<void> initialize();

  /// Close/cleanup storage
  Future<void> close();
}
