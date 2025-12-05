/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer_plus/commands/print_builder.dart';
import 'package:flutter_thermal_printer_plus/flutter_thermal_printer_plus.dart';
import 'package:flutter_thermal_printer_plus/models/paper_size.dart';
import 'package:flutter_thermal_printer_plus/models/printer_info.dart';
import 'package:flutter_thermal_printer_plus/commands/esc_pos_commands.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
      businessId: businessId,
      initialProducts: initialProducts,
      initialTotal: initialTotal,
    ));
    final productController = Get.find<ProductController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await printController.syncCartData(productController);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Print Receipt")),
      body: Column(
        children: [
          // Connection Status - Fixed to use PrinterInfo
          Obx(() {
            final printerInfo = printController.selectedPrinterInfo.value;
            final customPrinter = printController.selectedPrinter.value;

            if (printerInfo == null || customPrinter == null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey,
                child: Row(
                  children: [
                    Lottie.asset(
                      'assets/inactive.json',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "No Printer Selected",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }

            return FutureBuilder<bool>(
              future: _checkConnection(printerInfo),
              builder: (_, snapshot) {
                final connected = snapshot.data ?? false;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: connected ? Colors.green : Colors.red,
                  child: Row(
                    children: [
                      Lottie.asset(
                        connected ? 'assets/active.json' : 'assets/inactive.json',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          connected
                              ? "Connected: ${customPrinter.name ?? printerInfo.name ?? 'Printer'}"
                              : "Printer Offline",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),

          // Loading / Error
          Obx(() {
            if (printController.isLoadingSettings.value) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }
            if (printController.errorMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(printController.errorMessage.value, style: const TextStyle(color: Colors.red)),
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: Obx(() {
              final settings = printController.systemSettings.value;
              final prod = productController;

              if (settings == null) {
                return const Center(child: Text("Loading Settings..."));
              }

              return Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Container(
                    width: 330, // approx 80mm in UI
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ---------- HEADER ----------
                          Center(
                            child: Image(
                              image: CachedNetworkImageProvider('${settings.billLogo}'),
                              height: 80,
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
                          /*Text(
                            settings.firmName.toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black
                            ),
                            textAlign: TextAlign.center,
                          ),*/
                          const SizedBox(height: 4),
                          Text(
                            "Ph ${settings.firmContact1}${settings.firmContact2.isNotEmpty ? ', ${settings.firmContact2}' : ''}",
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "GSTIN: ${settings.billGstinNum}",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Divider(thickness: 1),

                          const Text(
                            "CASH RECEIPT",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),

                          Divider(thickness: 1),

                          // ---------- BILL INFO ----------
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Invoice: ${prod.finalInvoiceId.value}"),
                                Text(
                                  "Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}",
                                ),
                                Text("Customer: ${prod.customerName.value}"),
                                Text("Mobile: ${prod.customerMobileNumber.value}"),
                              ],
                            ),
                          ),

                          Divider(thickness: 1),

                          // ---------- TABLE HEADER ----------
                          Row(
                            children: const [
                              Expanded(flex: 3, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),

                          Divider(thickness: 1),

                          // ---------- ITEMS ----------
                          ...prod.cartItems.map((item) {
                            final name = item.itemName ?? "";
                            final price = item.sellingPrice ?? 0;
                            final qty = item.quantity;
                            final total = price * qty;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // wrapped title
                                  Text(name, style: const TextStyle(fontSize: 13)),
                                  Row(
                                    children: [
                                      const Spacer(flex: 3),
                                      Expanded(flex: 1, child: Text(price.toStringAsFixed(2))),
                                      Expanded(flex: 1, child: Text(qty.toString())),
                                      Expanded(flex: 1, child: Text(total.toStringAsFixed(2))),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                          Divider(thickness: 1),

                          // ---------- TOTALS ----------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Sub Total"),
                              Text(': ${prod.totalAmount.value.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("GST"),
                              Text(': ${prod.gstAmount.value.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Round Off"),
                              Text(': ${prod.roundOff.value.toStringAsFixed(2)}'),
                            ],
                          ),

                          Divider(thickness: 1),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "GRAND TOTAL",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text(
                                ': ${(prod.totalAmount.value +
                                    prod.gstAmount.value +
                                    prod.roundOff.value)
                                    .toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ---------- FOOTER ----------
                          const Text(
                            "THANK YOU! VISIT AGAIN!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => printController.selectBluetoothDevice(context),
                icon: const Icon(Icons.print),
                label: const Text("Select Printer"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final printController = Get.find<PrintController>();
                  final productController = Get.find<ProductController>();
                  printController.selectBluetoothDevice(context);

                  // Show the "Please wait… Printing..." dialog
                  /*showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.transparent, // transparent background
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                "Please wait… Printing...",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );*/

                  try {
                    // Sync cart and print
                    await printController.syncCartData(productController);
                    final success = await _printPerfect80mmReceipt(printController, productController);

                    // Complete order after printing
                    await printController.completeOrder(productController.cartId.value);
                    productController.resetUICart();

                    // Close the "printing" dialog
                    Navigator.of(context).pop(); // closes printing dialog

                    // Show toast in center
                    Fluttertoast.showToast(
                      msg: success ? "Printed Successfully!" : "Order Saved (No Printer)",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER, // <-- center of the screen
                      backgroundColor: success ? Colors.green : Colors.orange,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );

                  } catch (e) {
                    Navigator.of(context).pop(); // close dialog if error
                    Fluttertoast.showToast(
                      msg: "Printing Failed: $e",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text("Print Now", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Periodic connection check - Fixed to use PrinterInfo
  Future<bool> _checkConnection(PrinterInfo printer) async {
    try {
      return await FlutterThermalPrinterPlus.isConnected();
    } catch (e) {
      debugPrint("Connection check error: $e");
      return false;
    }
  }
  // PERFECT 80MM RECEIPT - EXACTLY LIKE YOUR PHOTO
  // PERFECT 80MM RECEIPT - WITH LOGO + SERIAL NO + TOTAL ITEMS
  Future<bool> _printPerfect80mmReceipt(PrintController pc, ProductController prod) async {
    final settings = pc.systemSettings.value;
    if (settings == null) return false;

    final isConnected = await FlutterThermalPrinterPlus.isConnected();
    if (!isConnected) {
      Get.snackbar("Printer Offline", "Please connect printer first", backgroundColor: Colors.red);
      return false;
    }

    final builder = PrintBuilder(PaperSize.mm80);
    final date = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    // ────── PRINT LOGO (PERFECT QUALITY) ──────
    if (settings.billLogo.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(settings.billLogo));
        if (response.statusCode == 200) {
          final original = img.decodeImage(response.bodyBytes);
          if (original != null) {
            // Resize to max 384px width (80mm paper)
            final resized = img.copyResize(original, width: 384);
            final grayscale = img.grayscale(resized);
            final bitmap = _convertTo1BitBitmap(grayscale, threshold: 180); // 180 gives best result

            builder.addRawBytes([0x1B, 0x40]); // ESC @ = Initialize printer
            builder.addRawBytes(ESCPOSCommands.printRasterImage(bitmap, resized.width, resized.height));
            builder.feed(1);
          }
        }
      } catch (e) {
        debugPrint("Logo failed (continuing without logo): $e");
      }
    }

    // ────── HEADER TEXT ──────
    builder
      //..text(settings.firmName.toUpperCase(), align: AlignPos.center, fontSize: FontSize.big, bold: true)
      ..text("Ph ${settings.firmContact1}${settings.firmContact2.isNotEmpty ? ', ${settings.firmContact2}' : ''}", align: AlignPos.center)
      ..text("GSTIN: ${settings.billGstinNum}", align: AlignPos.center)
      ..feed(1)
      ..line(char: '=');

    // ────── BILL INFO ──────
    builder
      ..text("Invoice : ${prod.finalInvoiceId.value}", align: AlignPos.left)
      ..text("Date    : $date", align: AlignPos.left)
      ..text("Customer: ${prod.customerName.value}", align: AlignPos.left)
      ..text("Mobile  : ${prod.customerMobileNumber.value}", align: AlignPos.left)
      ..line(char: '-');

    // ────── TABLE HEADER WITH # ──────
    builder
      ..text("# Item              Price   Qty  Total", bold: true)
      ..line(char: '-');

    // ────── ITEMS WITH SERIAL NUMBER ──────
    for (int i = 0; i < prod.cartItems.length; i++) {
      final item = prod.cartItems[i];
      final index = (i + 1).toString().padLeft(2); // 1 → " 1", 10 → "10"
      final name = (item.itemName ?? "Unknown").trim();
      final price = (item.sellingPrice ?? 0).toStringAsFixed(2);
      final qty = item.quantity.toString();
      final total = ((item.sellingPrice ?? 0) * item.quantity).toStringAsFixed(2);
      // First line: # + Name (16 chars) + values
      final firstLineName = name.length > 16 ? name.substring(0, 16) : name.padRight(16);
      builder.text("$index $firstLineName $price $qty $total");

      // Wrapped lines (if name is long)
      if (name.length > 16) {
        final remaining = name.substring(16);
        final chunks = _wrapText(remaining, 29); // 29 chars after "# " + index space
        for (var chunk in chunks) {
          builder.text("   ${chunk.padRight(29)}"); // 3 spaces + text
        }
      }
    }

    builder..line(char: '-');

    // ────── TOTALS ──────
    final subTotal = prod.totalAmount.value.toStringAsFixed(2);
    final gst = prod.gstAmount.value.toStringAsFixed(2);
    final roundOff = prod.roundOff.value.toStringAsFixed(2);
    final grandTotal = (prod.totalAmount.value + prod.gstAmount.value + prod.roundOff.value).toStringAsFixed(2);

    builder
      ..text("Sub-Total       : $subTotal")
      ..text("GST             : $gst")
      ..text("Round-Off       : $roundOff")
      ..line(char: '=')
      ..text("GRAND TOTAL     : $grandTotal", bold: true, fontSize: FontSize.normal)
      ..text("Total Items     : ${prod.cartItems.length}", bold: true)
      ..line(char: '=')
      ..feed(1)
      ..text("THANK YOU! VISIT AGAIN!", align: AlignPos.center, bold: true, fontSize: FontSize.normal)
      ..cut();

    try {
      final result = await FlutterThermalPrinterPlus.print(builder);
      return result;
    } catch (e) {
      debugPrint("Print error: $e");
      return false;
    }
  }

// Helper: Wrap long text
  List<String> _wrapText(String text, int maxLength) {
    final List<String> lines = [];
    String remaining = text;
    while (remaining.isNotEmpty) {
      if (remaining.length <= maxLength) {
        lines.add(remaining);
        break;
      }
      lines.add(remaining.substring(0, maxLength));
      remaining = remaining.substring(maxLength);
    }
    return lines;
  }

// Keep your existing _convertTo1BitBitmap (this one works perfectly)
  Uint8List _convertTo1BitBitmap(img.Image image, {int threshold = 180}) {
    final w = image.width;
    final h = image.height;
    final bytesPerRow = (w + 7) ~/ 8;
    final bitmap = Uint8List(bytesPerRow * h);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = image.getPixel(x, y);
        final gray = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114).toInt();
        if (gray < threshold) {
          final byteIndex = y * bytesPerRow + (x ~/ 8);
          final bit = 7 - (x % 8);
          bitmap[byteIndex] |= (1 << bit);
        }
      }
    }
    return bitmap;
  }
  String padRight(String text, int width) {
    if (text.length > width) return text.substring(0, width);
    return text.padRight(width);
  }

  String padLeft(String text, int width) {
    if (text.length > width) return text.substring(0, width);
    return text.padLeft(width);
  }

}
*/

import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer_plus/commands/print_builder.dart';
import 'package:flutter_thermal_printer_plus/commands/esc_pos_commands.dart';
import 'package:flutter_thermal_printer_plus/flutter_thermal_printer_plus.dart';
import 'package:flutter_thermal_printer_plus/models/paper_size.dart';
import 'package:flutter_thermal_printer_plus/models/printer_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
      businessId: businessId,
      initialProducts: initialProducts,
      initialTotal: initialTotal,
    ));
    final productController = Get.find<ProductController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await printController.syncCartData(productController);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Print Receipt")),
      body: Column(
        children: [
          // Connection Status
          Obx(() {
            final printerInfo = printController.selectedPrinterInfo.value;
            final customPrinter = printController.selectedPrinter.value;

            if (printerInfo == null || customPrinter == null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey,
                child: Row(
                  children: [
                    Lottie.asset('assets/inactive.json', height: 40, width: 40),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "No Printer Selected",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }

            return FutureBuilder<bool>(
              future: _checkConnection(printerInfo),
              builder: (_, snapshot) {
                final connected = snapshot.data ?? false;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: connected ? Colors.green : Colors.red,
                  child: Row(
                    children: [
                      Lottie.asset(
                        connected ? 'assets/active.json' : 'assets/inactive.json',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          connected
                              ? "Connected: ${customPrinter.name ?? printerInfo.name ?? 'Printer'}"
                              : "Printer Offline",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),

          // Loading / Error
          Obx(() {
            if (printController.isLoadingSettings.value) {
              return const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator());
            }
            if (printController.errorMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(printController.errorMessage.value, style: const TextStyle(color: Colors.red)),
              );
            }
            return const SizedBox.shrink();
          }),

          // Preview
          Expanded(
            child: Obx(() {
              final settings = printController.systemSettings.value;
              final prod = productController;

              if (settings == null) {
                return const Center(child: Text("Loading Settings..."));
              }

              return Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Container(
                    width: 330,
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // LOGO
                          Center(
                            child: Image(
                              image: CachedNetworkImageProvider('${settings.billLogo}'),
                              height: 80,
                              width: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                height: 80,
                                width: 200,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                          //const SizedBox(height: 4,),
                          Text(
                            "${settings.billAddress?? ''}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          //const SizedBox(height: 4),
                          Text(
                            "Ph ${settings.firmContact1}${settings.firmContact2.isNotEmpty ? ', ${settings.firmContact2}' : ''}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "GSTIN: ${settings.billGstinNum}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          const Divider(thickness: 1),

                          // BILL INFO
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Invoice: ${prod.finalInvoiceId.value}"),
                                Text("Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}"),
                                Text("Customer: ${prod.customerName.value}"),
                                Text("Mobile: ${prod.customerMobileNumber.value}"),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1),

                          // TABLE HEADER WITH #
                          Row(
                            children: const [
                              SizedBox(width: 20, child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              Expanded(flex: 3, child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              SizedBox(width: 50, child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right)),
                              SizedBox(width: 30, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                              SizedBox(width: 60, child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right)),
                            ],
                          ),
                          const Divider(thickness: 1),

                          // ITEMS WITH SERIAL NUMBER
                          ...prod.cartItems.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final item = entry.value;
                            final name = item.itemName ?? "";
                            final price = item.sellingPrice ?? 0;
                            final qty = item.quantity;
                            final total = price * qty;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 20, child: Text("$index", style: const TextStyle(fontSize: 11))),
                                  Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 11))),
                                  SizedBox(width: 50, child: Text(price.toStringAsFixed(2), style: const TextStyle(fontSize: 11), textAlign: TextAlign.right)),
                                  SizedBox(width: 30, child: Text(qty.toString(), style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
                                  SizedBox(width: 60, child: Text(total.toStringAsFixed(2), style: const TextStyle(fontSize: 11), textAlign: TextAlign.right)),
                                ],
                              ),
                            );
                          }),

                          const Divider(thickness: 1),

                          // TOTALS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Sub Total"),
                              Text(prod.totalAmount.value.toStringAsFixed(2)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("GST"),
                              Text(prod.gstAmount.value.toStringAsFixed(2)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Round Off"),
                              Text(prod.roundOff.value.toStringAsFixed(2)),
                            ],
                          ),
                          const Divider(thickness: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("GRAND TOTAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                (prod.totalAmount.value + prod.gstAmount.value + prod.roundOff.value).toStringAsFixed(2),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Total Items: ${prod.cartItems.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const Divider(thickness: 2),
                          const SizedBox(height: 8),
                          Text(
                            "${settings.quote}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => printController.selectBluetoothDevice(context),
                icon: const Icon(Icons.print),
                label: const Text("Select Printer"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final printController = Get.find<PrintController>();
                  final productController = Get.find<ProductController>();

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.transparent,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text("Please wait… Printing...", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  try {
                    await printController.syncCartData(productController);
                    final success = await _print80mmReceipt(printController, productController);

                    await printController.completeOrder(productController.cartId.value);
                    productController.resetUICart();

                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close screen

                    Fluttertoast.showToast(
                      msg: success ? "Printed Successfully!" : "Order Saved (No Printer)",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: success ? Colors.green : Colors.orange,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: "Printing Failed: $e",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text("PRINT NOW", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkConnection(PrinterInfo printer) async {
    try {
      return await FlutterThermalPrinterPlus.isConnected();
    } catch (e) {
      debugPrint("Connection check error: $e");
      return false;
    }
  }

  //  PERFECT 80MM RECEIPT - WITH CENTERED LOGO + SERIAL # + TOTAL ITEMS + RIGHT ALIGNED VALUES
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

  String padRight(String text, int width) {
    if (text.length > width) return text.substring(0, width);
    return text.padRight(width);
  }

  String padLeft(String text, int width) {
    if (text.length > width) return text.substring(0, width);
    return text.padLeft(width);
  }

  // Helper: Generate spaces for alignment
  String _spaces(int count) => ' ' * (count > 0 ? count : 0);

  // Helper: Wrap long text
  List<String> _wrapText(String text, int maxLength) {
    final List<String> lines = [];
    String remaining = text;
    while (remaining.isNotEmpty) {
      if (remaining.length <= maxLength) {
        lines.add(remaining);
        break;
      }
      lines.add(remaining.substring(0, maxLength));
      remaining = remaining.substring(maxLength);
    }
    return lines;
  }

  // Convert to 1-bit bitmap
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






/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:task/Constants/constants.dart';
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
    productController.fetchCartItems();                       // YESTERDAY
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
            return /*FutureBuilder<bool>(
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
            );*/
              StreamBuilder<bool>(
                stream: Stream.fromFuture(FlutterBluetoothPrinter.connect(printer.address)),
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
                      // Logo
                      Center(
                        child: Image(
                          image: CachedNetworkImageProvider('${settings.billLogo}'),
                          height: 80,
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

                      // Firm Name
                      Center(
                        child: Text(
                          settings.firmName,
                          style: GoogleFonts.merriweather(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PrintConstants.spaceBetweenWidgets,

                      // Contact
                      Center(
                        child: Text(
                          'CONTACT : ${settings.firmContact1} ${settings.firmContact2}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      PrintConstants.spaceBetweenWidgets,

                      // Address
                      Center(
                        child: Text(
                          settings.billAddress?.isNotEmpty == true
                              ? settings.billAddress!
                              : 'Not mentioned bill address',
                          style: GoogleFonts.merriweather(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PrintConstants.spaceBetweenWidgets,

                      // GSTIN
                      Center(
                        child: Text(
                          'GSTIN : ${settings.billGstinNum}',
                          style: PrintConstants.mainDetailsTextStyle,
                        ),
                      ),
                      PrintConstants.spaceBetweenWidgets,

                      // Invoice ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            'INVOICE ID : ${productController.finalInvoiceId.value}',
                            style: PrintConstants.mainDetailsTextStyle,
                          )),
                        ],
                      ),
                      PrintConstants.spaceBetweenWidgets,

                      // Date
                      Text('DATE: $formattedDate', style: PrintConstants.mainDetailsTextStyle),
                      PrintConstants.spaceBetweenWidgets,

                      // Customer Name
                      Obx(() {
                        final customerName = productController.customerName.value;
                        final nameLines = splitText(customerName, 20);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: nameLines.map((line) => Text(
                            nameLines.first == line ? 'CUSTOMER NAME : $line' : line,
                            style: PrintConstants.mainDetailsTextStyle,
                          )).toList(),
                        );
                      }),
                      PrintConstants.spaceBetweenWidgets,

                      // Mobile
                      Obx(() => Text(
                        'MOBILE : ${productController.customerMobileNumber.value}',
                        style: PrintConstants.mainDetailsTextStyle,
                      )),
                      PrintConstants.spaceBetweenWidgets,

                      // Table Header
                      Row(
                        children: const [
                          Expanded(flex: 1, child: Text('#', style: PrintConstants.itemsTextStyle, textAlign: TextAlign.center)),
                          Expanded(flex: 5, child: Text('ITEMS', style: PrintConstants.itemsTextStyle)),
                          Expanded(flex: 3, child: Text('AMOUNT', style: PrintConstants.itemsTextStyle, textAlign: TextAlign.right)),
                          Expanded(flex: 2, child: Text('QTY', style: PrintConstants.itemsTextStyle, textAlign: TextAlign.center)),
                          Expanded(flex: 3, child: Text('TOTAL', style: PrintConstants.itemsTextStyle, textAlign: TextAlign.right)),
                        ],
                      ),
                      const Divider(color: Colors.black),

                      // Items List
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
                                  style: PrintConstants.itemsTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(line, style: PrintConstants.itemsTextStyle),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  lineIdx == 0 ? '${(product.sellingPrice ?? 0).toStringAsFixed(2)}' : '',
                                  style: PrintConstants.itemsTextStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lineIdx == 0 ? 'x${product.quantity}' : '',
                                  style: PrintConstants.itemsTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  lineIdx == 0 ? itemTotal.toStringAsFixed(2) : '',
                                  style: PrintConstants.itemsTextStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        });
                      }),
                      const Divider(color: Colors.black),
                      PrintConstants.spaceBetweenWidgets,

                      // Totals Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAmountRow('General Items', '${cartItems.length}'),
                          _buildAmountRow('Sub-Total', productController.totalAmount.value.toStringAsFixed(2)),
                          _buildAmountRow('GST', productController.gstAmount.value.toStringAsFixed(2)),
                          _buildAmountRow('Round-Off', productController.roundOff.value.toStringAsFixed(2)),
                          _buildAmountRow(
                            'Grand Total',
                            (productController.totalAmount.value +
                                productController.gstAmount.value +
                                productController.roundOff.value).toStringAsFixed(2),
                            isBold: true,
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      PrintConstants.spaceBetweenWidgets,

                      // Thank You Note
                      const Center(
                        child: Text(
                          'Thank You.. Visit Again..!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  );

// Helper function for amounts row


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
              /*ElevatedButton(
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
              ),*/
              ElevatedButton(
                onPressed: () async {
                  final printController = Get.find<PrintController>();
                  final productController = Get.find<ProductController>();
                  // Show the "Please wait… Printing..." dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.transparent, // fully transparent background
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                "Please wait… Printing...",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  // Sync cart and print
                  await printController.syncCartData(productController);
                  await printController.printReceipt(context, productController);

                  // Close the dialog after printing completes
                  Navigator.of(context).pop();
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
  Widget _buildAmountRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 15), textAlign: TextAlign.right),
        ],
      ),
    );
  }
}*/

/*
return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image(
                          image: CachedNetworkImageProvider(
                            '${settings.billLogo}',
                          ),
                          height: 80,
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
                      Center(
                        child: Text(
                          settings.firmName,
                          style: GoogleFonts.merriweather(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      PrintConstants.spaceBetweenWidgets,

                      Center(
                        child: Text(
                          'CONTACT : ${settings.firmContact1} ${settings.firmContact2}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      PrintConstants.spaceBetweenWidgets,
                      /*Center(
                        child: Text(
                          settings.billAddress,
                          style: GoogleFonts.merriweather(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),*/
                      Center(
                        child: Text(
                          settings.billAddress?.isNotEmpty == true
                              ? settings.billAddress!
                              : 'Not mentioned bill address',
                          style: GoogleFonts.merriweather(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      PrintConstants.spaceBetweenWidgets,

                      Center(
                        child: Text(
                          'GSTIN : ${settings.billGstinNum}',
                          style: PrintConstants.mainDetailsTextStyle,
                        ),
                      ),

                      PrintConstants.spaceBetweenWidgets,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                            'INVOICE ID : ${productController.finalInvoiceId.value}',
                            style: PrintConstants.mainDetailsTextStyle,
                          )),
                        ],
                      ),
                      PrintConstants.spaceBetweenWidgets,
                      Text('DATE: $formattedDate', style: PrintConstants.mainDetailsTextStyle),
                      PrintConstants.spaceBetweenWidgets,
                      Obx(() {
                        final customerName = productController.customerName.value;
                        final nameLines = splitText(customerName, 20);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: nameLines.map((line) => Text(
                            nameLines.first == line ? 'CUSTOMER NAME : $line' : line,
                            style: PrintConstants.mainDetailsTextStyle,
                          )).toList(),
                        );
                      }),

                      PrintConstants.spaceBetweenWidgets,

                      Obx(() => Text(
                        'MOBILE : ${productController.customerMobileNumber.value}',
                        style: PrintConstants.mainDetailsTextStyle,
                      )),

                      PrintConstants.spaceBetweenWidgets,

                      Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '#',
                              style: PrintConstants.itemsTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              'ITEMS',
                              style: PrintConstants.itemsTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'AMOUNT',
                              style: PrintConstants.itemsTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'QTY',
                              style: PrintConstants.itemsTextStyle,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'TOTAL',
                              style: PrintConstants.itemsTextStyle,
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
                                  lineIdx == 0 ? '${idx + 1}' : '.',
                                  style: PrintConstants.itemsTextStyle,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  '$line', //(${product.sellingUnit!})
                                  style: PrintConstants.itemsTextStyle,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  lineIdx == 0 ? '${(product.sellingPrice ?? 0).toStringAsFixed(2)}' : '',
                                  style: PrintConstants.itemsTextStyle,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lineIdx == 0 ? 'x${product.quantity}' : '',
                                  style: PrintConstants.itemsTextStyle,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  lineIdx == 0 ? itemTotal.toStringAsFixed(2) : '',
                                  style: PrintConstants.itemsTextStyle,
                                ),
                              ),
                            ],
                          );
                        });
                      }),
                      const Divider(color: Colors.black),
                      PrintConstants.spaceBetweenWidgets,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // aligns text to the right
                        children: [
                          Text(
                            'General Items: ${cartItems.length}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Sub-Total: ${productController.totalAmount.value.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      //const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          // Column for all amounts
                          /*Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // aligns text to the right
                            children: [
                              Text(
                                'GST: ${productController.gstAmount.value.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(height: 3,),
                              Text(
                                'Round-Off: ${productController.roundOff.value.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),*/
                      PrintConstants.spaceBetweenWidgets,

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'GST:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                productController.gstAmount.value.toStringAsFixed(2),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Round-Off:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                productController.roundOff.value.toStringAsFixed(2),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                (productController.totalAmount.value +
                                    productController.gstAmount.value +
                                    productController.roundOff.value)
                                    .toStringAsFixed(2),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Colors.black,),
                      PrintConstants.spaceBetweenWidgets,
                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            '${productController.totalAmount.value + productController.gstAmount.value + productController.roundOff.value}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ],
                      ),*/
                      const SizedBox(height: 15),
                      const Center(
                        child: Text(
                          'Thank You.. Visit Again..!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  );
 */