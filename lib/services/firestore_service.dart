import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  FirestoreService({required this.userId});

  CollectionReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(userId).collection('data');

  Future<List<String>> getSearchHistory(String tabName) async {
    final doc = await _db.collection('users').doc(userId).collection('searchHistory').doc(tabName).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('history')) {
        return List<String>.from(data['history']);
      }
    }
    return [];
  }

  Future<void> saveSearchHistory(String tabName, List<String> history) async {
    await _db.collection('users').doc(userId).collection('searchHistory').doc(tabName).set({
      'history': history,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<dynamic>> getFavorites(String tabName) async {
    final doc = await _db.collection('users').doc(userId).collection('favorites').doc(tabName).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('items')) {
        return List<dynamic>.from(data['items']);
      }
    }
    return [];
  }

  Future<void> saveFavorites(String tabName, List<dynamic> items) async {
    await _db.collection('users').doc(userId).collection('favorites').doc(tabName).set({
      'items': items,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
