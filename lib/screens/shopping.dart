// shopping.dart
import 'package:flutter/material.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:myapp/backend/product.dart';
import 'package:myapp/elements/product_card.dart';
import 'package:myapp/elements/my_app_bar.dart';

class ShoppingPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const ShoppingPage({super.key, required this.toggleTheme});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final products = <Product>[
    Product(
        name: "Tag",
        price: 15.99,
        description: "Beauty.",
        imageUrl: "assets/images/laptop.jpg"),
    Product(
        name: "Ultra Tag",
        price: 29.99,
        description: "Sexiest tag on the block.",
        imageUrl: "assets/images/photo-1580522154071-c6ca47a859ad.jpg"),
    Product(
      name: "Super Tag",
      price: 19.99,
      description: "Cool redefined.",
      imageUrl: "assets/images/download (1).jpg",
    )
  ];
  final double _imageAspectRatio = 16 / 9;
  final double _verticalSpacing = 4.0;
  final int _maxLines = 2;
  final double _maxFontSize = 16.0;
  final double _minFontSize = 10.0;

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
        appBar: MyAppBar(),
        body: SingleChildScrollView(
            child: Column(children: [
          if (MediaQuery.of(context).size.width >= 800)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text("HollerTag Products",
                    style: TextStyle(
                        color: textColor,
                        fontSize: 55,
                        fontWeight: FontWeight.bold)),
                Spacer(),
                Text("Built for you.",
                    style: TextStyle(fontSize: 25, color: textColor))
              ]),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 30, 16.0, 0),
              child: Text("HollerTag Products",
                  style: TextStyle(
                      fontSize: 34,
                      color: textColor,
                      fontWeight: FontWeight.bold)),
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          GridView.custom(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, // Width of each card
              mainAxisExtent: 250, // Height of each card
              mainAxisSpacing: 30,
              crossAxisSpacing: 20,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  imgUrl: product.imageUrl,
                  description: product.description,
                  name: product.name,
                  phrase: "Beauty at its finest...",
                  toggleTheme: widget.toggleTheme,
                );
              },
              childCount: products.length,
            ),
          ),
        ])));
  }

  int _crossAxisCount(BuildContext context, double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
