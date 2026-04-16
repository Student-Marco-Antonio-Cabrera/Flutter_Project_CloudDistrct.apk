import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sync_operation.dart';
import 'database_service.dart';

class SyncService {
  SyncService({
    FirebaseFirestore? firestore,
    DatabaseService? databaseService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _databaseService = databaseService ?? DatabaseService.instance;

  final FirebaseFirestore _firestore;
  final DatabaseService _databaseService;

  Future<void> writeThroughSet({
    required String documentPath,
    required Map<String, dynamic> data,
    String? userUid,
    bool merge = true,
  }) async {
    try {
      await _firestore.doc(documentPath).set(
        _toFirestoreMap(data),
        SetOptions(merge: merge),
      );
    } catch (_) {
      await _databaseService.enqueueSyncOperation(
        SyncOperation(
          documentPath: documentPath,
          action: SyncAction.set,
          payload: _encodePayload(data),
          userUid: userUid,
          merge: merge,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  Future<void> writeThroughUpdate({
    required String documentPath,
    required Map<String, dynamic> data,
    String? userUid,
  }) async {
    try {
      await _firestore.doc(documentPath).update(_toFirestoreMap(data));
    } catch (_) {
      await _databaseService.enqueueSyncOperation(
        SyncOperation(
          documentPath: documentPath,
          action: SyncAction.update,
          payload: _encodePayload(data),
          userUid: userUid,
          merge: false,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  Future<void> writeThroughDelete({
    required String documentPath,
    String? userUid,
  }) async {
    try {
      await _firestore.doc(documentPath).delete();
    } catch (_) {
      await _databaseService.enqueueSyncOperation(
        SyncOperation(
          documentPath: documentPath,
          action: SyncAction.delete,
          payload: const <String, dynamic>{},
          userUid: userUid,
          merge: false,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  Future<void> flushPendingOperations({
    String? userUid,
    int batchSize = 100,
  }) async {
    final operations = await _databaseService.getPendingSyncOperations(
      userUid: userUid,
      limit: batchSize,
    );

    for (final operation in operations) {
      final operationId = operation.id;
      if (operationId == null) {
        continue;
      }

      try {
        final reference = _firestore.doc(operation.documentPath);
        final data = _decodePayload(operation.payload);

        switch (operation.action) {
          case SyncAction.set:
            await reference.set(
              _toFirestoreMap(data),
              SetOptions(merge: operation.merge),
            );
            break;
          case SyncAction.update:
            await reference.update(_toFirestoreMap(data));
            break;
          case SyncAction.delete:
            await reference.delete();
            break;
        }

        await _databaseService.deleteSyncOperation(operationId);
      } catch (error) {
        await _databaseService.markSyncOperationFailed(
          operationId,
          attempts: operation.attempts + 1,
          error: error.toString(),
        );
      }
    }
  }

  Map<String, dynamic> _encodePayload(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(
      _encodeValue(source) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> _decodePayload(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(
      _decodeValue(source) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> _toFirestoreMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(
      source.map((key, value) => MapEntry(key, _toFirestoreValue(value))),
    );
  }

  Object? _encodeValue(Object? value) {
    if (value is DateTime) {
      return {
        '__sync_type': 'datetime',
        'value': value.toUtc().toIso8601String(),
      };
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) =>
            MapEntry(key.toString(), _encodeValue(nestedValue)),
      );
    }
    if (value is Iterable) {
      return value.map(_encodeValue).toList(growable: false);
    }
    return value;
  }

  Object? _decodeValue(Object? value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(
        value.map(
          (key, nestedValue) => MapEntry(
            key.toString(),
            _decodeValue(nestedValue),
          ),
        ),
      );
      if (map['__sync_type'] == 'datetime' && map['value'] is String) {
        return DateTime.parse(map['value'] as String).toUtc();
      }
      return map;
    }
    if (value is List) {
      return value.map(_decodeValue).toList(growable: false);
    }
    return value;
  }

  Object? _toFirestoreValue(Object? value) {
    if (value is DateTime) {
      return Timestamp.fromDate(value.toUtc());
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) =>
            MapEntry(key.toString(), _toFirestoreValue(nestedValue)),
      );
    }
    if (value is Iterable) {
      return value.map(_toFirestoreValue).toList(growable: false);
    }
    return value;
  }
}
