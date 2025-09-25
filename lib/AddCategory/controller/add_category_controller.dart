import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';

import '../model/add_category_model.dart';

class AddCategoryController {

  Future<Map<String, dynamic>> addCategory(CategoryModel category) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.addCategoryEndPoint));
      request.fields.addAll(category.toJson());

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      return jsonResponse;
    } catch (e) {
      print('Exception: $e');
      return {'status': 'error', 'message': 'Failed to connect to server'};
    }
  }
}