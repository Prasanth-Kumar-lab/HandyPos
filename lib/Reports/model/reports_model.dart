import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:task/api_endpoints.dart';

class ReportModel {
  Future<List<String>> fetchBillerIds(String businessId) async {
    final url = Uri.parse(
      '${ApiConstants.listBillersEndPoint}?business_id=$businessId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => item['biller_name'].toString()).toList();
        } else if (data is Map && data.containsKey('data') && data['data'] is List) {
          return data['data'].map((item) => item['biller_id'].toString()).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch biller IDs: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch biller IDs: ',//$e
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return [];
    }
  }

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
        'An error occurred: ',//$e
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return {};
    }
  }
}
