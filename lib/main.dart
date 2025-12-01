import 'package:business_assistance/UI/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import 'Controller/AIAssistantController.dart';
import 'Controller/BusinessController.dart';
import 'Repo/AiRepository.dart';


void main() {
  Get.put(BusinessController());
  Get.put(AiController(repository: AiRepository(apiKey: "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")),);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}
