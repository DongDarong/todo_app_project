class Todo {
  final int id;
  final String title;
  final String? description;
  final String date;
  final String priority;
  final bool isDeleted;
  final String? deletedAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.priority,
    this.isDeleted = false,
    this.deletedAt,
  });

  // ================= FROM JSON =================
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'] ?? '',
      priority: json['priority'] ?? 'low',
      isDeleted: json['is_deleted'] == 1 ||
          json['is_deleted'] == true,
      deletedAt: json['deleted_at'],
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'priority': priority,
    };
  }

  // ================= COPY WITH =================
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? priority,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // ================= HELPERS =================
  bool get isHighPriority => priority == 'high';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, priority: $priority, deleted: $isDeleted)';
  }
}
