import 'package:business_assistance/Repo/UploadRepo.dart';
import 'package:business_assistance/UI/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Controller/AIAssistantController.dart';
import 'Controller/BusinessController.dart';
import 'Models/BusinessModel.dart';
import 'Repo/AiRepository.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";


Future<void> main() async {
  Get.put(BusinessController());
  Get.put(AiController(repository: AiRepository() , uploadrepo: Uploadrepo()),);
  await Supabase.initialize(
    url: 'https://khlbjnqclopfwbpyniqz.supabase.co',
    anonKey: 'sb_publishable_d4OCn0mQUx9s-KAL5qqxkg_Nfmfuseh',
  );
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
