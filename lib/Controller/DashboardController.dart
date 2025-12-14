import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../Models/Product.dart';
import '../Models/Sales.dart';
import '../Repo/BusinessRepository.dart';
import '../Repo/ProductRepo.dart';
import '../Repo/SalesRepo.dart';

class DashboardController extends GetxController {
  final BusinessRepository _businessRepo = BusinessRepository();
  final ProductRepo _productRepo = ProductRepo();
  final SalesRepo _salesRepo = SalesRepo();

  // --- Reactive Data State ---
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;

  // Raw Data (Now aggregates across all businesses)
  RxList<Product> allProducts = <Product>[].obs;
  RxList<Sale> allSales = <Sale>[].obs;
  RxInt totalBusinesses = 0.obs;

  // Derived Metrics
  RxDouble totalRevenue = 0.0.obs;
  RxInt totalInventoryCount = 0.obs;
  RxList<Product> lowStockItems = <Product>[].obs;
  RxMap<String, double> monthlySalesData = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch data for the entire system
    fetchDashboardData();
  }

  // Removed businessId parameter
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Fetch Raw Data (Using ALL methods)
      final fetchedProducts = await _productRepo.getAllProducts(); // <-- Changed
      final fetchedSales = await _salesRepo.getAllSales();         // <-- Changed
      final fetchedBusinesses = await _businessRepo.getAllBusiness();

      allProducts.assignAll(fetchedProducts);
      allSales.assignAll(fetchedSales);
      totalBusinesses.value = fetchedBusinesses.length;

      // 2. Aggregate and Calculate Metrics
      _calculateMetrics();

    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data across all businesses: $e';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateMetrics() {
    // --- Total Inventory Count & Low Stock Alert (Set LOW_STOCK_THRESHOLD = 5) ---
    const int LOW_STOCK_THRESHOLD = 5;
    totalInventoryCount.value = 0;
    lowStockItems.clear();

    // Aggregates ALL products
    for (var p in allProducts) {
      totalInventoryCount.value += p.quantity;
      if (p.quantity <= LOW_STOCK_THRESHOLD) {
        lowStockItems.add(p);
      }
    }

    // --- Total Revenue & Monthly Sales ---
    totalRevenue.value = 0.0;
    monthlySalesData.clear();

    // Aggregates ALL sales
    for (var s in allSales) {
      totalRevenue.value += s.totalPrice;

      // Aggregate by Month-Year string (e.g., "Jan 2024")
      final monthKey = '${s.soldAt.month}/${s.soldAt.year}';
      monthlySalesData.update(
        monthKey,
            (value) => value + s.totalPrice,
        ifAbsent: () => s.totalPrice,
      );
    }

    // Convert to a Map where keys are sorted month strings for chart display
    final sortedKeys = monthlySalesData.keys.toList()
      ..sort((a, b) {
        // Simple numeric sorting by month/year
        final monthA = int.parse(a.split('/')[0]);
        final yearA = int.parse(a.split('/')[1]);
        final monthB = int.parse(b.split('/')[0]);
        final yearB = int.parse(b.split('/')[1]);

        if (yearA != yearB) return yearA.compareTo(yearB);
        return monthA.compareTo(monthB);
      });

    final sortedMonthlyData = {
      for (var k in sortedKeys)
        k: monthlySalesData[k]!
    }.obs;

    monthlySalesData.assignAll(sortedMonthlyData);
  }
}