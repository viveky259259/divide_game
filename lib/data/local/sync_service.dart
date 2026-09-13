import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/data/local/hive_service.dart';

/// Tracks connectivity and drains the offline write queue when a connection
/// comes back.
///
/// The remote push itself is deliberately a single seam — [_push]. Point it at
/// Firestore (or any backend) and the whole offline story starts working; until
/// then the queue simply accumulates locally and nothing is lost.
class SyncService extends GetxService {
  final _connectivity = Connectivity();

  final isOnline = false.obs;
  final isSyncing = false.obs;
  final pendingCount = 0.obs;
  final lastSyncedAt = Rxn<DateTime>();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Set to true once a real backend is wired into [_push]. While false the
  /// queue is held rather than discarded, so no progress is thrown away.
  static const bool remoteConfigured = false;

  @override
  void onInit() {
    super.onInit();
    refreshPendingCount();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    unawaited(_checkNow());
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkNow() async {
    try {
      _handleConnectivityChange(await _connectivity.checkConnectivity());
    } catch (_) {
      isOnline.value = false;
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final online =
        results.any((r) => r != ConnectivityResult.none);
    final cameOnline = online && !isOnline.value;
    isOnline.value = online;
    if (cameOnline) unawaited(syncNow());
  }

  void refreshPendingCount() {
    pendingCount.value = HiveService.pendingSyncCount();
  }

  /// Drains the queue oldest-first. Entries are removed only after a
  /// successful push, so a failure mid-drain leaves the rest queued.
  Future<void> syncNow() async {
    if (isSyncing.value || !isOnline.value) return;
    if (!remoteConfigured) {
      refreshPendingCount();
      return;
    }

    isSyncing.value = true;
    try {
      final queue = HiveService.syncQueue();
      final keys = queue.keys.toList()..sort();
      final done = <String>[];

      for (final key in keys) {
        final entry = queue[key]!;
        final ok = await _push(
          entry['type'] as String,
          entry['payload'] as Map<String, dynamic>,
        );
        if (!ok) break;
        done.add(key);
      }

      if (done.isNotEmpty) {
        await HiveService.removeFromSyncQueue(done);
        lastSyncedAt.value = DateTime.now();
      }
    } finally {
      refreshPendingCount();
      isSyncing.value = false;
    }
  }

  /// Sends one queued operation to the backend. Returns false to stop the
  /// drain and leave this entry (and everything after it) queued.
  Future<bool> _push(String type, Map<String, dynamic> payload) async {
    // Wire up to Firestore here, e.g.:
    //   switch (type) {
    //     case 'submit_question':
    //       await firestore.collection('questions')
    //           .doc(payload['id']).set(payload);
    //   }
    return false;
  }
}
