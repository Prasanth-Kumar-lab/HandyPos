import 'dart:convert';

class Printer {
  final String address;
  final String? name;

  Printer({required this.address, this.name});
}
class SystemSettings {
  final String quoteId;
  final String quote;
  final String billPrefix;
  final String firmName;
  final String firmContact1;
  final String firmContact2;
  final String billAddress;
  final String billGstinNum;
  final String billLogo; // dynamic logo
  SystemSettings({
    required this.quoteId,
    required this.quote,
    required this.billPrefix,
    required this.firmName,
    required this.firmContact1,
    required this.firmContact2,
    required this.billAddress,
    required this.billGstinNum,
    required this.billLogo,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      quoteId: json['quote_id'] as String? ?? '',
      quote: json['quote'] ?? '',
      billPrefix: json['bill_prefix'] as String? ?? '',
      firmName: json['firm_name'] as String? ?? '',
      firmContact1: json['firm_contact1'] as String? ?? '',
      firmContact2: json['firm_contact2'] as String? ?? '',
      billAddress: json['bill_address'] as String? ?? '',
      billGstinNum: json['bill_gstin_num'] as String? ?? '',
      billLogo: json['bill_logo'] as String? ?? '',
    );
  }

  static SystemSettings? fromJsonResponse(String responseBody) {
    try {
      final Map<String, dynamic> json = jsonDecode(responseBody);
      return SystemSettings.fromJson(json);
    } catch (e) {
      print('Error parsing system settings JSON: $e');
      return null;
    }
  }
}