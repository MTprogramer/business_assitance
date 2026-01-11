import 'package:business_assistance/Controller/BusinessController.dart';
import 'package:business_assistance/Controller/DashboardController.dart';
import 'package:business_assistance/Repo/AiRepository.dart';
import 'package:business_assistance/UI/BottomSheets/AiAssistanceSheet.dart';
import 'package:business_assistance/UI/Screens/Bussiness/BusinessScreen.dart';
import 'package:business_assistance/UI/Screens/Dashboard/DashboardScreen.dart';
import 'package:business_assistance/UI/Screens/Products/ProductsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Controller/AIAssistantController.dart';
import '../../Controller/AuthController.dart';
import '../../Models/BusinessModel.dart';

import 'Bussiness/BusinessesListScreen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final screens = [
    DashboardScreen(),
    const BusinessesListScreen(),
    const ProductsScreen(),
  ];
  late AiController aiController;

  final navItems = const [
    {"icon": Icons.dashboard_outlined, "label": "Dashboard"},
    {"icon": Icons.business_outlined, "label": "Business"},
    {"icon": Icons.production_quantity_limits_outlined, "label": "Products"},
  ];
// Inside your _HomeScreenState class
// Inside your _HomeScreenState
  final authController = Get.find<AuthenticationController>();

  @override
  Widget build(BuildContext context) {

    //load data
    Get.find<BusinessController>().loadBusinesses();
    Get.find<DashboardController>().fetchDashboardData();
    aiController = Get.find<AiController>();
    aiController.loadChatHistory();


    return Scaffold(
      body: Row(
        children: [
          // --- CUSTOM SIDE NAV ---
          Container(
            width: 260, // Slightly wider for a premium feel
            decoration: BoxDecoration(
              color: Colors.blue.shade700, // Deeper blue for better contrast
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                )
              ],
            ),
            child: Column(
              children: [
                // 1. BEAUTIFIED APP TITLE HEADER
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_graph_rounded, color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "BUSINESS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              "ASSISTANCE",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                const SizedBox(height: 20),

                // 2. NAVIGATION ITEMS
                Expanded(
                  child: Stack(
                    children: [
                      // Selected indicator
                      // Inside the Expanded block in your sidebar
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        // REMOVE the "+ 80" because this Stack is now inside Expanded
                        // Use the exact height of your tile (usually 56 for ListTile + 8 for padding)
                        top: selectedIndex * 58.0,
                        left: 0,
                        child: Container(
                          width: 4,
                          height: 40, // Height of the indicator bar
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        itemCount: navItems.length,
                        itemBuilder: (context, index) {
                          final item = navItems[index];
                          final isSelected = index == selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              onTap: () => setState(() => selectedIndex = index),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              tileColor: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                              leading: Icon(
                                isSelected ? _getSelectedIcon(item["icon"] as IconData) : item["icon"] as IconData,
                                color: isSelected ? Colors.white : Colors.white70,
                                size: 22,
                              ),
                              title: Text(
                                item["label"].toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 3. ACCOUNT SECTION (BOTTOM)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              authController.currentUser?.name ?? "Guest User",
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              authController.currentUser?.email ?? "example@gmail.com",
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: "Account Settings",
                        offset: const Offset(0, -80), // Opens menu upwards
                        icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                        onSelected: (val) {
                          if (val == 'logout') {
                            aiController.messages.clear();
                            authController.logout();
                          }
                        },
                        itemBuilder: (context) => [
                          // const PopupMenuItem(
                          //   value: 'profile',
                          //   child: ListTile(
                          //     leading: Icon(Icons.person_outline),
                          //     title: Text("Profile"),
                          //     contentPadding: EdgeInsets.zero,
                          //   ),
                          // ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: ListTile(
                              leading: Icon(Icons.logout, color: Colors.red),
                              title: Text("Sign Out", style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN CONTENT ---
          Expanded(
            child: Container(
              color: Colors.white,
              child: screens[selectedIndex],
            ),
          ),
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
