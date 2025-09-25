class ListProductCategoryModel {
  final String catName;
  final String businessId;

  ListProductCategoryModel({required this.catName, required this.businessId});

  factory ListProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ListProductCategoryModel(
      catName: json['cat_name'] ?? '',
      businessId: json['business_id'] ?? '',
    );
  }

  Map<String, String> toJson() => {
    'cat_name': catName,
    'business_id': businessId,
  };
}