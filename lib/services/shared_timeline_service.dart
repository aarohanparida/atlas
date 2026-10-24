import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/atlas_memory.dart';
import '../models/shared_timeline.dart';

class SharedTimelineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in first.');
    return user.uid;
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();

    return List.generate(
      16,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> createTimeline(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Enter a timeline name.');
    }

    final code = _generateInviteCode();
    final timelineRef = _firestore.collection('sharedTimelines').doc();
    final inviteRef = _firestore.collection('inviteCodes').doc(code);

    final batch = _firestore.batch();

    batch.set(timelineRef, {
      'name': trimmedName,
      'ownerId': _uid,
      'memberIds': [_uid],
      'inviteCode': code,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(inviteRef, {
      'timelineId': timelineRef.id,
      'ownerId': _uid,
    });

    await batch.commit();
  }

  Stream<List<SharedTimeline>> getMyTimelines() {
    return _firestore
        .collection('sharedTimelines')
        .where('memberIds', arrayContains: _uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(SharedTimeline.fromDocument)
            .toList());
  }

  Future<void> joinTimeline(String inviteCode) async {
    final code = inviteCode.trim().toUpperCase();

    if (code.isEmpty) {
      throw Exception('Enter an invite code.');
    }

    final invite = await _firestore
        .collection('inviteCodes')
        .doc(code)
        .get();

    if (!invite.exists) {
      throw Exception('That invite code is invalid.');
    }

    final timelineId = invite.data()!['timelineId'] as String;

    await _firestore
        .collection('sharedTimelines')
        .doc(timelineId)
        .update({
      'memberIds': FieldValue.arrayUnion([_uid]),
    });
  }

  Stream<List<AtlasMemory>> getTimelineMemories(String timelineId) {
    return _firestore
        .collection('sharedTimelines')
        .doc(timelineId)
        .collection('memories')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AtlasMemory.fromDocument(doc))
            .toList());
  }

  Future<void> shareMemory(
    SharedTimeline timeline,
    AtlasMemory memory,
  ) async {
    await _firestore
        .collection('sharedTimelines')
        .doc(timeline.id)
        .collection('memories')
        .add({
      'title': memory.title,
      'description': memory.description,
      'date': Timestamp.fromDate(memory.date),
      'location': memory.location,
      'people': memory.people,
      // Photos are local files for now, so don't copy their paths.
      'photoPaths': <String>[],
      'createdBy': _uid,
      'sourceMemoryId': memory.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}