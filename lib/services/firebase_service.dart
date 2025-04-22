import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
      ),
    );
  }

  // Firestore methods with improved error handling
  static Future<DocumentReference> addEvent(Map<String, dynamic> eventData) async {
    try {
      return await _firestore.collection('events').add(eventData);
    } on FirebaseException catch (e) {
      throw FirestoreException.fromCode(e.code);
    }
  }

  static Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException.fromCode(e.code);
    }
  }

  static Future<DocumentReference> addBooking(Map<String, dynamic> bookingData) async {
    try {
      return await _firestore.collection('bookings').add(bookingData);
    } on FirebaseException catch (e) {
      throw FirestoreException.fromCode(e.code);
    }
  }

  static Stream<QuerySnapshot> getEventsStream() {
    try {
      return _firestore.collection('events').snapshots().handleError((error) {
        throw FirestoreException.fromCode((error as FirebaseException).code);
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromCode(e.code);
    }
  }

  static Future<void> submitFeedback({
    required String feedback,
    required int rating,
  }) async {
    try {
      await _firestore.collection('feedback').add({
        'feedback': feedback,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromCode(e.code);
    }
  }
}

class FirestoreException implements Exception {
  const FirestoreException([this.message = 'A Firestore error occurred']);

  factory FirestoreException.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const FirestoreException('Operation not permitted');
      case 'not-found':
        return const FirestoreException('Document not found');
      case 'already-exists':
        return const FirestoreException('Document already exists');
      case 'resource-exhausted':
        return const FirestoreException('Quota exceeded');
      default:
        return const FirestoreException();
    }
  }

  final String message;
}
