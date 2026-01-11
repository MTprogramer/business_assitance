import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Models/UserModel.dart';
import '../Repo/AuthRepo.dart';
import 'AIAssistantController.dart';

class AuthenticationController extends GetxController {
  final AuthenticationRepo _repo = AuthenticationRepo();


  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  UserModel? currentUser;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user_details');

    if (storedUser != null && _repo.currentSession != null) {
      currentUser = UserModel.fromJson(jsonDecode(storedUser));
      isLoggedIn.value = true;
    }
  }

  Future<void> handleSignIn(
      String email,
      String password,
      ) async {
    isLoading.value = true;

    try {
      final response = await _repo.signIn(email, password);

      if (response.user == null) {
        _showError("Login Failed", "Invalid email or password");
        return;
      }

      final name =
          response.user!.userMetadata?['full_name']?.toString() ?? "User";

      await _saveUser(response.user!, name);

      isLoggedIn.value = true;
      // Get.offAllNamed('/home');
    } on AuthApiException catch (e) {
      _showError("Login Failed", e.message);
    } catch (e) {
      // _showError("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSignUp(
      String email,
      String password,
      String name,
      ) async {
    isLoading.value = true;

    try {
      final response = await _repo.signUp(email, password, name);

      if (response.user == null) {
        _showError("Signup Failed", "Account creation failed");
        return;
      }

      await _saveUser(response.user!, name);

      isLoggedIn.value = true;
      // Get.offAllNamed('/home');
    } on AuthApiException catch (e) {
      _showError("Signup Failed", e.message);
    } catch (e) {
      _showError("Signup Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _repo.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_details');
    isLoggedIn.value = false;
    // Get.offAllNamed('/login');
  }

  Future<void> _saveUser(User user, String name) async {
    final prefs = await SharedPreferences.getInstance();

    currentUser = UserModel(
      id: user.id,
      name: name,
      email: user.email ?? '',
    );

    await prefs.setString(
      'user_details',
      jsonEncode(currentUser!.toJson()),
    );
  }

  void _showError(String title, String message) {
    Future.microtask(() {
      if (Get.isSnackbarOpen) return;

      Get.showSnackbar(
        GetSnackBar(
          title: title,
          message: message,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}
