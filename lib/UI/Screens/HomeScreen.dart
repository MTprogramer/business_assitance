import 'package:business_assistance/UI/Screens/Bussiness/BusinessScreen.dart';
import 'package:business_assistance/UI/Screens/Dashboard/DashboardScreen.dart';
import 'package:business_assistance/UI/Screens/Products/ProductsScreen.dart';
import 'package:flutter/material.dart';

import 'Bussiness/BusinessesListScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final screens = const [
    DashboardScreen(),
    BusinessesListScreen(),
    ProductsScreen(),
  ];

  final navItems = const [
    {"icon": Icons.dashboard_outlined, "label": "Dashboard"},
    {"icon": Icons.business_outlined, "label": "Business"},
    {"icon": Icons.production_quantity_limits_outlined, "label": "Products"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // CUSTOM SIDE NAV
          Container(
            width: 220,
            color: Colors.blue,
            child: Stack(
              children: [
                // Selected indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  top: 80 + selectedIndex * 60.0, // adjust for header height
                  left: 0,
                  child: Container(
                    width: 5,
                    height: 60,
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // APP NAME HEADER
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Business Assistance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Divider(color: Colors.white54, height: 1),

                    // NAVIGATION ITEMS
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(navItems.length, (index) {
                        final item = navItems[index];
                        final isSelected = index == selectedIndex;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            height: 60,
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? _getSelectedIcon(item["icon"] as IconData)
                                      : item["icon"] as IconData,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item["label"].toString(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // MAIN CONTENT
          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }

  IconData _getSelectedIcon(IconData icon) {
    // Map outlined icons to filled icons
    if (icon == Icons.dashboard_outlined) return Icons.dashboard;
    if (icon == Icons.business_outlined) return Icons.business;
    if (icon == Icons.production_quantity_limits_outlined) {
      return Icons.production_quantity_limits;
    }
    return icon;
  }
}
