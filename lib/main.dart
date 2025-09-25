import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/profile/views/profile_buttons.dart';
import 'package:task/profile/views/profile_buttons.dart';
import 'package:task/signup_page/views/signup_screen.dart';
import 'package:task/splash_screen/splash_screen.dart';

import 'home_screen/view/view.dart';
import 'login/views/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/splash', // Set Splash as initial

      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(
          name: '/home',
          page: () => HomeScreen(
            name: Get.arguments['name'] ?? 'User',
            username: Get.arguments['username'] ?? '',
            mobileNumber: Get.arguments['mobileNumber'] ?? 'N/A',
            businessId: Get.arguments['business_id']??'N/A',
            role: Get.arguments['role'] ?? 'N/A',
          ),
        ),
        GetPage(
          name: '/home',
          page: () => ProfileButtons(
            name: Get.arguments['name'] ?? 'User',
            username: Get.arguments['username'] ?? '',
            mobileNumber: Get.arguments['mobileNumber'] ?? 'N/A',
            businessId: Get.arguments['business_id']?? 'N/A',
          ),
        ),
      ],
    );
  }
}
