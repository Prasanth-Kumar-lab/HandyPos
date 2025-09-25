import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:task/signup_page/controller/signup_controller.dart';
import '../../../login/widgets/custom_text_field_and_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'SignUp today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      controller: controller.nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.mobileNumberController,
                      label: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.usernameController,
                      label: 'Username',
                      icon: Icons.account_circle_outlined,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your username' : null,
                    ),
                    const SizedBox(height: 16),
                    Obx(() => CustomTextField(
                      controller: controller.passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: controller.obscurePassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.aadharNumberController,
                      label: 'Aadhar Number',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Aadhar number';
                        }
                        if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                          return 'Please enter a valid 12-digit Aadhar number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.addressController,
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your address' : null,
                    ),
                    const SizedBox(height: 24),
                    Obx(() => CustomButton(
                      text: 'Sign Up',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.handleSignup,
                    )),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}