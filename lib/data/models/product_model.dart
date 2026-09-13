/// A reward a seller lists in the marketplace, priced in game points.
class ProductModel {
  final String id;
  final String name;
  final String description;
  final int priceInPoints;

  /// What the seller settles with the platform when a player redeems this —
  /// the cash value the business is willing to honour.
  final double redeemValueInRupees;
  final String sellerId;
  final String sellerName;
  final String category;
  final int stock;
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceInPoints,
    this.redeemValueInRupees = 0,
    required this.sellerId,
    required this.sellerName,
    this.category = 'General',
    this.stock = 0,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ProductModel copyWith({int? stock, bool? isActive}) => ProductModel(
        id: id,
        name: name,
        description: description,
        priceInPoints: priceInPoints,
        redeemValueInRupees: redeemValueInRupees,
        sellerId: sellerId,
        sellerName: sellerName,
        category: category,
        stock: stock ?? this.stock,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'priceInPoints': priceInPoints,
        'redeemValueInRupees': redeemValueInRupees,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'category': category,
        'stock': stock,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        priceInPoints: json['priceInPoints'] as int,
        redeemValueInRupees:
            (json['redeemValueInRupees'] as num?)?.toDouble() ?? 0,
        sellerId: json['sellerId'] as String,
        sellerName: json['sellerName'] as String,
        category: json['category'] as String? ?? 'General',
        stock: json['stock'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class PurchaseModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final int pointsSpent;

  /// Short code the player shows the seller to claim the reward.
  final String redemptionCode;
  final DateTime purchasedAt;
  final bool synced;

  PurchaseModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.pointsSpent,
    required this.redemptionCode,
    DateTime? purchasedAt,
    this.synced = false,
  }) : purchasedAt = purchasedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'productId': productId,
        'productName': productName,
        'pointsSpent': pointsSpent,
        'redemptionCode': redemptionCode,
        'purchasedAt': purchasedAt.toIso8601String(),
        'synced': synced,
      };

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        pointsSpent: json['pointsSpent'] as int,
        redemptionCode: json['redemptionCode'] as String? ?? '',
        purchasedAt: DateTime.parse(json['purchasedAt'] as String),
        synced: json['synced'] as bool? ?? false,
      );
}
