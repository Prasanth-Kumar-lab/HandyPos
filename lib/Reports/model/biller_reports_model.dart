import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';
class BillerReportsModel {
  Future<Map<String, dynamic>> fetchReport({
    required String businessId,
    required String fromDate,
    required String toDate,
    required String billerId,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.reportsApiEndPoint}?business_id=$businessId&from_date=$fromDate&to_date=$toDate&biller_id=$billerId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch report: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch report: $e',
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return {};
    }
  }
}