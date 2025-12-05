/*
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';
import '../../home_screen/model/product_model.dart';
import '../model/print_model.dart';
import '../../home_screen/controller/controller.dart'; // Import ProductController

class PrintController extends GetxController {
  final Rx<Printer?> selectedPrinter = Rx<Printer?>(null);
  RxList<Product> selectedProducts = <Product>[].obs;
  final RxDouble totalAmount = 0.0.obs;
  final String businessId;

  final RxString connectionStatus = ''.obs;
  ReceiptController? receiptController;
  final Rx<SystemSettings?> systemSettings = Rx<SystemSettings?>(null);
  final RxBool isLoadingSettings = false.obs;
  final RxString errorMessage = ''.obs;

  PrintController({
    required List<Product> initialProducts,
    required double initialTotal,
    required this.businessId,
  }) {
    selectedProducts.value = initialProducts;
    totalAmount.value = initialTotal;
  }

  void updateCartData(List<Product> products, double total) {
    selectedProducts.value = products.map((p) => Product(
      productId: p.productId,
      itemName: p.itemName,
      sellingPrice: p.sellingPrice,
      itemImage: p.itemImage,
      quantity: p.quantity, // Ensure quantity is copied
      cartItemId: p.cartItemId,
    )).toList();
    totalAmount.value = total;
    log('Updated cart in PrintController: ${products.length} items, total: $total');
  }

  Future<void> syncCartData(ProductController productController) async {
    await productController.fetchCartItems(); // Fetch latest cart items from API
    selectedProducts.value = productController.cartItems.map((p) => Product(
      productId: p.productId,
      itemName: p.itemName,
      sellingPrice: p.sellingPrice,
      itemImage: p.itemImage,
      quantity: p.quantity, // Use API-fetched quantity
      cartItemId: p.cartItemId,
    )).toList();
    totalAmount.value = selectedProducts.fold(
      0.0,
          (sum, p) => sum + ((p.sellingPrice ?? 0.0) * p.quantity),
    );
    log('Synced cart data with API: ${selectedProducts.length} items, total: ${totalAmount.value}');
  }

  void initializePrinterConnection(BuildContext context) {
    _loadSelectedPrinter(context);
    fetchSystemSettings();
  }

  Future<void> _loadSelectedPrinter(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('selected_printer_address');
    final name = prefs.getString('selected_printer_name');

    if (address != null) {
      selectedPrinter.value = Printer(address: address, name: name);
      log("Loaded saved printer: ${name ?? address}");

      connectionStatus.value = 'Connecting to saved printer...';
      _showConnectionStatusDialog(context);

      final isConnected = await FlutterBluetoothPrinter.connect(address);
      connectionStatus.value = isConnected ? 'Connected' : 'Failed to auto-connect';
      log(isConnected ? "Auto-connected to saved printer." : "Failed to auto-connect to saved printer.");
    }
  }

  Future<void> _saveSelectedPrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_printer_address', printer.address);
    await prefs.setString('selected_printer_name', printer.name ?? '');
    log("Saved printer: ${printer.name ?? printer.address}");
  }

  Future<void> selectBluetoothDevice(BuildContext context) async {
    final selected = await FlutterBluetoothPrinter.selectDevice(context);
    if (selected != null) {
      selectedPrinter.value = Printer(address: selected.address, name: selected.name);
      await _saveSelectedPrinter(selectedPrinter.value!);

      connectionStatus.value = 'Connecting...';
      _showConnectionStatusDialog(context);

      final isConnected = await FlutterBluetoothPrinter.connect(selected.address);
      connectionStatus.value = isConnected ? 'Connected' : 'Failed to connect';
    } else {
      log("Device selection canceled.");
    }
  }

  void _showConnectionStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Obx(() {
          return AlertDialog(
            title: const Text('Printer Connection'),
            content: Text(
              connectionStatus.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (connectionStatus.value != 'Connecting...')
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
            ],
          );
        });
      },
    );
  }

  Future<void> fetchSystemSettings() async {
    if (businessId.isEmpty) {
      errorMessage.value = 'Business ID is missing';
      return;
    }

    isLoadingSettings.value = true;
    errorMessage.value = '';

    final url = Uri.parse('${ApiConstants.listSystemSettingsEndPoint}?business_id=$businessId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final settings = SystemSettings.fromJsonResponse(response.body);
        if (settings != null) {
          systemSettings.value = settings;
          log('System settings fetched successfully.');
        } else {
          errorMessage.value = 'Invalid response format';
        }
      } else {
        errorMessage.value = 'Failed to fetch settings: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching settings: $e';
      log('Error fetching system settings: $e');
    } finally {
      isLoadingSettings.value = false;
    }
  }

  Future<bool> completeOrder(String cartId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.orderCompleteEndPoint),
        body: {
          'business_id': businessId,
          'cart_id': cartId,
          'status': 'Completed',
        },
      );

      log('Order Complete Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'Success') {
          log('Order marked as Completed successfully.');
          return true;
        } else {
          errorMessage.value = 'Failed to complete order: ${responseData['message'] ?? 'Unknown error'}';
          return false;
        }
      } else {
        errorMessage.value = 'Failed to complete order: ${response.statusCode} - ${response.body}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error completing order: $e';
      log('Error completing order: $e');
      return false;
    }
  }

  Future<void> printReceipt(BuildContext context, ProductController productController) async {
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
      log('Printing successful');

      // Call order_complete.php after successful print
      final cartId = productController.cartId.value;
      final orderCompleted = await completeOrder(cartId);

      if (orderCompleted) {
        // Clear cart only if order completion is successful
        await productController.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order completed and cart cleared')),
        );
        Navigator.of(context).pop(); // Close dialog or screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print successful but failed to complete order: ${errorMessage.value}')),
        );
      }
    } catch (e) {
      log('Printing failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing failed: $e')),
      );
    }
  }

  void setReceiptController(ReceiptController controller) {
    receiptController = controller;
  }
}
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';
import '../../home_screen/model/product_model.dart';
import '../model/print_model.dart';
import '../../home_screen/controller/controller.dart';

class PrintController extends GetxController {
  final Rx<Printer?> selectedPrinter = Rx<Printer?>(null);
  RxList<Product> selectedProducts = <Product>[].obs;
  final RxDouble totalAmount = 0.0.obs;
  final String businessId;

  final RxString connectionStatus = ''.obs;
  ReceiptController? receiptController;
  final Rx<SystemSettings?> systemSettings = Rx<SystemSettings?>(null);
  final RxBool isLoadingSettings = false.obs;
  final RxString errorMessage = ''.obs;

  PrintController({
    required List<Product> initialProducts,
    required double initialTotal,
    required this.businessId,
  }) {
    selectedProducts.value = initialProducts;
    totalAmount.value = initialTotal;
  }

  void updateCartData(List<Product> products, double total) {
    selectedProducts.value = products.map((p) => Product(
      productId: p.productId,
      itemName: p.itemName,
      sellingPrice: p.sellingPrice,
      itemImage: p.itemImage,
      quantity: p.quantity,
      cartItemId: p.cartItemId,
    )).toList();
    totalAmount.value = total;
    log('Updated cart in PrintController: ${products.length} items, total: $total');
  }

  Future<void> syncCartData(ProductController productController) async {
    await productController.fetchCartItems();
    selectedProducts.value = productController.cartItems.map((p) => Product(
      productId: p.productId,
      itemName: p.itemName,
      sellingPrice: p.sellingPrice,
      itemImage: p.itemImage,
      quantity: p.quantity,
      cartItemId: p.cartItemId,
    )).toList();
    totalAmount.value = selectedProducts.fold(
      0.0,
          (sum, p) => sum + ((p.sellingPrice ?? 0.0) * p.quantity),
    );
    log('Synced cart data with API: ${selectedProducts.length} items, total: ${totalAmount.value}');
  }

  void initializePrinterConnection(BuildContext context) {
    _loadSelectedPrinter(context);
    fetchSystemSettings();
  }

  Future<void> _loadSelectedPrinter(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('selected_printer_address');
    final name = prefs.getString('selected_printer_name');

    if (address != null) {
      selectedPrinter.value = Printer(address: address, name: name);
      log("Loaded saved printer: ${name ?? address}");

      connectionStatus.value = 'Connecting to saved printer...';
      _showConnectionStatusDialog(context);

      final isConnected = await FlutterBluetoothPrinter.connect(address);
      connectionStatus.value = isConnected ? 'Connected' : 'Failed to auto-connect';
      log(isConnected ? "Auto-connected to saved printer." : "Failed to auto-connect to saved printer.");
    }
  }

  Future<void> _saveSelectedPrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_printer_address', printer.address);
    await prefs.setString('selected_printer_name', printer.name ?? '');
    log("Saved printer: ${printer.name ?? printer.address}");
  }

  Future<void> selectBluetoothDevice(BuildContext context) async {
    final selected = await FlutterBluetoothPrinter.selectDevice(context);
    if (selected != null) {
      selectedPrinter.value = Printer(address: selected.address, name: selected.name);
      await _saveSelectedPrinter(selectedPrinter.value!);

      connectionStatus.value = 'Connecting...';
      _showConnectionStatusDialog(context);

      final isConnected = await FlutterBluetoothPrinter.connect(selected.address);
      connectionStatus.value = isConnected ? 'Connected' : 'Failed to connect';
    } else {
      log("Device selection canceled.");
    }
  }

  void _showConnectionStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Obx(() {
          return AlertDialog(
            title: const Text('Printer Connection'),
            content: Text(
              connectionStatus.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (connectionStatus.value != 'Connecting...')
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
            ],
          );
        });
      },
    );
  }

  Future<void> fetchSystemSettings() async {
    if (businessId.isEmpty) {
      errorMessage.value = 'Business ID is missing';
      return;
    }
    isLoadingSettings.value = true;
    errorMessage.value = '';

    final url = Uri.parse('${ApiConstants.listSystemSettingsEndPoint}?business_id=$businessId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final settings = SystemSettings.fromJsonResponse(response.body);
        if (settings != null) {
          systemSettings.value = settings;
          log('System settings fetched successfully.');
        } else {
          errorMessage.value = 'Invalid response format';
        }
      } else {
        errorMessage.value = 'Failed to fetch settings: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching settings: $e';
      log('Error fetching system settings: $e');
    } finally {
      isLoadingSettings.value = false;
    }
  }

  Future<bool> completeOrder(String cartId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.orderCompleteEndPoint),
        body: {
          'business_id': businessId,
          'cart_id': cartId,
          'status': 'Completed',
        },
      );

      log('Order Complete Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'Success') {
          log('Order marked as Completed successfully.');
          return true;
        } else {
          errorMessage.value = 'Failed to complete order: ${responseData['message'] ?? 'Unknown error'}';
          return false;
        }
      } else {
        errorMessage.value = 'Failed to complete order: ${response.statusCode} - ${response.body}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error completing order: $e';
      log('Error completing order: $e');
      return false;
    }
  }
  /*Future<void> printReceipt(BuildContext context, ProductController productController) async {
    if (selectedPrinter.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a printer first')),         //Prints only when bluetooth connected
      );
      return;
    }

    try {
      await receiptController?.print(
        address: selectedPrinter.value!.address,
        keepConnected: true,
        addFeeds: 4,
      );
      log('Printing successful');

      // Call order_complete.php after successful print
      final cartId = productController.cartId.value;
      final orderCompleted = await completeOrder(cartId);

      if (orderCompleted) {
        // Reset UI cart instead of clearing API cart
        productController.resetUICart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order completed and UI cart reset')),
        );
        Navigator.of(context).pop(); // Close dialog or screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print successful but failed to complete order: ${errorMessage.value}')),
        );
      }
    } catch (e) {
      log('Printing failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing failed: $e')),
      );
    }
  }*/
  /*Future<void> printReceipt(BuildContext context, ProductController productController) async {
    bool printSuccess = false;

    try {
      if (selectedPrinter.value == null) {
        log('No printer selected. Skipping print.');
      } else {
        await receiptController?.print(
          address: selectedPrinter.value!.address,
          keepConnected: true,
          addFeeds: 4,
        );
        printSuccess = true;
        log('Printing successful');
      }
    } catch (e) {
      log('Printing failed: $e');
    }

    // ✔ ALWAYS CALL completeOrder — no matter what
    final cartId = productController.cartId.value;
    final orderCompleted = await completeOrder(cartId);

    if (orderCompleted) {
      productController.resetUICart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            printSuccess
                ? 'Printed & Order Completed'
                : 'Printer not connected, but Order Completed',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order not completed: ${errorMessage.value}')),
      );
    }
  }*/                                                                                 //YESTERDAY
  Future<void> printReceipt(BuildContext context, ProductController productController) async {
    bool printSuccess = false;

    try {
      if (selectedPrinter.value != null) {
        await receiptController?.print(
          address: selectedPrinter.value!.address,
          keepConnected: true,
          addFeeds: 4,
        );
        printSuccess = true;
        log('Printing successful');
      } else {
        log('No printer selected → Skipping print (still completing order)');
      }
    } catch (e) {
      log('Print failed: $e');
    }
    // Always reset UI cart after user tried to print (intent was to finish sale)
    productController.resetUICart();
    Get.snackbar(
      'Success',
      printSuccess
          ? 'Printed & Order Completed'
          : 'Order Completed (No Printer Connected)',
      backgroundColor: printSuccess ? Colors.green : Colors.orange,
      colorText: Colors.white,
    );
    Navigator.of(context).pop(); // Close PrintScreen
  }
  void setReceiptController(ReceiptController controller) {
    receiptController = controller;
  }
}*/
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer_plus/commands/print_builder.dart';
import 'package:flutter_thermal_printer_plus/flutter_thermal_printer_plus.dart';
import 'package:flutter_thermal_printer_plus/commands/esc_pos_commands.dart';
import 'package:flutter_thermal_printer_plus/models/paper_size.dart';
import 'package:flutter_thermal_printer_plus/models/printer_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '../../api_endpoints.dart';
import '../../home_screen/controller/controller.dart';
import '../../home_screen/model/product_model.dart';
import '../model/print_model.dart';

