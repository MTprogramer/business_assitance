import 'package:business_assistance/UI/Screens/Bussiness/BusinessScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/BusinessController.dart';
import '../../../Models/BusinessModel.dart';
import '../../Dialogues/AddBusinessDialog.dart';
import '../../Dialogues/ShowDeleteDialogue.dart'; // Import Getx
// ... other imports

class BusinessesListScreen extends StatefulWidget {
  const BusinessesListScreen({super.key});

  @override
  State<BusinessesListScreen> createState() => _BusinessesListScreenState();
}

class _BusinessesListScreenState extends State<BusinessesListScreen> {
  // Use Get.find to get the registered controller instance
  final businessController = Get.find<BusinessController>();

  var showBusinessScreen = false;
  var selectedBusiness = Business(name: '', totalProducts: 0, date: DateTime.now());
  var showFlottingButton = true;

  // Remove the hardcoded List<Business> businesses!
  // The businessController.businessList will be used instead.

  @override
  Widget build(BuildContext context) {
    // Wrap the main body with Obx to react to controller changes
    return Obx(() {
      // Get the current list and loading state from the controller
      final businesses = businessController.businessList;
      final isLoading = businessController.isLoading.value;

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.white.withOpacity(0.2),
          leading: showBusinessScreen
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              setState(() {
                showBusinessScreen = false;
                showFlottingButton = true;
              });
            },
          )
              : null,
          title: Text(
            showBusinessScreen ? 'Business List -> ${selectedBusiness.name}' : 'Business List',
            style: const TextStyle(color: Colors.black87),
          ),
          elevation: 0,
        ),
        floatingActionButton: showFlottingButton ? Padding(
          padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddBusinessDialog(onSave: (business){
                  // Call the controller function to add the business
                  businessController.addBusiness(business);
                },),
              );
            },
            backgroundColor: Colors.blue,
            tooltip: 'Add',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ) : null ,
        body: Container(
          child: showBusinessScreen
              ? BusinessScreen(business: selectedBusiness)
              : isLoading
              ? _buildLoadingState() // Show loading spinner
              : businesses.isEmpty
              ? _buildEmptyState(context)
              : _buildBusinessCard(businesses), // Pass the reactive list
        ),
      );
    }); // End of Obx
  }

  // New Widget to show the loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Fetching businesses...", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // ... (Empty state widget remains largely the same)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/no_bussines_image.jpeg",
            height: 180,
          ),
          const SizedBox(height: 20),
          const Text(
            "You have no business yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Add your first business to get started",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddBusinessDialog(onSave: (business){
                  // Call the controller function to add the business
                  businessController.addBusiness(business);
                },),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Business"),
          ),
        ],
      ),
    );
  }

  // Updated to accept the business list
  Widget _buildBusinessCard(List<Business> businesses) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blue.shade50,
          child: const Row(
            children: [
              Expanded(flex: 3,
                  child: Text(
                      "Name", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2,
                  child: Text("Total Products",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2,
                  child: Text(
                      "Date", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3,
                  child: Text("Actions",
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return InkWell(
                onTap: () => {
                  setState(() {
                    showBusinessScreen = true;
                    showFlottingButton = false;
                    selectedBusiness = business;
                  })
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey
                        .shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(business.name)),
                      // Ensure totalProducts is not null before toString
                      Expanded(flex: 2, child: Text(
                          (business.totalProducts ?? 0).toString())),
                      Expanded(flex: 2, child: Text(
                          "${business.date.day}/${business.date
                              .month}/${business.date.year}")),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  ShowDeleteDialog(context, business:  business , isFromProduct: false,onDelete: () {
                                    // Call the controller delete function
                                    if (business.id != null) {
                                      businessController.deleteBusiness(business.id.toString());
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}