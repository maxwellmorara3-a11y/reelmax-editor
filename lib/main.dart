import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ReelMaxApp());

// ===== YOUR VOICES + KEY =====
class AIVoiceService {
  static const String apiKey = "sk_6a0eab5c052308c5e89e94ee70d9455ecda45c73f8226208"; // Your key
  static const Map<String, String> voices = {
    "Adam - Deep Male": "pNInz6obpgDQGcFmaJgB",
    "George - Your Voice JBFq": "JBFqnCBsd6RMkjVDRZzb",
    "Custom Voice hpp4": "hpp4J3VqNfWAUOO0d1Us",
    "Bella - Warm Female": "EXAVITQu4vr4xnSDxMaL",
    "Josh - Male Storyteller": "TxGEqnHWrfWFTfGW9XjX",
  };
  static Future<String?> speak(String text, String voiceName) async {
    String voiceId = voices[voiceName]?? "pNInz6obpgDQGcFmaJgB";
    try {
      final url = Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$voiceId");
      final response = await http.post(
        url,
        headers: {"xi-api-key": apiKey, "Content-Type": "application/json", "Accept": "audio/mpeg"},
        body: '{"text":"${text.replaceAll('"', '').replaceAll('\n', ' ')}","model_id":"eleven_multilingual_v2","voice_settings":{"stability":0.45,"similarity_boost":0.85}}',
      );
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/ai_${DateTime.now().millisecondsSinceEpoch}.mp3");
        await file.writeAsBytes(response.bodyBytes);
        final player = AudioPlayer();
        await player.play(DeviceFileSource(file.path));
        return file.path;
      }
    } catch (e) {}
    return null;
  }
}

class ReelMaxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  final picker = ImagePicker();
  Future<void> pickVideo() async {
    final x = await picker.pickVideo(source: ImageSource.gallery);
    if (x!= null) Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(file: File(x.path), isVideo: true)));
  }
  Future<void> pickPhoto() async {
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x!= null) Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(file: File(x.path), isVideo: false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Color(0xFF1A3A8F), Color(0xFF4AA9FF), Colors.white])),
        child: SafeArea(child: _editTab()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) {
          if (i == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => ScriptAnimatorScreen()));
          else setState(() => tab = i);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.content_cut), label: "Edit"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Templates"),
          BottomNavigationBarItem(icon: Icon(Icons.all_inclusive), label: "AI Lab"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
        ],
      ),
    );
  }

  Widget _editTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.diamond, size: 16, color: Colors.purple), SizedBox(width: 6), Text("Try Pro 7 days for -", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))])),
          Spacer(), CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.search, color: Colors.white)),
        ]),
        SizedBox(height: 35),
        Text("Video create", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        Row(children: [Text("Get started", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)), Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white)]),
        SizedBox(height: 18),
        Row(children: [
          Expanded(flex: 2, child: InkWell(onTap: pickVideo, child: Container(height: 110, decoration: BoxDecoration(color: Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_box, size: 36), SizedBox(height: 6), Text("New video", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])))),
          SizedBox(width: 12),
          Expanded(child: InkWell(onTap: pickPhoto, child: Container(height: 110, decoration: BoxDecoration(color: Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image, size: 32), SizedBox(height: 6), Text("Edit photo", style: TextStyle(fontWeight: FontWeight.bold))])))),
        ]),
        SizedBox(height: 22),
        GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 3, childAspectRatio: 1.2, children: [
          _btn(Icons.video_call_outlined, "AutoCut", pickVideo),
          _btn(Icons.face_retouching_natural, "Retouch", pickPhoto),
          _btn(Icons.auto_awesome, "AI generator", () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScriptAnimatorScreen()))),
          _btn(Icons.photo, "Photo tools", pickPhoto),
          _btn(Icons.videocam, "Shoot", pickVideo),
          _btn(Icons.auto_fix_high, "Auto enhance", pickVideo),
          _btn(Icons.book, "Cover maker", pickPhoto),
          _btn(Icons.subtitles, "Auto captions", pickVideo),
          _btn(Icons.person_off, "Remove bg", pickPhoto),
          _btn(Icons.image, "AI photo", pickPhoto),
          _btn(Icons.cloud, "Space", () {}),
          _btn(Icons.shopping_bag, "Marketing", () {}),
          _btn(Icons.mic, "Record", () {}),
          _btn(Icons.person_add, "Avatar", () {}),
          _btn(Icons.add_to_photos, "Generate media", () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScriptAnimatorScreen()))),
        ])
      ]),
    );
  }
  Widget _btn(IconData i, String l, VoidCallback t) => InkWell(onTap: t, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 28), SizedBox(height: 8), Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));
}

