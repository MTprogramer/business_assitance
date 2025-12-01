import 'package:business_assistance/UI/Dialogues/AddBusinessDialog.dart';
import 'package:business_assistance/UI/Dialogues/ShowDeleteDialogue.dart';
import 'package:business_assistance/Models/Product.dart';
import 'package:business_assistance/UI/Screens/Bussiness/BusinessScreen.dart';
import 'package:business_assistance/UI/Widgets/CustomButton.dart';
import 'package:business_assistance/UI/Widgets/ProductsList.dart';
import 'package:flutter/material.dart';

import '../../Dialogues/ProductAddDialogue.dart';
import '../../../Models/BusinessModel.dart';

class ProductsScreen extends StatefulWidget {
  final Business? business;

  const ProductsScreen({super.key, this.business});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Your existing products list
  var searchQuery = "";
  List<Product> products = [
    Product(
      id: "1",
      name: "Laptop",
      businessName: "Tech World", // <-- Used this
      price: 85000,
      imageUrl: "https://images.unsplash.com/photo-1541807084534-54c7d6124719?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      quantity: 1,
    ),
    Product(
      id: "2",
      name: "Smartphone",
      businessName: "Mobile Hub", // <-- Used this
      price: 45000,
      imageUrl: "https://images.unsplash.com/photo-1593305841334-a15d0793796c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      quantity: 3,
    ),
    Product(
      id: "3",
      name: "Headphones",
      businessName: "Sound Store", // <-- Used this
      price: 3500,
      imageUrl: "https://images.unsplash.com/photo-1620352586617-6f68c78c2578?q=80&w=2787&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      quantity: 2,
    ),
    Product(
      id: "4",
      name: "Shoes",
      businessName: "Fashion Feet", // <-- Used this
      price: 2500,
      imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      quantity: 5,
    ),
    Product(
      id: "5",
      name: "Watch",
      businessName: "Time Zone", // <-- Used this
      price: 6000,
      imageUrl: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=2799&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      quantity: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products
        .where(
          (p) =>
              p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.businessName.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: widget.business != null && products.isNotEmpty
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,
              toolbarHeight: 70,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomButton(
                    text: "Add Product",
                    startIcon: Icons.add,
                    onPressed: () {
                      _addNewProduct(context);
                    },
                    height: 42,
                    cornerRadius: 12,
                  ),
                ),
              ],
            )
          : null,
      body: products.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    BuildProductDataTable(
                      filteredProducts,
                      context,
                      (product) {
                        ShowDeleteDialog(
                          context,
                          product: product,
                          isFromProduct: true,
                          onDelete: () {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removing ${product.name}'),
                                ),
                              );
                              products.remove(product);
                            });
                          },
                        );
                      },
                      (product) {
                        // _editProduct(context, product);
                        _editProduct(context, product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Editing ${product.name}')),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  // Example call for adding a product (e.g., from a FloatingActionButton)
  void _addNewProduct(BuildContext context) {
    ShowProductFormDialog(
      context,
      onSave: (productData) {
        // 1. Create a new Product object (assign a new ID)
        final newProduct = Product(
          id: UniqueKey().toString(),
          name: productData['name'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          businessName: widget.business?.name??"",
          quantity:productData['quantity'],
        );

        // 2. Update your screen state
        setState(() {
          products.add(newProduct);
        });
      },
    );
  }

  void _editProduct(BuildContext context, Product productToEdit) {
    ShowProductFormDialog(
      context,
      existingProduct: productToEdit,
      onSave: (updatedData) {
        // 1. Find the index of the product to replace
        final index = products.indexWhere((p) => p.id == productToEdit.id);

        if (index != -1) {
          // 2. Create the updated Product object
          final updatedProduct = Product(
            id: updatedData['id'],
            name: updatedData['name'],
            price: updatedData['price'],
            imageUrl: updatedData['imageUrl'],
            businessName: updatedData['businessName'],
            quantity: updatedData['quantity'], // Keep existing quantity
          );

          setState(() {
            products[index] = updatedProduct;
          });
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/no_bussines_image.jpeg", height: 180),
          SizedBox(height: 20),
          Text(
            "You have no product yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Add your first product to get started",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 25),

          widget.business != null
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _addNewProduct(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add Business"),
                )
              : Container(),
        ],
      ),
    );
  }
}
