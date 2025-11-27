import 'package:flutter/material.dart';
import '../../Dialogues/AddBusinessDialog.dart';
import 'AddBusinessScreen.dart';
import 'BusinessesListScreen.dart';
import 'SellScreen.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  int selectedIndex = 0;

  final List<String> tabs = [
    "AddBusiness",
    "Business",
    "Sells Manager",
  ];

  final List<Widget> screens = [
    AddBusinessScreen(),
    BusinessesListScreen(),
    SellScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        /// ------ Top Navigation Buttons ------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(tabs.length, (index) {
            final bool isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 17),

        /// ------ Divider ------
        const Divider(
          thickness: 1.2,
          color: Colors.grey,
          height: 0,
        ),

        /// ------ Actual Screen Widget ------
        Expanded(
          child: screens[selectedIndex],
        ),
      ],
    );
  }
}


