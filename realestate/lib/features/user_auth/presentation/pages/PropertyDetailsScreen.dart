import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailsScreen({Key? key, required this.propertyId}) : super(key: key);

  @override
  _PropertyDetailsScreenState createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _showOwnerInfo = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _propertyFuture;

  @override
  void initState() {
    super.initState();
    _propertyFuture = _fetchPropertyDetails();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchPropertyDetails() {
    return FirestoreService().getPropertyById(widget.propertyId);
  }

  void _toggleOwnerInfo() {
    setState(() {
      _showOwnerInfo = !_showOwnerInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _propertyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Property not found', style: TextStyle(fontSize: 18)));
          }

          var property = snapshot.data!.data()!;
          return _buildPropertyDetails(property);
        },
      ),
    );
  }

  Widget _buildPropertyDetails(Map<String, dynamic> property) {
    String imageUrl = property['image'] as String? ?? 'https://via.placeholder.com/400x300';

    return CustomScrollView(
      slivers: [
        _buildAppBar(property, imageUrl),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyInfoCard(property),
                const SizedBox(height: 16.0),
                _buildInterestedButton(),
                if (_showOwnerInfo) _buildOwnerInfoCard(property),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(Map<String, dynamic> property, String imageUrl) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          property['propertyName'] ?? 'Property Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
        background: Hero(
          tag: 'property-${widget.propertyId}',
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyInfoCard(Map<String, dynamic> property) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildDetailRow(Icons.location_on, 'Address', property['propertyAddress'] ?? 'N/A'),
            _buildDetailRow(Icons.home, 'Type', property['type'] ?? 'N/A'),
            _buildDetailRow(Icons.straighten, 'Dimensions', property['dimensions'] ?? 'N/A'),
            _buildDetailRow(Icons.local_offer, 'Facilities', property['facilities'] ?? 'N/A'),
            _buildDetailRow(Icons.attach_money, 'Price', '\$${property['price'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestedButton() {
    return ElevatedButton.icon(
      onPressed: _toggleOwnerInfo,
      icon: Icon(_showOwnerInfo ? Icons.visibility_off : Icons.visibility),
      label: Text(_showOwnerInfo ? 'Hide Owner Info' : 'Show Owner Info'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildOwnerInfoCard(Map<String, dynamic> property) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Information',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildDetailRow(Icons.person, 'Name', property['ownerName'] ?? 'N/A'),
            _buildDetailRow(Icons.phone, 'Phone', property['ownerPhone'] ?? 'N/A'),
            _buildDetailRow(Icons.email, 'Email', property['ownerEmail'] ?? 'N/A'),
            _buildDetailRow(Icons.home, 'Address', property['ownerAddress'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
