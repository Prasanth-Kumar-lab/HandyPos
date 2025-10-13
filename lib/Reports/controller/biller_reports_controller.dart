import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../model/biller_reports_model.dart';
import '../view/biller_reports_data.dart';

class BillerReportsController extends GetxController {
  final BillerReportsModel _reportModel = BillerReportsModel();
  final String businessId;
  final String billerId;
  final String reportType;

  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  BillerReportsController({
    required this.businessId,
    required this.billerId,
    required this.reportType,
  });

  @override
  void onInit() {
    super.onInit();
    // Set default dates based on report type
    fromDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (reportType == 'Monthly Report') {
      toDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  Future<void> pickFromDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> generateReport() async {
    String from = fromDateController.text;
    String to = reportType.contains('Day') ? '0' : toDateController.text;

    if (from.isEmpty || (to != '0' && to.isEmpty)) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final data = await _reportModel.fetchReport(
      businessId: businessId,
      fromDate: from,
      toDate: to,
      billerId: billerId,
    );
    if (data.isNotEmpty) {
      Get.to(() => BillerReportsDisplayView(
        data: data,
        reportType: reportType,
        fromDate: from,
        toDate: to,
      ));
    }
  }
}

class BillerReportsDisplayController extends GetxController {
  final dynamic data;
  final String reportType;
  final String fromDate;
  final String toDate;

  BillerReportsDisplayController({
    required this.data,
    required this.reportType,
    required this.fromDate,
    required this.toDate,
  });

  String get status => data['status'] ?? 'Unknown';
  String get totalCollections => data['total_collections_today']?.toString() ?? '0';
  List<Map<String, dynamic>> get orders => List<Map<String, dynamic>>.from(data['orders'] ?? []);
}