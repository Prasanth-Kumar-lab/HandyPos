import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../model/system_settings_model.dart';

class SystemSettingsController extends GetxController {
  final TextEditingController billPrefixController = TextEditingController();
  final TextEditingController quoteController = TextEditingController();
  final TextEditingController firmNameController = TextEditingController();
  final TextEditingController firmContact1Controller = TextEditingController();
  final TextEditingController firmContact2Controller = TextEditingController();
  final TextEditingController fileController = TextEditingController();
  final TextEditingController billAddressController = TextEditingController();
  final TextEditingController billGstinNumController = TextEditingController();
  final TextEditingController businessIdController = TextEditingController();
  final RxBool isLoading = false.obs;
  final Rx<Map<String, dynamic>?> savedData = Rx<Map<String, dynamic>?>(null);
  final ImagePicker _picker = ImagePicker();
  final RxString selectedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize businessId from passed argument
    final String businessId = Get.arguments['businessId'] ?? '';
    businessIdController.text = businessId;
  }

  @override
  void onClose() {
    billPrefixController.dispose();
    quoteController.dispose();
    firmNameController.dispose();
    firmContact1Controller.dispose();
    firmContact2Controller.dispose();
    fileController.dispose();
    billAddressController.dispose();
    billGstinNumController.dispose();
    businessIdController.dispose();
    super.onClose();
  }
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;
        fileController.text = pickedFile.path.split('/').last; // Show filename only
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to pick image: ", //$e
        backgroundColor: Colors.red.shade600,
      );
    }
  }
  void clearImage() {
    selectedImagePath.value = '';
    fileController.clear();
  }
  String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /*
  Future<void> saveSystemSettings(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final model = SystemSettingsModel(
      billPrefix: billPrefixController.text,
      quote: quoteController.text,
      firmName: firmNameController.text,
      firmContact1: firmContact1Controller.text,
      firmContact2: firmContact2Controller.text,
      file: fileController.text,
      billAddress: billAddressController.text,
      billGstinNum: billGstinNumController.text,
      businessId: businessIdController.text,
    );

    final result = await model.saveSettings();

    isLoading.value = false;

    // Debug: Log result
    print('Model Result Status: ${result['status']}');
    print('Model Result Message: ${result['message']}');

    if (result['status'] == 'success') {
      savedData.value = result['data'];
      Get.snackbar(
        'Success',
        result['message'], // e.g., "System Settings Updated"
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        result['message'], // Only use model's error message
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }*/

  Future<void> saveSystemSettings(
      GlobalKey<FormState> formKey, {
        Future<void> Function()? onSuccess, // <-- callback after save
      }) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final model = SystemSettingsModel(
      billPrefix: billPrefixController.text,
      quote: quoteController.text,
      firmName: firmNameController.text,
      firmContact1: firmContact1Controller.text,
      firmContact2: firmContact2Controller.text,
      file: selectedImagePath.value.isNotEmpty
          ? selectedImagePath.value.split('/').last
          : fileController.text,
      billAddress: billAddressController.text,
      billGstinNum: billGstinNumController.text,
      businessId: businessIdController.text,
    );

    final result = await model.saveSettings(
      selectedImagePath: selectedImagePath.value,
    );

    isLoading.value = false;

    if (result['status'] == 'success') {
      savedData.value = result['data'];

      Fluttertoast.showToast(
        msg: result['message'] ?? 'Settings saved successfully!',
        backgroundColor: Colors.green.shade600,
      );

      // Auto-refresh after successful save
      if (onSuccess != null) {
        await onSuccess();
      }

    } else {
      Fluttertoast.showToast(
        msg: 'Failed to save settings',
        backgroundColor: Colors.red.shade600,
      );
    }
  }

}