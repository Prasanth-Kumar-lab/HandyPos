import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:task/api_endpoints.dart';

class SystemSettingsModel {
  final String billPrefix;
  final String quote;
  final String firmName;
  final String firmContact1;
  final String firmContact2;
  final String file;
  final String billAddress;
  final String billGstinNum;
  final String businessId;

  SystemSettingsModel({
    required this.billPrefix,
    required this.quote,
    required this.firmName,
    required this.firmContact1,
    required this.firmContact2,
    required this.file,
    required this.billAddress,
    required this.billGstinNum,
    required this.businessId,
  });

  // Convert model to map for API request
  Map<String, String> toJson() => {
    'bill_prefix': billPrefix,
    'quote': quote,
    'firm_name': firmName,
    'firm_contact1': firmContact1,
    'firm_contact2': firmContact2,
    'file': file,
    'bill_address': billAddress,
    'bill_gstin_num': billGstinNum,
    'business_id': businessId,
  };

  // API call to save system settings
  // API call to save system settings with image upload
  /*Future<Map<String, dynamic>> saveSettings({
    required String selectedImagePath, // Pass the actual file path
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.systemSettingsEndPoint),
      );

      // Add all text fields
      request.fields.addAll(toJson());

      // Only add file if a new image was picked
      if (selectedImagePath.isNotEmpty) {
        var file = await http.MultipartFile.fromPath(
          'file', // This must match the exact field name your backend expects (e.g., 'file', 'logo', 'bill_logo')
          selectedImagePath,
          filename: selectedImagePath.split('/').last,
        );
        request.files.add(file);
        print('Image attached: ${selectedImagePath.split('/').last}');
      } else {
        // Optional: Send old logo path or empty if no new image
        // Some backends allow keeping old image if no new one sent
        request.fields['file'] = file; // keep existing filename/path
      }

      print('Request Fields:57 ${request.fields}');
      print('Request Files: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('API Raw Response: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final status = (responseData['status'] ?? '').toString().toLowerCase();

        if (status == 'success' || status == 'updated') {
          return {
            'status': 'success',
            'message': responseData['message'] ?? 'Settings saved successfully',
            'data': responseData['data'] ?? {},
          };
        } else {
          return {
            'status': 'error',
            'message': responseData['message'] ?? 'Failed to save settings',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Exception during save: $e');
      return {
        'status': 'error',
        'message': 'Network or file error: $e',
      };
    }
  }*/
  Future<Map<String, dynamic>> saveSettings({
    required String selectedImagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.systemSettingsEndPoint),
      );

      request.fields.addAll(toJson());

      if (selectedImagePath.isNotEmpty) {
        var file = await http.MultipartFile.fromPath(
          'file',
          selectedImagePath,
          filename: selectedImagePath.split('/').last,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final status = (responseData['status'] ?? '').toString().toLowerCase();

        if (status == 'success' || status == 'updated') {

          //  SUCCESS TOAST
          Fluttertoast.showToast(
            msg: "Settings saved successfully", //responseData['message'] ?? "Settings saved successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          return {
            'status': 'success',
            'message': responseData['message'] ?? 'Settings saved successfully',
            'data': responseData['data'] ?? {},
          };
        } else {
          //  FAILED TOAST
          Fluttertoast.showToast(
            msg: "Failed to save settings",//responseData['message'] ?? "Failed to save settings",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          return {
            'status': 'error',
            'message': responseData['message'] ?? 'Failed to save settings',
          };
        }
      } else {
        //  SERVER ERROR TOAST
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      //  EXCEPTION TOAST
      Fluttertoast.showToast(
        msg: 'Failed to update settings ',//"Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return {
        'status': 'error',
        'message': 'Network or file error: $e',
      };
    }
  }

}