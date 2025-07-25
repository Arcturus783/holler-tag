import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/elements/my_app_bar.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/elements/image_cropper_popup.dart';

class LinkTagScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String tagId; // The scanned tag ID

  const LinkTagScreen({
    super.key,
    required this.toggleTheme,
    required this.tagId,
  });

  @override
  State<LinkTagScreen> createState() => _LinkTagScreenState();
}

class _LinkTagScreenState extends State<LinkTagScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers and state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  // Value notifiers for form state (removed color-related notifiers)
  final ValueNotifier<String?> _selectedSize = ValueNotifier<String?>(null);
  final ValueNotifier<XFile?> _selectedImage = ValueNotifier<XFile?>(null);

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
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
      begin: const Offset(0, 0.4),
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
    _nameController.dispose();
    _phoneController.dispose();
    _additionalInfoController.dispose();
    _selectedSize.dispose();
    _selectedImage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  // Hero section with tag ID
                  _buildHeroSection(context, currentGradient),
                  const SizedBox(height: 32),

                  // Tag ID display section
                  _buildTagDisplaySection(context, currentGradient, isDark),
                  const SizedBox(height: 32),

                  // Pet information section
                  _buildPetInformationSection(context, currentGradient, isDark),
                  const SizedBox(height: 32),

                  // Create pet button
                  _buildCreatePetButton(context, currentGradient),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, LinearGradient currentGradient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tag Scanned',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Create Pet Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: const Text(
              'Complete your pet\'s profile to activate this HollerTag and link it to your account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagDisplaySection(BuildContext context, LinearGradient currentGradient, bool isDark) {
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
                  Icons.verified,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Scanned Tag',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentGradient.colors.first.withValues(alpha: 0.1),
                  currentGradient.colors.last.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: currentGradient.colors.first.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: currentGradient.colors.first.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tag,
                    color: currentGradient.colors.first,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tag ID',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.tagId,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInformationSection(BuildContext context, LinearGradient currentGradient, bool isDark) {
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
                  Icons.pets,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Pet Information',
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

          // Contact Information fields (now takes full width)
          _buildContactFields(context, isDark, currentGradient),
        ],
      ),
    );
  }

  Widget _buildContactFields(BuildContext context, bool isDark, LinearGradient currentGradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Pet\'s Name *',
          hint: "Enter your pet's name",
          controller: _nameController,
          context: context,
          icon: Icons.pets_outlined,
          isDark: isDark,
          currentGradient: currentGradient,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Phone Number *',
          hint: 'Enter your phone number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          context: context,
          icon: Icons.phone_outlined,
          isDark: isDark,
          currentGradient: currentGradient,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Lost Pet Information *',
          hint: 'Enter your address, email, or any info that would help someone return your pet if lost',
          controller: _additionalInfoController,
          maxLines: 4,
          maxLength: 200,
          context: context,
          icon: Icons.info_outlined,
          isDark: isDark,
          currentGradient: currentGradient,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required BuildContext context,
    required bool isDark,
    required LinearGradient currentGradient,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    IconData? icon,
  }) {
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
        Container(
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
            controller: controller,
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
              suffixIcon: controller.text.trim().isNotEmpty ? const Icon(
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
        ),
      ],
    );
  }

  Widget _buildCreatePetButton(BuildContext context, LinearGradient currentGradient) {
    return ValueListenableBuilder3<String, String, String>(
      first: ValueNotifier(_nameController.text),
      second: ValueNotifier(_phoneController.text),
      third: ValueNotifier(_additionalInfoController.text),
      builder: (context, name, phone, additionalInfo, child) {
        final bool isFormValid = name.trim().isNotEmpty &&
            phone.trim().isNotEmpty &&
            additionalInfo.trim().isNotEmpty;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isFormValid ? currentGradient : LinearGradient(
              colors: [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.2)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isFormValid ? [
              BoxShadow(
                color: currentGradient.colors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ] : [],
          ),
          child: ElevatedButton(
            onPressed: isFormValid ? () {
              // TODO: Implement create pet functionality with widget.tagId
              print('Creating pet profile for tag: ${widget.tagId}');
              _showSnackBar("Pet profile created successfully!", Colors.green);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  color: isFormValid ? Colors.white : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Create Pet Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isFormValid ? Colors.white : Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImagePickerDialog(BuildContext context, ValueNotifier<XFile?> selectedImage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Image Source',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7),
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  _showImageCropperPopup(context, selectedImage);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7),
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
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
}

// Helper class for ValueListenableBuilder with 3 values
class ValueListenableBuilder3<A, B, C> extends StatelessWidget {
  const ValueListenableBuilder3({
    Key? key,
    required this.first,
    required this.second,
    required this.third,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, C c, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (_, b, __) {
            return ValueListenableBuilder<C>(
              valueListenable: third,
              builder: (_, c, __) {
                return builder(context, a, b, c, child);
              },
            );
          },
        );
      },
    );
  }
}