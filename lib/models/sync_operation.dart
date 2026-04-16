import 'dart:convert';

enum SyncAction { set, update, delete }

class SyncOperation {
  const SyncOperation({
    this.id,
    required this.documentPath,
    required this.action,
    this.payload = const <String, dynamic>{},
    this.userUid,
    this.merge = true,
    required this.createdAt,
    required this.updatedAt,
    this.attempts = 0,
    this.lastError,
  });

  final int? id;
  final String documentPath;
  final SyncAction action;
  final Map<String, dynamic> payload;
  final String? userUid;
  final bool merge;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attempts;
  final String? lastError;

  Map<String, Object?> toRow() => {
    'document_path': documentPath,
    'action': action.name,
    'payload_json': jsonEncode(payload),
    'user_uid': userUid,
    'merge': merge ? 1 : 0,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'attempts': attempts,
    'last_error': lastError,
  };

  factory SyncOperation.fromRow(Map<String, Object?> row) {
    final payloadJson = row['payload_json'] as String? ?? '{}';
    return SyncOperation(
      id: row['id'] as int?,
      documentPath: row['document_path'] as String? ?? '',
      action: SyncAction.values.firstWhere(
        (value) => value.name == row['action'],
        orElse: () => SyncAction.set,
      ),
      payload: Map<String, dynamic>.from(
        jsonDecode(payloadJson) as Map<String, dynamic>,
      ),
      userUid: row['user_uid'] as String?,
      merge: (row['merge'] as int? ?? 1) == 1,
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt:
          DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      attempts: row['attempts'] as int? ?? 0,
      lastError: row['last_error'] as String?,
    );
  }
}
