import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
class PropertiesListScreen extends StatefulWidget {
  @override
  _PropertiesListScreenState createState() => _PropertiesListScreenState();
}

class _PropertiesListScreenState extends State<PropertiesListScreen> {
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
  }

  Future<void> _addProperty() async {
    final formKey = GlobalKey<FormState>();
    String? name, address, type, wifi, bathrooms;
    int? price;
    Uint8List? image;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Property'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(hintText: 'Name'),
                  onSaved: (value) => name = value,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Address'),
                  onSaved: (value) => address = value,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter an address' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Type (house, villa, flat, etc.)'),
                  onSaved: (value) => type = value,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a property type' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Wifi'),
                  onSaved: (value) => wifi = value,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter wifi details' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Bathrooms'),
                  onSaved: (value) => bathrooms = value,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter bathroom details' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Price'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => price = int.tryParse(value ?? ''),
                  validator: (value) => (value?.isEmpty ?? true) || int.tryParse(value ?? '') == null
                      ? 'Please enter a valid price'
                      : null,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      image = await pickedImage.readAsBytes();
                    }
                  },
                  child: Text('Select Property Image'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                _saveProperty(name!, address!, type!, wifi!, bathrooms!, price!, image!);
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProperty(
    String name,
    String address,
    String type,
    String wifi,
    String bathrooms,
    int price,
    Uint8List image,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('properties').add({
        'name': name,
        'address': address,
        'type': type,
        'wifi': wifi,
        'bathrooms': bathrooms,
        'price': price,
        'image': image,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Property added successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding property: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('PropertyLords'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Property Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(
                  label: Text('All'),
                  selected: _selectedType == null,
                  onSelected: (_) => setState(() => _selectedType = null),
                ),
                ChoiceChip(
                  label: Text('House'),
                  selected: _selectedType == 'house',
                  onSelected: (_) => setState(() => _selectedType = 'house'),
                ),
                ChoiceChip(
                  label: Text('Villa'),
                  selected: _selectedType == 'villa',
                  onSelected: (_) => setState(() => _selectedType = 'villa'),
                ),
                ChoiceChip(
                  label: Text('Flat'),
                  selected: _selectedType == 'flat',
                  onSelected: (_) => setState(() => _selectedType = 'flat'),
                ),
                ChoiceChip(
                  label: Text('Farmhouse'),
                  selected: _selectedType == 'farmhouse',
                  onSelected: (_) => setState(() => _selectedType = 'farmhouse'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentUser != null
                ? StreamBuilder<QuerySnapshot>(
                    stream: _selectedType == null
                        ? FirebaseFirestore.instance.collection('properties').snapshots()
                        : FirebaseFirestore.instance
                            .collection('properties')
                            .where('type', isEqualTo: _selectedType)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No properties found'));
                      }

                      return GridView.builder(
                        padding: EdgeInsets.all(16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var property = snapshot.data!.docs[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailsScreen(propertyId: property.id),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRoundedImage(
                                    url: property['image'],
                                    height: 150.0,
                                  ),
                                  SizedBox(height: 8.0),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      property['name'] ?? 'Unnamed Property',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      property['address'] ?? 'No address',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      '\$${property['price']?.toString() ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProperty,
        child: Icon(Icons.add),
      ),
    );
  }
}

class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;

  PropertyDetailsScreen({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('properties').doc(propertyId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Property not found'));
          }

          var property = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRoundedImage(
                    url: property['image'],
                    height: 300.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    property['name'] ?? 'N/A',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    property['address'] ?? 'N/A',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Type: ${property['type'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Wifi: ${property['wifi'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Bathrooms: ${property['bathrooms'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '\$${property['price']?.toString() ?? 'N/A'}',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ClipRoundedImage extends StatelessWidget {
  final String? url;
  final double height;

  ClipRoundedImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRoundedNetworkImage(
      imageUrl: url ?? '',
      height: height,
      fit: BoxFit.cover,
    );
  }
}

class ClipRoundedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final BoxFit fit;

  ClipRoundedNetworkImage({
    required this.imageUrl,
    required this.height,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.network(
        imageUrl,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.error,
              color: Colors.grey[400],
              size: 48.0,
            ),
          );
        },
      ),
    );
  }
}
