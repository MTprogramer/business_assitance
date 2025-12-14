import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Models/BusinessModel.dart';
import '../Repo/BusinessRepository.dart';

class BusinessController extends GetxController {
  // Initialize the Repository
  final BusinessRepository repo = BusinessRepository();

  // Reactive state variables
  RxBool isLoading = true.obs;
  RxList<Business> businessList = <Business>[].obs;

  // Custom error message for display
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print("BusinessController initialized");
    // Call the data loading function when the controller is ready
    loadBusinesses();
  }

  /// Fetches all businesses from the repository (Supabase)
  void loadBusinesses() async {
    isLoading.value = true;
    errorMessage.value = ''; // Clear previous errors

    // The showLoading() method is now handled via the reactive isLoading variable on the UI
    // showLoading();

    try {
      // Fetch data from the Supabase repository
      final List<Business> fetchedBusinesses = await repo.getAllBusiness();

      // Update the reactive list
      businessList.assignAll(fetchedBusinesses);

      if (fetchedBusinesses.isEmpty) {
        print("No businesses found in Supabase.");
      } else {
        print("Successfully loaded ${fetchedBusinesses.length} businesses.");
      }

    } catch (e) {
      // Handle the error (e.g., network error, Supabase error)
      print("Error in loadBusinesses: $e");
      errorMessage.value = 'Failed to load businesses. Please check your connection.';
      // Optionally show a snackbar for immediate feedback
      Get.snackbar(
        "Error",
        "Failed to load business data: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Ensure loading state is turned off regardless of success or failure
      isLoading.value = false;
    }
  }

  // Add the function to handle adding a new business to the database and list
  void addBusiness(Business business) async {
    try {
      // 1. Add to Supabase
      final newBusiness = await repo.addBusiness(business);

      // 2. Add to reactive list and sort (optional)
      businessList.add(newBusiness);

      Get.snackbar(
        "Success",
        "${newBusiness.name} added successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding business: $e");
      Get.snackbar(
        "Error",
        "Could not add business: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add the function to handle deleting a business
  void deleteBusiness(String businessId) async {
    try {
      // 1. Delete from Supabase
      await repo.deleteBusinessById(businessId);

      // 2. Remove from reactive list using the ID
      businessList.removeWhere((b) => b.id.toString() == businessId);

      Get.snackbar(
        "Deleted",
        "Business deleted successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deleting business: $e");
      Get.snackbar(
        "Error",
        "Could not delete business: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add the function to handle deleting a business
  void updateBusiness(Business business) async {
    try {
      // 1. Delete from Supabase
      await repo.updateBusiness(business);
      Get.snackbar(
        "Deleted",
        "Business updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deleting business: $e");
      Get.snackbar(
        "Error",
        "Could not update business: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}