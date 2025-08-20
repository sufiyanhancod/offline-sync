import 'package:objectbox/objectbox.dart';

@Entity()
class Task {
  @Id()
  int id = 0;

  @Unique()
  String uuid;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;
  bool isDeleted;
  String syncAction; // 'create', 'update', 'delete'

  Task({
    required this.uuid,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAction = 'create',
  });

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        uuid: json['uuid'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Task copyWith({
    String? uuid,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? syncAction,
  }) {
    return Task(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      syncAction: syncAction ?? this.syncAction,
    );
  }
}
