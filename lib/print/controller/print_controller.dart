import 'dart:developer';

import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../home_screen/model/product_model.dart';
import '../model/print_model.dart';

class PrintController extends GetxController {
  final Rx<Printer?> selectedPrinter = Rx<Printer?>(null);
  final List<Product> selectedProducts;
  final double totalAmount;

  PrintController({required this.selectedProducts, required this.totalAmount});

  ReceiptController? receiptController;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedPrinter();
  }

  /// Load the selected printer from SharedPreferences
  Future<void> _loadSelectedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('selected_printer_address');
    final name = prefs.getString('selected_printer_name');

    if (address != null) {
      selectedPrinter.value = Printer(address: address, name: name);
      log("Loaded saved printer: ${name ?? address}");
    }
  }

  /// Save the selected printer to SharedPreferences
  Future<void> _saveSelectedPrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_printer_address', printer.address);
    await prefs.setString('selected_printer_name', printer.name ?? '');
    log("Saved printer: ${printer.name ?? printer.address}");
  }

  /// Select Bluetooth Printer
  Future<void> selectBluetoothDevice(BuildContext context) async {
    final selected = await FlutterBluetoothPrinter.selectDevice(context);
    if (selected != null) {
      selectedPrinter.value = Printer(address: selected.address, name: selected.name);
      await _saveSelectedPrinter(selectedPrinter.value!);
      log("Selected device: ${selectedPrinter.value!.name}");
    } else {
      log("Device selection canceled.");
    }
  }

  /// Generate and print PDF (for testing purposes)

  /// Print to Selected Device
  Future<void> printReceipt(BuildContext context) async {
    if (selectedPrinter.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a printer first')),
      );
      return;
    }

    try {
      await receiptController?.print(
        address: selectedPrinter.value!.address,
        keepConnected: true,
        addFeeds: 4,
      );
    } catch (e) {
      log('Printing failed: $e');
    }
  }

  void setReceiptController(ReceiptController controller) {
    receiptController = controller;
  }
}