import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/elements/my_app_bar.dart'; // Assuming you want your custom AppBar

class ScannedProductDetailPage extends StatefulWidget {
  final String productId;
  final VoidCallback toggleTheme; // Receive toggleTheme callback

  const ScannedProductDetailPage({
    super.key,
    required this.productId,
    required this.toggleTheme,
  });

  @override
  State<ScannedProductDetailPage> createState() => _ScannedProductDetailPageState();
}

class _ScannedProductDetailPageState extends State<ScannedProductDetailPage> {
  late Future<DocumentSnapshot> _productData;

  @override
  void initState() {
    super.initState();
    // Fetch the product data when the widget initializes
    _productData = FirebaseFirestore.instance
        .collection('tags') // Your Firestore collection where product info is stored
        .doc(widget.productId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
          toggleTheme: widget.toggleTheme), // Use your custom AppBar
      body: FutureBuilder<DocumentSnapshot>(
        future: _productData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Product information not found.'));
          }

          // Data exists, display it
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final address = data['Address'] ?? 'N/A';
          final description = data['Description'] ?? 'N/A';
          final phoneNumber = data['Phone Number'] ?? 'N/A';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanned Product ID: ${widget.productId}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('Address: $address',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Description: $description',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Phone Number: $phoneNumber',
                    style: Theme.of(context).textTheme.bodyLarge),
                // Add more fields as needed for the scanned product
              ],
            ),
          );
        },
      ),
    );
  }
}