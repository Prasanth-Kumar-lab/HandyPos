import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/login_controller.dart';
import '../widgets/custom_text_field_and_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Stack(
              children: [
                // Top-right Lottie animation
                Positioned(
                  top: 0,
                  right: 10,
                  child: SizedBox(
                    height: 140,
                    width: 100,
                    child: Lottie.asset(
                      'assets/Bill processing.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Main content
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Top animation
                          /*SizedBox(
                            height: 170,
                            child: Lottie.asset('assets/Billing icon.json'),
                          ),*/
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Login to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Username field
                          CustomTextField(
                            controller: controller.usernameController,
                            label: 'Username',
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          Obx(
                                () => CustomTextField(
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
                            ),
                          ),
                          const SizedBox(height: 1),

                          // Forgot password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Get.toNamed('/forgot-password'),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          Obx(() => CustomButton(
                            text: 'Login',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.handleLogin,
                          )),
                          const SizedBox(height: 16),

                          // Signup link
                          TextButton(
                            onPressed: () => Get.toNamed('/signup'),
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}