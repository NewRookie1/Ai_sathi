class CollectiveOrder {
  final String id;
  final String title;
  final String productName;
  final double price;
  final int targetQty;
  final int joinedQty;
  final String endsIn;

  const CollectiveOrder({
    required this.id,
    required this.title,
    required this.productName,
    required this.price,
    required this.targetQty,
    required this.joinedQty,
    required this.endsIn,
  });

  double get progress =>
      targetQty == 0 ? 0 : (joinedQty / targetQty).clamp(0.0, 1.0);
  int get spotsLeft => (targetQty - joinedQty).clamp(0, targetQty);

  CollectiveOrder copyWith({int? joinedQty}) => CollectiveOrder(
        id: id,
        title: title,
        productName: productName,
        price: price,
        targetQty: targetQty,
        joinedQty: joinedQty ?? this.joinedQty,
        endsIn: endsIn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'productName': productName,
        'price': price,
        'targetQty': targetQty,
        'joinedQty': joinedQty,
        'endsIn': endsIn,
      };

  factory CollectiveOrder.fromJson(Map<String, dynamic> json) =>
      CollectiveOrder(
        id: json['id'] as String,
        title: json['title'] as String,
        productName: json['productName'] as String,
        price: (json['price'] as num).toDouble(),
        targetQty: json['targetQty'] as int,
        joinedQty: json['joinedQty'] as int,
        endsIn: json['endsIn'] as String,
      );
}

class SecondHandItem {
  final String id;
  final String title;
  final double price;
  final double mrp;
  final String condition;
  final String seller;

  const SecondHandItem({
    required this.id,
    required this.title,
    required this.price,
    required this.mrp,
    required this.condition,
    required this.seller,
  });

  int get discountPercent =>
      mrp <= 0 ? 0 : (((mrp - price) / mrp) * 100).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'mrp': mrp,
        'condition': condition,
        'seller': seller,
      };

  factory SecondHandItem.fromJson(Map<String, dynamic> json) =>
      SecondHandItem(
        id: json['id'] as String,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        mrp: (json['mrp'] as num).toDouble(),
        condition: json['condition'] as String,
        seller: json['seller'] as String,
      );
}

class CollabPost {
  final String id;
  final String title;
  final String type;
  final String description;
  final String author;
  final String location;
  final int interestedCount;
  final bool interested;

  const CollabPost({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.author,
    required this.location,
    this.interestedCount = 0,
    this.interested = false,
  });

  CollabPost copyWith({bool? interested, int? interestedCount}) =>
      CollabPost(
        id: id,
        title: title,
        type: type,
        description: description,
        author: author,
        location: location,
        interestedCount: interestedCount ?? this.interestedCount,
        interested: interested ?? this.interested,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'description': description,
        'author': author,
        'location': location,
        'interestedCount': interestedCount,
        'interested': interested,
      };

  factory CollabPost.fromJson(Map<String, dynamic> json) => CollabPost(
        id: json['id'] as String,
        title: json['title'] as String,
        type: json['type'] as String,
        description: json['description'] as String,
        author: json['author'] as String,
        location: json['location'] as String,
        interestedCount: (json['interestedCount'] ?? 0) as int,
        interested: (json['interested'] ?? false) as bool,
      );
}
