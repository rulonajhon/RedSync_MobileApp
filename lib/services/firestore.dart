import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER METHODS
  // Create
  Future<void> createUser(
    String uid,
    String name,
    String email,
    String role,
  ) async {
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
  Future<void> updateUser(
    String uid,
    String name,
    String email,
    String? role, {
    Map<String, dynamic>? extra,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (role != null) data['role'] = role;
    if (extra != null)
      data.addAll(extra.map((key, value) => MapEntry(key, value as Object)));
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
    await _db.collection('notifications').doc(notificationId).update({
      'read': true,
    });
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

  Future<List<Map<String, dynamic>>> searchHealthcareProviders(
    String query,
  ) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'medical')
          .get();

      final providers = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
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
  Future<void> addEmergencyContact(
    String patientUid,
    String contactPhone,
  ) async {
    try {
      // Check if emergency contact already exists
      final existing = await _db
          .collection('emergency_contacts')
          .where('patientUid', isEqualTo: patientUid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception(
          'Emergency contact already exists. You can only have one emergency contact.',
        );
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
        return {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
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

  // DOSAGE CALCULATION METHODS

  // Save dosage calculation to history
  Future<String> saveDosageCalculation({
    required String uid,
    required String hemophiliaType,
    required double weight,
    required double targetFactorLevel,
    required double calculatedDosage,
    String? notes,
  }) async {
    try {
      final doc = await _db.collection('dosage_calculations').add({
        'uid': uid,
        'hemophiliaType': hemophiliaType,
        'weight': weight,
        'targetFactorLevel': targetFactorLevel,
        'calculatedDosage': calculatedDosage,
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Dosage calculation saved successfully');
      return doc.id;
    } catch (e) {
      print('Error saving dosage calculation: $e');
      rethrow;
    }
  }

  // Get dosage calculation history for a user
  Future<List<Map<String, dynamic>>> getDosageCalculationHistory(
    String uid, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _db
          .collection('dosage_calculations')
          .where('uid', isEqualTo: uid)
          .limit(limit)
          .get();

      // Sort the results locally by createdAt timestamp
      final docs = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      docs.sort((a, b) {
        final aTime =
            a['createdAt']?.millisecondsSinceEpoch ?? a['timestamp'] ?? 0;
        final bTime =
            b['createdAt']?.millisecondsSinceEpoch ?? b['timestamp'] ?? 0;
        return bTime.compareTo(aTime); // Descending order (newest first)
      });

      return docs;
    } catch (e) {
      print('Error getting dosage calculation history: $e');
      rethrow;
    }
  }

  // Get recent dosage calculations stream for real-time updates
  Stream<QuerySnapshot> getDosageCalculationStream(
    String uid, {
    int limit = 10,
  }) {
    try {
      return _db
          .collection('dosage_calculations')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();
    } catch (e) {
      print('Error getting dosage calculation stream: $e');
      rethrow;
    }
  }

  // Update dosage calculation notes
  Future<void> updateDosageCalculationNotes(
    String calculationId,
    String notes,
  ) async {
    try {
      await _db.collection('dosage_calculations').doc(calculationId).update({
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Dosage calculation notes updated successfully');
    } catch (e) {
      print('Error updating dosage calculation notes: $e');
      rethrow;
    }
  }

  // Delete dosage calculation
  Future<void> deleteDosageCalculation(String calculationId) async {
    try {
      await _db.collection('dosage_calculations').doc(calculationId).delete();
      print('Dosage calculation deleted successfully');
    } catch (e) {
      print('Error deleting dosage calculation: $e');
      rethrow;
    }
  }

  // Get user's preferred calculation settings
  Future<Map<String, dynamic>?> getUserCalculationSettings(String uid) async {
    try {
      final doc = await _db
          .collection('user_calculation_settings')
          .doc(uid)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user calculation settings: $e');
      rethrow;
    }
  }

  // Save/Update user's preferred calculation settings
  Future<void> saveUserCalculationSettings({
    required String uid,
    double? defaultWeight,
    double? defaultTargetLevel,
    String? preferredUnits,
    bool? autoSaveCalculations,
  }) async {
    try {
      final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

      if (defaultWeight != null) data['defaultWeight'] = defaultWeight;
      if (defaultTargetLevel != null)
        data['defaultTargetLevel'] = defaultTargetLevel;
      if (preferredUnits != null) data['preferredUnits'] = preferredUnits;
      if (autoSaveCalculations != null)
        data['autoSaveCalculations'] = autoSaveCalculations;

      await _db
          .collection('user_calculation_settings')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      print('User calculation settings saved successfully');
    } catch (e) {
      print('Error saving user calculation settings: $e');
      rethrow;
    }
  }

  // BLEED LOG METHODS

  // Save bleed log to Firestore
  Future<String> saveBleedLog({
    required String uid,
    required String date,
    required String time,
    required String bodyRegion,
    required String severity,
    String? specificRegion,
    String? notes,
    String? photoUrl,
  }) async {
    try {
      final doc = await _db.collection('bleed_logs').add({
        'uid': uid,
        'date': date,
        'time': time,
        'bodyRegion': bodyRegion,
        'specificRegion': specificRegion ?? '',
        'severity': severity,
        'notes': notes ?? '',
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Bleed log saved successfully');
      return doc.id;
    } catch (e) {
      print('Error saving bleed log: $e');
      rethrow;
    }
  }

  // Get bleed logs for a user
  Future<List<Map<String, dynamic>>> getBleedLogs(
    String uid, {
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _db
          .collection('bleed_logs')
          .where('uid', isEqualTo: uid)
          .limit(limit)
          .get();

      // Sort the results locally by createdAt timestamp
      final docs = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      docs.sort((a, b) {
        final aTime = a['createdAt']?.millisecondsSinceEpoch ?? 0;
        final bTime = b['createdAt']?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime); // Descending order (newest first)
      });

      return docs;
    } catch (e) {
      print('Error getting bleed logs: $e');
      rethrow;
    }
  }

  // Get bleed logs stream for real-time updates
  Stream<QuerySnapshot> getBleedLogsStream(String uid, {int limit = 20}) {
    try {
      return _db
          .collection('bleed_logs')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();
    } catch (e) {
      print('Error getting bleed logs stream: $e');
      rethrow;
    }
  }

  // Update bleed log
  Future<void> updateBleedLog(String logId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection('bleed_logs').doc(logId).update(data);
      print('Bleed log updated successfully');
    } catch (e) {
      print('Error updating bleed log: $e');
      rethrow;
    }
  }

  // Delete bleed log
  Future<void> deleteBleedLog(String logId) async {
    try {
      await _db.collection('bleed_logs').doc(logId).delete();
      print('Bleed log deleted successfully');
    } catch (e) {
      print('Error deleting bleed log: $e');
      rethrow;
    }
  }

  // Get bleed log statistics
  Future<Map<String, dynamic>> getBleedLogStats(String uid) async {
    try {
      final querySnapshot = await _db
          .collection('bleed_logs')
          .where('uid', isEqualTo: uid)
          .get();

      final logs = querySnapshot.docs.map((doc) => doc.data()).toList();

      // Calculate statistics
      final totalLogs = logs.length;
      final severityCounts = <String, int>{};
      final regionCounts = <String, int>{};

      for (final log in logs) {
        final severity = log['severity'] as String? ?? '';
        final region = log['bodyRegion'] as String? ?? '';

        severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
        regionCounts[region] = (regionCounts[region] ?? 0) + 1;
      }

      return {
        'totalLogs': totalLogs,
        'severityCounts': severityCounts,
        'regionCounts': regionCounts,
        'lastWeekCount': _getLogsInTimeframe(logs, 7),
        'lastMonthCount': _getLogsInTimeframe(logs, 30),
      };
    } catch (e) {
      print('Error getting bleed log stats: $e');
      rethrow;
    }
  }

  // Helper method to count logs in timeframe
  int _getLogsInTimeframe(List<Map<String, dynamic>> logs, int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    int count = 0;

    for (final log in logs) {
      final createdAt = log['createdAt'] as Timestamp?;
      if (createdAt != null && createdAt.toDate().isAfter(cutoffDate)) {
        count++;
      }
    }

    return count;
  }

  // =============================================================================================================

  // MEDICATION SCHEDULE METHODS

  // Save medication schedule
  Future<String> saveMedicationSchedule({
    required String uid,
    required String medicationName,
    required String dosage,
    required String administrationType,
    required String frequency,
    required TimeOfDay reminderTime,
    required bool notificationEnabled,
    String? notes,
  }) async {
    try {
      final scheduleData = {
        'uid': uid,
        'medicationName': medicationName,
        'dosage': dosage,
        'administrationType': administrationType,
        'frequency': frequency,
        'reminderTimeHour': reminderTime.hour,
        'reminderTimeMinute': reminderTime.minute,
        'notificationEnabled': notificationEnabled,
        'notes': notes ?? '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _db
          .collection('medication_schedules')
          .add(scheduleData);
      return docRef.id;
    } catch (e) {
      print('Error saving medication schedule: $e');
      rethrow;
    }
  }

  // Get medication schedules for a user
  Future<List<Map<String, dynamic>>> getMedicationSchedules(String uid) async {
    try {
      print('Fetching medication schedules for user: $uid'); // Debug log

      final querySnapshot = await _db
          .collection('medication_schedules')
          .where('uid', isEqualTo: uid)
          .where('isActive', isEqualTo: true)
          .get();

      print(
        'Found ${querySnapshot.docs.length} medication schedules',
      ); // Debug log

      final schedules = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort locally by createdAt (most recent first)
      schedules.sort((a, b) {
        final timeA = a['createdAt'] as Timestamp?;
        final timeB = b['createdAt'] as Timestamp?;
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA);
      });

      return schedules;
    } catch (e) {
      print('Error getting medication schedules: $e');
      return [];
    }
  }

  // Get today's medication reminders
  Future<List<Map<String, dynamic>>> getTodaysMedicationReminders(
    String uid,
  ) async {
    try {
      print(
        'Getting today\'s medication reminders for user: $uid',
      ); // Debug log

      final schedules = await getMedicationSchedules(uid);
      print('Retrieved ${schedules.length} total schedules'); // Debug log

      // Get already taken medications for today
      final takenMedications = await getTakenMedicationsToday(uid);
      print('Taken medications today: $takenMedications'); // Debug log

      final todaysReminders = <Map<String, dynamic>>[];
      final now = DateTime.now();
      print('Current time: $now'); // Debug log

      for (final schedule in schedules) {
        print(
          'Processing schedule: ${schedule['medicationName']}',
        ); // Debug log
        print(
          'Notification enabled: ${schedule['notificationEnabled']}',
        ); // Debug log

        // Skip if medication was already taken today
        if (takenMedications.contains(schedule['id'])) {
          print(
            'Skipping ${schedule['medicationName']} - already taken today',
          ); // Debug log
          continue;
        }

        if (schedule['notificationEnabled'] == true) {
          final reminderHour = schedule['reminderTimeHour'] as int? ?? 9;
          final reminderMinute = schedule['reminderTimeMinute'] as int? ?? 0;

          final reminderTime = DateTime(
            now.year,
            now.month,
            now.day,
            reminderHour,
            reminderMinute,
          );

          print('Reminder time: $reminderTime'); // Debug log

          // Check if medication should be taken today based on frequency
          bool shouldTakeToday = _shouldTakeMedicationToday(schedule, now);
          print('Should take today: $shouldTakeToday'); // Debug log

          if (shouldTakeToday) {
            final reminderData = Map<String, dynamic>.from(schedule);
            reminderData['reminderDateTime'] = reminderTime;
            reminderData['isPending'] = reminderTime.isAfter(now);
            reminderData['isOverdue'] =
                reminderTime.isBefore(now) &&
                reminderTime.isAfter(now.subtract(Duration(hours: 2)));
            todaysReminders.add(reminderData);
            print(
              'Added reminder for: ${schedule['medicationName']}',
            ); // Debug log
          }
        }
      }

      print('Total today\'s reminders: ${todaysReminders.length}'); // Debug log

      // Sort by reminder time
      todaysReminders.sort((a, b) {
        final timeA = a['reminderDateTime'] as DateTime;
        final timeB = b['reminderDateTime'] as DateTime;
        return timeA.compareTo(timeB);
      });

      return todaysReminders;
    } catch (e) {
      print('Error getting today\'s medication reminders: $e');
      return [];
    }
  }

  // Helper method to determine if medication should be taken today
  bool _shouldTakeMedicationToday(
    Map<String, dynamic> schedule,
    DateTime today,
  ) {
    final frequency = schedule['frequency'] as String? ?? 'Daily';
    final createdAt = schedule['createdAt'] as Timestamp?;

    print('Checking frequency: $frequency'); // Debug log
    print('Created at: $createdAt'); // Debug log

    if (createdAt == null) {
      print('No creation date, returning true'); // Debug log
      return true;
    }

    final scheduleDate = createdAt.toDate();
    final daysDifference = today.difference(scheduleDate).inDays;

    print('Schedule date: $scheduleDate'); // Debug log
    print('Days difference: $daysDifference'); // Debug log

    switch (frequency) {
      case 'Daily':
        print('Daily frequency - returning true'); // Debug log
        return true;
      case 'Every 2 days':
        final shouldTake = daysDifference % 2 == 0;
        print('Every 2 days - should take: $shouldTake'); // Debug log
        return shouldTake;
      case 'Every 3 days':
        final shouldTake = daysDifference % 3 == 0;
        print('Every 3 days - should take: $shouldTake'); // Debug log
        return shouldTake;
      case 'Weekly':
        final shouldTake = daysDifference % 7 == 0;
        print('Weekly - should take: $shouldTake'); // Debug log
        return shouldTake;
      case 'As needed':
        print('As needed - returning false'); // Debug log
        return false; // Manual only
      default:
        print('Default case - returning true'); // Debug log
        return true;
    }
  }

  // Update medication schedule
  Future<void> updateMedicationSchedule(
    String scheduleId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection('medication_schedules').doc(scheduleId).update(data);
    } catch (e) {
      print('Error updating medication schedule: $e');
      rethrow;
    }
  }

  // Delete/deactivate medication schedule
  Future<void> deleteMedicationSchedule(String scheduleId) async {
    try {
      await _db.collection('medication_schedules').doc(scheduleId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting medication schedule: $e');
      rethrow;
    }
  }

  // Mark medication as taken for today
  Future<void> markMedicationTaken(String uid, String scheduleId) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      await _db.collection('medication_taken').add({
        'uid': uid,
        'scheduleId': scheduleId,
        'date': dateKey,
        'takenAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Medication marked as taken for schedule: $scheduleId on $dateKey');
    } catch (e) {
      print('Error marking medication as taken: $e');
      rethrow;
    }
  }

  // Check if medication was taken today
  Future<bool> isMedicationTakenToday(String uid, String scheduleId) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final snapshot = await _db
          .collection('medication_taken')
          .where('uid', isEqualTo: uid)
          .where('scheduleId', isEqualTo: scheduleId)
          .where('date', isEqualTo: dateKey)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if medication was taken: $e');
      return false;
    }
  }

  // Get taken medications for today
  Future<Set<String>> getTakenMedicationsToday(String uid) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final snapshot = await _db
          .collection('medication_taken')
          .where('uid', isEqualTo: uid)
          .where('date', isEqualTo: dateKey)
          .get();
      
      return snapshot.docs
          .map((doc) => doc.data()['scheduleId'] as String)
          .toSet();
    } catch (e) {
      print('Error getting taken medications: $e');
      return <String>{};
    }
  }
}
