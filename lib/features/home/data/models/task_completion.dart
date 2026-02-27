class TaskCompletion {
  final String id;
  final String taskId;
  final DateTime completedAt;
  final int durationTaken; // actual waktu yang diambil

  TaskCompletion({
    required this.id,
    required this.taskId,
    required this.completedAt,
    required this.durationTaken,
  });

  /// Get date saja (tanpa waktu)
  DateTime get completionDate {
    return DateTime(completedAt.year, completedAt.month, completedAt.day);
  }

  /// Convert ke JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'completedAt': completedAt.toIso8601String(),
      'durationTaken': durationTaken,
    };
  }

  /// Create dari JSON
  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationTaken: json['durationTaken'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCompletion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          taskId == other.taskId &&
          completedAt == other.completedAt;

  @override
  int get hashCode => id.hashCode ^ taskId.hashCode ^ completedAt.hashCode;

  @override
  String toString() =>
      'TaskCompletion(taskId: $taskId, completedAt: $completedAt)';
}
