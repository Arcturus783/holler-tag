import 'package:flutter/material.dart';

import 'package:myapp/elements/my_app_bar.dart';

import 'package:myapp/elements/app_theme.dart';

import 'package:image_picker/image_picker.dart'; // For picking images

import 'dart:io'; // For handling File objects

import 'package:myapp/elements/image_cropper_popup.dart';

import 'package:myapp/backend/google_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:file_saver/file_saver.dart';

import 'package:barcode/barcode.dart';

class ProductPage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const ProductPage({super.key, required this.toggleTheme});

  // Helper function to determine the background color based on the theme

  Color _getContainerBackgroundColor(BuildContext context) {
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

    return isDarkMode
        ? const Color.fromARGB(255, 37, 37, 37)
        : const Color.fromARGB(255, 255, 255, 255);
  }

  @override
  Widget build(BuildContext context) {
    // Get the primary color from the current theme

    final primaryColor = Theme
        .of(context)
        .colorScheme
        .primary;

    // Check if the screen width is above 800 for responsive layout

    bool isWideScreen = MediaQuery
        .of(context)
        .size
        .width > 800;

    return Scaffold(
      appBar: MyAppBar(
        toggleTheme: toggleTheme,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive layout: Row for wide screens, Column for narrow screens

              if (isWideScreen)
                _buildWideLayout(context, primaryColor)
              else
                _buildNarrowLayout(context, primaryColor),

              const SizedBox(height: 32),

              // Combined customization and contact information section
              _buildCombinedCustomizationSection(context, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, Color primaryColor) {
    // Use IntrinsicHeight to make both children of the Row match the height

    // of the tallest child. In this case, the image will likely be the tallest.

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .stretch, // Stretch children to fill available height

        children: [
          // Left side: Product image in container (1/2 of the space)

          Expanded(
            flex: 1,
            child: _buildProductImage(),
          ),

          const SizedBox(width: 24),

          // Right side: Title and description (1/2 of the space)

          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getContainerBackgroundColor(context),

                borderRadius: BorderRadius.circular(12),

                border:
                Border.all(color: primaryColor, width: 2.0), // Added border
              ),
              child: _buildProductInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, Color primaryColor) {
    // For narrow layout, the image and info box are in a Column.

    // Their heights are not linked; each takes its natural height.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top: Product image

        _buildProductImage(),

        const SizedBox(height: 24),

        // Bottom: Title and description in a grey container

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getContainerBackgroundColor(context),

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: primaryColor, width: 2.0), // Added border
          ),
          child: _buildProductInfo(),
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    return Container(
      constraints:
      const BoxConstraints(maxHeight: 400), // Max height for the image

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/laptop.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HollerTag',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Meet the HollerTag, your once-stop shop for safety, style, and suave for your furry friend.'
              'The QR code on the back allows people who find a lost pet to access the owner\'s information, if they have unlocked it.'
              'Plus, thanks to advanced 3D printing, the HollerTag can be customized to the finest detail.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildFeatureList(),
      ],
    );
  }

  Widget _buildFeatureList() {
    final specs = [
      {'icon': Icons.lock_person, 'label': 'Control Your Personal Information'},
      {
        'icon': Icons.format_paint_rounded,
        'label': 'Customize Style, Color, and Shape'
      },
      {
        'icon': Icons.handyman_rounded,
        'label': 'Durable and Pet-Friendly Materials'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...specs.map((spec) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(spec['icon'] as IconData, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      spec['label'] as String,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCombinedCustomizationSection(BuildContext context,
      Color primaryColor) {
    final currentGradient = AppTheme.getDefaultGradient(context);

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

    final List<String> sizes = ['S', 'M', 'L', 'XL'];

    final ValueNotifier<Color?> _selectedColor = ValueNotifier<Color?>(null);
    final ValueNotifier<String?> _selectedSize = ValueNotifier<String?>(null);
    final ValueNotifier<XFile?> _selectedImage = ValueNotifier<XFile?>(null);

    // Contact information controllers
    final ValueNotifier<String> _nameController = ValueNotifier<String>('');
    final ValueNotifier<String> _addressController = ValueNotifier<String>('');
    final ValueNotifier<String> _phoneController = ValueNotifier<String>('');
    final ValueNotifier<String> _additionalInfoController = ValueNotifier<
        String>('');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getContainerBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customize Your Product',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Product Customization Section
          const Text(
            'Select Color:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 200.0,
            child: ValueListenableBuilder<Color?>(
              valueListenable: _selectedColor,
              builder: (context, selectedColor, child) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];

                    return SizedBox(
                      width: 36.0,
                      height: 36.0,
                      child: InkWell(
                        onTap: () {
                          _selectedColor.value = color;
                        },
                        borderRadius: BorderRadius.circular(18.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            Container(
                              width: 18.0,
                              height: 18.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                            if (selectedColor == color)
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          /*
          const Text(
            'Select Size:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String?>(
            valueListenable: _selectedSize,
            builder: (context, selectedSize, child) {
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: sizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: selectedSize == size,
                    onSelected: (bool selected) {
                      _selectedSize.value = selected ? size : null;
                    },
                    selectedColor:
                        AppTheme.getDefaultGradient(context).colors.first,
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.getDefaultGradient(context)
                              .colors
                              .first;
                        }

                        return null;
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Upload Custom Image (Optional):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<XFile?>(
            valueListenable: _selectedImage,
            builder: (context, image, child) {
              return Column(
                children: [
                  if (image != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: ClipOval(
                              child: Image.file(
                                File(image.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Add edit button on the preview

                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.white, size: 16),
                                onPressed: () => _showImageCropperPopup(
                                    context, _selectedImage),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showImagePickerDialog(context, _selectedImage),
                    icon: const Icon(Icons.photo_library),
                    label:
                        Text(image == null ? 'Upload Image' : 'Change Image'),
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      shadowColor:
                          WidgetStateProperty.all<Color>(Colors.transparent),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          final isDarkMode =
                              Theme.of(context).brightness == Brightness.dark;

                          return isDarkMode ? Colors.white : Colors.black;
                        },
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.transparent),
                      side: WidgetStateProperty.resolveWith<BorderSide>(
                        (Set<WidgetState> states) {
                          final isDarkMode =
                              Theme.of(context).brightness == Brightness.dark;

                          return BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black,
                            width: 2.5,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          */
          // Contact Information Section
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Required Name field
          const Text(
            'Name *',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _nameController,
            builder: (context, value, child) {
              return TextField(
                onChanged: (text) => _nameController.value = text,
                decoration: InputDecoration(
                  hintText: "Enter your pet's name",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  // Custom grey color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Optional Phone field
          const Text(
            'Phone Number',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _phoneController,
            builder: (context, value, child) {
              return TextField(
                onChanged: (text) => _phoneController.value = text,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Optional Additional Information field with character limit
          const Text(
            'Lost Pet Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _additionalInfoController,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    onChanged: (text) {
                      if (text.length <= 200) {
                        _additionalInfoController.value = text;
                      }
                    },
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Enter your address, email, or any info that would help someone return your pet if lost',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      counterText: '${value.length}/200',
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          const Text(
            'This information will be accessible via the QR code on your HollerTag.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Your feedback is important to us. If you have any suggestions for features you would like to see, we\'d love to hear them! Please reach out via the Contact Us option at the top.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (AuthService.getCurrentUser() != null) {
                  //continue with payment
                  createNewProductTag(address: _addressController.value,
                      description: _additionalInfoController.value,
                      yourBaseDomain: 'hollertag.com',
                      phoneNumber: _phoneController.value);
                } else {
                  _showPurchaseSignUpPopup(context);
                  //then continue with payment
                }
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    return currentGradient.colors.first;
                  },
                ),
                backgroundColor:
                WidgetStateProperty.all<Color>(Colors.transparent),
                side: WidgetStateProperty.resolveWith<BorderSide>(
                      (Set<WidgetState> states) {
                    return BorderSide(
                      color: currentGradient.colors.first,
                      width: 2.5,
                    );
                  },
                ),
              ),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    currentGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: const Text('Purchase',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void createNewProductTag({
    required String address,
    required String description,
    required String phoneNumber,
    required String yourBaseDomain, // New parameter for your domain
  }) async {
    try {
      // 1. Get the authenticated user's ID
      final User? currentUser = AuthService.getCurrentUser();

      if (currentUser == null) {
        throw Exception(
            'User not authenticated. Please log in to create a tag.');
      }

      final String ownerId = currentUser.uid;

      // 2. Prepare the data for the new document
      final Map<String, dynamic> newTagData = {
        'Phone': phoneNumber,
        'Additional Info': description,
        'Found': false,
        'Found Message': "",
        'Name': "Woofer",
        'ownerId' : ownerId,
      };

      // 3. Add the document to the "tags" collection
      DocumentReference documentRef =
      await FirebaseFirestore.instance.collection('tags').add(newTagData);

      //add pet tag to user
      await FirebaseFirestore.instance.collection('users').doc(ownerId).update({
        'pets': FieldValue.arrayUnion([documentRef.id])
      });

      final String newProductId = documentRef.id;
      print('Successfully created new product tag with ID: $newProductId');


      final String productUrl = 'https://$yourBaseDomain/products/$newProductId';
      final dm = Barcode.qrCode();
      final svg = dm.toSvg(productUrl, width: 200, height: 200);
      await File('barcode.svg').writeAsString(svg);
    } catch (e) {
      print('Error in createNewProductTag: $e');
      rethrow; // Re-throw the exception for handling in the UI
    }
  }


// Updated image picker dialog function

  Future<void> _showImagePickerDialog(BuildContext context,
      ValueNotifier<XFile?> selectedImage) async {
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

                  // No initial image needed for gallery pick

                  _showImageCropperPopup(context, selectedImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();

                  final ImagePicker picker = ImagePicker();

                  final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);

                  if (image != null) {
                    // ignore: use_build_context_synchronously

                    _showImageCropperPopup(context, selectedImage,
                        initialImage: image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Enhanced Purchase popup with modern design matching Contact Us popup ---
  void _showPurchaseSignUpPopup(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
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
              maxWidth: screenWidth > 600 ? screenWidth * 0.4 : screenWidth *
                  0.85,
              maxHeight: MediaQuery
                  .of(context)
                  .size
                  .height * 0.7,
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
                    // Title with gradient matching Contact Us style
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          currentGradient.createShader(
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

                    // Info cards matching the contact card style
                    _buildPurchaseCard(
                      Icons.shopping_cart_outlined,
                      'Secure Checkout',
                      'Complete your purchase with encrypted payment processing',
                      screenWidth,
                      isDark,
                      context
                    ),
                    const SizedBox(height: 32),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: currentGradient,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: currentGradient.colors.first
                                      .withValues(alpha: 0.3),
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
                              child: Text(
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

// Helper method to build purchase info cards matching contact card style
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


// New function to show the image cropper popup

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