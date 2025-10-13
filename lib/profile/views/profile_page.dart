import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Reports/view/biller_reports_view.dart';
import '../../login/views/login_screen.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final String businessId;
  final String user_id;
  final String role;

  const ProfilePage({
    Key? key,
    required this.businessId,
    required this.user_id,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController(userId: user_id, role: role));
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final mobileNumberController = TextEditingController();
    final roleController = TextEditingController();
    final addressController = TextEditingController();
    final isEditing = false.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: role == 'Biller'
            ? [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              Get.to(() => BillerReportsView(
                businessId: businessId,
                billerId: user_id,
                reportType: value,
              ));
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Day Report',
                child: Text('Day wise reports'),
              ),
              PopupMenuItem<String>(
                value: 'Monthly Report',
                child: Text('Monthly wise reports'),
              ),
            ],
          ),
        ]
            : null,
      ),
      body: Obx(() {
        if (controller.profile.value == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4C430)),
            ),
          );
        }
        final data = controller.profile.value!;
        nameController.text = data.name ?? '';
        usernameController.text = data.username ?? '';
        passwordController.text = data.password ?? '';
        mobileNumberController.text = data.mobileNumber ?? '';
        roleController.text = data.role ?? role;
        addressController.text = data.address ?? '';

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewTab(context, data, controller),
              SizedBox(height: 15),
              _buildDetailsTab(
                data,
                businessId,
                user_id,
                role,
                controller,
                nameController,
                usernameController,
                passwordController,
                mobileNumberController,
                roleController,
                addressController,
                isEditing,
              ),
              SizedBox(height: 20),
              if (isEditing.value)
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          usernameController.text.isEmpty ||
                          mobileNumberController.text.isEmpty ||
                          roleController.text.isEmpty ||
                          addressController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please fill all required fields',
                          backgroundColor: Color(0xFFE57373),
                          colorText: Colors.white,
                          margin: EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                        return;
                      }
                      if (passwordController.text.isNotEmpty && passwordController.text.length < 8) {
                        Get.snackbar(
                          'Error',
                          'Password must be at least 8 characters long',
                          backgroundColor: Color(0xFFE57373),
                          colorText: Colors.white,
                          margin: EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                        return;
                      }
                      await controller.updateProfile(
                        name: nameController.text,
                        username: usernameController.text,
                        password: passwordController.text.isEmpty ? null : passwordController.text,
                        mobileNumber: mobileNumberController.text,
                        role: roleController.text,
                        aadharNumber: '',
                        address: addressController.text,
                      );
                      isEditing.value = false;
                      Get.snackbar(
                        'Success',
                        'Profile updated successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Color(0xFFF4C430),
                        colorText: Color(0xFF1A2E35),
                        margin: EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4C430),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2E35),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() => FloatingActionButton(
        onPressed: () {
          isEditing.value = !isEditing.value;
          if (!isEditing.value) {
            final data = controller.profile.value!;
            nameController.text = data.name ?? '';
            usernameController.text = data.username ?? '';
            passwordController.text = data.password ?? '';
            mobileNumberController.text = data.mobileNumber ?? '';
            roleController.text = data.role ?? role;
            addressController.text = data.address ?? '';
          }
        },
        backgroundColor: Color(0xFFF4C430),
        child: Icon(
          isEditing.value ? Icons.close : Icons.edit,
          color: Color(0xFF1A2E35),
        ),
        shape: CircleBorder(),
      )),
    );
  }

  Widget _buildOverviewTab(BuildContext context, dynamic data, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFF4C430), width: 3),
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Color(0xFF1A2E35).withOpacity(0.1),
              child: Icon(
                Icons.person_rounded,
                size: 80,
                color: Color(0xFF1A2E35),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            data.name?.isEmpty ?? true ? 'User Profile' : data.name!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2E35),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    'Confirm Logout',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A2E35)),
                  ),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Get.offAll(() => const LoginScreen());
                        Get.snackbar(
                          'Logged Out',
                          'You have been logged out successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Color(0xFFE57373),
                          colorText: Colors.white,
                          margin: EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Color(0xFFE57373)),
                      ),
                    ),
                  ],
                ),
                barrierDismissible: false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFE57373),
              side: BorderSide(color: Color(0xFFE57373), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE57373),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Divider(thickness: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildDetailsTab(
      dynamic data,
      String businessId,
      String user_id,
      String role,
      ProfileController controller,
      TextEditingController nameController,
      TextEditingController usernameController,
      TextEditingController passwordController,
      TextEditingController mobileNumberController,
      TextEditingController roleController,
      TextEditingController addressController,
      RxBool isEditing,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2E35),
          ),
        ),
        SizedBox(height: 16),
        _buildEditableDetailTile('Name', nameController, Icons.person, isEditing),
        _buildEditableDetailTile(
          'Username',
          usernameController,
          Icons.alternate_email,
          isEditing,
          readOnly: true,
        ),

        _buildPasswordTile(controller, passwordController, isEditing),
        _buildEditableDetailTile('Mobile Number', mobileNumberController, Icons.phone, isEditing, keyboardType: TextInputType.phone),
        _buildEditableDetailTile('Role', roleController, Icons.work, isEditing),
        _buildEditableDetailTile('Address', addressController, Icons.location_on, isEditing),
        _buildDetailTile('User ID', user_id),
        Padding(
            padding: EdgeInsets.symmetric().copyWith(bottom: 70),
            child: _buildDetailTile('Business ID', businessId)),
      ],
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2E35),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableDetailTile(
      String label,
      TextEditingController controller,
      IconData icon,
      RxBool isEditing, {
        TextInputType? keyboardType,
        bool readOnly = false, // <-- Add this line
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isEditing.value
          ? TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly, // <-- Apply readOnly here
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF1A2E35)),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2E35),
            ),
          ),
          Flexible(
            child: Text(
              controller.text.isEmpty ? 'Not Provided' : controller.text,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPasswordTile(ProfileController controller, TextEditingController passwordController, RxBool isEditing) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isEditing.value
          ? Obx(() => TextField(
        controller: passwordController,
        obscureText: !controller.isPasswordVisible.value,
        decoration: InputDecoration(
          labelText: 'Password (min 8 characters)',
          prefixIcon: Icon(Icons.lock, color: Color(0xFF1A2E35)),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFFF4C430),
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade600,
          fontFamily: controller.isPasswordVisible.value ? null : 'monospace',
        ),
      ))
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2E35),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Text(
                  passwordController.text.isEmpty
                      ? 'Not Set'
                      : (controller.isPasswordVisible.value ? passwordController.text : '********'),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: controller.isPasswordVisible.value ? null : 'monospace',
                  ),
                )),
                if (passwordController.text.isNotEmpty)
                  Obx(() => IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFFF4C430),
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}