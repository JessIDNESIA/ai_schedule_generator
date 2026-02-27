class Task {
  final String id;
  final String name;
  final String priority; // "Tinggi", "Sedang", "Rendah"
  final int duration; // dalam menit
  final DateTime createdAt;

  Task({
    required this.id,
    required this.name,
    required this.priority,
    required this.duration,
    required this.createdAt,
  });

  /// Convert to JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'priority': priority,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create dari JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
      priority: json['priority'] as String,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert ke Map untuk AI prompt
  /// Format: "- [name] (Prioritas: [priority], Durasi: [duration] menit)"
  Map<String, dynamic> toSchedulePromptMap() {
    return {'name': name, 'priority': priority, 'duration': duration};
  }

  /// Create copy dengan perubahan
  Task copyWith({
    String? id,
    String? name,
    String? priority,
    int? duration,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          priority == other.priority &&
          duration == other.duration &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      priority.hashCode ^
      duration.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'Task(id: $id, name: $name, priority: $priority, duration: $duration)';
}
