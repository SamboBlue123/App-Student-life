import 'dart:convert';

class Task {
  final String id;
  final String description;
  final DateTime dueDate;
  final bool isDone;
  final bool isExam;

  Task({
    required this.id,
    required this.description,
    required this.dueDate,
    this.isDone = false,
    this.isExam = false,
  });

  Task copyWith({
    String? id,
    String? description,
    DateTime? dueDate,
    bool? isDone,
    bool? isExam,
  }) {
    return Task(
      id: id ?? this.id,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      isExam: isExam ?? this.isExam,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone,
      'isExam': isExam,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isDone: json['isDone'] as bool,
      isExam: json['isExam'] as bool,
    );
  }

  static List<Task> decodeList(String? source) {
    if (source == null || source.isEmpty) {
      return <Task>[];
    }

    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Task.fromJson)
        .toList();
  }

  static String encodeList(List<Task> tasks) {
    return jsonEncode(tasks.map((task) => task.toJson()).toList());
  }
}