class PrintController extends GetxController {
  final Rx<Printer?> selectedPrinter = Rx<Printer?>(null);
  final Rx<PrinterInfo?> selectedPrinterInfo = Rx<PrinterInfo?>(null);
  final RxString connectionStatus = 'Not Connected'.obs;
  final RxBool isScanning = false.obs;
  final RxBool isPrinting = false.obs; // ← NEW

  final RxList<Product> cartItems = <Product>[].obs;
  final RxDouble totalAmount = 0.0.obs;

  final String businessId;
  final Rx<SystemSettings?> systemSettings = Rx<SystemSettings?>(null);
  final RxBool isLoadingSettings = false.obs;
  final RxString errorMessage = ''.obs;

  PrintController({
    required this.businessId,
    required List<Product> initialProducts,
    required double initialTotal,
  }) {
    cartItems.assignAll(initialProducts);
    totalAmount.value = initialTotal;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedPrinter();
    fetchSystemSettings();
  }
  @override
  void onClose() {
    Get.closeAllSnackbars();
    if (Get.isDialogOpen == true) Get.back();
    super.onClose();
  }
  // ==================== PRINTER CONNECTION ====================
  Future<void> _loadSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = prefs.getString('printer_address');
      final name = prefs.getString('printer_name');

      if (address != null && address.isNotEmpty) {
        selectedPrinter.value = Printer(address: address, name: name);
        selectedPrinterInfo.value = PrinterInfo(
          address: address,
          name: name ?? "Saved Printer",
          type: ConnectionType.bluetooth,
        );
        await _tryReconnect();
      }
    } catch (e) {
      log("Failed to load saved printer: $e");
    }
  }

  Future<void> _tryReconnect() async {
    final printer = selectedPrinterInfo.value;
    if (printer == null) return;
    connectionStatus.value = "Reconnecting...";
    final connected = await _connectSafely(printer);
    connectionStatus.value = connected ? "Connected" : "Offline";
  }

  /*Future<bool> _connectSafely(PrinterInfo printer) async {
    try {
      return await FlutterThermalPrinterPlus.connectBluetooth(printer.address) ?? false;
    } catch (e) {
      log("Connect failed: $e");
      return false;
    }
  }*/

  Future<void> _savePrinter(Printer printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_address', printer.address);
    await prefs.setString('printer_name', printer.name ?? '');
  }

  Future<bool> _requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    bool allGranted = statuses.values.every((s) => s.isGranted || s.isLimited);
    if (!allGranted) {
      openAppSettings();
      Get.snackbar("Permission Denied", "Bluetooth & Location permissions required");
    }
    return allGranted;
  }

  Future<void> selectBluetoothDevice(BuildContext context) async {
    if (isScanning.value) return;

    isScanning.value = true;
    final hasPermission = await _requestBluetoothPermissions();
    if (!hasPermission) {
      isScanning.value = false;
      return;
    }

    List<PrinterInfo> devices = [];
    try {
      devices = await FlutterThermalPrinterPlus.scanBluetoothDevices() ?? [];
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Scan failed, please turn on Bluetooth",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      isScanning.value = false;
      return;
    }

    isScanning.value = false;

    if (devices.isEmpty) {
      Fluttertoast.showToast(
        msg: "No printers found, try again",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    // This will hold which device is being connected (for UI)
    final connectingDevice = ValueNotifier<PrinterInfo?>(null);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ValueListenableBuilder<PrinterInfo?>(
          valueListenable: connectingDevice,
          builder: (context, connecting, _) {
            final isConnecting = connecting != null;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 150),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isConnecting ? Icons.bluetooth_searching : Icons.print,
                          color: isConnecting ? Colors.blue : Colors.blueGrey,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isConnecting ? "Connecting to Printer" : "Available Printers",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body: Either list or connecting screen
                  Flexible(
                    child: isConnecting
                        ? _buildConnectingUI(connecting!)
                        : _buildDevicesList(devices, connectingDevice,),
                  ),

                  // Footer: Only show when NOT connecting
                  if (!isConnecting)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConnectingUI(PrinterInfo device) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade700,
                  ),
                ),
              ),
              Icon(
                Icons.bluetooth,
                size: 36,
                color: Colors.blue.shade700,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            device.name ?? "Unknown Device",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            device.address,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            "Connecting...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Keep the printer powered ON and in range",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 2,),
          Text(
            "If already connected please close this dialog",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(
      List<PrinterInfo> devices,
      ValueNotifier<PrinterInfo?> processingDevice,
      ) {
    return ValueListenableBuilder<PrinterInfo?>(
      valueListenable: processingDevice,
      builder: (context, processing, _) {
        return Column(
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${devices.length} printer${devices.length != 1 ? 's' : ''} found nearby",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Device list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: devices.length,
                itemBuilder: (_, i) {
                  final device = devices[i];
                  final isConnected = selectedPrinter.value?.address == device.address;
                  final isProcessingThis = processing?.address == device.address;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isConnected
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      color: isConnected
                          ? Colors.green.shade50
                          : isProcessingThis
                          ? Colors.blue.shade50
                          : Colors.white,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? Colors.green.shade100
                              : isProcessingThis
                              ? Colors.blue.shade100
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isProcessingThis ? Icons.bluetooth_searching : Icons.print,
                          color: isConnected
                              ? Colors.green.shade800
                              : isProcessingThis
                              ? Colors.blue.shade700
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.name ?? "Unknown Printer",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isConnected
                                    ? Colors.green.shade800
                                    : Colors.grey.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green.shade800,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Connected",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isProcessingThis)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Connecting",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            device.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (isConnected)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Tap to disconnect",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Transform.scale(
                        scale: 1.2,
                        child: Switch(
                          value: isConnected,
                          activeColor: Colors.green,
                          activeTrackColor: Colors.green.shade300,
                          inactiveThumbColor: Colors.grey.shade600,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: isProcessingThis
                              ? null
                              : (bool turnOn) async {
                            processingDevice.value = device;

                            if (turnOn) {
                              final success = await _connectSafely(device);

                              if (!context.mounted) return;

                              if (success) {
                                selectedPrinter.value = Printer(
                                  address: device.address,
                                  name: device.name,
                                );

                                selectedPrinterInfo.value = device;
                                await _savePrinter(selectedPrinter.value!);
                                connectionStatus.value = "Connected";

                                Fluttertoast.showToast(
                                  msg: "Connected successfully ready to use ${device.name}",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );

                              } else {
                                connectionStatus.value = "Failed";

                                Fluttertoast.showToast(
                                  msg: "Connection Failed: Could not connect to ${device.name}",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );

                              }
                            } else {
                              if (isConnected) {
                                await _disconnectSafely();

                                if (!context.mounted) return;

                                selectedPrinter.value = null;
                                selectedPrinterInfo.value = null;
                                connectionStatus.value = "Disconnected";

                                Fluttertoast.showToast(
                                  msg: "Disconnected ${device.name}",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );

                              }
                            }

                            processingDevice.value = null;
                          },
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabled: !isProcessingThis,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  /*Future<bool> _connectSafely(PrinterInfo device) async {
    try {
      final success = await FlutterThermalPrinterPlus.connectBluetooth(device.address);
      return success == true;
    } catch (e, s) {
      print("Bluetooth Connect Error: $e\n$s");
      return false;
    }
  }*/

  Future<bool> _connectSafely(PrinterInfo device) async {
    try {
      // Try plugin's normal method first
      final success = await FlutterThermalPrinterPlus.connectBluetooth(device.address);
      if (success == true) return true;
    } catch (e) {
      print("Plugin connect failed, trying fallback: $e");
    }

    // Fallback to our safe native method
    const platform = MethodChannel('flutter_thermal_printer_plus');
    try {
      final bool result = await platform.invokeMethod('connectViaFallback', {
        'address': device.address,
      });
      return result;
    } catch (e) {
      print("Fallback also failed: $e");
      return false;
    }
  }


  Future<void> _disconnectSafely() async {
    try {
      await FlutterThermalPrinterPlus.disconnectBluetooth();
    } catch (e) {
      print("Disconnect Error: $e");
    }
  }

/*
  Future<void> selectBluetoothDevice(BuildContext context) async {

    if (isScanning.value) return;

    isScanning.value = true;

    final hasPermission = await _requestBluetoothPermissions();

    if (!hasPermission) {

      isScanning.value = false;

      return;

    }

    List<PrinterInfo> devices = [];

    try {

      devices = await FlutterThermalPrinterPlus.scanBluetoothDevices() ?? [];

    } catch (e) {

      Get.snackbar("Scan Failed", "$e");

      isScanning.value = false;

      return;

    }

    isScanning.value = false;

    if (devices.isEmpty) {

      Get.snackbar("No Printers Found", "Turn on printer and try again");

      return;

    }

    // Create reactive maps OUTSIDE the build scope

    final connectingMap = <String, RxBool>{};

    final connectedMap = <String, RxBool>{};

    for (var d in devices) {

      final addr = d.address;

      connectingMap[addr] = false.obs;

      connectedMap[addr] = (selectedPrinterInfo.value?.address == addr && connectionStatus.value == "Connected").obs;

    }

    // Create a single controller to force rebuild

    final refreshTrigger = false.obs;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Create reactive connecting states once
        final Map<String, RxBool> isConnectingMap = {
          for (var d in devices) d.address: false.obs
        };

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          title: Row(
            children: [
              Icon(Icons.print, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Select Thermal Printer",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Obx(() => isScanning.value
                  ? const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
                  : const SizedBox.shrink()),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 460,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: devices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final device = devices[index];
                final address = device.address;

                // Each tile listens only to its own connecting state + global selected printer
                return Obx(() {
                  final isConnecting = isConnectingMap[address]!.value;
                  final isConnected = selectedPrinterInfo.value?.address == address;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: isConnected
                          ? Colors.green.withOpacity(0.18)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isConnected ? Colors.green.shade400 : Colors.grey.shade300,
                        width: isConnected ? 1.8 : 1,
                      ),
                      boxShadow: isConnected
                          ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: isConnected
                            ? Colors.green.withOpacity(0.25)
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.print,
                          size: 30,
                          color: isConnected ? Colors.green.shade800 : Colors.grey.shade700,
                        ),
                      ),
                      title: Text(
                        device.name ?? "Unknown Printer",
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: isConnected ? FontWeight.bold : FontWeight.w600,
                          color: isConnected ? Colors.green.shade900 : Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isConnecting)
                              const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              ),
                            if (isConnected && !isConnecting)
                              Row(
                                children: [
                                  //Icon(Icons.check_circle, size: 20, color: Colors.green.shade600),
                                  const SizedBox(width: 6),
                                  Text("Connected",
                                      style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      trailing: Switch(
                        value: isConnected,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green.shade600,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade300,
                        onChanged: isConnecting
                            ? null
                            : (bool turnOn) async {
                          // Prevent any crash from escaping
                          try {
                            // Set connecting state immediately
                            isConnectingMap[address]!.value = true;

                            if (turnOn) {
                              // Attempt connection with full safety
                              bool success = false;
                              try {
                                success = await _connectSafely(device). timeout(
                                  Duration(seconds: 12), // Prevent hanging forever
                                  onTimeout: () => false,
                                );
                              } catch (e) {
                                print("Connection error: $e");
                                success = false;
                              }

                              if (success) {
                                selectedPrinter.value = Printer(address: address, name: device.name);
                                selectedPrinterInfo.value = device;
                                connectionStatus.value = "Connected";
                                await _savePrinter(selectedPrinter.value!);

                                Get.snackbar(
                                  "Connected",
                                  "${device.name ?? "Printer"} connected successfully",
                                  backgroundColor: Colors.green.shade600,
                                  colorText: Colors.white,
                                  duration: Duration(seconds: 2),
                                );
                              } else {
                                // Auto turn off switch if failed
                                selectedPrinter.value = null;
                                selectedPrinterInfo.value = null;
                                connectionStatus.value = "Not Connected";

                                /*Get.snackbar(
                                  "Connection Failed",
                                  "Could not connect to ${device.name ?? "printer"}",
                                  backgroundColor: Colors.red.shade600,
                                  colorText: Colors.white,
                                );*/
                              }
                            } else {
                              // Disconnect path
                              try {
                                await FlutterThermalPrinterPlus.disconnectBluetooth();
                              } catch (e) {
                                print("Disconnect error: $e");
                              }

                              if (selectedPrinterInfo.value?.address == address) {
                                selectedPrinter.value = null;
                                selectedPrinterInfo.value = null;
                                connectionStatus.value = "Not Connected";

                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('printer_address');
                                await prefs.remove('printer_name');
                              }

                              //Get.snackbar("Disconnected", "Printer disconnected successfully",
                                //  backgroundColor: Colors.orange.shade600, colorText: Colors.white);
                            }
                          } catch (e, stack) {
                            // This catches ANY unexpected error (should never happen, but now safe)
                            debugPrint("Unexpected error in printer selection: $e\n$stack");
                            //Get.snackbar("Error", "Something went wrong. Please try again.");
                          } finally {
                            // Always reset connecting state, even if crashed
                            if (isConnectingMap[address] != null) {
                              isConnectingMap[address]!.value = false;
                            }
                          }
                        },
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          actions: [
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text("Close", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );

  }*/

  // ==================== DATA & ORDER ====================
  Future<void> syncCartData(ProductController controller) async {
    await controller.fetchCartItems();
    cartItems.assignAll(controller.cartItems);
    totalAmount.value = cartItems.fold(0.0, (sum, p) => sum + (p.sellingPrice ?? 0) * p.quantity);
  }

  Future<void> fetchSystemSettings() async {
    isLoadingSettings.value = true;
    try {
      final url = Uri.parse('${ApiConstants.listSystemSettingsEndPoint}?business_id=$businessId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('....................${response.body}');
        systemSettings.value = SystemSettings.fromJsonResponse(response.body);
      }
    } catch (e) {
      //errorMessage.value = "Failed to load shop settings";
    } finally {
      isLoadingSettings.value = false;
    }
  }

  Future<bool> completeOrder(String cartId) async {
    if (cartId.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.orderCompleteEndPoint),
        body: {'business_id': businessId, 'cart_id': cartId, 'status': 'Completed'},
      );
      final data = jsonDecode(response.body);
      return data['status'] == 'Success';
    } catch (e) {
      return false;
    }
  }

  // ==================== MAIN: AUTO PRINT RECEIPT ====================
  Future<bool> printCurrentReceipt() async {
    final productController = Get.find<ProductController>();
    return await _print80mmReceipt(this, productController);
  }

  // ==================== PERFECT 80MM RECEIPT (NOW INSIDE CONTROLLER) ====================
  Future<bool> _print80mmReceipt(PrintController pc, ProductController prod) async {
    final settings = pc.systemSettings.value;
    if (settings == null) return false;

    // Check if printer is connected
    final isConnected = await FlutterThermalPrinterPlus.isConnected();
    if (!isConnected) {
      debugPrint("Printer not connected");
      Fluttertoast.showToast(
        msg: "Printer Not Connected, Please connect to printer first",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    final builder = PrintBuilder(PaperSize.mm80);
    final date = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    // Helper: Smart word wrap for item names
    List<String> wrap(String text, int max) {
      final words = text.split(' ');
      final lines = <String>[];
      String current = '';
      for (var word in words) {
        if ((current + word).length > max) {
          lines.add(current.trim());
          current = '$word ';
        } else {
          current += '$word ';
        }
      }
      if (current.isNotEmpty) lines.add(current.trim());
      return lines;
    }

    // Helper: Format numbers with right alignment
    String formatRight(String value, int width) {
      if (value.length > width) return value.substring(0, width);
      return value.padLeft(width);
    }

    // Helper: Format left-aligned text
    String formatLeft(String value, int width) {
      if (value.length > width) return value.substring(0, width);
      return value.padRight(width);
    }

    // Print Logo
    try {
      if (settings.billLogo.isNotEmpty) {
        debugPrint("Downloading logo from: ${settings.billLogo}");
        final response = await http.get(Uri.parse(settings.billLogo));
        if (response.statusCode == 200) {
          final imageBytes = response.bodyBytes;
          debugPrint("Logo downloaded, size: ${imageBytes.length} bytes");

          final decodedImage = img.decodeImage(imageBytes);
          if (decodedImage != null) {
            debugPrint("Image decoded: ${decodedImage.width}x${decodedImage.height}");

            // Resize to fit 80mm paper
            final resized = img.copyResize(decodedImage, width: 384);
            debugPrint("Image resized to: ${resized.width}x${resized.height}");

            // Convert to grayscale then to 1-bit bitmap
            final grayscale = img.grayscale(resized);
            final bitmap = _convertTo1BitBitmap(grayscale, threshold: 200);
            debugPrint("Bitmap created: ${bitmap.length} bytes");

            // Center and print logo
            builder.text("", align: AlignPos.center);
            final escCommand = ESCPOSCommands.printRasterImage(bitmap, resized.width, resized.height);
            builder.addRawBytes(escCommand);
            builder.feed(1);
            debugPrint("Logo added to receipt");
          }
        }
      }
    } catch (e) {
      debugPrint("Logo print error (continuing without logo): $e");
    }

    builder
    // Print wrapped address instead of single text line
    ..feed(1);
    final wrappedAddress = wrapAddressSafely(settings.billAddress, 35);
    for (final line in wrappedAddress) {
      builder.text(line, align: AlignPos.center, fontSize: FontSize.normal, bold: true);
    }
    // Header text
    builder
      //..text(settings.billAddress, align: AlignPos.center, fontSize: FontSize.normal, bold: true)
      //..text(settings.firmName.toUpperCase(), align: AlignPos.center, fontSize: FontSize.big, bold: true)
      ..text("Ph ${settings.firmContact1}${settings.firmContact2.isNotEmpty ? ', ${settings.firmContact2}' : ''}", align: AlignPos.center)
      ..text("GSTIN: ${settings.billGstinNum}", align: AlignPos.center)
      //..feed(1)
      ..line(char: '=')
      ..text("Invoice: ${prod.finalInvoiceId.value}", align: AlignPos.left)
      ..text("Date   : $date", align: AlignPos.left)
      ..text("Customer: ${prod.customerName.value}", align: AlignPos.left)
      ..text("Mobile : ${prod.customerMobileNumber.value}", align: AlignPos.left)
      ..line(char: '-');

    // Table Header with # - RIGHT ALIGNED VALUES
    builder
      ..text(
          "${formatLeft("#", 4)} ${formatLeft("Item", 20)} ${formatRight("Price", 5)} ${formatRight("Qty", 5)} ${formatRight("Total", 7)}",
          bold: true
      )
      ..line(char: '-');

    // Items with serial numbers starting from 1
    for (int i = 0; i < prod.cartItems.length; i++) {
      final item = prod.cartItems[i];
      final index = (i + 1).toString(); // Serial number starts from 1
      final name = item.itemName ?? "Unknown";
      final price = (item.sellingPrice ?? 0).toStringAsFixed(2);
      final qty = item.quantity.toString();
      final total = ((item.sellingPrice ?? 0) * item.quantity).toStringAsFixed(2);

      // Wrap long product names (22 chars max for name column)
      final lines = wrap(name, 22);
      for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        if (lineIndex == 0) {
          // First line: include serial #, name, and all values
          builder.text(
              "${formatLeft(index, 4)} ${formatLeft(lines[lineIndex], 20)} ${formatRight(price, 5)} ${formatRight(qty, 4)} ${formatRight(total, 9)}"
          );
        } else {
          // Continuation lines: only name (with indentation)
          builder.text("   ${formatLeft(lines[lineIndex], 24)} ${formatRight("", 8)} ${formatRight("", 6)} ${formatRight("", 8)}");
        }
      }

      // Add a small space between items if not last item
      if (i < prod.cartItems.length - 1) {
        builder.text("");
      }
    }

    // Totals section
    builder
      ..line(char: '-')
      ..text("${formatLeft("Sub Total", 32)}${formatRight(prod.totalAmount.value.toStringAsFixed(2), 14)}")
      ..text("${formatLeft("GST", 32)}${formatRight(prod.gstAmount.value.toStringAsFixed(2), 14)}")
      ..text("${formatLeft("Round Off", 32)}${formatRight(prod.roundOff.value.toStringAsFixed(2), 14)}")
      ..line(char: '=')
      ..text("${formatLeft("GRAND TOTAL", 32)}${formatRight((prod.totalAmount.value + prod.gstAmount.value + prod.roundOff.value).toStringAsFixed(2), 14)}",
          bold: true, fontSize: FontSize.normal)
      ..text("${formatLeft("Total Items", 32)}${formatRight((prod.cartItems.length).toStringAsFixed(2), 14)}",
          bold: true, fontSize: FontSize.normal)
    //..text("Total Items: ${prod.cartItems.length}", bold: true)
      ..line(char: '=');
      //..feed(1)
      //..text("${settings.quote}", align: AlignPos.center, bold: true, fontSize: FontSize.normal);
    builder;
    // Print wrapped address instead of single text line
    //..feed(1);
    final wrappedQuote = wrapAddressSafely(settings.quote, 43);
    for (final line in wrappedQuote) {
      builder.text(line, align: AlignPos.center, fontSize: FontSize.normal, bold: true);
    }
    builder
      ..cut();

    try {
      debugPrint("Sending print job...");
      final result = await FlutterThermalPrinterPlus.print(builder);
      debugPrint("Print result: $result");
      return result;
    } catch (e) {
      debugPrint("Print failed: $e");

      Fluttertoast.showToast(
        msg: "Print error", //$e
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }
  List<String> wrapAddressSafely(String text, int maxLength) {
    final words = text.split(' ');
    final lines = <String>[];
    String currentLine = '';

    for (var word in words) {
      // If this word cannot fit in the current line → move to next line
      if ((currentLine.isEmpty ? 0 : currentLine.length + 1) + word.length > maxLength) {
        if (currentLine.isNotEmpty) lines.add(currentLine);
        currentLine = word;
      } else {
        currentLine += (currentLine.isEmpty ? word : ' $word');
      }
    }

    if (currentLine.isNotEmpty) lines.add(currentLine);

    return lines;
  }
  List<String> _wrap(String text, int len) {
    List<String> lines = [];
    String s = text;
    while (s.isNotEmpty) {
      if (s.length <= len) {
        lines.add(s.padRight(len));
        break;
      }
      lines.add(s.substring(0, len));
      s = s.substring(len);
    }
    return lines;
  }

  Uint8List _to1Bit(img.Image img, {int threshold = 180}) {
    final w = img.width;
    final h = img.height;
    final bpr = (w + 7) ~/ 8;
    final data = Uint8List(bpr * h);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = img.getPixel(x, y);
        final gray = (p.r * 0.299 + p.g * 0.587 + p.b * 0.114).toInt();
        if (gray < threshold) {
          data[y * bpr + (x ~/ 8)] |= (0x80 >> (x % 8));
        }
      }
    }
    return data;
  }
  Uint8List _convertTo1BitBitmap(img.Image image, {int threshold = 128}) {
    final width = image.width;
    final height = image.height;
    final bytesPerRow = (width + 7) ~/ 8;
    final bitmap = Uint8List(bytesPerRow * height);

    int blackPixels = 0;
    int minGray = 255;
    int maxGray = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        // Calculate luminance
        final gray = (r * 0.299 + g * 0.587 + b * 0.114).round();
        if (gray < minGray) minGray = gray;
        if (gray > maxGray) maxGray = gray;

        // Use threshold (darker = black, lighter = white)
        final isBlack = gray < threshold;

        if (isBlack) {
          blackPixels++;
          final byteIndex = y * bytesPerRow + (x ~/ 8);
          final bitIndex = 7 - (x % 8); // MSB first (bit 7 = leftmost)
          bitmap[byteIndex] |= (1 << bitIndex);
        }
      }
    }
    debugPrint("Bitmap: $blackPixels black pixels out of ${width * height} total");
    debugPrint("Gray range: $minGray to $maxGray (threshold: $threshold)");
    return bitmap;
  }
  List<int> _printColumnImage(Uint8List bitmap, int width, int height) {
    final command = <int>[];

    // Set line spacing to 0
    command.addAll([0x1B, 0x33, 0x00]); // ESC 3 0

    // ESC * - Select bit-image mode
    command.addAll([0x1B, 0x2A]); // ESC *
    command.add(0x21); // m = 33 (24-dot double-density)

    // Width in dots (not bytes)
    command.addAll([width & 0xFF, (width >> 8) & 0xFF]); // nL nH

    // Image data (entire bitmap)
    command.addAll(bitmap);

    // Line feed
    command.add(0x0A);

    // Reset line spacing
    command.addAll([0x1B, 0x32]); // ESC 2

    return command;
  }
}