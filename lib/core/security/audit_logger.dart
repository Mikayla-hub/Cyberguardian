import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

enum AuditAction {
  login,
  logout,
  scanInitiated,
  scanCompleted,
  reportSubmitted,
  lessonStarted,
  lessonCompleted,
  incidentViewed,
  settingsChanged,
  biometricAuth,
  tokenRefreshed,
  securityAlert,
}

class AuditEntry {
  final String id;
  final AuditAction action;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AuditEntry({
    required this.action,
    required this.description,
    this.metadata,
  })  : id = const Uuid().v4(),
        timestamp = DateTime.now().toUtc();

  Map<String, dynamic> toMap() => {
        'id': id,
        'action': action.name,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}

class AuditLogger {
  static const String _boxName = 'audit_log';
  late Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> log(AuditEntry entry) async {
    await _box.put(entry.id, entry.toMap());

    // Keep only last 1000 entries
    if (_box.length > 1000) {
      final keysToDelete = _box.keys.take(_box.length - 1000).toList();
      await _box.deleteAll(keysToDelete);
    }
  }

  List<AuditEntry> getRecentEntries({int count = 50}) {
    return _box.values
        .take(count)
        .map((map) => AuditEntry(
              action: AuditAction.values.firstWhere(
                (a) => a.name == map['action'],
                orElse: () => AuditAction.securityAlert,
              ),
              description: map['description'] as String? ?? '',
              metadata: map['metadata'] as Map<String, dynamic>?,
            ))
        .toList();
  }

  Future<void> clearLogs() async {
    await _box.clear();
  }
}
