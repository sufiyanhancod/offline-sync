import 'package:flutter/material.dart';
import 'package:app/features/offline_sync/offline_sync_app.dart';
import 'package:app/features/offline_sync/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  runApp(const OfflineSyncApp());
}
