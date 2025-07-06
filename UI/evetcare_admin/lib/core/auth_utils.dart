import 'package:evetcare_admin/utils/authorization.dart'; 

Map<String, String> createHeaders() {
  final token = Authorization.token;

  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}