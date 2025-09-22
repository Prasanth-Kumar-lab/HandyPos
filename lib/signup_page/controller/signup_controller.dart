import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';
import 'package:task/login/views/login_screen.dart';
import 'package:task/signup_page/model/user_model.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final adminIdController = TextEditingController();
  final aadharNumberController = TextEditingController();
  final addressController = TextEditingController();

  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var selectedRole = 'Admin'.obs;

  @override
  void onClose() {
    nameController.dispose();
    mobileNumberController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    adminIdController.dispose();
    aadharNumberController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void setRole(String? role) {
    if (role != null) {
      selectedRole.value = role;
    }
  }

  Future<void> handleSignup() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      // Construct user model
      final user = UserModelSignUp(
        name: nameController.text.trim(),
        mobileNumber: mobileNumberController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        role: selectedRole.value,
        adminId: selectedRole.value == 'Biller' ? adminIdController.text.trim() : null,
        aadharNumber: aadharNumberController.text.trim().isNotEmpty ? aadharNumberController.text.trim() : null,
        address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
      );

      try {
        // Make API call
        final response = await http.post(
          Uri.parse(ApiConstants.signUpEndpoint),
          body: user.toJson(),
        );

        isLoading.value = false;

        if (response.statusCode == 200) {
          // Enhanced snackbar for successful signup
          Get.snackbar(
            'Welcome Aboard!',
            'Your account has been created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 3),
            icon: Icon(Icons.check_circle, color: Colors.white),
          );

          // Delay navigation to allow snackbar to be visible
          //await Future.delayed(Duration(seconds: 3));
          // Navigate to LoginPage without replacing the current screen
          //Get.offAll(() => LoginScreen());
        } else {
          Get.snackbar(
            'Error',
            'Sign Up Failed: ${response.body}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}