import 'package:uuid/uuid.dart';
import 'package:app/features/offline_sync/models/models.dart';
import 'package:app/features/offline_sync/services/database_service.dart';
import 'package:app/features/offline_sync/services/sync_service.dart';

// Task Repository
class TaskRepository {
  final DatabaseService _db = DatabaseService.instance;
  final SyncService _syncService = SyncService();

  Future<List<Task>> getAllTasks() async {
    await _db.init();
    return _db.storage.getTasksCopy();
  }

  Future<Task> createTask(String title, String description) async {
    await _db.init();

    final task = Task(
      uuid: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncAction: 'create',
    );

    _db.taskBox.put(task);
    _syncService.addToSyncQueue(task, 'create');

    return task;
  }

  Future<Task> updateTask(Task task) async {
    await _db.init();

    task.updatedAt = DateTime.now();
    task
      ..isSynced = false
      ..syncAction = 'update';

    _db.taskBox.put(task);
    _syncService.addToSyncQueue(task, 'update');

    return task;
  }

  Future<void> deleteTask(Task task) async {
    await _db.init();

    task
      ..isDeleted = true
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..syncAction = 'delete';

    _db.taskBox.put(task);
    _syncService.addToSyncQueue(task, 'delete');
  }

  Stream<List<Task>> watchTasks() {
    // For now, return stream of current tasks
    // TODO: Implement proper ObjectBox streams when database is set up
    // Note: This method doesn't initialize the database, so it might fail
    // if called before any other method that initializes it
    try {
      return Stream.value(_db.storage.getTasksCopy());
    } catch (e) {
      return Stream.value(<Task>[]);
    }
  }
}
