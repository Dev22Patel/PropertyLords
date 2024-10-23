import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../presentation/services/firestore_service.dart';

class AddPropertyScreen extends StatefulWidget {
  final VoidCallback onPropertyAdded;

  const AddPropertyScreen({Key? key, required this.onPropertyAdded}) : super(key: key);

  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _propertyNameController = TextEditingController();
  final _propertyDimensionsController = TextEditingController();
  final _propertyFacilitiesController = TextEditingController();
  final _propertyBHKController = TextEditingController();

  String _propertyType = 'house';

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _downloadUrl;

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Property',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Owner Details'),
                    _buildTextField(_ownerNameController, 'Owner Name', Icons.person),
                    _buildTextField(_ownerPhoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                    _buildTextField(_ownerEmailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                    _buildTextField(_ownerAddressController, 'Address', Icons.home),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Property Details'),
                    _buildTextField(_propertyNameController, 'Property Name', Icons.business),
                    _buildTextField(_propertyAddressController, 'Property Address', Icons.location_on),
                    _buildTextField(_propertyDimensionsController, 'Dimensions', Icons.straighten),
                    _buildTextField(_propertyFacilitiesController, 'Facilities', Icons.local_offer),
                    _buildDropdown(),
                    _buildTextField(_propertyBHKController, 'Number of BHK', Icons.king_bed, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 24), // Add extra space at the bottom
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _propertyType,
        onChanged: (newValue) {
          setState(() {
            _propertyType = newValue!;
          });
        },
        items: ['house', 'villa', 'flat', 'farmhouse']
            .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.capitalize()),
                ))
            .toList(),
        decoration: InputDecoration(
          labelText: 'Property Type',
          prefixIcon: const Icon(Icons.home_work, color: Color(0xFF1E3A8A)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
          ),
        ),
      ),
    );
  }

Widget _buildImagePicker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Property Image',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E3A8A),
        ),
      ),
      const SizedBox(height: 12),
      Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: _imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imageFile!.path),
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: Icon(
                Icons.add_a_photo,
                size: 64,
                color: const Color(0xFF9CA3AF),
              ),
            ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_a_photo, color: Colors.white),
          label: Text(
            _imageFile != null ? 'Change Image' : 'Add Property Image',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSubmitButton() {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E3A8A).withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: _submitProperty,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_home_work, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Submit Property',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
  );
}
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      FirebaseStorage storage = FirebaseStorage.instanceFor(
          bucket: 'flutter-firebase-3c0d2.appspot.com');
      final ref = storage.ref().child('images/${DateTime.now().toIso8601String()}_${_imageFile!.name}');
      await ref.putFile(File(_imageFile!.path));
      _downloadUrl = await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    }
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _uploadImage();

    if (_downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload an image first.')));
      return;
    }

    try {
      await FirestoreService().addProperty(
        ownerName: _ownerNameController.text,
        ownerPhone: _ownerPhoneController.text,
        ownerEmail: _ownerEmailController.text,
        ownerAddress: _ownerAddressController.text,
        propertyName: _propertyNameController.text,
        propertyAddress: _propertyAddressController.text,
        dimensions: _propertyDimensionsController.text,
        facilities: _propertyFacilitiesController.text,
        type: _propertyType,
        bhk: _propertyBHKController.text,
        image: _downloadUrl!,
      );

      widget.onPropertyAdded();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding property: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding property: $e')));
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
