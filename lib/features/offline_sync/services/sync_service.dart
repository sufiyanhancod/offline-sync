import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app/features/offline_sync/models/models.dart';
import 'package:app/features/offline_sync/services/api_service.dart';
import 'package:app/features/offline_sync/services/database_service.dart';

// Sync Service
class SyncService {
  final DatabaseService _db = DatabaseService.instance;
  final ApiService _api = ApiService();
  final Connectivity _connectivity = Connectivity();

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Sync from server to local
  Future<void> syncFromServer() async {
    if (!await isOnline()) return;

    try {
      final serverTasks = await _api.getTasks();
      final taskBox = _db.taskBox;

      for (final serverTask in serverTasks) {
        // For now, we'll use a simple approach without ObjectBox queries
        // TODO: Implement proper ObjectBox queries when database is set up
        serverTask.isSynced = true;
        taskBox.put(serverTask);
      }
    } catch (e) {
      print('Sync from server failed: $e');
    }
  }

  // Sync local changes to server
  Future<void> syncToServer() async {
    if (!await isOnline()) return;

    final syncQueueBox = _db.syncQueueBox;
    final taskBox = _db.taskBox;
    final queueItems = syncQueueBox.getAll();

    for (final queueItem in queueItems) {
      try {
        switch (queueItem.action) {
          case 'create':
            final taskData =
                json.decode(queueItem.data) as Map<String, dynamic>;
            final task = Task.fromJson(taskData);
            await _api.createTask(task);

            // For now, we'll use a simple approach without ObjectBox queries
            // TODO: Implement proper ObjectBox queries when database is set up
            break;

          case 'update':
            final taskData =
                json.decode(queueItem.data) as Map<String, dynamic>;
            final task = Task.fromJson(taskData);
            await _api.updateTask(task);

            // TODO: Implement proper ObjectBox queries when database is set up
            break;

          case 'delete':
            await _api.deleteTask(queueItem.taskUuid);

            // TODO: Implement proper ObjectBox queries when database is set up
            break;
        }

        syncQueueBox.remove(queueItem.id);
      } catch (e) {
        queueItem.retryCount++;
        if (queueItem.retryCount >= 3) {
          syncQueueBox.remove(queueItem.id);
        } else {
          syncQueueBox.put(queueItem);
        }
        print('Sync item failed: $e');
      }
    }
  }

  // Full sync operation
  Future<void> performFullSync() async {
    await syncFromServer();
    await syncToServer();
  }

  // Add item to sync queue
  void addToSyncQueue(Task task, String action) {
    try {
      final syncQueue = SyncQueue(
        taskUuid: task.uuid,
        action: action,
        data: json.encode(task.toJson()),
        timestamp: DateTime.now(),
      );
      _db.syncQueueBox.put(syncQueue);
    } catch (e) {
      // If database is not initialized, we'll skip adding to sync queue
      print('Failed to add to sync queue: $e');
    }
  }
}
