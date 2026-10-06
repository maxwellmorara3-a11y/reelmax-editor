import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phone = TextEditingController(text: "+254");
  bool loading = false;
  login() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_phone", phone.text);
    await prefs.setBool("is_logged", true);
    setState(() => loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome ${phone.text}!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Login to ReelMax", style: TextStyle(color: Colors.white)), iconTheme: IconThemeData(color: Colors.white)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 20),
          Text("Login to save projects", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text("Your projects sync to phone", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 30),
          TextField(controller: phone, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Phone", filled: true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: loading? null : login, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7B61FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Login / Sign Up"))),
        ]),
      ),
    );
  }
}
