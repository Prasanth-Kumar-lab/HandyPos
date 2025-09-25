class AddTaxModel {
  final String taxType;
  final String taxPercentage;
  final String businessId;

  AddTaxModel({ required this.taxType,required this.taxPercentage, required this.businessId});

  Map<String, String> toJson() => {
    'tax_type': taxType,
    'tax_percentage': taxPercentage,
    'business_id': businessId,
  };
}