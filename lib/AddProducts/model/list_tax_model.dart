// Updated ListProductCategoryModel (unchanged, but included for completeness)
class ListTaxModel {
  final String taxType;
  final String taxPercentage;

  ListTaxModel({required this.taxType, required this.taxPercentage});

  factory ListTaxModel.fromJson(Map<String, dynamic> json) {
    return ListTaxModel(
      taxType: json['tax_type'] ?? '',
      taxPercentage: json['tax_percentage'] ?? '',
    );
  }

  Map<String, String> toJson() => {
    'tax_type': taxType,
    'tax_percentage': taxPercentage,
  };
}