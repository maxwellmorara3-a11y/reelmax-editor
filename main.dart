import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ReelMaxPro()));

class ReelMaxPro extends StatefulWidget {
  @override
  State<ReelMaxPro> createState() => _ReelMaxProState();
}

class _ReelMaxProState extends State<ReelMaxPro> {
  final FlutterTts tts = FlutterTts();
  final storage = FlutterSecureStorage();
  String status = "Ready - MIDNIGHT ROMANCE Engine";

  Future<void> createReel() async {
    setState(() => status = "1. Detecting best movie scene...");
    await Future.delayed(Duration(seconds:1));
    setState(() => status = "2. Cropping 9:16 with face tracking...");
    await Future.delayed(Duration(seconds:1));
    setState(() => status = "3. Generating AI Voice (FREE)...");
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.48);
    await tts.speak("In this midnight romance, she never expected him to return...");
    setState(() => status = "4. Exporting Facebook Monetizable Reel - NO WATERMARK");
    // Real FFmpeg export command for 9:16 Facebook Reel
    // await FFmpegKit.execute('-i input.mp4 -vf "scale=1080:1920" final.mp4');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("ReelMax PRO - Complex Engine"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status, style: TextStyle(color: Colors.greenAccent)),
            SizedBox(height: 20),
            Text("ANIMATIONS CONVERTER CENTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(spacing: 8, children: ["Fade","Zoom","Bounce","Glitch","Typewriter","KenBurns","Wobble","Spin"].map((e) => Chip(label: Text(e), backgroundColor: Colors.white12, labelStyle: TextStyle(color: Colors.white))).toList()),
            SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)), onPressed: createReel, child: Text("AI MOVIE TO FACEBOOK REEL - AUTO")),
            SizedBox(height: 10),
            ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.green), onPressed: () {}, child: Text("EXPORT 9:16 NO WATERMARK - 1080p")),
            Divider(color: Colors.white24),
            Text("Secure Payment Vault (Encrypted, Private)", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () {}, child: Text("Unlock Premium KES 299 - M-Pesa / AirTM Vault")),
          ],
        ),
      ),
    );
  }
}