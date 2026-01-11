import 'package:business_assistance/Controller/AuthController.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../Models/Product.dart';
import '../Models/Sales.dart';
import '../Repo/BusinessRepository.dart';
import '../Repo/ProductRepo.dart';
import '../Repo/SalesRepo.dart';
enum ChartViewMode { weekly, monthly, yearly }
class DashboardController extends GetxController {

  final authController = Get.find<AuthenticationController>();
  final BusinessRepository _businessRepo = BusinessRepository();
  final ProductRepo _productRepo = ProductRepo();
  final SalesRepo _salesRepo = SalesRepo();

  var viewMode = ChartViewMode.monthly.obs;
  var selectedDate = DateTime.now().obs;

  RxMap<int, double> chartData = <int, double>{}.obs;

  // --- New State Variables ---
  // var viewMode = ChartViewMode.monthly.obs;
  var selectedMonthForDaily = DateTime.now().obs; // The month user wants to see daily data for

  // Metrics
  RxMap<int, double> monthlyData = <int, double>{}.obs; // Key: 1-12 (Month)
  RxMap<int, double> dailyData = <int, double>{}.obs;   // Key: 1-31 (Day)

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
    // fetchDashboardData();
  }


  // Helper to normalize a date to the start of the day (00:00:00)
  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  // Helper to get the Monday of any given date
  DateTime _getMonday(DateTime date) {
    DateTime d = _normalize(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  bool _weekHasData(DateTime monday) {
    DateTime sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));
    return allSales.any((s) => s.soldAt.isAfter(monday.subtract(const Duration(seconds: 1))) &&
        s.soldAt.isBefore(sunday.add(const Duration(seconds: 1))));
  }

  void nextPeriod() {
    if (viewMode.value == ChartViewMode.monthly) {
      // Find next month in the same year with data
      for (int m = selectedDate.value.month + 1; m <= 12; m++) {
        if (_monthHasData(selectedDate.value.year, m)) {
          updateSelectedDate(DateTime(selectedDate.value.year, m, 1));
          return;
        }
      }
    } else if (viewMode.value == ChartViewMode.weekly) {
      int currentMonth = selectedDate.value.month;
      DateTime checkMonday = selectedDate.value.add(const Duration(days: 7));

      // Keep looking for a Monday that has data, as long as it's in the same month
      while (checkMonday.month == currentMonth) {
        if (_weekHasData(checkMonday)) {
          updateSelectedDate(checkMonday);
          return;
        }
        checkMonday = checkMonday.add(const Duration(days: 7));
      }
    }
  }

  void previousPeriod() {
    if (viewMode.value == ChartViewMode.monthly) {
      for (int m = selectedDate.value.month - 1; m >= 1; m--) {
        if (_monthHasData(selectedDate.value.year, m)) {
          updateSelectedDate(DateTime(selectedDate.value.year, m, 1));
          return;
        }
      }
    } else if (viewMode.value == ChartViewMode.weekly) {
      int currentMonth = selectedDate.value.month;
      DateTime checkMonday = selectedDate.value.subtract(const Duration(days: 7));

      while (checkMonday.month == currentMonth) {
        if (_weekHasData(checkMonday)) {
          updateSelectedDate(checkMonday);
          return;
        }
        checkMonday = checkMonday.subtract(const Duration(days: 7));
      }
    }
  }

  void changeViewMode(ChartViewMode mode) {
    viewMode.value = mode;

    if (allSales.isEmpty) {
      updateChartData();
      return;
    }

    // Use the month and year the user is ALREADY looking at
    DateTime currentView = selectedDate.value;

    if (mode == ChartViewMode.weekly) {
      // When switching to weekly, find the latest week WITH DATA
      // inside the currently viewed month.
      DateTime lastDayOfMonth = DateTime(currentView.year, currentView.month + 1, 0);
      DateTime checkMonday = _getMonday(lastDayOfMonth);

      bool foundWeek = false;
      while (checkMonday.month == currentView.month) {
        if (_weekHasData(checkMonday)) {
          selectedDate.value = checkMonday;
          foundWeek = true;
          break;
        }
        checkMonday = checkMonday.subtract(const Duration(days: 7));
      }

      // If no sales found in this specific month, just show the first week of that month
      if (!foundWeek) {
        selectedDate.value = _getMonday(DateTime(currentView.year, currentView.month, 1));
      }
    }
    else if (mode == ChartViewMode.monthly) {
      // Keep the year, but ensure the date is set to the 1st of the month
      selectedDate.value = DateTime(currentView.year, currentView.month, 1);
    }

    updateChartData();
  }

  // Check if a specific month in a year has sales
  bool _monthHasData(int year, int month) {
    return allSales.any((s) => s.soldAt.year == year && s.soldAt.month == month);
  }


  // Check if buttons should be enabled
  bool get canGoNext {
    if (viewMode.value == ChartViewMode.yearly) return false;
    if (viewMode.value == ChartViewMode.monthly) {
      for (int m = selectedDate.value.month + 1; m <= 12; m++) {
        if (_monthHasData(selectedDate.value.year, m)) return true;
      }
    } else {
      DateTime current = selectedDate.value.add(const Duration(days: 7));
      while (current.month == selectedDate.value.month) {
        if (_weekHasData(current)) return true;
        current = current.add(const Duration(days: 7));
      }
    }
    return false;
  }

  bool get canGoPrevious {
    if (viewMode.value == ChartViewMode.yearly) return false;
    if (viewMode.value == ChartViewMode.monthly) {
      for (int m = selectedDate.value.month - 1; m >= 1; m--) {
        if (_monthHasData(selectedDate.value.year, m)) return true;
      }
    } else {
      DateTime current = selectedDate.value.subtract(const Duration(days: 7));
      while (current.month == selectedDate.value.month) {
        if (_weekHasData(current)) return true;
        current = current.subtract(const Duration(days: 7));
      }
    }
    return false;
  }

  void _setLatestYearAsDefault() {
    if (allSales.isEmpty) {
      selectedDate.value = DateTime.now();
      return;
    }

    final latestSale = allSales.reduce(
          (a, b) => a.soldAt.isAfter(b.soldAt) ? a : b,
    );

    selectedDate.value = DateTime(latestSale.soldAt.year, latestSale.soldAt.month);
  }


  // Removed businessId parameter
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Fetch Raw Data (Using ALL methods)
      final fetchedProducts = await _productRepo.getAllProducts(authController.currentUser!.id); // <-- Changed
      final fetchedSales = await _salesRepo.getAllSales(authController.currentUser!.id);         // <-- Changed
      final fetchedBusinesses = await _businessRepo.getAllBusiness(authController.currentUser!.id);

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
    _prepareMonthlyData();
    _prepareDailyData();
    _setLatestYearAsDefault();
    updateChartData();
  }


  // Aggregates data for the 12 months of the CURRENT year
  void _prepareMonthlyData() {
    monthlyData.clear();
    // Initialize all 12 months with 0.0
    for (int i = 1; i <= 12; i++) monthlyData[i] = 0.0;

    for (var s in allSales) {
      if (s.soldAt.year == selectedMonthForDaily.value.year) {
        monthlyData[s.soldAt.month] = (monthlyData[s.soldAt.month] ?? 0) + s.totalPrice;
      }
    }
  }

  // Aggregates data for each day of the SELECTED month
  void _prepareDailyData() {
    dailyData.clear();
    int daysInMonth = DateTime(selectedMonthForDaily.value.year, selectedMonthForDaily.value.month + 1, 0).day;

    // Initialize all days with 0.0
    for (int i = 1; i <= daysInMonth; i++) dailyData[i] = 0.0;

    for (var s in allSales) {
      if (s.soldAt.month == selectedMonthForDaily.value.month &&
          s.soldAt.year == selectedMonthForDaily.value.year) {
        dailyData[s.soldAt.day] = (dailyData[s.soldAt.day] ?? 0) + s.totalPrice;
      }
    }
  }

  // void changeViewMode(ChartViewMode mode) {
  //   viewMode.value = mode;
  // }

  void updateSelectedMonth(DateTime date) {
    selectedMonthForDaily.value = date;
    _prepareDailyData(); // Recalculate daily bars when month changes
    _prepareMonthlyData(); // Recalculate monthly bars if year changed
  }

  // Call this after fetching data or changing date/mode
  void updateChartData() {
    chartData.clear();
    DateTime date = selectedDate.value;

    if (viewMode.value == ChartViewMode.yearly) {
      // Buckets 1-12 (Months)
      for (int i = 1; i <= 12; i++) chartData[i] = 0.0;
      for (var s in allSales) {
        if (s.soldAt.year == date.year) {
          chartData[s.soldAt.month] = (chartData[s.soldAt.month] ?? 0) + s.totalPrice;
        }
      }
    }
    else if (viewMode.value == ChartViewMode.monthly) {
      // Buckets 1-31 (Days)
      int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) chartData[i] = 0.0;
      for (var s in allSales) {
        if (s.soldAt.month == date.month && s.soldAt.year == date.year) {
          chartData[s.soldAt.day] = (chartData[s.soldAt.day] ?? 0) + s.totalPrice;
        }
      }
    }
    // else if (viewMode.value == ChartViewMode.weekly) {
    //   // Determine the week to display: either latest week with sales or user-selected week
    //   if (allSales.isEmpty) return;
    //
    //   // Pick latest sale date if current week has no sales
    //   DateTime latestSaleDate = allSales
    //       .reduce((a, b) => a.soldAt.isAfter(b.soldAt) ? a : b)
    //       .soldAt;
    //
    //   // Start of the week (Monday)
    //   DateTime monday = DateTime(
    //     latestSaleDate.year,
    //     latestSaleDate.month,
    //     latestSaleDate.day - (latestSaleDate.weekday - 1),
    //   );
    //   // Initialize 7 days
    //   for (int i = 0; i < 7; i++) chartData[i] = 0.0;
    //
    //   for (var s in allSales) {
    //     final saleDate = DateTime(s.soldAt.year, s.soldAt.month, s.soldAt.day);
    //     int diff = saleDate.difference(monday).inDays;
    //     if (diff >= 0 && diff < 7) {
    //       chartData[diff] = (chartData[diff] ?? 0) + s.totalPrice;
    //     }
    //   }
    //
    //   // Update selectedDate to the Monday of that week
    //   selectedDate.value = monday;
    // }

    else if (viewMode.value == ChartViewMode.weekly) {
      // Buckets 0-6 (Mon-Sun)
      // Find the Monday of the week containing selectedDate
      DateTime monday = date.subtract(Duration(days: date.weekday - 1));
      monday = DateTime(monday.year, monday.month, monday.day); // Strip time

      for (int i = 0; i < 7; i++) chartData[i] = 0.0;

      for (var s in allSales) {
        DateTime saleDate = DateTime(s.soldAt.year, s.soldAt.month, s.soldAt.day);
        int difference = saleDate.difference(monday).inDays;
        if (difference >= 0 && difference < 7) {
          chartData[difference] = (chartData[difference] ?? 0) + s.totalPrice;
        }
      }
    }
  }


  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
    updateChartData();
  }

  // Helper for Max Y calculation
  double get chartMaxY {
    if (chartData.isEmpty) return 500;
    double max = chartData.values.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 500 : max * 1.15;
  }

}