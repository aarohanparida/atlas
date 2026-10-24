import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/atlas_memory.dart';
import 'notification_service.dart';

class MemoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No signed-in user.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
      get _memoriesCollection {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('memories');
  }

  Future<void> createMemory({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required List<String> people,
    required List<String> photoPaths,
  }) async {
    await _memoriesCollection.add({
      'title': title.trim(),
      'description': description.trim(),
      'date': Timestamp.fromDate(date),
      'location': location.trim(),
      'people': people,
      'photoPaths': photoPaths,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await NotificationService.instance
    .refreshSmartOnThisDayReminders();
  }

  Stream<List<AtlasMemory>> getRecentMemories() {
    return _memoriesCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    AtlasMemory.fromDocument(document),
              )
              .toList(),
        );
  }

  // getting all memories for timeline
  Stream<List<AtlasMemory>> getAllMemories() {
    return _memoriesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    AtlasMemory.fromDocument(document),
              )
              .toList(),
        );
  }

  Future<void> updateMemory({
    required String memoryId,
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required List<String> people,
  }) async {
    await _memoriesCollection.doc(memoryId).update({
      'title': title.trim(),
      'description': description.trim(),
      'date': Timestamp.fromDate(date),
      'location': location.trim(),
      'people': people,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMemory(String memoryId) async {
    await _memoriesCollection.doc(memoryId).delete();
  }
}