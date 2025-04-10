import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:myapp/elements/custom_button.dart';

//import 'package:myapp/elements/app_theme.dart';
//add the theme to the button/text elements please

class ProductCard extends StatefulWidget {
  final String imgUrl;
  final String description;
  final String name;
  final String phrase;
  final double width;
  final double height;
  const ProductCard({
    super.key,
    required this.imgUrl,
    required this.description,
    required this.name,
    required this.phrase,
    required this.width,
    required this.height,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromARGB(252, 255, 255, 255),
        width: widget.width,
        height: widget.height,
        child: GFCard(
            boxFit: BoxFit.cover,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 2.0,
            image: Image.asset(
              widget.imgUrl,
              height: 150, // Adjust height as needed
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            showImage: true,
            titlePosition: GFPosition.start,
            content: Text(widget.description),
            buttonBar: GFButtonBar(children: <Widget>[
              CustomButton(
                onPressed: () {},
                textColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 64, 128, 255),
                child: Text(
                  "Buy",
                ),
              )
            ]),
            title: GFListTile(
              title: Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ),
              subTitle: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: Text(
                  widget.phrase,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                  ),
                ),
              ),
            )));
  }
}
