import 'package:flutter/material.dart';
import 'package:myapp/elements/my_app_bar.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:image_cropper/image_cropper.dart'; // For cropping images
import 'dart:io'; // For handling File objects
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

              // product customization section
              _buildCustomizationSection(context, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildNarrowLayout(BuildContext context, Color primaryColor) {
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
      constraints: const BoxConstraints(maxHeight: 400),
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

  Widget _buildCustomizationSection(BuildContext context, Color primaryColor) {
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
    final ValueNotifier<XFile?> _selectedImage = ValueNotifier<XFile?>(null); // To hold the selected image file

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
                  selectedColor: AppTheme.getDefaultGradient(context).colors.first,
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.getDefaultGradient(context).colors.first;
                      }
                      return null; // Use default unselected color
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
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipOval(
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => _showImagePickerDialog(context, _selectedImage),
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                          return isDarkMode ? Colors.white : Colors.black;
                        },
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                      side: WidgetStateProperty.resolveWith<BorderSide>(
                        (Set<WidgetState> states) {
                          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                          return BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black,
                            width: 2.5,
                          );
                        },
                      ),
                    ),
                    child: Text(
                      'Upload Image',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              );
            },
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
                // Access selected color, size, and image (_selectedImage.value) here
                // print('Selected Color: ${_selectedColor.value}');
                // print('Selected Size: ${_selectedSize.value}');
                // print('Selected Image Path: ${_selectedImage.value?.path}');
                // Add to cart logic
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
                child: const Text('Add to Cart',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImagePickerDialog(BuildContext context, ValueNotifier<XFile?> selectedImageNotifier) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    // ignore: use_build_context_synchronously
                    _cropCircularImage(context, pickedFile, selectedImageNotifier);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    // ignore: use_build_context_synchronously
                    _cropCircularImage(context, pickedFile, selectedImageNotifier);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _cropCircularImage(BuildContext context, XFile imageFile, ValueNotifier<XFile?> selectedImageNotifier) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Make it a square
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Adjust Profile Picture',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Adjust Profile Picture',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      selectedImageNotifier.value = XFile(croppedFile.path);
    }
  }
}
