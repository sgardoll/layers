import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/revenuecat_service.dart';

/// Provides the singleton RevenueCatService instance
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});
