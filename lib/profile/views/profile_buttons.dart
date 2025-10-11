import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/AddBiller/views/add_biller_screen.dart';
import 'package:task/AddCategory/views/add_category_views.dart';
import 'package:task/AddProducts/Views/add-products_view.dart';
import 'package:task/Add_Tax/Views/add_tax_view.dart';
import 'package:task/Reports/view/reports_view.dart';
import 'package:task/login/views/login_screen.dart';
import '../../AddSystemSettings/view/system_settings_view.dart';
import 'profile_page.dart';
import '../widgets/profile_action_button.dart';

class ProfileButtons extends StatelessWidget {
  final String name;
  final String username;
  final String mobileNumber;
  final String businessId;
  final String user_id;
  final String role;

  const ProfileButtons({
    super.key,
    required this.name,
    required this.username,
    required this.mobileNumber,
    required this.businessId,
    required this.user_id,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black87),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            elevation: 8,
            color: Colors.white,
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildMenuItem(
                value: 'Edit Profile',
                icon: Icons.person_outline_outlined,
                title: 'Edit Profile',
              ),
              _buildMenuItem(
                value: 'Add Products',
                icon: Icons.location_on_outlined,
                title: 'Add Products',
              ),
              _buildMenuItem(
                value: 'Add Category',
                icon: Icons.favorite_border,
                title: 'Add Category',
              ),
              _buildMenuItem(
                value: 'Add Tax',
                icon: Icons.work_history_outlined,
                title: 'Add Tax',
              ),
              _buildMenuItem(
                value: 'Add Biller',
                icon: Icons.security,
                title: 'Add Biller',
              ),
              _buildMenuItem(
                value: 'Add System Settings',
                icon: Icons.support_agent_outlined,
                title: 'Add System Settings',
              ),
              _buildMenuItem(
                value: 'Daily Reports',
                icon: Icons.settings_outlined,
                title: 'Daily Reports',
              ),
              _buildMenuItem(
                value: 'Logout',
                icon: Icons.logout,
                title: 'Logout',
                textColor: Colors.red.shade600,
                iconColor: Colors.red.shade600,
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'Edit Profile':
                  Get.to(() => ProfilePage(
                    businessId: businessId,
                    role: role,
                    user_id: user_id,
                  ));
                  break;
                case 'Add Products':
                  Get.to(() => AddProductsPage(businessId: businessId));
                  break;
                case 'Add Category':
                  Get.to(() => AddCategoryView(businessId: businessId));
                  break;
                case 'Add Tax':
                  Get.to(() => AddTaxView(businessId: businessId));
                  break;
                case 'Add Biller':
                  Get.to(() => AddBillerScreen(businessId: businessId));
                  break;
                case 'Add System Settings':
                  Get.to(() => AddSystemSettingsView(),
                      arguments: {'businessId': businessId});
                  break;
                case 'Daily Reports':
                  Get.to(()=>ReportsView(businessId: businessId,));
                // Handle settings action
                  break;
                case 'Logout':
                  _logout(context);
                  break;
              }
            },
          ),
        ],
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
                          backgroundImage:
                          const AssetImage('assets/profile_placeholder.png'),
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Business ID: $businessId',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildDashboardBox(
                    title: 'Billers',
                    color: Colors.orange.shade100,
                    icon: Icons.people,
                    onTap: () {
                      Get.snackbar('Tapped', 'You tapped on Billers');
                    },
                  ),
                  _buildDashboardBox(
                    title: 'Customers',
                    color: Colors.green.shade100,
                    icon: Icons.bar_chart,
                    onTap: () {
                      Get.snackbar('Tapped', 'You tapped on Customers');
                    },
                  ),
                  _buildDashboardBox(
                    title: 'Number of transactions',
                    color: Colors.blue.shade100,
                    icon: Icons.attach_money,
                    onTap: () {
                      Get.snackbar('Tapped', 'You tapped on Transactions');
                    },
                  ),
                  _buildDashboardBox(
                    title: 'Invoices',
                    color: Colors.purple.shade100,
                    icon: Icons.receipt_long,
                    onTap: () {
                      Get.snackbar('Tapped', 'You tapped on Invoices');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String title,
    Color? textColor,
    Color? iconColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Colors.black87,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBox({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => LoginScreen());
  }
}