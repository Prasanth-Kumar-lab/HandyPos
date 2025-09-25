import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:task/AddBiller/views/add_biller_screen.dart';
import 'package:task/AddCategory/views/add_category_views.dart';
import 'package:task/AddProducts/Views/add-products_view.dart';
import 'package:task/Add_Tax/Views/add_tax_view.dart';
import 'package:task/login/views/login_screen.dart';
import 'package:task/profile/views/profile_page.dart';
import '../widgets/profile_action_button.dart';

class ProfileButtons extends StatelessWidget {
  final String name;
  final String username;
  final String mobileNumber;
  final String businessId;

  const ProfileButtons({
    super.key,
    required this.name,
    required this.username,
    required this.mobileNumber,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.back,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: AssetImage('assets/profile_placeholder.png'),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle avatar edit action
                          },
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Business ID: $businessId', // Dynamic name from parameter
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      name, // Dynamic username from parameter
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    /*Text(
                      '$username', // Dynamic mobile number from parameter
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),*/
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ProfileActionButton(
                icon: Icons.person_outline_outlined,
                title: 'Edit Profile',
                onTap: () {
                  Get.to(() => ProfilePage(
                    name: name,
                    username: username,
                    mobileNumber: mobileNumber,
                  )); // Pass params to ProfilePage if needed
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              ProfileActionButton(
                icon: Icons.location_on_outlined,
                title: 'Add Products',
                onTap: () {
                  Get.to(()=>AddProductsPage(businessId: businessId,));// Handle address action
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              ProfileActionButton(
                icon: Icons.favorite_border,
                title: 'Add Category',
                onTap: () {
                  Get.to(()=>AddCategoryView(businessId: businessId,));// Handle favorites action
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              ProfileActionButton(
                icon: Icons.work_history_outlined,
                title: 'Add Tax',
                onTap: () {
                  Get.to(()=>AddTaxView(businessId:businessId));// Handle orders action
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              ProfileActionButton(
                icon: Icons.security,
                title: 'Add Biller',
                onTap: () {
                  Get.to(()=>AddBillerScreen());// Handle privacy action
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              ProfileActionButton(
                icon: Icons.support_agent_outlined,
                title: 'Chat & Support',
                onTap: () {
                  // Handle support action
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              ProfileActionButton(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  // Handle settings action
                },
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              ProfileActionButton(
                icon: Icons.logout,
                title: 'Logout',
                textColor: Colors.red.shade600,
                onTap: () {
                  Get.offAll(() => LoginScreen());
                },
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}