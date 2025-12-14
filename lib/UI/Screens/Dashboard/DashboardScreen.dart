import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart'; // You will need to add fl_chart to your pubspec.yaml

import '../../../Controller/DashboardController.dart';
import '../../../Models/Product.dart';
import '../../../Models/Sales.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light background for contrast
      appBar: AppBar(
        title: const Text('Business Dashboard', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text('Error: ${controller.errorMessage.value}', style: const TextStyle(color: Colors.red, fontSize: 18)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- I. Overview Cards (Big Numbers) ---
              _buildOverviewCards(context),
              const SizedBox(height: 30),

              // --- II. Inventory and Sales Analysis ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Low Stock Alert (Takes 40% width)
                  Expanded(
                    flex: 4,
                    child: _buildLowStockAlert(),
                  ),
                  const SizedBox(width: 20),
                  // Monthly Revenue Chart (Takes 60% width)
                  Expanded(
                    flex: 6,
                    child: _buildRevenueChart(),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- IV. Latest Sales History ---
              _buildLatestSalesHistory(),
            ],
          ),
        );
      }),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildOverviewCards(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GridView.count(
      crossAxisCount: width > 1200 ? 4 : width > 800 ? 2 : 1,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        InfoCard(
          title: "Total Revenue",
          value: controller.totalRevenue.value,
          icon: Icons.paid_rounded,
          color: Colors.green.shade600,
          suffix: '\$',
        ),
        InfoCard(
          title: "Total Inventory Items",
          value: controller.totalInventoryCount.value,
          icon: Icons.inventory_2_rounded,
          color: Colors.blue.shade600,
        ),
        InfoCard(
          title: "Total Products Available",
          value: controller.allProducts.length,
          icon: Icons.category_rounded,
          color: Colors.purple.shade600,
        ),
        InfoCard(
          title: "Total Businesses Managed",
          value: controller.totalBusinesses.value,
          icon: Icons.business_center_rounded,
          color: Colors.orange.shade600,
        ),
      ],
    );
  }


  Widget _buildLowStockAlert() {
    final lowStockCount = controller.lowStockItems.length;
    final isLow = lowStockCount > 0;

    // --- ANIMATION: Animated Container for Alert Background ---
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isLow ? Colors.red.shade300 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: isLow ? Colors.red.shade100 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      height: 400, // Fixed height for alignment with chart
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isLow ? Colors.red : Colors.green,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                isLow ? '🚨 LOW STOCK ALERT ($lowStockCount)' : 'Inventory Status: OK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLow ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const Divider(height: 25),

          if (isLow)
            Expanded(
              child: ListView.builder(
                itemCount: controller.lowStockItems.length,
                itemBuilder: (context, index) {
                  final product = controller.lowStockItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Qty: ${product.quantity}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'All key products are above the low stock threshold.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper function to calculate MaxY dynamically and robustly
//   double _calculateMaxY(List<MapEntry<String, double>> monthlyData) {
//     if (monthlyData.isEmpty) return 500; // Default max if no data
//
//     final maxMonthlyRevenue = monthlyData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
//
//     if (maxMonthlyRevenue == 0) return 500;
//
//     // Find the nearest intelligent rounding factor (100, 1000, 10000, etc.)
//     double roundingFactor = 100;
//     if (maxMonthlyRevenue > 10000) {
//       roundingFactor = 1000;
//     } else if (maxMonthlyRevenue > 50000) {
//       roundingFactor = 10000;
//     }
//
//     // Round up the max value to the nearest factor (e.g., 1020 -> 1100, 4500 -> 5000)
//     final roundedMax = (maxMonthlyRevenue / roundingFactor).ceil() * roundingFactor;
//
//     // Add a small buffer (e.g., 10%) for padding at the top
//     return roundedMax + (roundedMax * 0.1);
//   }
//
// // Helper function to calculate the necessary width for the chart body
//   double _calculateChartWidth(int dataPoints, double barWidth, double spaceAround) {
//     // Formula: (Number of bars * Bar width) + (Number of spaces * Space size) + Padding
//     // We use 30 as a minimum width per bar group.
//     const double widthPerGroup = 35.0;
//     final minWidth = dataPoints * widthPerGroup;
//
//     // Ensure the chart is at least the width of its container, but can grow horizontally.
//     return minWidth > 600 ? minWidth : 600; // Use 600 as a standard minimum width for a chart in a wide column
//   }

  // Add these functions inside the DashboardScreen class

// Helper function to build BarChartGroupData
  List<BarChartGroupData> _buildBarGroups(List<MapEntry<String, double>> monthlyData) {
    return List.generate(monthlyData.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: monthlyData[i].value,
            color: Colors.blue.shade400,
            width: 16,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

// Helper function to calculate MaxY dynamically (Ensure this is also present)
  double _calculateMaxY(List<MapEntry<String, double>> monthlyData) {
    if (monthlyData.isEmpty) return 500;

    final maxMonthlyRevenue = monthlyData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (maxMonthlyRevenue == 0) return 500;

    double roundingFactor = 100;
    if (maxMonthlyRevenue > 10000) {
      roundingFactor = 1000;
    } else if (maxMonthlyRevenue > 50000) {
      roundingFactor = 10000;
    }

    final roundedMax = (maxMonthlyRevenue / roundingFactor).ceil() * roundingFactor;
    return roundedMax + (roundedMax * 0.1);
  }

// Helper function to calculate chart width (Ensure this is also present)
  double _calculateChartWidth(int dataPoints, double barWidth, double spaceAround) {
    const double widthPerGroup = 35.0;
    final minWidth = dataPoints * widthPerGroup;
    return minWidth > 600 ? minWidth : 600;
  }

  Widget _buildRevenueChart() {
    final monthlyData = controller.monthlySalesData.entries.toList();
    final barGroups = _buildBarGroups(monthlyData); // Use the helper function
    final maxY = _calculateMaxY(monthlyData);
    final chartWidth = _calculateChartWidth(monthlyData.length, 16, 20);

    return Container(
      padding: const EdgeInsets.all(20),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Revenue Trend',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Divider(height: 20),
          Expanded(
            child: monthlyData.isEmpty
                ? const Center(
              child: Text(
                'No sales data recorded yet to build the trend chart.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: chartWidth, // Controls the scrollable area
                child: BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45, // Increased size to accommodate rotation
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                              final monthYear = monthlyData[value.toInt()].key;
                              final parts = monthYear.split('/');

                              // Map month number to short name (1 -> Jan)
                              final monthNum = int.tryParse(parts[0]) ?? 1;
                              const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              final month = monthNames[monthNum];
                              final year = parts[1].substring(2); // Get last two digits of year ('24)

                              // Return rotated labels
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8.0,
                                child: RotatedBox(
                                  quarterTurns: 0, // 1 is and -1 for opposite date position
                                  child: Text(
                                    '$month \'${year}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                      // Y-axis titles (Left Titles) are fine as they are not rotated
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '\$${rod.toY.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeOut,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// NOTE: You must also ensure the SideTitleWidget is imported from 'package:fl_chart/fl_chart.dart';
// If your existing code structure does not import SideTitleWidget, the rotation might fail.

  Widget _buildLatestSalesHistory() {
    final latestSales = controller.allSales.take(5).toList(); // Take the last 5 sales

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Sales Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Divider(height: 20),

          if (latestSales.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('No recent sales activity to display.')),
            )
          else
          // --- ANIMATION: List Fade-in/Slide-in ---
            ...latestSales.asMap().entries.map((entry) {
              int index = entry.key;
              Sale sale = entry.value;
              Product? product = controller.allProducts.firstWhereOrNull((p) => p.id == sale.productId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                // Use AnimatedOpacity and SlideTransition for the list items
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + index * 50),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(Icons.receipt_long, color: Colors.blue.shade600),
                    ),
                    title: Text('${sale.quantity} units of ${product?.name ?? 'Unknown Product'}'),
                    subtitle: Text('Sold on: ${sale.soldAt.day}/${sale.soldAt.month}/${sale.soldAt.year}'),
                    trailing: Text(
                      '+\$${sale.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}


class InfoCard extends StatelessWidget {
  final String title;
  final num value;
  final IconData icon;
  final Color color;
  final String suffix;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 30),
            ],
          ),
          const SizedBox(height: 15),
          // --- ANIMATION: Animated Counter ---
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1000),
            builder: (context, val, child) {
              String formattedValue;
              if (value is int) {
                formattedValue = val.toInt().toString();
              } else {
                formattedValue = '${val.toStringAsFixed(2)}';
              }

              return Text(
                '$suffix$formattedValue',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}