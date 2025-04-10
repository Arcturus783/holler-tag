class Product {
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  
  Product({
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });
}