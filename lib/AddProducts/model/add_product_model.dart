import 'dart:convert';
import 'dart:io'; // Added for File handling

class AddProductsAPI {
  final String productId;
  final String productCode;
  final String productCat;
  final String itemName;
  final String sellingPrice;
  final String units;
  final String cgst;
  final String sgst;
  final String igst;
  final String businessId;
  final String availabilityStatus;
  final String? imagePath; // Added for image_path

  AddProductsAPI({
    required this.productId,
    required this.productCode,
    required this.productCat,
    required this.itemName,
    required this.sellingPrice,
    required this.units,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.businessId,
    required this.availabilityStatus,
    this.imagePath, // Nullable image_path
  });

  factory AddProductsAPI.fromJson(Map<String, dynamic> json) {
    return AddProductsAPI(
      productId: json['product_id'] as String? ?? '',
      productCode: json['product_code'] as String? ?? '',
      productCat: json['product_cat'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      sellingPrice: json['selling_price'] as String? ?? '',
      units: json['selling_unit'] as String? ?? '',
      cgst: json['cgst'] as String? ?? '',
      sgst: json['sgst'] as String? ?? '',
      igst: json['igst'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      availabilityStatus: json['availability_status'] as String? ?? '',
      imagePath: json['image_path'] as String?, // Handle image_path
    );
  }

  Map<String, String> toMap() {
    return {
      'product_id': productId,
      'product_code': productCode,
      'product_cat': productCat,
      'item_name': itemName,
      'selling_price': sellingPrice,
      'selling_unit': units,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'business_id': businessId,
      'availability_status': availabilityStatus,
      // image_path is not included here as it's handled separately as a file
    };
  }
}