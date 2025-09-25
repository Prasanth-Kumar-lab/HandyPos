
class UserModelSignUp {
  final String name;
  final String mobileNumber;
  final String username;
  final String password;
  final String role;
  final String aadharNumber;
  final String address;

  UserModelSignUp({
    required this.name,
    required this.mobileNumber,
    required this.username,
    required this.password,
    required this.role,
    required this.aadharNumber,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile_number': mobileNumber,
    'username': username,
    'password': password,
    'role': role,
    'aadhar_number': aadharNumber,
    'address': address,
  };
}