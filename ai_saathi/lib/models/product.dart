class Product {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String? category;
  final String? craftType;
  final String? material;
  final List<String> colors;
  final List<String> tags;
  final double price;
  final double? minPrice;
  final double? maxPrice;
  final int quantity;
  final List<ProductImage> images;
  final String? enhancedImage;
  final double? rawMaterialCost;
  final double? laborCost;
  final ProductStats stats;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.category,
    this.craftType,
    this.material,
    this.colors = const [],
    this.tags = const [],
    required this.price,
    this.minPrice,
    this.maxPrice,
    this.quantity = 0,
    this.images = const [],
    this.enhancedImage,
    this.rawMaterialCost,
    this.laborCost,
    required this.stats,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      craftType: json['craft_type'],
      material: json['material'],
      colors: List<String>.from(json['colors'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      quantity: json['quantity'] ?? 0,
      images: (json['images'] as List?)
          ?.map((e) => ProductImage.fromJson(e))
          .toList() ?? [],
      enhancedImage: json['enhanced_image'],
      rawMaterialCost: json['raw_material_cost']?.toDouble(),
      laborCost: json['labor_cost']?.toDouble(),
      stats: ProductStats.fromJson(json['stats'] ?? {}),
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'category': category,
      'craft_type': craftType,
      'material': material,
      'colors': colors,
      'tags': tags,
      'price': price,
      'min_price': minPrice,
      'max_price': maxPrice,
      'quantity': quantity,
      'images': images.map((e) => e.toJson()).toList(),
      'enhanced_image': enhancedImage,
      'raw_material_cost': rawMaterialCost,
      'labor_cost': laborCost,
      'stats': stats.toJson(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? name,
    String? description,
    String? category,
    String? craftType,
    String? material,
    List<String>? colors,
    List<String>? tags,
    double? price,
    double? minPrice,
    double? maxPrice,
    int? quantity,
    List<ProductImage>? images,
    String? enhancedImage,
    double? rawMaterialCost,
    double? laborCost,
    String? status,
  }) {
    return Product(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      craftType: craftType ?? this.craftType,
      material: material ?? this.material,
      colors: colors ?? this.colors,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      quantity: quantity ?? this.quantity,
      images: images ?? this.images,
      enhancedImage: enhancedImage ?? this.enhancedImage,
      rawMaterialCost: rawMaterialCost ?? this.rawMaterialCost,
      laborCost: laborCost ?? this.laborCost,
      stats: stats,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ProductImage {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final bool isOriginal;
  final DateTime createdAt;

  ProductImage({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.isOriginal = true,
    required this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      url: json['url'],
      thumbnailUrl: json['thumbnail_url'],
      isOriginal: json['is_original'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'is_original': isOriginal,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ProductStats {
  final int views;
  final int orders;
  final int quantitySold;
  final double revenue;
  final double conversionRate;

  ProductStats({
    this.views = 0,
    this.orders = 0,
    this.quantitySold = 0,
    this.revenue = 0,
    this.conversionRate = 0,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      views: json['views'] ?? 0,
      orders: json['orders'] ?? 0,
      quantitySold: json['quantity_sold'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      conversionRate: (json['conversion_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'views': views,
      'orders': orders,
      'quantity_sold': quantitySold,
      'revenue': revenue,
      'conversion_rate': conversionRate,
    };
  }
}
