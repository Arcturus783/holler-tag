import 'package:flutter/material.dart';
import 'package:myapp/elements/my_app_bar.dart';

class ProductPage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const ProductPage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    // Check if the screen width is above 600 for responsive layout
    bool isWideScreen = MediaQuery.of(context).size.width > 600;

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
              if (isWideScreen) _buildWideLayout() else _buildNarrowLayout(),

              const SizedBox(height: 32),

              // product customization section
              _buildCustomizationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
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
          child: _buildProductInfo(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top: Product image
        _buildProductImage(),
        const SizedBox(height: 24),
        // Bottom: Title and description
        _buildProductInfo(),
      ],
    );
  }

  Widget _buildProductImage() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 5),
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
        Text(
          'HollerTag',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Meet the HollerTag, your once-stop shop for safety, style, and suave for your furry friend.'
          'The QR code on the back allows people who find a lost pet to access the owner\'s information, if they have unlocked it.'
          'Plus, thanks to advanced 3D printing, the HollerTag can be customized to the finest detail.',
          style: const TextStyle(
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
      {'icon': Icons.format_paint_rounded, 'label': 'Customize Style, Color, and Shape'},
      {'icon': Icons.handyman_rounded, 'label': 'Durable and Pet-Friendly Materials'},
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
                  Text(
                      spec['label'] as String,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
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
            'Your feedback is important to us. If you have any suggestions for features you would like to see, we\'d love to hear them!',
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
