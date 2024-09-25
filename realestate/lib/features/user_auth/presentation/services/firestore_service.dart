
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  FirestoreService();

  Stream<QuerySnapshot> getAllPropertiesAdmin() {
       return _db.collection('properties').snapshots();
     }

     // Get all properties (for regular users)
     Stream<QuerySnapshot> getAllProperties() {
       // You might want to add any filtering logic here if needed
       return _db.collection('properties').snapshots();
     }
  

  // Get properties by owner ID
  Stream<QuerySnapshot> getPropertiesByOwnerId(String ownerId) {
    return _db.collection('properties').where('ownerId', isEqualTo: ownerId).snapshots();
  }

  // Get properties by type
  Stream<QuerySnapshot> getPropertiesByType(String propertyType) {
    return _db.collection('properties').where('type', isEqualTo: propertyType).snapshots();
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

  // ... (rest of the methods remain the same)
}
