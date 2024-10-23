
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  FirestoreService();

  Stream<QuerySnapshot> getAllPropertiesAdmin() {
    return _db.collection('properties').snapshots();
  }

  Stream<QuerySnapshot> getAllProperties({bool includeSuspected = true}) {
    if (includeSuspected) {
      return _db.collection('properties').snapshots();
    } else {
      return _db.collection('properties')
          .where('isSuspected', isEqualTo: false)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getPropertiesByType(String propertyType) {
    return _db.collection('properties')
        .where('type', isEqualTo: propertyType)
        .where('isSuspected', isEqualTo: false)
        .snapshots();
  }

  // Get properties by owner ID
  Stream<QuerySnapshot> getPropertiesByOwnerId(String ownerId) {
    return _db.collection('properties').where('ownerId', isEqualTo: ownerId).snapshots();
  }


  // Add a new property to the collection
  Future<void> addProperty({
  required String ownerName,
  required String ownerPhone,
  required String ownerEmail,
  required String ownerAddress,
  required String propertyName,
  required String propertyAddress,
  required String dimensions,
  required String facilities,
  required String type,
  required String bhk,
  required String image,
}) async {
  if (_currentUser == null) {
    throw Exception('No user logged in');
  }

  try {
    await _db.collection('properties').add({
      'ownerId': _currentUser!.uid,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerEmail': ownerEmail,
      'ownerAddress': ownerAddress,
      'propertyName': propertyName,
      'propertyAddress': propertyAddress,
      'dimensions': dimensions,
      'facilities': facilities,
      'type': type,
      'bhk': bhk,
      'createdAt': FieldValue.serverTimestamp(),
      'image': image,
      'isSuspected': false,  // Add this line
    });
  } catch (e) {
    print('Error adding property: $e');
    throw Exception('Failed to add property: $e');
  }
}

  // Update an existing property by ID
  Future<void> updateProperty(String propertyId, Map<String, dynamic> updatedData) async {
    try {
      await _db.collection('properties').doc(propertyId).update(updatedData);
    } catch (e) {
      print('Error updating property: $e');
      throw Exception('Failed to update property: $e');
    }
  }

  // Delete a property by ID
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _db.collection('properties').doc(propertyId).delete();
    } catch (e) {
      print('Error deleting property: $e');
      throw Exception('Failed to delete property: $e');
    }
  }

  // Get property by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getPropertyById(String propertyId) async {
    try {
      return await _db.collection('properties').doc(propertyId).get();
    } catch (e) {
      print('Error getting property by ID: $e');
      rethrow;
    }
  }

  // Get properties for the current user
  Stream<QuerySnapshot> getCurrentUserProperties() {
    if (_currentUser != null) {
      return _db.collection('properties').where('ownerId', isEqualTo: _currentUser!.uid).snapshots();
    } else {
      return Stream.empty();
    }
  }

   Stream<QuerySnapshot> getAllUsers() {
    return _db.collection('users').snapshots();
  }

  // Get user by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) {
    return _db.collection('users').doc(userId).update({'role': role});
  }

  // Delete user
  Future<void> deleteUser(String userId) {
    return _db.collection('users').doc(userId).delete();
  }

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final usersCount = await _db.collection('users').count().get();
    final propertiesCount = await _db.collection('properties').count().get();

    return {
      'usersCount': usersCount.count,
      'propertiesCount': propertiesCount.count,
    };
  }


  Future<void> markPropertyAsSuspected(String propertyId, String reason) async {
    try {
      // Get the property data first
      DocumentSnapshot property = await _db.collection('properties').doc(propertyId).get();

      // Add to suspected_properties collection
      await _db.collection('suspected_properties').doc(propertyId).set({
        'propertyId': propertyId,
        'reportedBy': _currentUser?.uid,
        'reportedAt': FieldValue.serverTimestamp(),
        'reason': reason,
        'status': 'pending', // pending, reviewed, cleared
        'propertyData': property.data(), // Store the property data for reference
      });

      // Update the original property document to mark it as suspected
      await _db.collection('properties').doc(propertyId).update({
        'isSuspected': true,
        'suspectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking property as suspected: $e');
      throw Exception('Failed to mark property as suspected: $e');
    }
  }

  // Remove property from suspected list
  Future<void> clearSuspectedProperty(String propertyId) async {
    try {
      // Update the status in suspected_properties collection
      await _db.collection('suspected_properties').doc(propertyId).update({
        'status': 'cleared',
        'clearedAt': FieldValue.serverTimestamp(),
        'clearedBy': _currentUser?.uid,
      });

      // Update the original property document
      await _db.collection('properties').doc(propertyId).update({
        'isSuspected': false,
      });
    } catch (e) {
      print('Error clearing suspected property: $e');
      throw Exception('Failed to clear suspected property: $e');
    }
  }

  // Get all suspected properties
  Stream<QuerySnapshot> getSuspectedProperties() {
    return _db.collection('suspected_properties')
        .orderBy('reportedAt', descending: true)
        .snapshots();
  }

  // Get suspected status for a property
  Future<bool> isPropertySuspected(String propertyId) async {
    try {
      DocumentSnapshot property = await _db.collection('properties').doc(propertyId).get();
      return (property.data() as Map<String, dynamic>)['isSuspected'] ?? false;
    } catch (e) {
      print('Error checking suspected status: $e');
      return false;
    }
  }
}
