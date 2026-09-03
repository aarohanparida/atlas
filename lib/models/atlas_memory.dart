import 'package:cloud_firestore/cloud_firestore.dart';

class AtlasMemory {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final List<String> people;
  final DateTime? createdAt;

  AtlasMemory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.people,
    this.createdAt,
  });

  factory AtlasMemory.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return AtlasMemory(
      id: document.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      people: List<String>.from(data['people'] ?? []),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}