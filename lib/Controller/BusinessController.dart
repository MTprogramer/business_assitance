import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/BusinessModel.dart';
import '../Repo/BusinessRepository.dart';


class BusinessController extends GetxController {
  final BusinessRepository repo = BusinessRepository();

  RxBool isLoading = true.obs;
  RxList<Business> businessList = <Business>[].obs;

  void showLoading() {
    Get.snackbar(
      "Loading",
      "Please wait...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
  @override
  void onInit() {
    super.onInit();
    print("BusinessController initialized");
    loadBusinesses();
  }

  Future<void> loadBusinesses() async {

    print("BusinessController load fun called");
    showLoading();
    isLoading.value = true;

    final list = await repo.getBusinesses();
    businessList.assignAll(list);
    print("BusinessController load fun list is $list");

    isLoading.value = false;
  }

  Future<void> addBusiness(Business business) async {
    await repo.addBusiness(business);
    await loadBusinesses(); // refresh UI
  }

  Future<void> deleteBusiness(String id) async {
    await repo.deleteBusiness(id);
    await loadBusinesses();
  }

  Future<void> updateBusiness(Business business) async {
    await repo.updateBusiness(business);
    await loadBusinesses();
  }
}
