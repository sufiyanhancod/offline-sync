# Offline Sync Feature

This feature provides offline-first task management with automatic synchronization when connectivity is restored.

## Features

- **Offline-First**: Tasks are stored locally and can be created, updated, and deleted without internet connection
- **Automatic Sync**: Changes are queued and synchronized when connectivity is restored
- **Conflict Resolution**: Server changes take precedence over local changes
- **Retry Logic**: Failed sync operations are retried up to 3 times

## Architecture

### Models
- `Task`: Represents a task with sync metadata
- `SyncQueue`: Queues sync operations for offline changes

### Services
- `DatabaseService`: Manages local data storage (currently in-memory, can be replaced with ObjectBox)
- `ApiService`: Handles HTTP communication with the server
- `SyncService`: Orchestrates synchronization between local and remote data

### Repositories
- `TaskRepository`: Provides a clean interface for task operations

## Usage

### Basic Task Operations

```dart
final repository = TaskRepository();

// Create a task
final task = await repository.createTask('Task Title', 'Task Description');

// Update a task
task.isCompleted = true;
await repository.updateTask(task);

// Delete a task
await repository.deleteTask(task);
```

### Manual Sync

```dart
final syncService = SyncService();

// Check connectivity
final isOnline = await syncService.isOnline();

// Perform full sync
await syncService.performFullSync();
```

### Testing

To test the offline sync functionality:

1. Run the test app:
   ```bash
   flutter run -t lib/features/offline_sync/test_offline_sync.dart
   ```

2. Create tasks while offline
3. Toggle connectivity and observe sync behavior
4. Check sync status indicators on tasks

## Current Implementation

The current implementation uses in-memory storage for simplicity. To use ObjectBox:

1. Ensure ObjectBox is properly configured
2. Replace `InMemoryStorage` with actual ObjectBox implementation
3. Update `DatabaseService` to use ObjectBox
4. Generate ObjectBox model files

## Dependencies

- `objectbox: ^4.0.0` - Local database
- `http: ^1.1.0` - HTTP client
- `connectivity_plus: ^5.0.0` - Connectivity detection
- `uuid: ^4.0.0` - Unique identifier generation

## Future Enhancements

- Real-time sync using WebSockets
- Conflict resolution strategies
- Data compression for large datasets
- Background sync scheduling
- Offline analytics and metrics
