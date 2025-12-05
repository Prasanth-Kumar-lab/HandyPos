/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/system_settings_controller.dart';
import '../widgets/Circular_fields.dart';

class AddSystemSettingsView extends StatelessWidget {
  const AddSystemSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SystemSettingsController());
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add System Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                /// Bill Prefix
                CircularInputField(
                  controller: controller.billPrefixController,
                  labelText: 'Bill Prefix',
                  hintText: 'Enter bill prefix (e.g., INV)',
                  validator: (value) => controller.validateField(value, 'bill prefix'),
                ),
                const SizedBox(height: 16),

                /// Quote
                CircularInputField(
                  controller: controller.quoteController,
                  labelText: 'Quote',
                  hintText: 'Enter quote',
                  validator: (value) => controller.validateField(value, 'quote'),
                ),
                const SizedBox(height: 16),

                /// Firm Name
                CircularInputField(
                  controller: controller.firmNameController,
                  labelText: 'Firm Name',
                  hintText: 'Enter firm name',
                  validator: (value) => controller.validateField(value, 'firm name'),
                ),
                const SizedBox(height: 16),

                /// Firm Contact 1
                CircularInputField(
                  controller: controller.firmContact1Controller,
                  labelText: 'Firm Contact 1',
                  hintText: 'Enter primary contact number',
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      controller.validateField(value, 'primary contact number'),
                ),
                const SizedBox(height: 16),

                /// Firm Contact 2
                CircularInputField(
                  controller: controller.firmContact2Controller,
                  labelText: 'Firm Contact 2',
                  hintText: 'Enter secondary contact number (optional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                /// File
                CircularInputField(
                  controller: controller.fileController,
                  labelText: 'File',
                  hintText: 'Enter file name or path',
                  validator: (value) =>
                      controller.validateField(value, 'file name or path'),
                ),
                const SizedBox(height: 16),

                /// Bill Address
                CircularInputField(
                  controller: controller.billAddressController,
                  labelText: 'Bill Address',
                  hintText: 'Enter billing address',
                  maxLines: 3,
                  validator: (value) =>
                      controller.validateField(value, 'billing address'),
                ),
                const SizedBox(height: 16),

                /// GSTIN Number
                CircularInputField(
                  controller: controller.billGstinNumController,
                  labelText: 'Bill GSTIN Number',
                  hintText: 'Enter GSTIN number',
                  validator: (value) =>
                      controller.validateField(value, 'GSTIN number'),
                ),
                const SizedBox(height: 24),

                /// Save Button
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.saveSystemSettings(formKey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Circular button
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )),
                const SizedBox(height: 24),

                /// Saved Data
                Obx(() => controller.savedData.value != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved System Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bill Prefix: ${controller.savedData.value!['bill_prefix']}'),
                            const SizedBox(height: 8),
                            Text('Quote: ${controller.savedData.value!['quote']}'),
                            const SizedBox(height: 8),
                            Text('Firm Name: ${controller.savedData.value!['firm_name']}'),
                            const SizedBox(height: 8),
                            Text('Firm Contact 1: ${controller.savedData.value!['firm_contact1']}'),
                            const SizedBox(height: 8),
                            Text('Firm Contact 2: ${controller.savedData.value!['firm_contact2']}'),
                            const SizedBox(height: 8),
                            Text('File: ${controller.savedData.value!['file']}'),
                            const SizedBox(height: 8),
                            Text('Bill Address: ${controller.savedData.value!['bill_address']}'),
                            const SizedBox(height: 8),
                            Text('Bill GSTIN Number: ${controller.savedData.value!['bill_gstin_num']}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
// File: add_system_settings_view.dart
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/system_settings_controller.dart';
import '../widgets/Circular_fields.dart';

class AddSystemSettingsView extends StatelessWidget {
  const AddSystemSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SystemSettingsController());

    // Extract businessId from navigation arguments
    final String businessId = Get.arguments['businessId']?.toString() ?? '90';
    controller.businessIdController.text = businessId;

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'System Settings',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          ),
          backgroundColor: Colors.orange.shade300,
          foregroundColor: Colors.black87,
          elevation: 0,

          // ===========================
          //   EDIT SETTINGS FIRST TAB
          // ===========================
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: 'Edit Settings'),
              Tab(icon: Icon(Icons.remove_red_eye), text: 'View Settings'),
            ],
          ),
        ),

        // ===========================
        //  TAB ORDER CHANGED
        //  1. Edit Settings
        //  2. View Settings
        // ===========================
        body: TabBarView(
          children: [
            EditSettingsTab(controller: controller),  // FIRST TAB
            ViewSettingsTab(businessId: businessId),  // SECOND TAB
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Tab 1: Edit / Add System Settings Form (FIRST TAB)
// ============================================================
class EditSettingsTab extends StatelessWidget {
  final SystemSettingsController controller;

  const EditSettingsTab({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit System Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              CircularInputField(
                controller: controller.billPrefixController,
                labelText: 'Bill Prefix',
                hintText: 'e.g., INV',
                validator: (v) => controller.validateField(v, 'bill prefix'),
              ),
              const SizedBox(height: 16),

              CircularInputField(
                controller: controller.quoteController,
                labelText: 'Quote',
                hintText: 'Enter your company quote',
              ),
              const SizedBox(height: 16),

              CircularInputField(
                controller: controller.firmNameController,
                labelText: 'Firm Name',
                validator: (v) => controller.validateField(v, 'firm name'),
              ),
              const SizedBox(height: 16),

              CircularInputField(
                controller: controller.firmContact1Controller,
                labelText: 'Contact 1',
                keyboardType: TextInputType.phone,
                validator: (v) => controller.validateField(v, 'contact 1'),
              ),
              const SizedBox(height: 16),

              CircularInputField(
                controller: controller.firmContact2Controller,
                labelText: 'Contact 2 (Optional)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              CircularInputField(
                controller: controller.fileController,
                labelText: 'Logo Path',
                hintText: 'e.g., /bill_quotes/3',
                validator: (v) => controller.validateField(v, 'logo path'),
              ),
              const SizedBox(height: 16),

              CircularInputField(
                controller: controller.billAddressController,
                labelText: 'Bill Address',
                maxLines: 3,
                validator: (v) => controller.validateField(v, 'address'),
              ),
              const SizedBox(height: 16),

              CircularInputField(
                controller: controller.billGstinNumController,
                labelText: 'GSTIN Number',
                validator: (v) => controller.validateField(v, 'GSTIN'),
              ),
              const SizedBox(height: 30),

              Obx(
                    () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.saveSystemSettings(formKey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Obx(
                    () => controller.savedData.value != null
                    ? Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Settings saved successfully!',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Tab 2: View Current System Settings (SECOND TAB)
// ============================================================
class ViewSettingsTab extends StatelessWidget {
  final String businessId;

  const ViewSettingsTab({required this.businessId, super.key});

  Future<Map<String, dynamic>?> fetchSettings() async {
    try {
      final url =
          'https://erpapp.in/mart_print/mart_print_apis/list_system_seetings_api.php?business_id=$businessId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // API returns a Map directly, NOT a List
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No settings found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap "Edit Settings" to create one'),
                ],
              ),
            ),
          );
        }

        final settings = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current System Settings',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700),
                  ),
                  const Divider(height: 40),

                  _buildRow('Firm Name', settings['firm_name']),
                  _buildRow(
                      'Bill Prefix',
                      settings['bill_prefix']?.isEmpty ?? true
                          ? 'Not set'
                          : settings['bill_prefix']),
                  _buildRow(
                      'Quote',
                      settings['quote']?.isEmpty ?? true
                          ? 'Not set'
                          : settings['quote']),
                  _buildRow(
                      'Contact 1',
                      settings['firm_contact1']?.isEmpty ?? true
                          ? 'Not set'
                          : settings['firm_contact1']),
                  _buildRow(
                      'Contact 2',
                      settings['firm_contact2']?.isEmpty ?? true
                          ? 'Not set'
                          : settings['firm_contact2']),
                  _buildRow('GSTIN', settings['bill_gstin_num']),
                  _buildRow(
                      'Address',
                      settings['bill_address']?.isEmpty ?? true
                          ? 'Not set'
                          : settings['bill_address'],
                      multiLine: true),

                  if (settings['bill_logo'] != null &&
                      settings['bill_logo'].toString().isNotEmpty &&
                      settings['bill_logo'] != './bill_quotes/3')
                    ...[
                      const SizedBox(height: 20),
                      Text('Logo Preview',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://erpapp.in/mart_print/mart_print/${settings['bill_logo']}',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, dynamic value, {bool multiLine = false}) {
    final safeValue = (value == null || value.toString().trim().isEmpty)
        ? 'Not set'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: safeValue,
              style: TextStyle(
                fontStyle: safeValue == 'Not set' ? FontStyle.italic : FontStyle.normal,
                color: safeValue == 'Not set' ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';
import 'dart:convert';
import '../controller/system_settings_controller.dart';
import '../widgets/Circular_fields.dart';

class SystemSettingsView extends StatefulWidget {
  const SystemSettingsView({super.key});

  @override
  State<SystemSettingsView> createState() => _SystemSettingsViewState();
}

class _SystemSettingsViewState extends State<SystemSettingsView> {
  final controller = Get.put(SystemSettingsController());
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic>? settings;
  bool isLoadingData = true;

  late final String businessId;

  @override
  void initState() {
    super.initState();
    // Extract businessId from navigation arguments
    businessId = Get.arguments['businessId']?.toString() ?? '90';
    controller.businessIdController.text = businessId;

    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final url =
          '${ApiConstants.listSystemSettingsEndPoint}?business_id=$businessId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          settings = data;
          _prefillFields();
        }
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    } finally {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  void _prefillFields() {
    controller.billPrefixController.text = settings?['bill_prefix'] ?? '';
    controller.quoteController.text = settings?['quote'] ?? '';
    controller.firmNameController.text = settings?['firm_name'] ?? '';
    controller.firmContact1Controller.text = settings?['firm_contact1'] ?? '';
    controller.firmContact2Controller.text = settings?['firm_contact2'] ?? '';
    controller.fileController.text = settings?['bill_logo'] ?? '';
    controller.billAddressController.text = settings?['bill_address'] ?? '';
    controller.billGstinNumController.text = settings?['bill_gstin_num'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'System Settings',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          ),
          backgroundColor: Colors.orange.shade300,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: 'Edit Settings'),
              Tab(icon: Icon(Icons.remove_red_eye), text: 'View Settings'),
            ],
          ),
        ),
        body: isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildEditSettingsTab(),
            _buildViewSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSettingsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Form(
        key: formKey,
        child: RefreshIndicator(
          onRefresh: fetchSettings,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit System Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                CircularInputField(
                  controller: controller.billPrefixController,
                  labelText: 'Bill Prefix',
                  hintText: 'e.g., INV',
                  //validator: (v) => controller.validateField(v, 'bill prefix'),
                ),
                const SizedBox(height: 16),

                CircularInputField(
                  controller: controller.quoteController,
                  labelText: 'Quote',
                  hintText: 'Enter your company quote',
                ),
                const SizedBox(height: 16),

                CircularInputField(
                  controller: controller.firmNameController,
                  labelText: 'Firm Name',
                  //validator: (v) => controller.validateField(v, 'firm name'),
                ),
                const SizedBox(height: 16),

                CircularInputField(
                  controller: controller.firmContact1Controller,
                  labelText: 'Contact 1',
                  keyboardType: TextInputType.phone,
                  //validator: (v) => controller.validateField(v, 'contact 1'),
                ),
                const SizedBox(height: 16),

                CircularInputField(
                  controller: controller.firmContact2Controller,
                  labelText: 'Contact 2 (Optional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                /*CircularInputField(
                  controller: controller.fileController,
                  labelText: 'Logo Path',
                  hintText: 'e.g., /bill_quotes/3',
                  validator: (v) => controller.validateField(v, 'logo path'),
                ),*/
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Logo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // ---- IMAGE PREVIEW BOX ----
                        Obx(() {
                          String existingLogoUrl = controller.fileController.text.trim();
                          String pickedImage = controller.selectedImagePath.value;

                          Widget imageWidget;

                          if (pickedImage.isNotEmpty) {
                            imageWidget = Image.file(
                              File(pickedImage),
                              fit: BoxFit.contain,
                            );
                          } else if (existingLogoUrl.isNotEmpty) {
                            imageWidget = Image(
                              image: CachedNetworkImageProvider(existingLogoUrl),
                              fit: BoxFit.contain,
                            );
                          } else {
                            imageWidget = const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 100,
                              width: 200,
                              color: Colors.grey.shade200,
                              child: imageWidget,
                            ),
                          );
                        }),

                        const SizedBox(width: 12),

                        // ---- PICK BUTTON ONLY (no clear button) ----
                        ElevatedButton.icon(
                          onPressed: controller.pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Pick"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade400,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ---- STATUS TEXT ----
                    Obx(() {
                      if (controller.selectedImagePath.value.isNotEmpty) {
                        return Text(
                          "New image selected",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        );
                      } else if (controller.fileController.text.isNotEmpty) {
                        return Text(
                          "Current Logo Loaded",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        );
                      } else {
                        return Text(
                          "No logo uploaded yet",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        );
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                /*CircularInputField(
                  controller: controller.billAddressController,
                  labelText: 'Bill Address',
                  maxLines: 7,
                  //validator: (v) => controller.validateField(v, 'address'),
                ),*/
                TextField(
                  controller: controller.billAddressController,
                  decoration: InputDecoration(
                    labelText: 'Bill Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // circular style
                    ),
                    alignLabelWithHint: true, // aligns label for multi-line
                  ),
                  keyboardType: TextInputType.multiline,

                  maxLines: null, // unlimited growth
                ),

                const SizedBox(height: 16),

                CircularInputField(
                  controller: controller.billGstinNumController,
                  labelText: 'GSTIN Number',
                  //validator: (v) => controller.validateField(v, 'GSTIN'),
                ),
                const SizedBox(height: 30),
                Obx(
                      () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveSystemSettings(
                      formKey,
                      onSuccess: refreshSettings, // <-- auto refresh callback
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade400,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Obx(
                      () => controller.savedData.value != null
                      ? Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Text(
                            'Settings saved successfully!',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewSettingsTab() {
    if (settings == null || settings!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings_outlined,
                  size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No settings found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Tap "Edit Settings" to create one'),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current System Settings',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700),
              ),
              const Divider(height: 40),
              _buildRow('Firm Name', settings!['firm_name']),
              _buildRow(
                  'Bill Prefix',
                  settings!['bill_prefix']?.isEmpty ?? true
                      ? 'Not set'
                      : settings!['bill_prefix']),
              _buildRow(
                  'Quote',
                  settings!['quote']?.isEmpty ?? true
                      ? 'Not set'
                      : settings!['quote']),
              _buildRow(
                  'Contact 1',
                  settings!['firm_contact1']?.isEmpty ?? true
                      ? 'Not set'
                      : settings!['firm_contact1']),
              _buildRow(
                  'Contact 2',
                  settings!['firm_contact2']?.isEmpty ?? true
                      ? 'Not set'
                      : settings!['firm_contact2']),
              _buildRow('GSTIN', settings!['bill_gstin_num']),
              _buildRow(
                  'Address',
                  settings!['bill_address']?.isEmpty ?? true
                      ? 'Not set'
                      : settings!['bill_address'],
                  multiLine: true),
              if (settings!['bill_logo'] != null &&
                  settings!['bill_logo'].toString().isNotEmpty &&
                  settings!['bill_logo'] != './bill_quotes/3')
                ...[
                  const SizedBox(height: 20),
                  Text('Logo Preview',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 150,
                      width: 200,
                      color: Colors.grey[200],
                      child: Image(
                        image: CachedNetworkImageProvider(
                          '${settings!['bill_logo']}',
                        ),
                        height: 150,
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          width: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  )
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, dynamic value, {bool multiLine = false}) {
    final safeValue = (value == null || value.toString().trim().isEmpty)
        ? 'Not set'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: safeValue,
              style: TextStyle(
                fontStyle:
                safeValue == 'Not set' ? FontStyle.italic : FontStyle.normal,
                color: safeValue == 'Not set' ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> refreshSettings() async {
    setState(() {
      isLoadingData = true;
    });
    await fetchSettings();
  }

}

