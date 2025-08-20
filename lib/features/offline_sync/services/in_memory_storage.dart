import 'package:app/features/offline_sync/models/models.dart';

class InMemoryStorage {
  static final InMemoryStorage _instance = InMemoryStorage._internal();
  factory InMemoryStorage() => _instance;
  InMemoryStorage._internal();

  final List<Task> _tasks = [];
  final List<SyncQueue> _syncQueue = [];

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<SyncQueue> get syncQueue => List.unmodifiable(_syncQueue);

  // Method to get a copy of tasks that can be modified
  List<Task> getTasksCopy() => List.from(_tasks);

  void addTask(Task task) {
    _tasks.add(task);
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.uuid == task.uuid);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  void removeTask(String uuid) {
    _tasks.removeWhere((t) => t.uuid == uuid);
  }

  void addToSyncQueue(SyncQueue item) {
    _syncQueue.add(item);
  }

  void removeFromSyncQueue(int id) {
    _syncQueue.removeWhere((item) => item.id == id);
  }

  void clear() {
    _tasks.clear();
    _syncQueue.clear();
  }
}
