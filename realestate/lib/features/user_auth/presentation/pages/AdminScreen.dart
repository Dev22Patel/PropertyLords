import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import 'PropertyDetailsScreen.dart';
import 'AddPropertyScreen.dart';
import 'AdminDashboardScreen.dart';

class AdminPropertiesListScreen extends StatefulWidget {
  const AdminPropertiesListScreen({super.key});

  @override
  _AdminPropertiesListScreenState createState() => _AdminPropertiesListScreenState();
}

class _AdminPropertiesListScreenState extends State<AdminPropertiesListScreen> {
  User? _currentUser;
  String? _selectedType;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
    print('Current user in AdminPropertiesListScreen: ${_currentUser?.uid}');
  }

  void _showAddPropertyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyScreen(
          onPropertyAdded: () => setState(() {}),
        ),
      ),
    );
  }

  void _showSuspectPropertyDialog(DocumentSnapshot property) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Mark as Suspected',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Why is this property suspected?',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6B7280),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  _firestoreService
                      .markPropertyAsSuspected(property.id, reasonController.text)
                      .then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Property marked as suspected',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: const Color(0xFF1E3A8A),
                      ),
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Properties',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminUsersListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF3F4F6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Property Types',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChoiceChip('All', _selectedType == null),
                    const SizedBox(width: 8.0),
                    _buildChoiceChip('House', _selectedType == 'house'),
                    const SizedBox(width: 8.0),
                    _buildChoiceChip('Villa', _selectedType == 'villa'),
                    const SizedBox(width: 8.0),
                    _buildChoiceChip('Flat', _selectedType == 'flat'),
                    const SizedBox(width: 8.0),
                    _buildChoiceChip('Farmhouse', _selectedType == 'farmhouse'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _selectedType == null
                    ? _firestoreService.getAllProperties()
                    : _firestoreService.getPropertiesByType(_selectedType!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Error in AdminPropertiesListScreen: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No properties found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    );
                  }

                  print('Number of properties: ${snapshot.data!.docs.length}');

                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var property = snapshot.data!.docs[index];
                      return _buildPropertyCard(property);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPropertyScreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Property',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

Widget _buildPropertyCard(DocumentSnapshot property) {
  // Safely access the data
  final propertyData = property.data() as Map<String, dynamic>;
  final bool isSuspected = propertyData['isSuspected'] ?? false;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyDetailsScreen(propertyId: property.id),
        ),
      );
    },
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.network(
                  propertyData['image'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 99,
                ),
              ),
              if (isSuspected) // Use the safely accessed value
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Suspected',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    propertyData['propertyName'] ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${propertyData['bhk'] ?? 'N/A'} BHK',
                    style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        onPressed: () => _showSuspectPropertyDialog(property),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _showDeleteConfirmation(property),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  void _showDeleteConfirmation(DocumentSnapshot property) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this property?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _firestoreService.deleteProperty(property.id).then((_) {
                  setState(() {});
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildChoiceChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.white : const Color(0xFF1E3A8A),
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF1E3A8A),
      backgroundColor: Colors.white,
      onSelected: (isSelected) {
        setState(() {
          _selectedType = isSelected ? (label == 'All' ? null : label.toLowerCase()) : null;
        });
      },
    );
  }
}
