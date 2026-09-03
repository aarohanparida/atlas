import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<bool> profileExists() async {
    final uid = _uid;

    if (uid == null) {
      return false;
    }

    final document =
        await _firestore.collection('users').doc(uid).get();

    return document.exists;
  }

  Future<void> createProfile({
    required String name,
    DateTime? birthday,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No signed-in user.');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': user.email,

      // Birthday is optional
      'birthday':
          birthday == null ? null : Timestamp.fromDate(birthday),

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> getFirstName() async {
    final user = _auth.currentUser;

    if (user == null) {
      return 'User';
    }

    final document =
        await _firestore.collection('users').doc(user.uid).get();

    final data = document.data();

    if (data == null) {
      return 'User';
    }

    final fullName = data['name'] as String? ?? 'User';

    return fullName.trim().split(' ').first;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _firestore.collection('users').doc(user.uid).get();

    return document.data();
  }

  Stream<Map<String, dynamic>?> getProfileStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((document) => document.data());
  }

  Future<void> updateProfile({
    required String name,
    DateTime? birthday,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No signed-in user.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'name': name.trim(),
      'birthday':
          birthday == null ? null : Timestamp.fromDate(birthday),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}