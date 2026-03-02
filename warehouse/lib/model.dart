class Product {
  Product({required this.name, required this.description, required this.category, required this.price, required this.n});

  final String name;
  final String description;
  final String category;
  final int price;
  final int n;

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'category': category, 'price': price, 'n': n};
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(name: map['name'], description: map['description'], category: map['category'], price: map['price'], n: map['n']);
  }
}