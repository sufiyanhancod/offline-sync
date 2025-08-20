import 'package:objectbox/objectbox.dart';

@Entity()
class SyncQueue {
  @Id()
  int id = 0;

  String taskUuid;
  String action; // 'create', 'update', 'delete'
  String data; // JSON string of task data
  DateTime timestamp;
  int retryCount;

  SyncQueue({
    required this.taskUuid,
    required this.action,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });
}
