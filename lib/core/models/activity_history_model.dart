/// A locally persisted audit entry for a completed operational activity.
class ActivityHistoryModel {
  final int? id;
  final String userId;
  final String? lapakId;
  final String activityType;
  final String title;
  final String description;
  final DateTime occurredAt;
  final String? referenceId;

  const ActivityHistoryModel({
    this.id,
    required this.userId,
    this.lapakId,
    required this.activityType,
    required this.title,
    required this.description,
    required this.occurredAt,
    this.referenceId,
  });

  factory ActivityHistoryModel.fromMap(Map<String, Object?> map) {
    return ActivityHistoryModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String? ?? '',
      lapakId: map['lapak_id'] as String?,
      activityType: map['activity_type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      occurredAt: DateTime.tryParse(map['occurred_at'] as String? ?? '') ?? DateTime.now(),
      referenceId: map['reference_id'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
        'user_id': userId,
        'lapak_id': lapakId,
        'activity_type': activityType,
        'title': title,
        'description': description,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'reference_id': referenceId,
        'event_key': '$userId:$activityType:${referenceId ?? occurredAt.toUtc().toIso8601String()}',
      };
}
