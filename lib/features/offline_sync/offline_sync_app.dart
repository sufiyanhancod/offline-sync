import 'package:flutter/material.dart';
import 'package:app/features/offline_sync/presentation/task_list_screen.dart';
import 'package:app/features/offline_sync/services/database_service.dart';

class OfflineSyncApp extends StatelessWidget {
  const OfflineSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Sync Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}
