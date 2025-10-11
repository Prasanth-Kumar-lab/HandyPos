class Product {
  String? itemName;
  double? sellingPrice;
  String? itemImage;
  String? productId; // Assuming product_id is separate from itemName
  String? cartItemId; // New field to store cart_item_id
  int quantity;
  String? sellingUnit; // Added to store selling_unit from JSON
  String? availabilityStatus;
  String? productCategory;

  Product({
    this.itemName,
    this.sellingPrice,
    this.itemImage,
    this.productId,
    this.cartItemId,
    this.quantity = 0,
    this.sellingUnit, // Added as an optional parameter
    this.availabilityStatus,
    this.productCategory
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      itemName: json['item_name']?.toString(),
      sellingPrice: double.tryParse(json['selling_price']?.toString() ?? ''),
      itemImage: json['image_path']?.toString(),
      productId: json['product_id']?.toString(),
      cartItemId: json['cart_item_id']?.toString(), // Optional, if provided by products API
      quantity: 0,
      sellingUnit: json['selling_unit']?.toString(), // Added to parse selling_unit
      availabilityStatus: json['availability_status']?.toString(),
        productCategory: json['product_cat']?.toString()
    );
  }
  factory Product.fromCartJson(Map<String, dynamic> json) {
    return Product(
      itemName: json['product_name']?.toString() ?? json['item_name']?.toString(),
      sellingPrice: double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0.0,
      itemImage: json['product_image']?.toString(),
      productId: json['product_id']?.toString(),
      cartItemId: json['cart_item_id']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      sellingUnit: json['selling_unit']?.toString(), // Added to parse selling_unit
      availabilityStatus: json['availability_status'].toString(),
      productCategory: json['product_cat'].toString(),
    );
  }
}