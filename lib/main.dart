import 'package:business_assistance/Repo/UploadRepo.dart';
import 'package:business_assistance/UI/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Controller/AIAssistantController.dart';
import 'Controller/AuthController.dart';
import 'Controller/BusinessController.dart';
import 'Models/BusinessModel.dart';
import 'Repo/AiRepository.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";

import 'Repo/CustomDBRepo.dart';


Future<void> main() async {
  await Supabase.initialize(
    url: 'https://khlbjnqclopfwbpyniqz.supabase.co',
    anonKey: 'sb_publishable_d4OCn0mQUx9s-KAL5qqxkg_Nfmfuseh',
  );
  Get.put(AuthenticationController());
  Get.put(BusinessController());
  Get.put(AiController(repository: AiRepository() , uploadrepo: Uploadrepo() , customDBRepo: CustomDBRepo()));
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
   MyApp({super.key});
  final authController = Get.find<AuthenticationController>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Obx(() {
        if (authController.isLoggedIn.value) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      }),
    );
  }
}


class AuthScreen extends StatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  late bool isLogin;
  bool _obscurePassword = true; // State for password visibility
  bool _obscureConfirmPassword = true; // State for confirm password visibility

  final authController = Get.find<AuthenticationController>();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  // Email Validation Helper
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLogin ? "Welcome Back" : "Create Account",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 24),

                  if (!isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: "Full Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person)
                      ),
                      validator: (val) => val!.isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // EMAIL FIELD WITH RIGID VALIDATION
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email)
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Email is required";
                      if (!_isValidEmail(val)) return "Please enter a valid email address";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD FIELD WITH EYE BUTTON & 6 DIGIT LIMIT
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Password is required";
                      if (val.length < 6) return "Password must be at least 6 digits";
                      return null;
                    },
                  ),

                  if (!isLogin) ...[
                    const SizedBox(height: 16),
                    // CONFIRM PASSWORD WITH EYE BUTTON
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please confirm your password";
                        if (val != _passwordController.text) return "Passwords do not match";
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: authController.isLoading.value ? null : _submit,
                      child: authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isLogin ? "LOGIN" : "SIGN UP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        _formKey.currentState?.reset();
                        _emailController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                        _nameController.clear();
                      });
                    },
                    child: Text(isLogin ? "New here? Create account" : "Already have an account? Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed to request
      if (isLogin) {
        authController.handleSignIn(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        authController.handleSignUp(_emailController.text.trim(), _passwordController.text.trim(), _nameController.text.trim());
      }
    }
  }
}