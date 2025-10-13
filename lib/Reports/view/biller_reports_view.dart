import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/biller_reports_controller.dart';

class BillerReportsView extends StatelessWidget {
  final String businessId;
  final String billerId;
  final String reportType;

  const BillerReportsView({
    Key? key,
    required this.businessId,
    required this.billerId,
    required this.reportType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BillerReportsController(
      businessId: businessId,
      billerId: billerId,
      reportType: reportType,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '$reportType',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Report Type: ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: controller.reportType.isEmpty
                        ? 'No Report Type Selected'
                        : controller.reportType,
                    style: const TextStyle(
                      fontSize: 22,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24,),
            Column(
              children: [
                _buildDateField(
                  label: 'From Date',
                  controller: controller.fromDateController,
                  icon: Icons.calendar_today,
                  onTap: () => controller.pickFromDate(context),
                ),
                if (reportType.contains('Monthly')) const SizedBox(height: 16),
                if (reportType.contains('Monthly'))
                  _buildDateField(
                    label: 'To Date',
                    controller: controller.toDateController,
                    icon: Icons.calendar_today,
                    onTap: () => controller.pickToDate(context),
                  ),
                SizedBox(height: 28),
                Center(
                  child: ElevatedButton(
                    onPressed: controller.generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4C430),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2E35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1A2E35)),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}