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
          'Premium Ultra Laptop Pro',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Experience unparalleled performance with our flagship laptop. '
          'Featuring the latest processor technology, stunning display, and '
          'all-day battery life. Perfect for professionals and creatives who '
          'demand the best.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildSpecsList(),
      ],
    );
  }

  Widget _buildSpecsList() {
    final specs = [
      {'icon': Icons.memory, 'label': 'Latest Gen Processor'},
      {'icon': Icons.sd_storage, 'label': '1TB SSD Storage'},
      {'icon': Icons.battery_full, 'label': '12 Hour Battery Life'},
      {'icon': Icons.monitor, 'label': '4K Retina Display'},
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
                  Text(spec['label'] as String),
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
            'This section will contain product customization options and order functionality.',
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
