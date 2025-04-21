// product_card.dart
import 'package:flutter/material.dart';
//import 'package:getwidget/getwidget.dart';
import 'package:myapp/elements/custom_button.dart';
import 'package:myapp/backend/product.dart';
import 'package:myapp/main.dart';
import 'package:myapp/screens/product_page.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String imgUrl;
  final String description;
  final String name;
  final String phrase;
  final VoidCallback toggleTheme;
  const ProductCard({
    super.key,
    required this.imgUrl,
    required this.product,
    required this.description,
    required this.name,
    required this.phrase,
    required this.toggleTheme,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovering = false;
  final double _imageAspectRatio = 16 / 9;
  final double _verticalSpacing = 4.0; // Small gap
  final int _maxLines = 2;
  final double _maxFontSize = 16.0;
  final double _minFontSize = 10.0;

  void _openProductPage(BuildContext ctx) {
    Navigator.pushNamed(
      ctx,
      AppRoutes.product_page,
      arguments: {'product': widget.product, 'toggleTheme': widget.toggleTheme},
    );
  }

  @override
Widget build(BuildContext context) {
  return MouseRegion(
    onEnter: (_) => setState(() => _isHovering = true),
    onExit: (_) => setState(() => _isHovering = false),
    child: GestureDetector(
      onTap: () => _openProductPage(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight > 0 ? constraints.maxHeight : 200;
          double imageHeight = height * 0.65;
          double spacing = height * 0.01;
          double fontSize = (height * 0.12).clamp(_minFontSize, _maxFontSize);

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.asset(widget.imgUrl, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: _maxLines,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}


  TextPainter _createTextPainter(String text, double fontSize, BuildContext context, double maxWidth, int maxLines) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
  }
}