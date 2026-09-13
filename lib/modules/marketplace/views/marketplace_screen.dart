import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/models/product_model.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/modules/marketplace/marketplace_controller.dart';
import 'package:mumbai_train_quiz/widgets/app_widgets.dart';

/// The platform at the end of the ride: what the points are actually for.
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = MarketplaceController.to;

    return Obx(() {
      if (c.products.isEmpty && c.myPurchases.isEmpty) {
        return const EmptyState(
          icon: Icons.storefront_outlined,
          title: 'Shutters down',
          message: 'No seller has anything on the shelf right now. '
              'Keep playing — the points keep.',
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _Balance(),
          const SizedBox(height: 18),
          if (c.categories.length > 2) ...[
            _Categories(
              categories: c.categories,
              selected: c.category.value,
              onPick: (v) => c.category.value = v,
            ),
            const SizedBox(height: 18),
          ],
          ...c.visible.map(
            (p) => _ProductCard(
              product: p,
              onBuy: () => _confirm(context, c, p),
            ),
          ),
          if (c.myPurchases.isNotEmpty) ...[
            const SizedBox(height: 26),
            const Text(
              'YOUR CODES',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...c.myPurchases.map((p) => _PurchaseRow(purchase: p)),
          ],
        ],
      );
    });
  }

  Future<void> _confirm(
    BuildContext context,
    MarketplaceController c,
    ProductModel product,
  ) async {
    final short = _shortBy(product);
    if (short > 0) {
      Get.snackbar(
        'Not yet',
        '$short more points and it is yours.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final go = await Get.dialog<bool>(
      AlertDialog(
        title: Text(product.name),
        content: Text(
          'Spend ${product.priceInPoints} points? You get a code to show at '
          '${product.sellerName}.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            child: const Text('SPEND'),
          ),
        ],
      ),
    );

    if (go != true) return;

    final code = await c.buy(product);
    if (code == null) {
      Get.snackbar(
        'That did not go through',
        'Your balance moved. Have another look.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    await Get.dialog<void>(_CodeDialog(product: product, code: code));
  }

  int _shortBy(ProductModel product) {
    final points = AuthController.to.current.value?.totalPoints ?? 0;
    return product.priceInPoints - points;
  }
}

class _Balance extends StatelessWidget {
  const _Balance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.marketplace.withOpacity(0.30),
            AppColors.cardBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.marketplace.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_mall_outlined,
              color: AppColors.marketplace, size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POINTS TO SPEND',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      '${AuthController.to.current.value?.totalPoints ?? 0}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onPick;

  const _Categories({
    required this.categories,
    required this.selected,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final name = categories[i];
          final on = name == selected;
          return GestureDetector(
            onTap: () => onPick(name),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: on
                    ? AppColors.marketplace.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: on ? AppColors.marketplace : AppColors.trackGrey,
                ),
              ),
              child: Text(
                name,
                style: TextStyle(
                  color:
                      on ? AppColors.marketplace : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onBuy;

  const _ProductCard({required this.product, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.trackGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${product.priceInPoints} pts',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  product.sellerName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              if (product.redeemValueInRupees > 0)
                Text(
                  'worth ₹${product.redeemValueInRupees.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.marketplace,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                product.stock <= 5
                    ? 'only ${product.stock} left'
                    : '${product.stock} available',
                style: TextStyle(
                  color: product.stock <= 5
                      ? AppColors.wrong
                      : AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
              const Spacer(),
              // Watches the balance on its own so the button flips the moment
              // a round pays out.
              Obx(() {
                final points =
                    AuthController.to.current.value?.totalPoints ?? 0;
                final affordable = points >= product.priceInPoints;
                return ElevatedButton(
                  onPressed: onBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: affordable
                        ? AppColors.marketplace
                        : AppColors.surface,
                    foregroundColor: affordable
                        ? Colors.white
                        : AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    affordable
                        ? 'REDEEM'
                        : '${product.priceInPoints - points} SHORT',
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

/// The moment of payoff — big, readable, and copyable.
class _CodeDialog extends StatelessWidget {
  final ProductModel product;
  final String code;

  const _CodeDialog({required this.product, required this.code});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            product.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.marketplace),
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.marketplace,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Show this at ${product.sellerName}. It is saved under your '
            'codes, so you can close this.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
          child: const Text('COPY'),
        ),
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('DONE'),
        ),
      ],
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  final PurchaseModel purchase;

  const _PurchaseRow({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.marketplace.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.productName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${purchase.pointsSpent} points',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            purchase.redemptionCode,
            style: const TextStyle(
              color: AppColors.marketplace,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
