import 'dart:math';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/data/models/product_model.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';

/// Where points turn into something you can hold.
///
/// A seller lists a reward with two numbers on it: what a player pays in
/// points, and what the business settles in rupees when the code is redeemed.
/// The second number is what makes the shelf worth stocking.
class MarketplaceController extends GetxController {
  static MarketplaceController get to => Get.find();

  final _uuid = const Uuid();
  final _random = Random();

  final products = <ProductModel>[].obs;
  final myPurchases = <PurchaseModel>[].obs;
  final category = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshShelf();
  }

  void refreshShelf() {
    products.assignAll(HiveService.availableProducts());
    final id = Get.find<AuthController>().current.value?.id;
    if (id != null) myPurchases.assignAll(HiveService.purchasesFor(id));
  }

  List<String> get categories {
    final names = products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...names];
  }

  List<ProductModel> get visible => category.value == 'All'
      ? products
      : products.where((p) => p.category == category.value).toList();

  bool canAfford(ProductModel product) {
    final points = Get.find<AuthController>().current.value?.totalPoints ?? 0;
    return points >= product.priceInPoints;
  }

  /// Returns the redemption code on success, or null if the player could not
  /// pay. Points are taken first and stock is decremented after, so a failed
  /// balance check never touches the shelf.
  Future<String?> buy(ProductModel product) async {
    final auth = Get.find<AuthController>();
    final user = auth.current.value;
    if (user == null) return null;

    final paid = await auth.spendPoints(product.priceInPoints);
    if (!paid) return null;

    final code = _code();
    final purchase = PurchaseModel(
      id: _uuid.v4(),
      userId: user.id,
      productId: product.id,
      productName: product.name,
      pointsSpent: product.priceInPoints,
      redemptionCode: code,
    );

    await HiveService.savePurchase(purchase);
    await HiveService.saveProduct(product.copyWith(stock: product.stock - 1));
    await HiveService.enqueueSync('purchase', purchase.toJson());
    Get.find<SyncService>().refreshPendingCount();

    refreshShelf();
    return code;
  }

  /// Six characters the player can read out at a counter — no look-alike
  /// glyphs, so nobody argues over an O against a zero.
  String _code() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }
}
