import 'package:flutter/material.dart';
import 'package:myapp/backend/google_auth.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/elements/my_app_bar.dart';

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

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // Placeholder data for user information
  String _userName = AuthService.getCurrentUser()?.displayName ?? '';
  String _userEmail = AuthService.getCurrentUser()?.email ?? '';
  DocumentReference? docRef; // Make it nullable initially

  // Initialize userData as null or with default empty map
  Map<String, dynamic> _userData = {};

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
  final List<Map<String, String>> _activeAnimalTags = [];

  // Placeholder for credit card information
  String _creditCardNumber = '**** **** **** 1234';
  String _creditCardExpiry = '12/26';
  String _creditCardHolder = 'John Doe';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers for editable fields
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

  // Expansion state for settings section
  bool _isSettingsExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize docRef after super.initState()
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      docRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      _userName = currentUser.displayName ?? '';
      _userEmail = currentUser.email ?? '';
      _fetchUserData(); // Fetch user data when the state initializes
    } else {
      // Handle the case where there is no current user (e.g., navigate to sign-in)
      print("No current user found.");
      // You might want to navigate to the sign-in page here
      // Navigator.of(context).pushReplacementNamed(AppRoutes.signin);
    }


    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Initialize controllers with current placeholder data.
    // These will be updated by setState in _fetchUserData once data is loaded.
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

  // Asynchronous function to fetch user data
  Future<void> _fetchUserData() async {
    if (docRef == null) return; // Ensure docRef is not null

    try {
      DocumentSnapshot doc = await docRef!.get();
      if (doc.exists && doc.data() != null) {
        // Use setState to update the UI once data is fetched
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
          // Update TextEditingControllers
          //_nameController.text = _userName;
          //_emailController.text = _userEmail;
          // Clear previous tags and fetch new ones
          _activeAnimalTags.clear();
          if (_userData['pets'] != null && (_userData['pets'] as List).isNotEmpty) {
            for (String id in _userData['pets']) {
              DocumentReference petRef = FirebaseFirestore.instance.collection('tags').doc(id);
              petRef.get().then(
                    (DocumentSnapshot petDoc) {
                  if (petDoc.exists && petDoc.data() != null) {
                    final data = petDoc.data() as Map<String, dynamic>;
                    setState(() { // Update state again for pet tags
                      _activeAnimalTags.add(
                        {
                          'tagName': data['Name'] ?? 'Unnamed',
                          'qrCode': id,
                          'found': data['Found']?.toString() ?? 'false', // Convert boolean to string
                          'foundMessage': data['Found Message'] ?? '',
                          'phone': data['Phone'] ?? '',
                          'additionalInfo': data['Additional Info'] ?? '',
                        },
                      );
                    });
                  }
                },
                onError: (e) => print("Error getting pet document: $e"),
              );
            }
          }
        });
      } else {
        print("Document does not exist or data is null.");
      }
    } catch (e) {
      print("Error getting user document: $e");
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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


  // Helper to build a modern section title
  Widget _buildSectionTitle(String title, {IconData? icon}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: currentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: currentGradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get gradient
  LinearGradient _getGradient() {
    return AppTheme.getDefaultGradient(context);
  }

  // Function to show found message popup
  void _showFoundMessageDialog(String message, String petName) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  Colors.grey[900]!.withValues(alpha: 0.95),
                  Colors.grey[800]!.withValues(alpha: 0.95),
                ]
                    : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.grey[50]!.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$petName - Found Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Message content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message.isNotEmpty ? message : 'No additional message provided.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: currentGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: currentGradient.colors.first.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build modern pet tag card
  Widget _buildPetTagCard(Map<String, String> tag, int index) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isFound = tag['found']?.toLowerCase() == 'true';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[800]!.withValues(alpha: 0.95),
            Colors.grey[700]!.withValues(alpha: 0.95),
          ]
              : [
            Colors.white.withValues(alpha: 0.95),
            Colors.grey[50]!.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // QR Code placeholder with modern styling
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[600]!.withValues(alpha: 0.3)
                    : Colors.grey[200]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.qr_code,
                size: 40,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black54,
              ),
            ),
            const SizedBox(width: 20),

            // Tag information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag['tagName']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag['qrCode']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.black.withValues(alpha: 0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status indicator - only show if pet is found
                  if (isFound) ...[
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reported Found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showFoundMessageDialog(
                              tag['foundMessage'] ?? '',
                              tag['tagName'] ?? 'Pet'
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action button
            // Replace the action button container in _buildPetTagCard with this:
            GestureDetector(
              onTap: () => _showEditPetDialog(
                tag['qrCode']!,
                tag['tagName'] ?? '',
                tag['phone'] ?? '',
                tag['additionalInfo'] ?? '',
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _getGradient(),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getGradient().colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Build order history card
  Widget _buildOrderCard(Map<String, String> order) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    switch (order['status']) {
      case 'Delivered':
        statusColor = Colors.green;
        break;
      case 'Processing':
        statusColor = Colors.orange;
        break;
      case 'Shipped':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[900]!.withValues(alpha: 0.95),
            Colors.grey[800]!.withValues(alpha: 0.95),
          ]
              : [
            Colors.white.withValues(alpha: 0.95),
            Colors.grey[50]!.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['orderId']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['date']!,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  order['status']!,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order['total']!,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to build a text input field with modern styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    void Function(String)? onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          labelStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: currentGradient.colors.first,
              width: 2.0,
            ),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 900.0;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Scaffold(
      appBar: MyAppBar(toggleTheme: widget.toggleTheme),
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ]
                : [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: currentGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentGradient.colors.first
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            _userName.isNotEmpty ? _userName : 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _activeAnimalTags.length == 1 ? '1 Active Tag' : '${_activeAnimalTags.length} Active Tags',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              /*
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${_orderHistory.length} Orders',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),

                               */
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Main content
                    screenWidth > breakpoint
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Pet Tags (featured)
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Your Pet Tags',
                                  icon: Icons.pets),
                              _activeAnimalTags.isEmpty
                                  ? _buildEmptyState(
                                  'No active pet tags found.',
                                  'Add your first pet tag to get started!')
                                  : Column(
                                children: _activeAnimalTags
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  print("not empty, length: ${_activeAnimalTags.length}");
                                  print(_activeAnimalTags[0]);
                                  return _buildPetTagCard(
                                      entry.value, entry.key);
                                }).toList(),
                              ),
                              /*
                              const SizedBox(height: 32),
                              _buildSectionTitle('Recent Orders',
                                  icon: Icons.history),
                              _orderHistory.isEmpty
                                  ? _buildEmptyState('No orders found.',
                                  'Your order history will appear here.')
                                  : Column(
                                children: _orderHistory
                                    .map((order) =>
                                    _buildOrderCard(order))
                                    .toList(),
                              ),

                               */
                            ],
                          ),
                        ),

                        const SizedBox(width: 32),

                        // Right column - Settings
                        /*
                              Expanded(
                                child: _buildSettingsPanel(),
                              ),

                               */
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pet Tags section (mobile)
                        _buildSectionTitle('Your Pet Tags',
                            icon: Icons.pets),
                        _activeAnimalTags.isEmpty
                            ? _buildEmptyState(
                            'No active pet tags found.',
                            'Add your first pet tag to get started!')
                            : Column(
                          children: _activeAnimalTags
                              .asMap()
                              .entries
                              .map((entry) {
                            return _buildPetTagCard(
                                entry.value, entry.key);
                          }).toList(),
                        ),

                        /*
                        const SizedBox(height: 32),
                        _buildSectionTitle('Recent Orders',
                            icon: Icons.history),
                        _orderHistory.isEmpty
                            ? _buildEmptyState('No orders found.',
                            'Your order history will appear here.')
                            : Column(
                          children: _orderHistory
                              .map(
                                  (order) => _buildOrderCard(order))
                              .toList(),
                        ),

                        const SizedBox(height: 32),
                        _buildSettingsPanel(),

                         */
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[900]!.withValues(alpha: 0.95),
            Colors.grey[800]!.withValues(alpha: 0.95),
          ]
              : [
            Colors.white.withValues(alpha: 0.95),
            Colors.grey[50]!.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[900]!.withValues(alpha: 0.95),
            Colors.grey[800]!.withValues(alpha: 0.95),
          ]
              : [
            Colors.white.withValues(alpha: 0.95),
            Colors.grey[50]!.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Settings header
          InkWell(
            onTap: () {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: currentGradient,
                borderRadius: _isSettingsExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: currentGradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Account Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Icon(
                    _isSettingsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Expandable settings content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isSettingsExpanded ? null : 0,
            child: _isSettingsExpanded ? _buildSettingsContent() : null,
          ),
        ],
      ),
    );
  }

  // Add this function to show the edit dialog
  void _showEditPetDialog(String tagId, String currentName, String currentPhone, String currentAdditionalInfo) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    final additionalInfoController = TextEditingController(text: currentAdditionalInfo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            Future<void> savePetInfo() async {
              setState(() {
                isLoading = true;
              });

              try {
                await FirebaseFirestore.instance.collection('tags').doc(tagId).update({
                  'Name': nameController.text.trim(),
                  'Phone': phoneController.text.trim(),
                  'Additional Info': additionalInfoController.text.trim(),
                });

                if (context.mounted) {
                  Navigator.of(context).pop();
                  _fetchUserData(); // Refresh the pet data
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Pet information updated successfully!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating pet information: $e'),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                    ),
                  );
                }
              } finally {
                if (context.mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            }

            Widget buildEditTextField({
              required TextEditingController controller,
              required String labelText,
              String? hintText,
              TextInputType keyboardType = TextInputType.text,
              int maxLines = 1,
              int? maxLength,
            }) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  decoration: InputDecoration(
                    labelText: labelText,
                    hintText: hintText,
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.02),
                    labelStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: currentGradient.colors.first,
                        width: 2.0,
                      ),
                    ),
                    counterStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  keyboardType: keyboardType,
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                      Colors.grey[900]!.withValues(alpha: 0.95),
                      Colors.grey[800]!.withValues(alpha: 0.95),
                    ]
                        : [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.grey[50]!.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            gradient: currentGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Edit Pet Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Form fields
                    buildEditTextField(
                      controller: nameController,
                      labelText: 'Pet Name',
                      hintText: 'Enter your pet\'s name',
                    ),
                    buildEditTextField(
                      controller: phoneController,
                      labelText: 'Phone Number',
                      hintText: 'Enter your contact phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    buildEditTextField(
                      controller: additionalInfoController,
                      labelText: 'Additional Info',
                      hintText: 'Enter helpful information for someone who finds your pet',
                      maxLines: 3,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: currentGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : savePetInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsContent() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information Section
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            onChanged: (value) {
              setState(() {
                _userName = value;
              });
            },
          ),
          _buildTextField(
            controller: _emailController,
            labelText: 'Email Address',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              setState(() {
                _userEmail = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Shipping Information Section
          Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressLine1Controller,
            labelText: 'Address Line 1',
            hintText: 'e.g., 123 Main St',
            onChanged: (value) => setState(() => _shippingAddressLine1 = value),
          ),
          _buildTextField(
            controller: _addressLine2Controller,
            labelText: 'Address Line 2 (Optional)',
            hintText: 'e.g., Apt 4B',
            onChanged: (value) => setState(() => _shippingAddressLine2 = value),
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  labelText: 'City',
                  hintText: 'e.g., Anytown',
                  onChanged: (value) => setState(() => _shippingCity = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  labelText: 'State/Province',
                  hintText: 'e.g., NY',
                  onChanged: (value) => setState(() => _shippingState = value),
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

          const SizedBox(height: 24),

          // Credit Card Information Section
          Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cardNumberController,
            labelText: 'Card Number',
            hintText: '**** **** **** 1234',
            keyboardType: TextInputType.number,
            readOnly: true,
            onChanged: (value) => setState(() => _creditCardNumber = value),
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

          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: currentGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: currentGradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // In a real app, this would trigger saving data to a backend
                  print('Saving data...');
                  print('User Name: $_userName');
                  print('Shipping Address: $_shippingAddressLine1');
                  // Add other data to print for demonstration
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Profile updated successfully!',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      backgroundColor: currentGradient.colors.first,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}