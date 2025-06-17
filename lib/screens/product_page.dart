import 'package:flutter/material.dart';

import 'package:myapp/elements/my_app_bar.dart';

import 'package:myapp/elements/app_theme.dart';

import 'package:image_picker/image_picker.dart'; // For picking images

import 'dart:io'; // For handling File objects

import 'package:myapp/elements/image_cropper_popup.dart';

import 'package:myapp/backend/google_auth.dart';

class ProductPage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const ProductPage({super.key, required this.toggleTheme});

  // Helper function to determine the background color based on the theme

  Color _getContainerBackgroundColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode
        ? const Color.fromARGB(255, 37, 37, 37)
        : const Color.fromARGB(255, 255, 255, 255);
  }

  @override
  Widget build(BuildContext context) {
    // Get the primary color from the current theme

    final primaryColor = Theme.of(context).colorScheme.primary;

    // Check if the screen width is above 800 for responsive layout

    bool isWideScreen = MediaQuery.of(context).size.width > 800;

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
        ...specs.map((spec) => Padding(
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

  Widget _buildCombinedCustomizationSection(BuildContext context, Color primaryColor) {
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
    final ValueNotifier<String> _additionalInfoController = ValueNotifier<String>('');

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
          const SizedBox(height: 16),
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
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Optional Address field
          const Text(
            'Address (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _addressController,
            builder: (context, value, child) {
              return TextField(
                onChanged: (text) => _addressController.value = text,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Optional Phone field
          const Text(
            'Phone Number (Optional)',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Optional Additional Information field with character limit
          const Text(
            'Additional Information (Optional)',
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
                      hintText: 'Enter any additional information',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            'Your feedback is important to us. If you have any suggestions for features you would like to see, we\'d love to hear them!',
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
                } else {
                  AuthService.signInWithGoogle();

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
                shaderCallback: (bounds) => currentGradient.createShader(
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

// Updated image picker dialog function

  Future<void> _showImagePickerDialog(
      BuildContext context, ValueNotifier<XFile?> selectedImage) async {
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