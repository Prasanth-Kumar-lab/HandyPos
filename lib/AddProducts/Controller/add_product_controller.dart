import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:task/AddProducts/model/list_product_category_fetch.dart';
import 'package:task/AddProducts/model/list_tax_model.dart';
import '../../api_endpoints.dart';
import '../model/add_product_model.dart';

class AddProductsController extends GetxController {
  var products = <AddProductsAPI>[].obs;
  var categories = <ListProductCategoryModel>[].obs;
  var taxes = <ListTaxModel>[].obs;
  final String businessId;

  AddProductsController({required this.businessId});

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
    fetchTaxes();
  }

  Future<void> fetchCategories() async {
    if (businessId.isEmpty) {
      print('Business ID is empty, cannot fetch categories');
      Get.snackbar('Error', 'Business ID is missing');
      return;
    }

    final url = Uri.parse('${ApiConstants.listProductCategory}?business_id=$businessId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        categories.value = jsonList
            .map((json) => ListProductCategoryModel.fromJson(json))
            .toList();
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to fetch categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      Get.snackbar('Error', 'Error fetching categories: $e');
    }
  }

  Future<void> fetchTaxes() async {
    if (businessId.isEmpty) {
      print('Business ID is empty, cannot fetch taxes');
      Get.snackbar('Error', 'Business ID is missing');
      return;
    }

    final url = Uri.parse('${ApiConstants.listTax}?business_id=$businessId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> jsonList;
        if (jsonData is List) {
          jsonList = jsonData;
        } else if (jsonData is Map) {
          jsonList = jsonData['data'] ?? []; // Adjust 'data' key if needed
        } else {
          throw Exception('Unexpected response format');
        }
        taxes.value = jsonList
            .map((json) => ListTaxModel.fromJson(json))
            .toList();
      } else {
        print('Failed to fetch taxes: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to fetch taxes');
      }
    } catch (e) {
      print('Error fetching taxes: $e');
      Get.snackbar('Error', 'Error fetching taxes: $e');
    }
  }

  Future<void> fetchProducts() async {
    if (businessId.isEmpty) {
      print('Business ID is empty, cannot fetch products');
      Get.snackbar('Error', 'Business ID is missing');
      return;
    }

    final url = Uri.parse('${ApiConstants.productsEndPoint}?business_id=$businessId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        products.value = jsonList
            .map((json) => AddProductsAPI.fromJson(json))
            .toList();
      } else {
        print('Failed to fetch products: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to fetch products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      Get.snackbar('Error', 'Error fetching products: $e');
    }
  }

  Future<void> addProduct(Map<String, String> params) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.addProductsEndPoint));
    params['business_id'] = businessId;
    request.fields.addAll(params);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'Success') {
          await fetchProducts();
          Get.snackbar('Success', 'Product added successfully');
        } else {
          print('Failed to add product: ${json['message']}');
          Get.snackbar('Error', 'Failed to add product: ${json['message']}');
        }
      } else {
        print('Failed to add product: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding product: $e');
      Get.snackbar('Error', 'Error adding product: $e');
    }
  }

  Future<void> updateProduct(String productCode, Map<String, String> params) async {
    params['product_code'] = productCode;
    params['business_id'] = businessId;
    final request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.productsEndPoint}'));
    request.fields.addAll(params);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'Success') {
          await fetchProducts();
          Get.snackbar('Success', 'Product updated successfully');
        } else {
          print('Failed to update product: ${json['message']}');
          Get.snackbar('Error', 'Failed to update product: ${json['message']}');
        }
      } else {
        print('Failed to update product: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      Get.snackbar('Error', 'Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String productCode) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.productsEndPoint}'));
    request.fields['product_code'] = productCode;
    request.fields['business_id'] = businessId;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'Success') {
          await fetchProducts();
          Get.snackbar('Success', 'Product deleted successfully');
        } else {
          print('Failed to delete product: ${json['message']}');
          Get.snackbar('Error', 'Failed to delete product: ${json['message']}');
        }
      } else {
        print('Failed to delete product: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      Get.snackbar('Error', 'Error deleting product: $e');
    }
  }
}