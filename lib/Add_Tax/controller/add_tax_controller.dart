import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:task/Add_Tax/model/add_tax_model.dart';
import 'package:task/api_endpoints.dart';

class AddTaxController {

  Future<Map<String, dynamic>> addTaxMethod(AddTaxModel addTax) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.addTaxEndPoint));
      request.fields.addAll(addTax.toJson());

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