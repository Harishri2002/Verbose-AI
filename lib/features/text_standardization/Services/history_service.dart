import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save standardization to history
  Future<void> saveToHistory(String inputText, String outputText) async {
    if (currentUserId == null) return; // Only save if user is logged in

    try {
      await _firestore.collection('users').doc(currentUserId).collection('history').add({
        'input': inputText,
        'output': outputText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving to history: $e');
    }
  }

  // Get user's history
  Stream<QuerySnapshot> getHistory() {
    if (currentUserId == null) {
      // Return empty stream if user is not logged in
      return Stream.value(null as QuerySnapshot);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Delete history item
  Future<void> deleteHistoryItem(String docId) async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('history')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error deleting history item: $e');
    }
  }

  // Clear all history
  Future<void> clearAllHistory() async {
    if (currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final snapshots = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('history')
          .get();

      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}