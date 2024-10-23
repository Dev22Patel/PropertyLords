import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatePostScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const UpdatePostScreen({Key? key, required this.postId, required this.postData}) : super(key: key);

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _bhkController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _propertyAddressController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with existing data
    _propertyNameController.text = widget.postData['propertyName'] ?? '';
    _bhkController.text = widget.postData['bhk']?.toString() ?? '';
    _dimensionsController.text = widget.postData['dimensions'] ?? '';
    _facilitiesController.text = widget.postData['facilities'] ?? '';
    _ownerAddressController.text = widget.postData['ownerAddress'] ?? '';
    _ownerEmailController.text = widget.postData['ownerEmail'] ?? '';
    _ownerNameController.text = widget.postData['ownerName'] ?? '';
    _ownerPhoneController.text = widget.postData['ownerPhone'] ?? '';
    _propertyAddressController.text = widget.postData['propertyAddress'] ?? '';
    _typeController.text = widget.postData['type'] ?? '';
  }

  Future<void> _updatePost() async {
    try {
      await FirebaseFirestore.instance.collection('properties').doc(widget.postId).update({
        'propertyName': _propertyNameController.text,
        'bhk': int.tryParse(_bhkController.text) ?? 0,
        'dimensions': _dimensionsController.text,
        'facilities': _facilitiesController.text,
        'ownerAddress': _ownerAddressController.text,
        'ownerEmail': _ownerEmailController.text,
        'ownerName': _ownerNameController.text,
        'ownerPhone': _ownerPhoneController.text,
        'propertyAddress': _propertyAddressController.text,
        'type': _typeController.text,
      });
      Navigator.pop(context); // Go back after successful update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Post',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _propertyNameController,
              decoration: InputDecoration(labelText: 'Property Name'),
            ),
            TextField(
              controller: _bhkController,
              decoration: InputDecoration(labelText: 'BHK'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dimensionsController,
              decoration: InputDecoration(labelText: 'Dimensions'),
            ),
            TextField(
              controller: _facilitiesController,
              decoration: InputDecoration(labelText: 'Facilities'),
            ),
            TextField(
              controller: _ownerAddressController,
              decoration: InputDecoration(labelText: 'Owner Address'),
            ),
            TextField(
              controller: _ownerEmailController,
              decoration: InputDecoration(labelText: 'Owner Email'),
            ),
            TextField(
              controller: _ownerNameController,
              decoration: InputDecoration(labelText: 'Owner Name'),
            ),
            TextField(
              controller: _ownerPhoneController,
              decoration: InputDecoration(labelText: 'Owner Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _propertyAddressController,
              decoration: InputDecoration(labelText: 'Property Address'),
            ),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePost,
              child: Text('Update Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
