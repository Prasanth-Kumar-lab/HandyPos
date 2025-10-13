import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../model/reports_model.dart';
import '../view/ReportDetails.dart';
import '../view/reports_view.dart';

class ReportsController extends GetxController {
  final ReportModel _reportModel = ReportModel();
  final String businessId;
  final bool isReportTypePreSelected; // New flag
  final String? preSelectedReportType; // Store pre-selected report type

  final reportType = ''.obs;
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final billerIds = <String>[].obs;
  final selectedBillerId = ''.obs;

  final List<String> reportTypes = [
    'Day Report',
    'Monthly Report',
    'Biller Wise Day Report',
    'Biller Wise Monthly Report',
  ];

  ReportsController({required this.businessId})
      : isReportTypePreSelected = Get.arguments != null && Get.arguments['reportType'] != null,
        preSelectedReportType = Get.arguments?['reportType'];

  @override
  void onInit() {
    super.onInit();
    fetchBillerIds();
    // Set the pre-selected report type if provided
    if (isReportTypePreSelected && preSelectedReportType != null) {
      reportType.value = preSelectedReportType!;
    }
  }

  Future<void> fetchBillerIds() async {
    billerIds.value = await _reportModel.fetchBillerIds(businessId);
    if (billerIds.isNotEmpty) {
      selectedBillerId.value = billerIds.first;
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
    String to = reportType.value.contains('Day') ? '0' : toDateController.text;
    String biller = reportType.value.contains('Biller') ? selectedBillerId.value : '0';

    if (from.isEmpty || (to != '0' && to.isEmpty) || (biller != '0' && biller.isEmpty)) {
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
      billerId: biller,
    );
    if (data.isNotEmpty) {
      Get.to(
            () => ReportDisplayView(data: data),
        arguments: {
          'fromDate': from,
          'toDate': to,
          'reportType': reportType.value,
        },
      );
    }
  }
}

class ReportDisplayController extends GetxController {
  final dynamic data;

  ReportDisplayController({required this.data});

  String get status => data['status'] ?? 'Unknown';
  String get totalCollections => data['total_collections_today']?.toString() ?? '0';
  List<Map<String, dynamic>> get orders => List<Map<String, dynamic>>.from(data['orders'] ?? []);
}