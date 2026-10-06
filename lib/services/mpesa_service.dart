import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  // YOUR KEYS FROM SCREENSHOT - SANDBOX
  static const String consumerKey = "kjklaZ9HGNzRBU9IhprGizMOggWhtuEfvHoNrvG3k7jh4TvD";
  static const String consumerSecret = "C5c3EHAPYJxRIYhuEkwGyFWxR9M8dJHmIpzCHCsdFC9JrYoRIwZ0mnujneZ1G98q";

  // Sandbox credentials
  static const String shortCode = "174379"; // Safaricom sandbox paybill
  static const String passKey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"; // Sandbox passkey
  static const String baseUrl = "https://sandbox.safaricom.co.ke";

  static Future<String?> getToken() async {
    String credentials = base64Encode(utf8.encode("$consumerKey:$consumerSecret"));
    var res = await http.get(Uri.parse("$baseUrl/oauth/v1/generate?grant_type=client_credentials"),
      headers: {"Authorization": "Basic $credentials"});
    if(res.statusCode==200){
      return jsonDecode(res.body)["access_token"];
    }
    return null;
  }

  static Future<bool> stkPush(String phone, int amount) async {
    try {
      String? token = await getToken();
      if(token==null) return false;

      String timestamp = DateTime.now().toString().replaceAll("-", "").replaceAll(":", "").split(".")[0].replaceAll(" ", "").substring(0,14);
      // format: yyyyMMddHHmmss
      DateTime now = DateTime.now();
      timestamp = "${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}${now.hour.toString().padLeft(2,'0')}${now.minute.toString().padLeft(2,'0')}${now.second.toString().padLeft(2,'0')}";

      String password = base64Encode(utf8.encode("$shortCode$passKey$timestamp"));

      String phoneFormatted = phone.replaceAll("+", "");
      if(phoneFormatted.startsWith("0")) phoneFormatted = "254${phoneFormatted.substring(1)}";

      var body = {
        "BusinessShortCode": shortCode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": phoneFormatted,
        "PartyB": shortCode,
        "PhoneNumber": phoneFormatted,
        "CallBackURL": "https://mydomain.com/callback",
        "AccountReference": "ReelMax",
        "TransactionDesc": "ReelMax PRO"
      };

      var res = await http.post(Uri.parse("$baseUrl/mpesa/stkpush/v1/processrequest"),
        headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
        body: jsonEncode(body));

      print("MPESA RES: ${res.body}");
      return res.statusCode==200;
    } catch(e){
      print("MPESA Error $e");
      return false;
    }
  }
}
