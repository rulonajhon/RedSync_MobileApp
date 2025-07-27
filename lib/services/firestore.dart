import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER METHODS
  // Create
  Future<void> createUser(String uid, String name, String email, String role) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Read
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Update
  Future<void> updateUser(String uid, String name, String email, String? role, {Map<String, dynamic>? extra}) async {
    final data = {
      'name': name,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (role != null) data['role'] = role;
    if (extra != null) data.addAll(extra.map((key, value) => MapEntry(key, value as Object)));
    await _db.collection('users').doc(uid).update(data);
  }

  // Delete
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // Get user profile with hemophilia type
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Get user role for login routing
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      rethrow;
    }
  }


  // =============================================================================================================


  // NOTIFICATION METHODS
  Future<void> createNotification(String uid, String text) async {
    await _db.collection('notifications').add({
      'uid': uid,
      'text': text,
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getNotifications(String uid) {
    try {
      if (uid.isEmpty) {
        throw Exception('User ID is empty');
      }
      return _db
          .collection('notifications')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error in getNotifications: $e');
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead(String uid) async {
    try {
      if (uid.isEmpty) return;
      
      final notifications = await _db
          .collection('notifications')
          .where('uid', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .get();
      
      if (notifications.docs.isEmpty) return;
      
      final batch = _db.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking notifications as read: $e');
      rethrow;
    }
  }

  Future<void> deleteAllNotifications(String uid) async {
    try {
      if (uid.isEmpty) return;
      
      final notifications = await _db
          .collection('notifications')
          .where('uid', isEqualTo: uid)
          .get();
      
      if (notifications.docs.isEmpty) return;
      
      final batch = _db.batch();
      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting notifications: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'read': true});
  }

  // =============================================================================================================

  // HEALTHCARE PROVIDER METHODS
  Stream<QuerySnapshot> getHealthcareProviders() {
    try {
      return _db
          .collection('users')
          .where('role', isEqualTo: 'medical')
          // Removed .orderBy('name') to avoid composite index requirement
          .snapshots();
    } catch (e) {
      print('Error getting healthcare providers: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchHealthcareProviders(String query) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'medical')
          .get();
      
      final providers = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .where((provider) {
            final name = provider['name']?.toString().toLowerCase() ?? '';
            return name.contains(query.toLowerCase());
          })
          .toList();
      
      return providers;
    } catch (e) {
      print('Error searching healthcare providers: $e');
      rethrow;
    }
  }

  // EMERGENCY CONTACT METHODS
  Future<void> addEmergencyContact(String patientUid, String contactPhone) async {
    try {
      // Check if emergency contact already exists
      final existing = await _db
          .collection('emergency_contacts')
          .where('patientUid', isEqualTo: patientUid)
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        throw Exception('Emergency contact already exists. You can only have one emergency contact.');
      }
      
      await _db.collection('emergency_contacts').add({
        'patientUid': patientUid,
        'contactPhone': contactPhone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding emergency contact: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getEmergencyContact(String patientUid) async {
    try {
      final snapshot = await _db
          .collection('emergency_contacts')
          .where('patientUid', isEqualTo: patientUid)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return {
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data(),
        };
      }
      return null;
    } catch (e) {
      print('Error getting emergency contact: $e');
      rethrow;
    }
  }

  Future<void> updateEmergencyContact(String contactId, String newPhone) async {
    try {
      await _db.collection('emergency_contacts').doc(contactId).update({
        'contactPhone': newPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating emergency contact: $e');
      rethrow;
    }
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    try {
      await _db.collection('emergency_contacts').doc(contactId).delete();
    } catch (e) {
      print('Error deleting emergency contact: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getEmergencyContacts(String patientUid) {
    try {
      return _db
          .collection('emergency_contacts')
          .where('patientUid', isEqualTo: patientUid)
          // Remove .orderBy to avoid index requirement
          .snapshots();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      rethrow;
    }
  }
}