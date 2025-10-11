/*
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import '../../home_screen/controller/controller.dart';
import '../../home_screen/model/product_model.dart';
import '../controller/print_controller.dart';

class PrintScreen extends StatelessWidget {
  final List<Product> initialProducts;
  final double initialTotal;
  final String businessId;

  const PrintScreen({
    Key? key,
    required this.initialProducts,
    required this.initialTotal,
    required this.businessId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final printController = Get.put(PrintController(
      initialProducts: initialProducts,
      initialTotal: initialTotal,
      businessId: businessId,
    ));
    final productController = Get.find<ProductController>();

    // Sync cart data on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await printController.syncCartData(productController);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Receipt'),
      ),
      body: Column(
        children: [
          Obx(() {
            final printer = printController.selectedPrinter.value;
            if (printer == null) {
              return const SizedBox.shrink();
            }
            return FutureBuilder<bool>(
              future: FlutterBluetoothPrinter.connect(printer.address),
              builder: (context, snapshot) {
                bool isConnected = snapshot.data ?? false;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Lottie.asset(
                          isConnected ? 'assets/active.json' : 'assets/inactive.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Selected Printer: ${printer.name ?? printer.address}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          Obx(() {
            if (printController.isLoadingSettings.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (printController.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Error: ${printController.errorMessage.value}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: printController.fetchSystemSettings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              final settings = printController.systemSettings.value;
              final cartItems = productController.cartItems; // Use cartItems directly for API quantities
              if (settings == null) {
                return const Center(child: Text('Loading receipt data...'));
              }
              return Receipt(
                builder: (context) {
                  var now = DateTime.now();
                  var formatter = DateFormat('dd/MM/yyyy hh:mm:ss a');
                  String formattedDate = formatter.format(now);
                  double discountAmt = (printController.totalAmount.value * 0.1).ceilToDouble();
                  double grandAmt = printController.totalAmount.value - discountAmt;
                  double givenAmount = 700.00;
                  double returnAmount = givenAmount - grandAmt;

                  List<String> splitText(String text, int maxLength) {
                    List<String> lines = [];
                    if (text.length <= maxLength) {
                      lines.add(text);
                      return lines;
                    }
                    while (text.isNotEmpty) {
                      if (text.length <= maxLength) {
                        lines.add(text);
                        break;
                      }
                      int splitIndex = text.substring(0, maxLength).lastIndexOf(' ');
                      if (splitIndex == -1 || splitIndex < maxLength ~/ 2) {
                        splitIndex = maxLength;
                      }
                      lines.add(text.substring(0, splitIndex));
                      text = text.substring(splitIndex).trim();
                    }
                    return lines;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          settings.firmName,
                          style: GoogleFonts.merriweather(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          'CONTACT : ${settings.firmContact1} ${settings.firmContact2}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          settings.billAddress,
                          style: GoogleFonts.merriweather(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          'GSTIN : ${settings.billGstinNum}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                            'INVOICE ID : ${productController.finalInvoiceId.value}',
                            style: TextStyle(fontSize: 17),
                          )),
                          /*Obx(() => Text(
                            productController.finalInvoiceId.value, // Dynamic final_invoice_id
                            style: TextStyle(fontSize: 17),
                          )),*/
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('DATE: $formattedDate', style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 6),
                      Obx(() {
                        final customerName = productController.customerName.value;
                        final nameLines = splitText(customerName, 20);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: nameLines.map((line) => Text(
                            nameLines.first == line ? 'CUSTOMER NAME : $line' : line,
                            style: const TextStyle(fontSize: 16),
                          )).toList(),
                        );
                      }),
                      const SizedBox(height: 6),
                      Obx(() => Text(
                        'MOBILE : ${productController.customerMobileNumber.value}',
                        style: const TextStyle(fontSize: 17),
                      )),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '#',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              'ITEMS',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'AMOUNT',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'QTY',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'TOTAL',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      ...cartItems.asMap().entries.expand((entry) {
                        int idx = entry.key;
                        Product product = entry.value;
                        double itemTotal = (product.sellingPrice ?? 0) * product.quantity;
                        final itemName = product.itemName ?? 'Unknown';
                        final itemNameLines = splitText(itemName, 20);
                        return itemNameLines.asMap().entries.map((lineEntry) {
                          int lineIdx = lineEntry.key;
                          String line = lineEntry.value;
                          return Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  lineIdx == 0 ? '${idx + 1}' : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  line,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  lineIdx == 0 ? '${(product.sellingPrice ?? 0).toStringAsFixed(2)}(1Kg)' : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lineIdx == 0 ? 'x${product.quantity}' : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  lineIdx == 0 ? itemTotal.toStringAsFixed(2) : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ],
                          );
                        });
                      }),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 10),
                      const Text('Total', style: TextStyle(fontSize: 19)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('General Items:', style: TextStyle(fontSize: 16)),
                          Text(
                            '${cartItems.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text(
                            'TOTAL:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                          Text(
                            printController.totalAmount.value.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                      const Divider(color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('DISCOUNT (10%):', style: TextStyle(fontSize: 16)),
                          Text(
                            discountAmt.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                          Text(
                            grandAmt.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Given Amount:', style: TextStyle(fontSize: 16)),
                          Text(
                            givenAmount.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('RETURN Amount:', style: TextStyle(fontSize: 16)),
                          Text(
                            returnAmount.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Thank You.. Visit Again..!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  );
                },
                onInitialized: (controller) {
                  printController.setReceiptController(controller);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => printController.selectBluetoothDevice(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Select Device",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await printController.syncCartData(productController); // Sync before printing
                  await printController.printReceipt(context, productController);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Print",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import '../../home_screen/controller/controller.dart';
import '../../home_screen/model/product_model.dart';
import '../controller/print_controller.dart';

class PrintScreen extends StatelessWidget {
  final List<Product> initialProducts;
  final double initialTotal;
  final String businessId;

  const PrintScreen({
    Key? key,
    required this.initialProducts,
    required this.initialTotal,
    required this.businessId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final printController = Get.put(PrintController(
      initialProducts: initialProducts,
      initialTotal: initialTotal,
      businessId: businessId,
    ));
    final productController = Get.find<ProductController>();

    // Sync cart data on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await printController.syncCartData(productController);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Receipt'),
      ),
      body: Column(
        children: [
          Obx(() {
            final printer = printController.selectedPrinter.value;
            if (printer == null) {
              return const SizedBox.shrink();
            }
            return FutureBuilder<bool>(
              future: FlutterBluetoothPrinter.connect(printer.address),
              builder: (context, snapshot) {
                bool isConnected = snapshot.data ?? false;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Lottie.asset(
                          isConnected ? 'assets/active.json' : 'assets/inactive.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Selected Printer: ${printer.name ?? printer.address}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          Obx(() {
            if (printController.isLoadingSettings.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (printController.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Error: ${printController.errorMessage.value}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: printController.fetchSystemSettings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              final settings = printController.systemSettings.value;
              final cartItems = productController.cartItems;
              if (settings == null) {
                return const Center(child: Text('Loading receipt data...'));
              }
              return Receipt(
                builder: (context) {
                  var now = DateTime.now();
                  var formatter = DateFormat('dd/MM/yyyy hh:mm:ss a');
                  String formattedDate = formatter.format(now);
                  double discountAmt = (printController.totalAmount.value * 0.1).ceilToDouble();
                  double grandAmt = printController.totalAmount.value - discountAmt;
                  double givenAmount = 700.00;
                  double returnAmount = givenAmount - grandAmt;

                  List<String> splitText(String text, int maxLength) {
                    List<String> lines = [];
                    if (text.length <= maxLength) {
                      lines.add(text);
                      return lines;
                    }
                    while (text.isNotEmpty) {
                      if (text.length <= maxLength) {
                        lines.add(text);
                        break;
                      }
                      int splitIndex = text.substring(0, maxLength).lastIndexOf(' ');
                      if (splitIndex == -1 || splitIndex < maxLength ~/ 2) {
                        splitIndex = maxLength;
                      }
                      lines.add(text.substring(0, splitIndex));
                      text = text.substring(splitIndex).trim();
                    }
                    return lines;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          settings.firmName,
                          style: GoogleFonts.merriweather(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          'CONTACT : ${settings.firmContact1} ${settings.firmContact2}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          settings.billAddress,
                          style: GoogleFonts.merriweather(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          'GSTIN : ${settings.billGstinNum}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                            'INVOICE ID : ${productController.finalInvoiceId.value}',
                            style: TextStyle(fontSize: 17),
                          )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('DATE: $formattedDate', style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 6),
                      Obx(() {
                        final customerName = productController.customerName.value;
                        final nameLines = splitText(customerName, 20);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: nameLines.map((line) => Text(
                            nameLines.first == line ? 'CUSTOMER NAME : $line' : line,
                            style: const TextStyle(fontSize: 16),
                          )).toList(),
                        );
                      }),
                      const SizedBox(height: 6),
                      Obx(() => Text(
                        'MOBILE : ${productController.customerMobileNumber.value}',
                        style: const TextStyle(fontSize: 17),
                      )),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '#',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              'ITEMS',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'AMOUNT',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'QTY',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'TOTAL',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      ...cartItems.asMap().entries.expand((entry) {
                        int idx = entry.key;
                        Product product = entry.value;
                        double itemTotal = (product.sellingPrice ?? 0) * product.quantity;
                        final itemName = product.itemName ?? 'Unknown';
                        final itemNameLines = splitText(itemName, 20);
                        return itemNameLines.asMap().entries.map((lineEntry) {
                          int lineIdx = lineEntry.key;
                          String line = lineEntry.value;
                          return Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  lineIdx == 0 ? '${idx + 1}' : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  line,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  lineIdx == 0 ? '${(product.sellingPrice ?? 0).toStringAsFixed(2)}(1Kg)' : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lineIdx == 0 ? 'x${product.quantity}' : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  lineIdx == 0 ? itemTotal.toStringAsFixed(2) : '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ],
                          );
                        });
                      }),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 10),
                      const Text('Total', style: TextStyle(fontSize: 19)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('General Items:', style: TextStyle(fontSize: 16)),
                          Text(
                            '${cartItems.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text(
                            'TOTAL:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                          Text(
                            printController.totalAmount.value.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                          Text(
                            printController.totalAmount.value.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Thank You.. Visit Again..!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  );
                },
                onInitialized: (controller) {
                  printController.setReceiptController(controller);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => printController.selectBluetoothDevice(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Select Device",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await printController.syncCartData(productController);
                  await printController.printReceipt(context, productController);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Print",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}