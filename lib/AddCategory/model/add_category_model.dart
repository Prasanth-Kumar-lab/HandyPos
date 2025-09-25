class CategoryModel {
  final String categoryName;
  final String businessId;

  CategoryModel({required this.categoryName, required this.businessId});

  Map<String, String> toJson() => {
    'category_name': categoryName,
    'business_id': businessId,
  };
}