import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart'; // You will need to add fl_chart to your pubspec.yaml

import '../../../Controller/DashboardController.dart';
import '../../../Models/Product.dart';
import '../../../Models/Sales.dart';
import '../Bussiness/BusinessScreen.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light background for contrast
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
        child: FloatingActionButton(
          onPressed: () {
            openRightSideBottomSheet(context);
          },
          backgroundColor: Colors.white,
          tooltip: 'Add',
          child: Image.asset("assets/images/robot.png", height: 44),
        ),
      ) ,
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
                    child: _buildRevenueChart(context),
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

  Widget _buildRevenueChart(BuildContext context) {
    return Obx(() {
      final mode = controller.viewMode.value;
      final dataMap = controller.chartData;
      final chartEntries = dataMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

      // Dynamic Header Text
      String title = "${mode.name.capitalizeFirst} Revenue";
      String subtitle = "";
      DateTime date = controller.selectedDate.value;

      if (mode == ChartViewMode.yearly) {
        subtitle = "Year: ${date.year}";
      } else if (mode == ChartViewMode.monthly) {
        const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        subtitle = "${months[date.month]} ${date.year}";
      } else {
        DateTime mon = date.subtract(Duration(days: date.weekday - 1));
        DateTime sun = mon.add(const Duration(days: 6));
        subtitle = "${mon.day}/${mon.month} - ${sun.day}/${sun.month} (${date.year})";
      }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: Colors.blue.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                _buildChartControls(context),
              ],
            ),
            const Divider(height: 25),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Only scroll if Monthly (31 days)
                  bool isScrollable = mode == ChartViewMode.monthly;
                  double width = isScrollable ? 1000 : constraints.maxWidth;

                  return dataMap.values.every((v) => v == 0)
                      ? const Center(child: Text('No data for this period.'))
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: isScrollable ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: width,
                      child: _buildBarChart(chartEntries, mode),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChartControls(BuildContext context) {
    return Row(
      children: [
        ToggleButtons(
          isSelected: [
            controller.viewMode.value == ChartViewMode.weekly,
            controller.viewMode.value == ChartViewMode.monthly,
            controller.viewMode.value == ChartViewMode.yearly,
          ],
          onPressed: (index) => controller.changeViewMode(ChartViewMode.values[index]),
          constraints: const BoxConstraints(minHeight: 32, minWidth: 60),
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          children: const [Text("Week"), Text("Month"), Text("Year")],
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showYearPickerWeb(context),
          icon: const Icon(Icons.calendar_month, color: Colors.blue),
        )
      ],
    );
  }

  void _showYearPickerWeb(BuildContext context) {
    final currentYear = controller.selectedDate.value.year;
    final years = List.generate(15, (i) => 2016 + i);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            itemCount: years.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (_, index) {
              final year = years[index];
              final isSelected = year == currentYear;

              return InkWell(
                onTap: () {
                  controller.updateSelectedDate(
                    DateTime(year, controller.selectedDate.value.month),
                  );
                  Navigator.pop(context);
                      // Get.back();
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<MapEntry<int, double>> entries, ChartViewMode mode) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: controller.chartMaxY,
        barGroups: entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value,
              color: Colors.blue.shade500,
              width: mode == ChartViewMode.monthly ? 12 : 28,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            )
          ],
        )).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int i = value.toInt();
                String text = "";
                if (mode == ChartViewMode.weekly) {
                  text = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i % 7];
                } else if (mode == ChartViewMode.yearly) {
                  text = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][i];
                } else {
                  text = i.toString(); // Days 1-31
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: const TextStyle(fontSize: 10)));
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text('\$${v.toInt()}', style: const TextStyle(fontSize: 9)))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // Widget _buildChartControls() {
  //   return Row(
  //     children: [
  //       // Toggle Switch
  //       ToggleButtons(
  //         isSelected: [
  //           controller.viewMode.value == ChartViewMode.daily,
  //           controller.viewMode.value == ChartViewMode.monthly
  //         ],
  //         onPressed: (index) {
  //           controller.changeViewMode(index == 0 ? ChartViewMode.daily : ChartViewMode.monthly);
  //         },
  //         constraints: const BoxConstraints(minHeight: 30, minWidth: 60),
  //         borderRadius: BorderRadius.circular(8),
  //         selectedColor: Colors.white,
  //         fillColor: Colors.blue,
  //         children: const [Text("Daily"), Text("Monthly")],
  //       ),
  //       const SizedBox(width: 10),
  //       // Month Picker (Only shows when in Daily mode or to change year)
  //       IconButton(
  //         icon: const Icon(Icons.calendar_month, color: Colors.blue),
  //         onPressed: () async {
  //           // Simple month picker logic
  //           DateTime? picked = await showDatePicker(
  //             context: Get.context!,
  //             initialDate: controller.selectedMonthForDaily.value,
  //             firstDate: DateTime(2020),
  //             lastDate: DateTime(2030),
  //           );
  //           if (picked != null) controller.updateSelectedMonth(picked);
  //         },
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _buildRevenueChart() {
  //   return Obx(() {
  //     final isMonthly = controller.viewMode.value == ChartViewMode.monthly;
  //     final dataMap = isMonthly ? controller.monthlyData : controller.dailyData;
  //     final chartEntries = dataMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  //
  //     // Format the Month Name for the title (e.g., "January 2024")
  //     const monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  //     final currentMonthName = monthNames[controller.selectedMonthForDaily.value.month];
  //     final currentYear = controller.selectedMonthForDaily.value.year;
  //
  //     return Container(
  //       padding: const EdgeInsets.all(20),
  //       height: 400,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // --- HEADER SECTION ---
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     isMonthly ? 'Annual Revenue Trend' : 'Daily Revenue Trend',
  //                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                   ),
  //                   // SHOW MONTH NAME ON TOP WHEN DAILY IS SELECTED
  //                   if (!isMonthly)
  //                     Text(
  //                       '$currentMonthName $currentYear',
  //                       style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
  //                     ),
  //                   if (isMonthly)
  //                     Text('Year: $currentYear', style: const TextStyle(color: Colors.grey, fontSize: 12)),
  //                 ],
  //               ),
  //               _buildChartControls(),
  //             ],
  //           ),
  //           const Divider(height: 25),
  //
  //           // --- CHART SECTION ---
  //           Expanded(
  //             child: LayoutBuilder(
  //               builder: (context, constraints) {
  //                 // If Monthly: Use full width of container
  //                 // If Daily: Use 1000px to allow scrolling
  //                 final double chartWidth = isMonthly ? constraints.maxWidth : 1100;
  //
  //                 return dataMap.values.every((v) => v == 0)
  //                     ? const Center(child: Text('No data recorded for this period.'))
  //                     : SingleChildScrollView(
  //                   scrollDirection: Axis.horizontal,
  //                   // Disable scrolling if it's Monthly
  //                   physics: isMonthly ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
  //                   child: SizedBox(
  //                     width: chartWidth,
  //                     child: _buildBarChart(chartEntries, isMonthly),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }
  //
  // Widget _buildBarChart(List<MapEntry<int, double>> entries, bool isMonthly) {
  //   final maxY = _calculateMaxYFromEntries(entries);
  //
  //   return BarChart(
  //     BarChartData(
  //       maxY: maxY,
  //       alignment: BarChartAlignment.spaceAround, // Distributes bars evenly
  //       barGroups: entries.map((e) => BarChartGroupData(
  //         x: e.key,
  //         barRods: [
  //           BarChartRodData(
  //             toY: e.value,
  //             color: isMonthly ? Colors.blue.shade600 : Colors.blue.shade400,
  //             width: isMonthly ? 24 : 14, // Monthly bars are thicker
  //             borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
  //           )
  //         ],
  //       )).toList(),
  //       titlesData: FlTitlesData(
  //         leftTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             reservedSize: 45,
  //             getTitlesWidget: (val, meta) => Text('\$${val.toInt()}', style: const TextStyle(fontSize: 10)),
  //           ),
  //         ),
  //         bottomTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             getTitlesWidget: (value, meta) {
  //               if (isMonthly) {
  //                 const shortMonths = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  //                 return SideTitleWidget(
  //                   axisSide: meta.axisSide,
  //                   child: Text(shortMonths[value.toInt()], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                 );
  //               } else {
  //                 return SideTitleWidget(
  //                   axisSide: meta.axisSide,
  //                   child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
  //                 );
  //               }
  //             },
  //           ),
  //         ),
  //         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //       ),
  //       gridData: FlGridData(
  //         show: true,
  //         drawVerticalLine: false,
  //         getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
  //       ),
  //       borderData: FlBorderData(show: false),
  //     ),
  //   );
  // }

  double _calculateMaxYFromEntries(List<MapEntry<int, double>> entries) {
    if (entries.isEmpty) return 500;
    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxVal == 0 ? 500 : maxVal * 1.2;
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