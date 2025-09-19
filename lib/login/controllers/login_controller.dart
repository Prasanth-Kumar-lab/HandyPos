import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:task/home_screen/view/view.dart';

import '../../api_endpoints.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var obscurePassword = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> handleLogin() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        final response = await http.post(
          Uri.parse(ApiConstants.loginEndpoint), // End_Point integration.
          body: {
            'username': usernameController.text,
            'password': passwordController.text,
          },
        );

        final data = jsonDecode(response.body);
        if (data['status'] == 'Success') {
          isLoading.value = false;
          Get.snackbar('Success', data['message'],
              snackPosition: SnackPosition.BOTTOM);
          Get.to(() => HomeScreen());
        } else {
          isLoading.value = false;
          Get.snackbar('Error', data['message'] ?? 'Login failed',
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'Something went wrong',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
