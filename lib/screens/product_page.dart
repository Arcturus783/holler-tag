import 'package:flutter/material.dart';
import 'package:myapp/elements/my_app_bar.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:myapp/elements/image_cropper_popup.dart';
import 'package:myapp/backend/google_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppRoutes {
  static const String signin = '/signin';
}

class ProductPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const ProductPage({super.key, required this.toggleTheme});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Value notifiers for form state
  final ValueNotifier<Color?> _selectedColor = ValueNotifier<Color?>(null);
  final ValueNotifier<String?> _selectedSize = ValueNotifier<String?>(null);
  final ValueNotifier<XFile?> _selectedImage = ValueNotifier<XFile?>(null);
  final ValueNotifier<String> _nameController = ValueNotifier<String>('');
  final ValueNotifier<String> _phoneController = ValueNotifier<String>('');
  final ValueNotifier<String> _additionalInfoController = ValueNotifier<String>('');

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 900.0;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: MyAppBar(),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section
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
                          color: currentGradient.colors.first.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Protect Your Pet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    'HollerTag',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Safety • Style • Smart Technology',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Main content layout
                  screenWidth > breakpoint
                      ? _buildWideLayout(context)
                      : _buildNarrowLayout(context),

                  const SizedBox(height: 32),

                  // Customization and order section
                  _buildCustomizationSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: _buildProductImage(context),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildProductInfoCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(context),
        const SizedBox(height: 24),
        _buildProductInfoCard(context),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[850]!.withValues(alpha: 0.95),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/laptop.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProductInfoCard(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[850]!.withValues(alpha: 0.95),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HollerTag',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Meet the HollerTag, your one-stop shop for safety, style, and suave for your furry friend. '
                'The QR code on the back allows people who find a lost pet to access the owner\'s information, if they have unlocked it. '
                'Plus, thanks to advanced 3D printing, the HollerTag can be customized to the finest detail.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureList(context),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    final specs = [
      {'icon': Icons.lock_person, 'label': 'Control Your Personal Information'},
      {'icon': Icons.format_paint_rounded, 'label': 'Customize Style, Color, and Shape'},
      {'icon': Icons.handyman_rounded, 'label': 'Durable and Pet-Friendly Materials'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        ...specs.map((spec) => Container(
          margin: const EdgeInsets.only(bottom: 12.0),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: currentGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: currentGradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  spec['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  spec['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.8)
                        : Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCustomizationSection(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 900.0;

    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[850]!.withValues(alpha: 0.95),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: currentGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: currentGradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.palette,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Customize Your HollerTag',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Color selection and contact information - responsive layout
          screenWidth > breakpoint
              ? _buildWideCustomizationLayout(colors, isDark, currentGradient, context)
              : _buildNarrowCustomizationLayout(colors, isDark, currentGradient, context),

          const SizedBox(height: 32),

          // Bottom section with improved visual hierarchy
          _buildBottomSection(isDark, currentGradient),
        ],
      ),
    );
  }

  // New method for wide screen layout (laptop/desktop) with perfect alignment
  Widget _buildWideCustomizationLayout(List<Color> colors, bool isDark, LinearGradient currentGradient, BuildContext context) {
    return Column(
      children: [
        // Row for section titles - perfectly aligned
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left column title
            Expanded(
              flex: 1,
              child: _buildSectionTitle(
                'Select Color',
                Icons.palette_outlined,
                isDark,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 40),
            // Right column title
            Expanded(
              flex: 2,
              child: _buildSectionTitle(
                'Contact Information',
                Icons.contact_page_outlined,
                isDark,
                gradient: currentGradient,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Row for section content - aligned to start
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Color selection content
            Expanded(
              flex: 1,
              child: _buildColorGrid(colors, isDark),
            ),
            const SizedBox(width: 40),
            // Right column - Contact information content
            Expanded(
              flex: 2,
              child: _buildContactFields(context, isDark, currentGradient),
            ),
          ],
        ),
      ],
    );
  }

  // New method for narrow screen layout (mobile/tablet)
  Widget _buildNarrowCustomizationLayout(List<Color> colors, bool isDark, LinearGradient currentGradient, BuildContext context) {
    return Column(
      children: [
        // Color selection
        _buildSectionTitle('Select Color', Icons.palette_outlined, isDark),
        const SizedBox(height: 16),
        _buildColorGrid(colors, isDark),
        const SizedBox(height: 32),
        // Contact information section
        _buildSectionTitle('Contact Information', Icons.contact_page_outlined, isDark, gradient: currentGradient),
        const SizedBox(height: 16),
        _buildContactFields(context, isDark, currentGradient),
      ],
    );
  }

  // Helper method to build consistent section titles
  Widget _buildSectionTitle(String title, IconData icon, bool isDark, {LinearGradient? gradient, double fontSize = 16}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? _selectedColor.value : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: gradient?.colors.first ?? (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1)),
              width: 1,
            ),
            boxShadow: gradient != null ? [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            color: gradient != null ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6)),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // Enhanced color grid with better visual design
  Widget _buildColorGrid(List<Color> colors, bool isDark) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 900.0;

    return ValueListenableBuilder<Color?>(
      valueListenable: _selectedColor,
      builder: (context, selectedColor, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
              children: [ GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > breakpoint ? 4 : 8,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: screenWidth > breakpoint ? 16.0 : 12.0,
                  mainAxisSpacing: screenWidth > breakpoint ? 16.0 : 12.0,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];
                  final isSelected = selectedColor == color;
                  final dotSize = screenWidth > breakpoint ? 56.0 : 32.0;
                  final iconSize = screenWidth > breakpoint ? 18.0 : 12.0;
                  final borderWidth = screenWidth > breakpoint ? 3.0 : 2.5;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                      setState((){
                        _selectedColor.value = color;
                      }),
                      borderRadius: BorderRadius.circular(dotSize / 2),
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? color
                                : Colors.grey.withValues(alpha: 0.3),
                            width: isSelected ? borderWidth : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: screenWidth > breakpoint ? 12 : 8,
                              offset: Offset(0, screenWidth > breakpoint ? 4 : 2),
                            ),
                          ]
                              : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.all(screenWidth > breakpoint ? 5 : 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                          child: isSelected
                              ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: iconSize,
                          )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ]
          )
        );
      },
    );
  }

  // Enhanced contact fields with better spacing and validation indicators
  Widget _buildContactFields(BuildContext context, bool isDark, LinearGradient currentGradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pet name field
        _buildTextField(
          label: 'Pet\'s Name *',
          hint: "Enter your pet's name",
          valueNotifier: _nameController,
          context: context,
          icon: Icons.pets_outlined,
        ),
        const SizedBox(height: 20),

        // Phone field
        _buildTextField(
          label: 'Phone Number *',
          hint: 'Enter your phone number',
          valueNotifier: _phoneController,
          keyboardType: TextInputType.phone,
          context: context,
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 20),

        // Additional info field
        _buildTextField(
          label: 'Lost Pet Information *',
          hint: 'Enter your address, email, or any info that would help someone return your pet if lost',
          valueNotifier: _additionalInfoController,
          maxLines: 4,
          maxLength: 200,
          context: context,
          icon: Icons.info_outlined,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required ValueNotifier<String> valueNotifier,
    required BuildContext context,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    IconData? icon,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<String>(
          valueListenable: valueNotifier,
          builder: (context, value, child) {
            final bool hasValue = value.trim().isNotEmpty;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                onChanged: (text) {
                  if (maxLength != null && text.length <= maxLength) {
                    valueNotifier.value = text;
                  } else if (maxLength == null) {
                    valueNotifier.value = text;
                  }
                },
                keyboardType: keyboardType,
                maxLines: maxLines ?? 1,
                maxLength: maxLength,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  suffixIcon: hasValue ? Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ) : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: currentGradient.colors.first,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(maxLines != null && maxLines > 1 ? 16.0 : 16.0),
                  counterStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Enhanced bottom section with better visual hierarchy
  Widget _buildBottomSection(bool isDark, LinearGradient currentGradient) {
    return Column(
      children: [
        // Info cards row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.info_outline,
                title: 'QR Code Access',
                description: 'This information will be accessible via the QR code on your HollerTag.',
                color: Colors.blue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.feedback_outlined,
                title: 'We Value Feedback',
                description: 'Have suggestions? Contact us through the menu above.',
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Enhanced purchase button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: currentGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: currentGradient.colors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (AuthService.getCurrentUser() != null) {
                if(_additionalInfoController.value.trim().isEmpty ||
                    _nameController.value.trim().isEmpty ||
                    _phoneController.value.trim().isEmpty){
                  _showSnackBar("Please fill out all required fields!", Colors.red);
                } else{
                  createNewProductTag(
                    name: _nameController.value,
                    description: _additionalInfoController.value,
                    yourBaseDomain: 'hollertag.co',
                    phoneNumber: _phoneController.value,
                  );
                  _showSnackBar("HollerTag purchased successfully!", Colors.green);
                }
              } else {
                _showPurchaseSignUpPopup(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Purchase HollerTag',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for info cards
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Backend functions (unchanged)
  void createNewProductTag({
    required String name,
    required String description,
    required String phoneNumber,
    required String yourBaseDomain,
  }) async {
    try {
      final User? currentUser = AuthService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in to create a tag.');
      }

      final String ownerId = currentUser.uid;

      final Map<String, dynamic> newTagData = {
        'Phone': phoneNumber,
        'Additional Info': description,
        'Found': false,
        'Found Message': "",
        'Name': name,
        'ownerId': ownerId,
      };

      DocumentReference documentRef =
      await FirebaseFirestore.instance.collection('tags').add(newTagData);

      await FirebaseFirestore.instance.collection('users').doc(ownerId).update({
        'pets': FieldValue.arrayUnion([documentRef.id])
      });

      final String newProductId = documentRef.id;
      print('Successfully created new product tag with ID: $newProductId');

      final String productUrl = 'https://$yourBaseDomain/tags/$newProductId';

      final dm = Barcode.qrCode();
      final svg = dm.toSvg(productUrl, width: 200, height: 200);
      //now use the svg to do smth

    } catch (e) {
      print('Error in createNewProductTag: $e');
      rethrow;
    }
  }



  Future<void> _showImagePickerDialog(BuildContext context, ValueNotifier<XFile?> selectedImage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  _showImageCropperPopup(context, selectedImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _showImageCropperPopup(context, selectedImage, initialImage: image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPurchaseSignUpPopup(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.85,
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.85,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
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
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => currentGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        'Account Required',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28 : 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPurchaseCard(
                      Icons.shopping_cart_outlined,
                      'Secure Checkout',
                      'Complete your purchase with encrypted payment processing',
                      screenWidth,
                      isDark,
                      context,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
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
                                Navigator.of(dialogContext).pop();
                                Navigator.pushNamed(context, AppRoutes.signin);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Create Account',
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
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildPurchaseCard(IconData icon, String title, String description,
      double screenWidth, bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.getDefaultGradient(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageCropperPopup(
      BuildContext context, ValueNotifier<XFile?> selectedImage,
      {XFile? initialImage}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageCropperPopup(
          initialImage: initialImage ?? selectedImage.value,
          onImageCropped: (XFile croppedImage) {
            selectedImage.value = croppedImage;
          },
        );
      },
    );
  }
}