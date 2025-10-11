import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/reports_controller.dart';

class ReportsView extends StatelessWidget {
  final String businessId;

  const ReportsView({Key? key, required this.businessId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController(businessId: businessId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            color: Colors.white,
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
            const Text(
              'Select Report Type',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2E35),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.reportType.value.isEmpty ? null : controller.reportType.value,
              hint: const Text('Choose Report Type'),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: controller.reportTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(type),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.reportType.value = value ?? '';
              },
            )),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.reportType.value.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  _buildDateField(
                    label: 'From Date',
                    controller: controller.fromDateController,
                    icon: Icons.calendar_today,
                    onTap: () => controller.pickFromDate(context),
                  ),
                  if (controller.reportType.value.contains('Monthly')) const SizedBox(height: 16),
                  if (controller.reportType.value.contains('Monthly'))
                    _buildDateField(
                      label: 'To Date',
                      controller: controller.toDateController,
                      icon: Icons.calendar_today,
                      onTap: () => controller.pickToDate(context),
                    ),
                  if (controller.reportType.value.contains('Biller')) const SizedBox(height: 16),
                  if (controller.reportType.value.contains('Biller'))
                    Obx(() => DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: controller.selectedBillerId.value.isEmpty
                          ? null
                          : controller.selectedBillerId.value,
                      hint: const Text('Select Biller ID'),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: controller.billerIds.map((id) {
                        return DropdownMenuItem<String>(
                          value: id,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(id),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedBillerId.value = value ?? '';
                      },
                      menuMaxHeight: 300,
                    )),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: controller.generateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4C430),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: const Text(
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
              );
            }),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1A2E35)),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}


