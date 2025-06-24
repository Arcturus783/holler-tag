import 'package:flutter/material.dart';
import 'package:myapp/backend/google_auth.dart';

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

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  // Placeholder data for user information
  String _userName = AuthService.getCurrentUser()!.displayName ?? '';
  String _userEmail = AuthService.getCurrentUser()!.email ?? '';

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
    {'tagName': 'Charlie (Bird)', 'qrCode': 'QR54321', 'status': 'Active'},
  ];

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

    // Initialize controllers with current placeholder data
    _nameController = TextEditingController(text: _userName);
    _emailController = TextEditingController(text: _userEmail);
    _addressLine1Controller = TextEditingController(text: _shippingAddressLine1);
    _addressLine2Controller = TextEditingController(text: _shippingAddressLine2);
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
    _fadeController.dispose();
    _slideController.dispose();

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

  // Helper to build a modern section title
  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: BorderRadius.circular(12),
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
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get gradient
  LinearGradient _getGradient() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const LinearGradient(
      colors: [Colors.indigo, Colors.deepPurpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color.fromARGB(255, 0, 217, 255), Color.fromARGB(255, 0, 255, 255)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Build modern pet tag card
  Widget _buildPetTagCard(Map<String, String> tag, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lightColors = [
      [const Color.fromARGB(255, 0, 217, 255), const Color.fromARGB(255, 0, 255, 255)],
      [const Color.fromARGB(255, 0, 180, 255), const Color.fromARGB(255, 0, 217, 255)],
      [const Color.fromARGB(255, 0, 255, 200), const Color.fromARGB(255, 0, 255, 255)],
      [const Color.fromARGB(255, 100, 200, 255), const Color.fromARGB(255, 0, 217, 255)],
      [const Color.fromARGB(255, 50, 230, 255), const Color.fromARGB(255, 0, 255, 255)],
    ];

    final darkColors = [
      [Colors.indigo, Colors.deepPurpleAccent],
      [Colors.indigo.shade800, Colors.indigo],
      [Colors.deepPurple, Colors.deepPurpleAccent],
      [Colors.indigo.shade700, Colors.deepPurple],
      [Colors.deepPurpleAccent, Colors.indigo],
    ];

    final cardColors = isDark ? darkColors[index % darkColors.length] : lightColors[index % lightColors.length];



    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColors[0].withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code,
                  size: 40,
                  color: Colors.black54,
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag['qrCode']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tag['status']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build order history card
  Widget _buildOrderCard(Map<String, String> order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    switch (order['status']) {
      case 'Delivered':
        statusColor = isDark ? Colors.greenAccent : Colors.green;
        break;
      case 'Processing':
        statusColor = isDark ? Colors.orangeAccent : Colors.orange;
        break;
      case 'Shipped':
        statusColor = isDark ? const Color.fromARGB(255, 0, 217, 255) : Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.indigo.withValues(alpha:0.3)
                : const Color.fromARGB(255, 0, 217, 255).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['date']!,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status']!,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order['total']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha:0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      gradient: _getGradient(),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_activeAnimalTags.length} Active Tags',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_orderHistory.length} Orders',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
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
                            _buildSectionTitle('Your Pet Tags', icon: Icons.pets),
                            _activeAnimalTags.isEmpty
                                ? _buildEmptyState('No active pet tags found.', 'Add your first pet tag to get started!')
                                : Column(
                              children: _activeAnimalTags.asMap().entries.map((entry) {
                                return _buildPetTagCard(entry.value, entry.key);
                              }).toList(),
                            ),

                            const SizedBox(height: 32),
                            _buildSectionTitle('Recent Orders', icon: Icons.history),
                            _orderHistory.isEmpty
                                ? _buildEmptyState('No orders found.', 'Your order history will appear here.')
                                : Column(
                              children: _orderHistory.map((order) => _buildOrderCard(order)).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 32),

                      // Right column - Settings
                      Expanded(
                        child: _buildSettingsPanel(),
                      ),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Tags section (mobile)
                      _buildSectionTitle('Your Pet Tags', icon: Icons.pets),
                      _activeAnimalTags.isEmpty
                          ? _buildEmptyState('No active pet tags found.', 'Add your first pet tag to get started!')
                          : Column(
                        children: _activeAnimalTags.asMap().entries.map((entry) {
                          return _buildPetTagCard(entry.value, entry.key);
                        }).toList(),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle('Recent Orders', icon: Icons.history),
                      _orderHistory.isEmpty
                          ? _buildEmptyState('No orders found.', 'Your order history will appear here.')
                          : Column(
                        children: _orderHistory.map((order) => _buildOrderCard(order)).toList(),
                      ),

                      const SizedBox(height: 32),
                      _buildSettingsPanel(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                gradient: _getGradient(),
                borderRadius: _isSettingsExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
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
            height: _isSettingsExpanded ? null : 0,
            child: _isSettingsExpanded ? _buildSettingsContent() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information Section
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                  onChanged: (value) => setState(() => _shippingZipCode = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _countryController,
                  labelText: 'Country',
                  hintText: 'e.g., USA',
                  onChanged: (value) => setState(() => _shippingCountry = value),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Credit Card Information Section
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                  onChanged: (value) => setState(() => _creditCardExpiry = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cardHolderController,
                  labelText: 'Cardholder Name',
                  hintText: 'John Doe',
                  onChanged: (value) => setState(() => _creditCardHolder = value),
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
                gradient: _getGradient(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.indigo.withValues(alpha:0.3)
                        : const Color.fromARGB(255, 0, 217, 255).withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                      content: const Text('Profile updated successfully!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
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
    );
  }
}