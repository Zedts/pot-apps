import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import '../models/activity_history_model.dart';
import '../storage/token_storage.dart';

/// Stores the limited, device-local operational audit trail used by Riwayat.
class ActivityHistoryService {
  static const _databaseName = 'pot_activity_history.db';
  static const _tableName = 'activity_history';
  static const _supportedActivityTypes = {
    AppConstants.activityClockIn,
    AppConstants.activityClockOut,
    AppConstants.activityReceiveGoods,
    AppConstants.activityProcessSale,
    AppConstants.activityDailyClosing,
    AppConstants.activityProfileUpdated,
  };
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final databasePath = join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            lapak_id TEXT,
            activity_type TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            occurred_at TEXT NOT NULL,
            reference_id TEXT,
            event_key TEXT NOT NULL UNIQUE
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_activity_history_user_time '
          'ON $_tableName(user_id, occurred_at DESC)',
        );
      },
    );
    return _database!;
  }

  /// Saves a completed action. Local logging must never interrupt its source flow.
  Future<void> record(ActivityHistoryModel entry) async {
    if (!_supportedActivityTypes.contains(entry.activityType)) return;
    try {
      final cachedUser = entry.userId.trim().isEmpty
          ? await TokenStorage.getUser()
          : null;
      if (entry.userId.trim().isEmpty && cachedUser == null) return;
      final entryToSave = cachedUser == null
          ? entry
          : ActivityHistoryModel(
              userId: cachedUser.id,
              lapakId: entry.lapakId ?? cachedUser.lapakId,
              activityType: entry.activityType,
              title: entry.title,
              description: entry.description,
              occurredAt: entry.occurredAt,
              referenceId: entry.referenceId,
            );
      final db = await _db;
      await db.insert(
        _tableName,
        entryToSave.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (error) {
      debugPrint('[ActivityHistoryService] Failed to save activity: $error');
    }
  }

  Future<List<ActivityHistoryModel>> getForUser(String userId) async {
    final db = await _db;
    final rows = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'occurred_at DESC',
    );
    return rows.map(ActivityHistoryModel.fromMap).toList();
  }
}
