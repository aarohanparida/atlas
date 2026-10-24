import 'package:cloud_firestore/cloud_firestore.dart';

class SharedTimeline {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final String inviteCode;

  const SharedTimeline({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    required this.inviteCode,
  });

  factory SharedTimeline.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return SharedTimeline(
      id: document.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      inviteCode: data['inviteCode'] ?? '',
    );
  }
}
