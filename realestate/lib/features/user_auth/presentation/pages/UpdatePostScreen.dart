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

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with existing data
    _propertyNameController.text = widget.postData['propertyName'] ?? '';
    _bhkController.text = widget.postData['bhk']?.toString() ?? '';
  }

  Future<void> _updatePost() async {
    try {
      await FirebaseFirestore.instance.collection('properties').doc(widget.postId).update({
        'propertyName': _propertyNameController.text,
        'bhk': int.tryParse(_bhkController.text) ?? 0,
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
      body: Padding(
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
