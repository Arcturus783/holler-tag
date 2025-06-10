import 'package:flutter/material.dart';
import 'package:myapp/backend/google_auth.dart';

// Assuming AppRoutes is defined in a common file like app_routes.dart or main.dart
// For this example, we'll assume it's accessible or defined locally for clarity.
class AppRoutes {
  static const String home = '/';
  static const String reviews = '/reviews';
  static const String product_page = '/product_page';
  static const String dashboard = '/dashboard';
  static const String signin = '/signin';
  static const String contact = '/contact';
}

class DashboardPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const DashboardPage({required this.toggleTheme, super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Placeholder data for user information
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';

  // Placeholder data for shipping information
  String _shippingAddressLine1 = '123 Main St';
  String _shippingAddressLine2 = 'Apt 4B';
  String _shippingCity = 'Anytown';
  String _shippingState = 'Anystate';
  String _shippingZipCode = '12345';
  String _shippingCountry = 'USA';

  // Placeholder for order history
  final List<Map<String, String>> _orderHistory = [
    {
      'orderId': '#1001',
      'date': '2023-01-15',
      'status': 'Delivered',
      'total': '\$59.99'
    },
    {
      'orderId': '#1002',
      'date': '2023-02-20',
      'status': 'Processing',
      'total': '\$24.50'
    },
    {
      'orderId': '#1003',
      'date': '2023-03-01',
      'status': 'Shipped',
      'total': '\$120.00'
    },
  ];

  // Placeholder for active animal tags
  final List<Map<String, String>> _activeAnimalTags = [
    {'tagName': 'Buddy (Dog)', 'qrCode': 'QR12345', 'status': 'Active'},
    {'tagName': 'Whiskers (Cat)', 'qrCode': 'QR67890', 'status': 'Active'},
  ];

  // Placeholder for credit card information
  String _creditCardNumber = '**** **** **** 1234';
  String _creditCardExpiry = '12/26';
  String _creditCardHolder = 'John Doe';

  // --- Controllers for editable fields ---
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;
  late TextEditingController _cardNumberController;
  late TextEditingController _cardExpiryController;
  late TextEditingController _cardHolderController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current placeholder data
    _nameController = TextEditingController(text: _userName);
    _emailController = TextEditingController(text: _userEmail);
    _addressLine1Controller =
        TextEditingController(text: _shippingAddressLine1);
    _addressLine2Controller =
        TextEditingController(text: _shippingAddressLine2);
    _cityController = TextEditingController(text: _shippingCity);
    _stateController = TextEditingController(text: _shippingState);
    _zipCodeController = TextEditingController(text: _shippingZipCode);
    _countryController = TextEditingController(text: _shippingCountry);
    _cardNumberController = TextEditingController(text: _creditCardNumber);
    _cardExpiryController = TextEditingController(text: _creditCardExpiry);
    _cardHolderController = TextEditingController(text: _creditCardHolder);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  // --- Helper to build a section title ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // --- Helper to build a text input field ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false, // Added for non-editable fields if needed
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsive layout
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 900.0; // Define your breakpoint for two columns

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Dashboard'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // This Column is now the single child of SingleChildScrollView
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            screenWidth > breakpoint
                ? Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align content to the top
                    children: [
                      // --- Left Column (now Active Animal Tags and Order History) ---
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0), // Add spacing between columns
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Active Animal Tags Section (now first)
                              _buildSectionTitle('Active Animal Tags'),
                              _activeAnimalTags.isEmpty
                                  ? const Text('No active animal tags found.')
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _activeAnimalTags.length,
                                      itemBuilder: (context, index) {
                                        final tag = _activeAnimalTags[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline, // Use outline color for border
                                              width:
                                                  1.0, // Thicker border for better visibility
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tag Name: ${tag['tagName']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                    'QR Code: ${tag['qrCode']} (Placeholder)'),
                                                Text(
                                                    'Status: ${tag['status']}'),
                                                // Placeholder for QR code image
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(Icons.qr_code,
                                                          size: 40,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 20),

                              // Order History Section (now second)
                              _buildSectionTitle('Order History'),
                              _orderHistory.isEmpty
                                  ? const Text('No past orders found.')
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _orderHistory.length,
                                      itemBuilder: (context, index) {
                                        final order = _orderHistory[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline, // Use outline color for border
                                              width:
                                                  1.0, // Thicker border for better visibility
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Order ID: ${order['orderId']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text('Date: ${order['date']}'),
                                                Text(
                                                    'Status: ${order['status']}'),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Text(
                                                    'Total: ${order['total']}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // --- Right Column (User Info, Shipping, and Credit Card) ---
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0), // Add spacing between columns
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Information Section
                              _buildSectionTitle('User Information'),
                              _buildTextField(
                                controller: _nameController,
                                labelText: 'Name',
                                hintText: 'Enter your full name',
                                onChanged: (value) {
                                  setState(() {
                                    _userName = value;
                                  });
                                },
                              ),
                              _buildTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'Enter your email address',
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    _userEmail = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Shipping Information Section
                              _buildSectionTitle('Shipping Information'),
                              _buildTextField(
                                controller: _addressLine1Controller,
                                labelText: 'Address Line 1',
                                hintText: 'e.g., 123 Main St',
                                onChanged: (value) => setState(
                                    () => _shippingAddressLine1 = value),
                              ),
                              _buildTextField(
                                controller: _addressLine2Controller,
                                labelText: 'Address Line 2 (Optional)',
                                hintText: 'e.g., Apt 4B',
                                onChanged: (value) => setState(
                                    () => _shippingAddressLine2 = value),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cityController,
                                      labelText: 'City',
                                      hintText: 'e.g., Anytown',
                                      onChanged: (value) =>
                                          setState(() => _shippingCity = value),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _stateController,
                                      labelText: 'State/Province',
                                      hintText: 'e.g., NY',
                                      onChanged: (value) => setState(
                                          () => _shippingState = value),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _zipCodeController,
                                      labelText: 'Zip/Postal Code',
                                      hintText: 'e.g., 12345',
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => setState(
                                          () => _shippingZipCode = value),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _countryController,
                                      labelText: 'Country',
                                      hintText: 'e.g., USA',
                                      onChanged: (value) => setState(
                                          () => _shippingCountry = value),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Credit Card Information Section
                              _buildSectionTitle('Credit Card Information'),
                              _buildTextField(
                                controller: _cardNumberController,
                                labelText: 'Card Number',
                                hintText: '**** **** **** 1234',
                                keyboardType: TextInputType.number,
                                readOnly:
                                    true, // Typically, full card numbers are not edited directly
                                onChanged: (value) =>
                                    setState(() => _creditCardNumber = value),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cardExpiryController,
                                      labelText: 'Expiry Date',
                                      hintText: 'MM/YY',
                                      keyboardType: TextInputType.datetime,
                                      onChanged: (value) => setState(
                                          () => _creditCardExpiry = value),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cardHolderController,
                                      labelText: 'Cardholder Name',
                                      hintText: 'John Doe',
                                      onChanged: (value) => setState(
                                          () => _creditCardHolder = value),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : // --- Single Column Layout (for smaller screens) ---
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Animal Tags Section (now first)
                      _buildSectionTitle('Active Animal Tags'),
                      _activeAnimalTags.isEmpty
                          ? const Text('No active animal tags found.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _activeAnimalTags.length,
                              itemBuilder: (context, index) {
                                final tag = _activeAnimalTags[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // Use outline color for border
                                      width:
                                          1.0, // Thicker border for better visibility
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tag Name: ${tag['tagName']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            'QR Code: ${tag['qrCode']} (Placeholder)'),
                                        Text('Status: ${tag['status']}'),
                                        // Placeholder for QR code image
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(Icons.qr_code,
                                                  size: 40, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 20),

                      // Order History Section (now second)
                      _buildSectionTitle('Order History'),
                      _orderHistory.isEmpty
                          ? const Text('No past orders found.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _orderHistory.length,
                              itemBuilder: (context, index) {
                                final order = _orderHistory[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // Use outline color for border
                                      width:
                                          1.0, // Thicker border for better visibility
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order ID: ${order['orderId']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text('Date: ${order['date']}'),
                                        Text('Status: ${order['status']}'),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            'Total: ${order['total']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 20),

                      // User Information Section
                      _buildSectionTitle('User Information'),
                      _buildTextField(
                        controller: _nameController,
                        labelText: 'Name',
                        hintText: 'Enter your full name',
                        onChanged: (value) {
                          setState(() {
                            _userName = value;
                          });
                        },
                      ),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          setState(() {
                            _userEmail = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Shipping Information Section
                      _buildSectionTitle('Shipping Information'),
                      _buildTextField(
                        controller: _addressLine1Controller,
                        labelText: 'Address Line 1',
                        hintText: 'e.g., 123 Main St',
                        onChanged: (value) =>
                            setState(() => _shippingAddressLine1 = value),
                      ),
                      _buildTextField(
                        controller: _addressLine2Controller,
                        labelText: 'Address Line 2 (Optional)',
                        hintText: 'e.g., Apt 4B',
                        onChanged: (value) =>
                            setState(() => _shippingAddressLine2 = value),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cityController,
                              labelText: 'City',
                              hintText: 'e.g., Anytown',
                              onChanged: (value) =>
                                  setState(() => _shippingCity = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _stateController,
                              labelText: 'State/Province',
                              hintText: 'e.g., NY',
                              onChanged: (value) =>
                                  setState(() => _shippingState = value),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _zipCodeController,
                              labelText: 'Zip/Postal Code',
                              hintText: 'e.g., 12345',
                              keyboardType: TextInputType.number,
                              onChanged: (value) =>
                                  setState(() => _shippingZipCode = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _countryController,
                              labelText: 'Country',
                              hintText: 'e.g., USA',
                              onChanged: (value) =>
                                  setState(() => _shippingCountry = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Credit Card Information Section
                      _buildSectionTitle('Credit Card Information'),
                      _buildTextField(
                        controller: _cardNumberController,
                        labelText: 'Card Number',
                        hintText: '**** **** **** 1234',
                        keyboardType: TextInputType.number,
                        readOnly:
                            true, // Typically, full card numbers are not edited directly
                        onChanged: (value) =>
                            setState(() => _creditCardNumber = value),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cardExpiryController,
                              labelText: 'Expiry Date',
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.datetime,
                              onChanged: (value) =>
                                  setState(() => _creditCardExpiry = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _cardHolderController,
                              labelText: 'Cardholder Name',
                              hintText: 'John Doe',
                              onChanged: (value) =>
                                  setState(() => _creditCardHolder = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
            // Placeholder for Save Button - remains outside the conditional layout
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // In a real app, this would trigger saving data to a backend
                    print('Saving data...');
                    print('User Name: $_userName');
                    print('Shipping Address: $_shippingAddressLine1');
                    // Add other data to print for demonstration
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profile updated! (Placeholder)'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
