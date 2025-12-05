import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/profile/views/profile_buttons.dart';
import 'package:task/signup_page/views/signup_screen.dart';
import 'package:task/splash_screen/splash_screen.dart';
import 'package:task/home_screen/view/view.dart';
import 'package:task/login/views/login_screen.dart';
import 'package:task/print/controller/print_controller.dart'; // Adjust path if needed
import 'home_screen/model/product_model.dart'; // If used in injection

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
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),

        // Inject PrintController when navigating to Home
        GetPage(
          name: '/home',
          page: () {
            final args = Get.arguments ?? {};
            final initialProducts = args['products'] as List<Product>? ?? []; // Map to initialProducts
            final initialTotal = args['total'] as double? ?? 0.0; // Map to initialTotal
            final businessId = args['business_id'] ?? '';

            // Inject controller dynamically with real data
            Get.put(PrintController(
              initialProducts: initialProducts, // Updated parameter name
              initialTotal: initialTotal, // Updated parameter name
              businessId: businessId,
            ));

            return HomeScreen(
              name: args['name'] ?? 'User',
              username: args['username'] ?? '',
              mobileNumber: args['number'] ?? 'N/A',
              businessId: businessId,
              role: args['role'] ?? 'N/A',
              user_id: args['id'] ?? 'N/A',
            );
          },
        ),

        GetPage(
          name: '/profile',
          page: () {
            final args = Get.arguments ?? {};
            return ProfileButtons(
              name: args['name'] ?? 'User',
              username: args['username'] ?? '',
              mobileNumber: args['number'] ?? 'N/A',
              businessId: args['business_id'] ?? 'N/A',
              user_id: args['id'] ?? 'N/A',
              role: args['role'] ?? 'N/A',
            );
          },
        ),
      ],
    );
  }
}




/*
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>HandyPos</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>HandyPos</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>CADisableMinimumFrameDurationOnPhone</key>
	<true/>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
</dict>
</plist>
 */