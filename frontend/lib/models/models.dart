class User {
  final int id;
  final String username;
  final String role;
  final String? token;

  final int? restaurantId;

  User({required this.id, required this.username, required this.role, this.token, this.restaurantId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      token: json['access_token'],
      restaurantId: (json['restaurant_id'] as num?)?.toInt(),
    );
  }
}

class Category {
  final int id;
  final String name;
  final int restaurantId;

  Category({required this.id, required this.name, required this.restaurantId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? 'Unknown',
      restaurantId: (json['restaurant_id'] as num?)?.toInt() ?? 0,  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final String? categoryName;
  final bool isAvailable;
  final Map<String, dynamic> modifiers;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
    required this.isAvailable,
    required this.modifiers,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? 'Unknown Item',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      categoryName: json['category_name'],
      isAvailable: json['is_available'] ?? true,
      modifiers: json['modifiers'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category_id': categoryId,
      'is_available': isAvailable,
      'modifiers': modifiers,
    };
  }
}

class OrderItem {
  final int? id;
  final int productId;
  final int quantity;
  final Map<String, dynamic> selectedModifiers;
  final Product? product;

  OrderItem({
    this.id,
    required this.productId,
    required this.quantity,
    required this.selectedModifiers,
    this.product,
  });

  OrderItem copyWith({
    int? id,
    int? productId,
    int? quantity,
    Map<String, dynamic>? selectedModifiers,
    Product? product,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'selected_modifiers': selectedModifiers,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int?,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedModifiers: json['selected_modifiers'] ?? {},
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class Order {
  final int? id;
  final double totalAmount;
  final String paymentStatus;
  final String status;
  final List<OrderItem> items;
  final DateTime? createdAt;

  Order({
    this.id,
    required this.totalAmount,
    required this.paymentStatus,
    required this.status,
    required this.items,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] as num?)?.toInt(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'unpaid',
      status: json['status'] ?? 'pending',
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
