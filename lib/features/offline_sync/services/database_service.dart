import 'package:app/features/offline_sync/models/models.dart';
import 'package:app/features/offline_sync/services/in_memory_storage.dart';

// Simple Box interface to simulate ObjectBox
abstract class Box<T> {
  void put(T item);
  List<T> getAll();
  void remove(int id);
}

class DatabaseService {
  DatabaseService._();
  static DatabaseService? _instance;
  InMemoryStorage? _storage;

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<void> init() async {
    if (_storage != null) return;
    _storage = InMemoryStorage();
  }

  InMemoryStorage get storage {
    if (_storage == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _storage!;
  }

  // Simulate ObjectBox Box interface
  Box<Task> get taskBox => _TaskBox(_storage!);
  Box<SyncQueue> get syncQueueBox => _SyncQueueBox(_storage!);

  void close() {
    _storage = null;
  }
}

// Simulate ObjectBox Box interface
class _TaskBox implements Box<Task> {
  _TaskBox(this._storage);
  final InMemoryStorage _storage;

  @override
  void put(Task task) {
    if (task.id == 0) {
      task.id = DateTime.now().millisecondsSinceEpoch;
    }
    _storage.addTask(task);
  }

  @override
  List<Task> getAll() {
    return _storage.tasks;
  }

  @override
  void remove(int id) {
    final task = _storage.tasks.firstWhere((t) => t.id == id);
    _storage.removeTask(task.uuid);
  }
}

class _SyncQueueBox implements Box<SyncQueue> {
  _SyncQueueBox(this._storage);
  final InMemoryStorage _storage;

  @override
  void put(SyncQueue item) {
    if (item.id == 0) {
      item.id = DateTime.now().millisecondsSinceEpoch;
    }
    _storage.addToSyncQueue(item);
  }

  @override
  List<SyncQueue> getAll() {
    return _storage.syncQueue;
  }

  @override
  void remove(int id) {
    _storage.removeFromSyncQueue(id);
  }
}
