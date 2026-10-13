import 'package:get/get.dart';

import 'package:mumbai_train_quiz/modules/admin/admin_controller.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/modules/contribute/contribute_controller.dart';
import 'package:mumbai_train_quiz/modules/marketplace/marketplace_controller.dart';

enum HomeTab { map, contribute, review, market, profile }

/// Owns which tab is showing. The tabs a person sees depend on their role —
/// players get the map, the market and a profile; contributors add the
/// question form; admins add the review desk.
class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final index = 0.obs;

  List<HomeTab> get tabs {
    final auth = AuthController.to;
    return [
      HomeTab.map,
      if (auth.isContributor) HomeTab.contribute,
      if (auth.isAdmin) HomeTab.review,
      HomeTab.market,
      HomeTab.profile,
    ];
  }

  HomeTab get current {
    final list = tabs;
    return list[index.value.clamp(0, list.length - 1)];
  }

  void select(int i) => index.value = i;

  /// Tabs re-read their data when opened, since a round, a purchase or an
  /// approval may have changed it since they were last shown.
  void onTabShown(HomeTab tab) {
    switch (tab) {
      case HomeTab.contribute:
        Get.find<ContributeController>().refreshSubmissions();
      case HomeTab.review:
        Get.find<AdminController>().refreshQueue();
      case HomeTab.market:
        Get.find<MarketplaceController>().refreshShelf();
      case HomeTab.map:
      case HomeTab.profile:
        break;
    }
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(ContributeController());
    Get.put(AdminController());
    Get.put(MarketplaceController());
  }
}
