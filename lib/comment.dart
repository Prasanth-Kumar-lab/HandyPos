/*
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // 👈 This is the missing import!
class Print extends StatefulWidget {
  const Print({Key? key}) : super(key: key);

  @override
  State<Print> createState() => _PrintState();
}

class _PrintState extends State<Print> {
  ReceiptController? controllerl;
  var _selectedPrinter; // Holds the selected printer device

  Future<void> _generateAndPrintPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            'Hello World',
            style: pw.TextStyle(
              fontSize: 40,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Select Bluetooth Printer
  Future<void> _selectBluetoothDevice() async {
    final selected = await FlutterBluetoothPrinter.selectDevice(context);
    if (selected != null) {
      setState(() {
        _selectedPrinter = selected;
      });
      log("Selected device: ${_selectedPrinter.name}");
    } else {
      log("Device selection canceled.");
    }
  }

  /// Print to Selected Device
  Future<void> _printReceipt() async {
    if (_selectedPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a printer first')),
      );
      return;
    }

    try {
      await controllerl?.print(
        address: _selectedPrinter.address,
        keepConnected: true,
        addFeeds: 4,
      );
    } catch (e) {
      log('Printing failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello PDF Example'),
      ),
      body: Column(
        children: [
          // 👇 DISPLAY SELECTED PRINTER ABOVE RECEIPT (not printed)
          if (_selectedPrinter != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Lottie animation (printer, loading, etc.)
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Lottie.asset(
                      'assets/active.json', // 🔁 Replace with your actual asset path
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10), // spacing between animation and text
                  Expanded(
                    child: Text(
                      'Selected Printer: ${_selectedPrinter.name ?? _selectedPrinter.address}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // 👇 RECEIPT - ONLY THIS PART IS PRINTED
          Expanded(
            child: Receipt(
              builder: (context) => Column(
                children: [
                  Text('Hello World'),
                  SizedBox(height: 5),
                  Text('Address, Place'),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.account_circle, size: 40, color: Colors.blue),
                      Text(
                        'Username',
                        style: TextStyle(fontSize: 20),
                      ),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ],
              ),
              onInitialized: (controller) {
                this.controllerl = controller;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _selectBluetoothDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text("Select Device"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _printReceipt,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Print"),
            ),
          ],
        ),
      ),
    );
  }

}

 */