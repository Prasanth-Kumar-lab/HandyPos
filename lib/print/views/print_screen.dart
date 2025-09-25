/*
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../home_screen/model/product_model.dart';
import 'package:flutter/material.dart';

import '../controller/print_controller.dart';
class PrintScreen extends StatelessWidget {
  final List<Product> selectedProducts;
  final double totalAmount;
  final String name;
  final String mobileNumber;

  const PrintScreen({
    Key? key,
    required this.selectedProducts,
    required this.totalAmount,
    required this.name,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with GetX
    final controller = Get.put(PrintController(
      selectedProducts: selectedProducts,
      totalAmount: totalAmount,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Receipt'),
      ),
      body: Column(
        children: [
          // DISPLAY SELECTED PRINTER ABOVE RECEIPT (not printed)
          Obx(() => controller.selectedPrinter.value != null
              ? Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Lottie.asset(
                    'assets/active.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selected Printer: ${controller.selectedPrinter.value!.name ?? controller.selectedPrinter.value!.address}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
              : SizedBox.shrink()),

          // RECEIPT - ONLY THIS PART IS PRINTED
          Expanded(
            child: Receipt(
              builder: (context) {
                var now = DateTime.now();
                var formatter = DateFormat('dd/MM/yyyy hh:mm:ss a');
                String formattedDate = formatter.format(now);

                double discountAmt = (totalAmount * 0.1).ceilToDouble();
                double grandAmt = totalAmount - discountAmt;
                double givenAmount = 700.00;
                double returnAmount = givenAmount - grandAmt;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'SUVIDHA SUPER MART',
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    Center(
                      child: Text(
                        'KHAMMAM',
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Text(
                        'CONTACT : 9402512345',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Text(
                        'GSTIN : 1234567800',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('INVOICE ID : 187', style: TextStyle(fontSize: 14)),
                        Text('SOURCESSS', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('DATE: $formattedDate', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 6),
                    Text('CUSTOMER NAME : ${name}', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 6),
                    Text('MOBILE : ${mobileNumber}', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '#',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'ITEMS',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'AMOUNT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'QTY',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.black),
                    ...selectedProducts.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Product product = entry.value;
                      double itemTotal = (product.sellingPrice ?? 0) * product.quantity;
                      return Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              product.itemName ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${(product.sellingPrice ?? 0).toStringAsFixed(2)}(1Kg)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${product.quantity}Kg',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              itemTotal.toStringAsFixed(2),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    }),
                    Divider(color: Colors.black),
                    SizedBox(height: 10),
                    Text('Total:', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('General Items:', style: TextStyle(fontSize: 14)),
                        Text(
                          '${selectedProducts.length}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'TOTAL:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          totalAmount.toStringAsFixed(2),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    Divider(color: Colors.black),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DISCOUNT (10%):', style: TextStyle(fontSize: 14)),
                        Text(
                          discountAmt.toStringAsFixed(2),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Divider(color: Colors.black),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          grandAmt.toStringAsFixed(2),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Given Amount:', style: TextStyle(fontSize: 14)),
                        Text(
                          givenAmount.toStringAsFixed(2),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('RETURN Amount:', style: TextStyle(fontSize: 14)),
                        Text(
                          returnAmount.toStringAsFixed(2),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Thank You.. Visit Again..!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Text(
                        'SUVIDHA SUPER MART',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                );
              },
              onInitialized: (controller) {
                Get.find<PrintController>().setReceiptController(controller);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => controller.selectBluetoothDevice(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                "Select Device",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => controller.printReceipt(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                "Print",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
//import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import '../../home_screen/model/product_model.dart';
import '../controller/print_controller.dart';

class PrintScreen extends StatelessWidget {
  final List<Product> selectedProducts;
  final double totalAmount;
  final String name;
  final String mobileNumber;

  const PrintScreen({
    Key? key,
    required this.selectedProducts,
    required this.totalAmount,
    required this.name,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with GetX
    final controller = Get.put(PrintController(
      selectedProducts: selectedProducts,
      totalAmount: totalAmount,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Receipt'),
      ),
      body: Column(
        children: [
          // DISPLAY SELECTED PRINTER ABOVE RECEIPT (not printed)
          Obx(() {
            final printer = controller.selectedPrinter.value;
            if (printer == null) {
              return const SizedBox.shrink();
            }

            // Check Bluetooth connection status
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

          // RECEIPT - ONLY THIS PART IS PRINTED
          Expanded(
            child: Receipt(
              builder: (context) {
                var now = DateTime.now();
                var formatter = DateFormat('dd/MM/yyyy hh:mm:ss a');
                String formattedDate = formatter.format(now);

                double discountAmt = (totalAmount * 0.1).ceilToDouble();
                double grandAmt = totalAmount - discountAmt;
                double givenAmount = 700.00;
                double returnAmount = givenAmount - grandAmt;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'SUVIDHA SUPER MART',
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Center(
                      child: Text(
                        'KHAMMAM',
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        'CONTACT : 9402512345',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        'GSTIN : 1234567800',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('INVOICE ID : 187', style: TextStyle(fontSize: 14)),
                        const Text('SOURCESSS', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('DATE: $formattedDate', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    Text('CUSTOMER NAME : $name', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    Text('MOBILE : $mobileNumber', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '#',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'ITEMS',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'AMOUNT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'QTY',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.black),
                    ...selectedProducts.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Product product = entry.value;
                      double itemTotal = (product.sellingPrice ?? 0) * product.quantity;
                      return Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              product.itemName ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${(product.sellingPrice ?? 0).toStringAsFixed(2)}(1Kg)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'x${product.quantity}',//Total quantity
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              itemTotal.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    }),
                    const Divider(color: Colors.black),
                    const SizedBox(height: 10),
                    const Text('Total:', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('General Items:', style: TextStyle(fontSize: 14)),
                        Text(
                          '${selectedProducts.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Text(
                          'TOTAL:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          totalAmount.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    const Divider(color: Colors.black),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DISCOUNT (10%):', style: TextStyle(fontSize: 14)),
                        Text(
                          discountAmt.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          grandAmt.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Given Amount:', style: TextStyle(fontSize: 14)),
                        Text(
                          givenAmount.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('RETURN Amount:', style: TextStyle(fontSize: 14)),
                        Text(
                          returnAmount.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Thank You.. Visit Again..!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Center(
                      child: Text(
                        'SUVIDHA SUPER MART',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                );
              },
              onInitialized: (controller) {
                Get.find<PrintController>().setReceiptController(controller);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => controller.selectBluetoothDevice(context),
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
              onPressed: () => controller.printReceipt(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text(
                "Print",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}