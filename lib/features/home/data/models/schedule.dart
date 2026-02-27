class Schedule {
  final String id;
  final List<String> taskIds; // referensi ke task IDs
  final String rawContent; // Raw markdown dari AI
  final String formattedContent; // Formatted version
  final DateTime generatedAt;

  Schedule({
    required this.id,
    required this.taskIds,
    required this.rawContent,
    required this.formattedContent,
    required this.generatedAt,
  });

  /// Convert ke JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskIds': taskIds,
      'rawContent': rawContent,
      'formattedContent': formattedContent,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// Create dari JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      taskIds: List<String>.from(json['taskIds'] as List ?? []),
      rawContent: json['rawContent'] as String,
      formattedContent: json['formattedContent'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  /// Create copy dengan perubahan
  Schedule copyWith({
    String? id,
    List<String>? taskIds,
    String? rawContent,
    String? formattedContent,
    DateTime? generatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      taskIds: taskIds ?? this.taskIds,
      rawContent: rawContent ?? this.rawContent,
      formattedContent: formattedContent ?? this.formattedContent,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// Get durasi total dari tasks
  int getTotalDuration() {
    // Akan diimplementasikan setelah punya akses ke repository
    return 0; // placeholder
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Schedule &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rawContent == other.rawContent &&
          generatedAt == other.generatedAt;

  @override
  int get hashCode => id.hashCode ^ rawContent.hashCode ^ generatedAt.hashCode;

  @override
  String toString() =>
      'Schedule(id: $id, tasks: ${taskIds.length}, generatedAt: $generatedAt)';
}
