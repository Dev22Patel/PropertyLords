import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import 'PropertyDetailsScreen.dart';
import 'AddPropertyScreen.dart';

class AdminPropertiesListScreen extends StatefulWidget {
  const AdminPropertiesListScreen({super.key});

  @override
  _AdminPropertiesListScreenState createState() => _AdminPropertiesListScreenState();
}

class _AdminPropertiesListScreenState extends State<AdminPropertiesListScreen> {
  User? _currentUser;
  String? _selectedType;

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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
        backgroundColor: const Color(0xFF1E3A8A), // Dark blue
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF3F4F6), // Light gray background
        child: SingleChildScrollView( // Added SingleChildScrollView
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
              _currentUser != null
                  ? StreamBuilder<QuerySnapshot>(
  stream: _selectedType == null
      ? FirestoreService().getAllPropertiesAdmin()
      : FirestoreService().getPropertiesByType(_selectedType!),
  builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
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

                        return GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true, // Added
                          physics: const NeverScrollableScrollPhysics(), // Added
                          itemBuilder: (context, index) {
                            var property = snapshot.data!.docs[index];
                            return _buildPropertyCard(property);
                          },
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ],
          ),
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
  return GestureDetector(
    onTap: () {
      // Navigate to property details screen
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network(
              property['image'] ?? 'https://via.placeholder.com/150',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 120, // Adjusted height to prevent overflow
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['propertyName'] ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${property['bhk'] ?? 'N/A'} BHK',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8.0), // Added spacing between texts
                // Spacer is removed; instead, use SizedBox to manage spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Handle property deletion
                        FirestoreService().deleteProperty(property.id).then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
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