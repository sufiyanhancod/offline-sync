import 'package:flutter/material.dart';
import 'package:app/features/offline_sync/models/models.dart';
import 'package:app/features/offline_sync/repositories/task_repository.dart';
import 'package:app/features/offline_sync/services/sync_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskRepository _repository = TaskRepository();
  final SyncService _syncService = SyncService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSyncing = false;
  bool _isOnline = false;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _checkConnectivity();
  }

  Future<void> _initializeApp() async {
    try {
      final tasks = await _repository.getAllTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
        });
      }
    } catch (e) {
      print('Failed to initialize app: $e');
      if (mounted) {
        setState(() {
          _tasks = [];
        });
      }
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final isOnline = await _syncService.isOnline();
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    } catch (e) {
      print('Failed to check connectivity: $e');
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _syncService.performFullSync();
      await _checkConnectivity();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully')),
        );
      }
    } catch (e) {
      print('Sync failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showAddTaskDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                await _repository.createTask(
                  _titleController.text,
                  _descriptionController.text,
                );
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
                // Refresh the list from repository
                if (mounted) {
                  await _initializeApp();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isOnline ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _checkConnectivity,
          ),
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _performSync,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tasks yet', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Add your first task to get started'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) async {
                        task.isCompleted = value ?? false;
                        await _repository.updateTask(task);
                        // Refresh the list
                        if (mounted) {
                          await _initializeApp();
                        }
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              task.isSynced
                                  ? Icons.cloud_done
                                  : Icons.cloud_queue,
                              size: 16,
                              color:
                                  task.isSynced ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.isSynced ? 'Synced' : 'Pending sync',
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isSynced
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _repository.deleteTask(task);
                        // Refresh the list
                        if (mounted) {
                          await _initializeApp();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