class EditorScreen extends StatefulWidget {
  final File file; final bool isVideo;
  EditorScreen({required this.file, required this.isVideo});
  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  VideoPlayerController? vc;
  @override
  void initState() {
    super.initState();
    if (widget.isVideo) vc = VideoPlayerController.file(widget.file)..initialize().then((_) => setState(() => vc!.play()));
  }
  Future<void> export() async {
    final dir = await getTemporaryDirectory();
    String out = "${dir.path}/MIDNIGHT_ROMANCE_${DateTime.now().millisecondsSinceEpoch}.mp4";
    await widget.file.copy(out);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exported: $out")));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text("ReelMax Editor"), actions: [IconButton(icon: Icon(Icons.check), onPressed: export)]),
      body: Column(children: [
        Expanded(child: Stack(children: [
          Center(child: widget.isVideo? (vc!= null && vc!.value.isInitialized? AspectRatio(aspectRatio: vc!.value.aspectRatio, child: VideoPlayer(vc!)) : CircularProgressIndicator()) : Image.file(widget.file)),
          Positioned(bottom: 20, right: 20, child: Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: Text("MIDNIGHT ROMANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ])),
        Container(color: Color(0xFF1E1E1E), padding: EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: export, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), child: Text("Export with MIDNIGHT ROMANCE"))))
      ]),
    );
  }
}

class ScriptAnimatorScreen extends StatefulWidget {
  @override
  _ScriptAnimatorScreenState createState() => _ScriptAnimatorScreenState();
}

class _ScriptAnimatorScreenState extends State<ScriptAnimatorScreen> {
  TextEditingController scriptCtrl = TextEditingController(text: "In Murang'a, under midnight moon, she waited by the river. A boda light appears. He is here. Love is about midnight promises. This is MIDNIGHT ROMANCE.");
  bool generating = false;
  String status = "8-min = 32 scenes";
  String selectedVoice = "Adam - Deep Male";
  double progress = 0;

  Future<void> generate() async {
    setState(() => {generating = true, progress = 0});
    var sentences = scriptCtrl.text.split(RegExp(r'(?<=[.!?])\s+'));
    for (int i = 0; i < sentences.length && i < 8; i++) {
      setState(() => {progress = i / sentences.length, status = "Generating scene ${i+1} with $selectedVoice..."});
      await AIVoiceService.speak(sentences[i], selectedVoice);
      try {
        String url = "https://image.pollinations.ai/prompt/${Uri.encodeComponent("cinematic romance midnight ${sentences[i]}")}?width=720&height=1280&seed=$i";
        var resp = await http.get(Uri.parse(url));
        final dir = await getTemporaryDirectory();
        File("${dir.path}/scene_$i.jpg").writeAsBytesSync(resp.bodyBytes);
      } catch (e) {}
    }
    setState(() => {generating = false, status = "DONE! Played with $selectedVoice + MIDNIGHT ROMANCE watermark"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("8-Min AI Generator"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: scriptCtrl, maxLines: 6, maxLength: 4000, decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Script")),
          SizedBox(height: 12),
          DropdownButton<String>(value: selectedVoice, isExpanded: true, items: ["Adam - Deep Male", "George - Your Voice JBFq", "Custom Voice hpp4", "Bella - Warm Female", "Josh - Male Storyteller"].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => selectedVoice = v!)),
          SizedBox(height: 12),
          if (generating) LinearProgressIndicator(value: progress),
          Text(status),
          SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: generating? null : generate, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: Text(generating? "Generating..." : "Generate with $selectedVoice"))),
        ]),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phone = TextEditingController(text: "+254");
  login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_phone", phone.text);
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Login")), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [TextField(controller: phone), SizedBox(height: 20), ElevatedButton(onPressed: login, child: Text("Login"))])));
  }
}
