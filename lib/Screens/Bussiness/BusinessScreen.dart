import 'package:business_assistance/Screens/Products/ProductsScreen.dart';
import 'package:flutter/material.dart';
// Note: Assuming these imports are still correct for your project context
import '../../Dialogues/AddBusinessDialog.dart';
import '../../Models/BusinessModel.dart';
import 'BusinessDetails.dart';
import 'BusinessesListScreen.dart';
import 'SellScreen.dart';

class BusinessScreen extends StatefulWidget {
  final Business business;

  const BusinessScreen({super.key, required this.business});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  int selectedIndex = 0;

  final List<String> tabs = [
    "Business Detail", // Updated tab names to match the reference image
    "Products",
    "Sell Manger",
  ];

  late final List<Widget> screens = [
    BusinessDetails(business: widget.business),
    ProductsScreen(business: widget.business),
    SellScreen(),
  ];

  // Define the colors
  static const Color selectedTabColor = Colors.blue; // Light purple/blue for background
  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Colors.black87;
  static const Color containerBorderColor = Color(0xFFC0C0C0); // Light gray border for the main container

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Optional: Add horizontal padding
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Rounded corners for the main container
              border: Border.all(color: containerBorderColor), // Gray border around the main container
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (index) {
                final bool isSelected = selectedIndex == index;

                return Expanded( // Use Expanded to ensure even spacing and take up full width
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      // Only apply rounded corners to the selected tab
                      decoration: BoxDecoration(
                        color: isSelected ? selectedTabColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(9), // Slightly smaller radius than the container
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected ? selectedTextColor : unselectedTextColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 17),

        /// ------ Divider (Removed, as it's not present under the tabs in the reference) ------
        // const Divider(
        //   thickness: 1.2,
        //   color: Colors.grey,
        //   height: 0,
        // ),

        /// ------ Actual Screen Widget ------
        Expanded(
          child: screens[selectedIndex],
        ),
      ],
    );
  }
}