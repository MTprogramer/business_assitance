import 'package:business_assistance/Screens/Bussiness/BusinessScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../Controller/BusinessController.dart';
import '../../Dialogues/AddBusinessDialog.dart';
import '../../Dialogues/ShowDeleteDialogue.dart';
import '../../Models/BusinessModel.dart';
import '../../Models/Product.dart';

class BusinessesListScreen extends StatefulWidget {
  const BusinessesListScreen({super.key});

  @override
  State<BusinessesListScreen> createState() => _BusinessesListScreenState();
}

class _BusinessesListScreenState extends State<BusinessesListScreen> {
  final businessController = Get.find<BusinessController>();
  var showBusinessScreen = false;
  var selectedBusiness = Business(name: '', totalProducts: 0, date: DateTime.now());
  var showFlottingButton = true;

  final List<Business> businesses = [
    Business(
      name: "Tech Store",
      totalProducts: 5,
      date: DateTime.now(),
    ),
    Business(
      name: "Foodies",
      totalProducts: 3,
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white.withOpacity(0.2),
        leading: showBusinessScreen
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
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
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 0,
      ),


      floatingActionButton: showFlottingButton ? FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddBusinessDialog(),
          );
        },
        backgroundColor: Colors.blue,
        tooltip: 'Add',
        child: Icon(Icons.add, color: Colors.white),
      ) : null ,
      body: Container(
        child: showBusinessScreen
            ? BusinessScreen(business: selectedBusiness)
            : businesses.isEmpty
            ? _buildEmptyState(context)
            : _buildBusinessCard(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/no_bussines_image.jpeg",
            height: 180,
          ),
          SizedBox(height: 20),
          Text(
            "You have no business yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Add your first business to get started",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 25),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddBusinessDialog(),
              );
            },
            icon: Icon(Icons.add),
            label: Text("Add Business"),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard() {
   return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blue.shade50,
          child: Row(
            children: const [
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
                      Expanded(flex: 2, child: Text(
                          business.totalProducts.toString())),
                      Expanded(flex: 2, child: Text(
                          "${business.date.day}/${business.date
                              .month}/${business.date.year}")),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            // IconButton(
                            //   icon: const Icon(
                            //       Icons.edit, color: Colors.blue),
                            //   onPressed: () {
                            //     // TODO: handle edit
                            //   },
                            // ),
                            IconButton(
                              icon: const Icon(
                                  Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  ShowDeleteDialog(context, business:  business , isFromProduct: false,onDelete: (){}),
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

