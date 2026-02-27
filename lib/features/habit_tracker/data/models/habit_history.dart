import '../models/task_completion.dart';

/// Model untuk tracking habit/task completion history
/// Manages current streak, longest streak, dan completion statistics
class HabitHistory {
  final String taskId;
  final String taskName;
  final List<TaskCompletion> completions; // sorted by date
  final DateTime createdAt;

  HabitHistory({
    required this.taskId,
    required this.taskName,
    required this.completions,
    required this.createdAt,
  });

  /// Current streak (consecutive days dari today ke belakang)
  /// Returns 0 jika hari ini atau kemarin tidak ada completion
  int get currentStreak {
    if (completions.isEmpty) return 0;

    // Sort completions by date (descending)
    final sorted = List<TaskCompletion>.from(completions)
      ..sort((a, b) => b.completionDate.compareTo(a.completionDate));

    // Start dari today
    DateTime lastDate = DateTime.now();
    lastDate = DateTime(lastDate.year, lastDate.month, lastDate.day);

    int streak = 0;

    for (final completion in sorted) {
      final completionDate = completion.completionDate;

      // Check jika date match atau jika ada gap lebih dari 1 hari
      if (completionDate.difference(lastDate).inDays.abs() <= 1) {
        if (completionDate != lastDate) {
          // Valid consecutive day
          lastDate = completionDate;
          streak++;
        }
      } else {
        // Gap found
        break;
      }
    }

    return streak;
  }

  /// Longest streak ever achieved
  int get longestStreak {
    if (completions.isEmpty) return 0;

    // Sort by date
    final sorted = List<TaskCompletion>.from(completions)
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    int maxStreak = 1;
    int currentStreak = 1;
    DateTime lastDate = sorted[0].completionDate;

    for (int i = 1; i < sorted.length; i++) {
      final completionDate = sorted[i].completionDate;
      final daysDiff = completionDate.difference(lastDate).inDays;

      if (daysDiff == 1) {
        // Consecutive
        currentStreak++;
      } else if (daysDiff > 1) {
        // Gap
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        currentStreak = 1;
      }
      // if daysDiff == 0, same day, skip

      lastDate = completionDate;
    }

    maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
    return maxStreak;
  }

  /// Total completion count
  int get totalCompletions => completions.length;

  /// Completion rate (%)
  double get completionRate {
    if (completions.isEmpty) return 0.0;
    // Hmm, ini butuh total expected, untuk sekarang return based total
    return (totalCompletions / (daysSinceCreation + 1)) * 100;
  }

  /// Days sejak task dibuat
  int get daysSinceCreation {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// Get milestone status berdasarkan streak
  String getMilestoneEmoji() {
    final streak = currentStreak;
    if (streak >= 100) return '🏆'; // Trophy
    if (streak >= 30) return '🔥'; // Fire
    if (streak >= 7) return '⭐'; // Star
    if (streak >= 3) return '🎯'; // Target
    return '📌'; // Pin
  }

  /// Check jika completed hari ini
  bool get isCompletedToday {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return completions.any((c) => c.completionDate == todayDate);
  }

  /// Get completion dates untuk calendar view
  List<DateTime> get completionDates {
    return completions.map((c) => c.completionDate).toList()..sort();
  }

  /// Convert ke JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'completions': completions.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create dari JSON
  factory HabitHistory.fromJson(Map<String, dynamic> json) {
    return HabitHistory(
      taskId: json['taskId'] as String,
      taskName: json['taskName'] as String,
      completions: (json['completions'] as List? ?? [])
          .map((c) => TaskCompletion.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create copy dengan completion baru
  HabitHistory addCompletion(TaskCompletion completion) {
    final newCompletions = List<TaskCompletion>.from(completions)
      ..add(completion);
    return HabitHistory(
      taskId: taskId,
      taskName: taskName,
      completions: newCompletions,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'HabitHistory(taskId: $taskId, completions: $totalCompletions, currentStreak: $currentStreak)';
}
