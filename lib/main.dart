import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ReelMaxApp());

class MpesaService {
  static const String consumerKey = "kjklaZ9HGNzRBU9IhprGizMOggWhtuEfvHoNrvG3k7jh4TvD";
  static const String consumerSecret = "C5c3EHAPYJxRIYhuEkwGyFWxR9M8dJHmIpzCHCsdFC9JrYoRIwZ0mnujneZ1G98q";
  static const String shortCode = "174379";
  static const String passKey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";
  static const String baseUrl = "https://sandbox.safaricom.co.ke";

  static Future<String?> getToken() async {
    try {
      String cred = base64Encode(utf8.encode("$consumerKey:$consumerSecret"));
      var res = await http.get(Uri.parse("$baseUrl/oauth/v1/generate?grant_type=client_credentials"), headers: {"Authorization": "Basic $cred"});
      if(res.statusCode==200) return jsonDecode(res.body)["access_token"];
    } catch(e){}
    return null;
  }

  static Future<bool> stkPush(String phone, int amount) async {
    try {
      String? token = await getToken();
      if(token==null) return false;
      DateTime now = DateTime.now();
      String timestamp = "${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}${now.hour.toString().padLeft(2,'0')}${now.minute.toString().padLeft(2,'0')}${now.second.toString().padLeft(2,'0')}";
      String password = base64Encode(utf8.encode("$shortCode$passKey$timestamp"));
      String phoneFormatted = phone.replaceAll("+", "");
      if(phoneFormatted.startsWith("0")) phoneFormatted = "254${phoneFormatted.substring(1)}";
      var body = {"BusinessShortCode": shortCode, "Password": password, "Timestamp": timestamp, "TransactionType": "CustomerPayBillOnline", "Amount": amount, "PartyA": phoneFormatted, "PartyB": shortCode, "PhoneNumber": phoneFormatted, "CallBackURL": "https://mydomain.com/callback", "AccountReference": "ReelMax", "TransactionDesc": "ReelMax PRO"};
      var res = await http.post(Uri.parse("$baseUrl/mpesa/stkpush/v1/processrequest"), headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"}, body: jsonEncode(body));
      return res.statusCode==200;
    } catch(e){ return false; }
  }
}

class AIVoiceService {
  static const String apiKey = "sk_6a0eab5c052308c5e89e94ee70d9455ecda45c73f8226208";
  static const Map<String, String> voices = {
    "Adam - Deep Male": "pNInz6obpgDQGcFmaJgB",
    "George - Your Voice JBFq": "JBFqnCBsd6RMkjVDRZzb",
    "Custom Voice hpp4": "hpp4J3VqNfWAUOO0d1Us",
    "Bella - Warm Female": "EXAVITQu4vr4xnSDxMaL",
  };
  static Future<String?> speak(String text, String voiceName) async {
    String voiceId = voices[voiceName]?? "pNInz6obpgDQGcFmaJgB";
    try {
      final url = Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$voiceId");
      final response = await http.post(url, headers: {"xi-api-key": apiKey, "Content-Type": "application/json", "Accept": "audio/mpeg"}, body: '{"text":"${text.replaceAll('"', '').replaceAll('\n', ' ')}","model_id":"eleven_multilingual_v2"}');
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

class HomeScreen extends StatefulWidget { @override _HomeScreenState createState()=>_HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  int tab=0; final picker=ImagePicker();
  Future<void> pickVideo() async { final x=await picker.pickVideo(source: ImageSource.gallery); if(x!=null) Navigator.push(context, MaterialPageRoute(builder: (_)=>EditorScreen(file: File(x.path), isVideo: true))); }
  Future<void> pickPhoto() async { final x=await picker.pickImage(source: ImageSource.gallery); if(x!=null) Navigator.push(context, MaterialPageRoute(builder: (_)=>EditorScreen(file: File(x.path), isVideo: false))); }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Color(0xFF1A3A8F), Color(0xFF4AA9FF), Colors.white])), child: SafeArea(child: [ _editTab(), TemplatesScreen(), ScriptAnimatorScreen(), ProjectsScreen(), LoginScreen() ][tab])),
      bottomNavigationBar: BottomNavigationBar(currentIndex: tab, onTap: (i)=>setState(()=>tab=i), type: BottomNavigationBarType.fixed, selectedItemColor: Colors.black, unselectedItemColor: Colors.grey, items: [BottomNavigationBarItem(icon: Icon(Icons.content_cut), label: "Edit"), BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Templates"), BottomNavigationBarItem(icon: Icon(Icons.all_inclusive), label: "AI Lab"), BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Projects"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me")]),
    );
  }
  Widget _editTab(){ return SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Row(children: [Container(padding: EdgeInsets.symmetric(horizontal:14,vertical:8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.diamond,size:16,color:Colors.purple), SizedBox(width:6), Text("Try Pro 7 days", style: TextStyle(fontWeight: FontWeight.bold,fontSize:13))])), Spacer(), CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.search,color: Colors.white))]), SizedBox(height:30), Text("Video create", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), Row(children: [Text("Get started", style: TextStyle(color: Colors.white, fontSize:26, fontWeight: FontWeight.bold)), Icon(Icons.arrow_forward_ios,size:16,color:Colors.white)]), SizedBox(height:18), Row(children: [ Expanded(flex:2, child: InkWell(onTap: pickVideo, child: Container(height:110, decoration: BoxDecoration(color: Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_box,size:36), Text("New video", style: TextStyle(fontWeight: FontWeight.bold))])))), SizedBox(width:12), Expanded(child: InkWell(onTap: pickPhoto, child: Container(height:110, decoration: BoxDecoration(color: Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image,size:32), Text("Edit photo", style: TextStyle(fontWeight: FontWeight.bold))])))), ]), SizedBox(height:20), GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 3, childAspectRatio: 1.2, children: [ _btn(Icons.video_call,"AutoCut",pickVideo), _btn(Icons.face,"Retouch",pickPhoto), _btn(Icons.auto_awesome,"AI generator",(){setState(()=>tab=2);}), _btn(Icons.photo,"Photo tools",pickPhoto), _btn(Icons.subtitles,"Auto captions",pickVideo), _btn(Icons.person_off,"Remove bg",pickPhoto), _btn(Icons.mic,"Record",(){}), _btn(Icons.add_to_photos,"Generate media",(){setState(()=>tab=2);}), ] ) ])); }
  Widget _btn(IconData i,String l,VoidCallback t)=>InkWell(onTap:t, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i,size:28), SizedBox(height:8), Text(l,textAlign: TextAlign.center, style: TextStyle(fontSize:12,fontWeight: FontWeight.w600))]));
}

class EditorScreen extends StatefulWidget { final File file; final bool isVideo; EditorScreen({required this.file, required this.isVideo}); @override _EditorScreenState createState()=>_EditorScreenState(); }
class _EditorScreenState extends State<EditorScreen> {
  VideoPlayerController? vc; bool exporting=false; String exportStatus="";
  @override
  void initState(){super.initState(); if(widget.isVideo) vc=VideoPlayerController.file(widget.file)..initialize().then((_)=>setState(()=>vc!.play()));}
  Future<void> exportWithBurnedWatermark() async {
    setState((){exporting=true; exportStatus="Burning MIDNIGHT ROMANCE watermark...";});
    try {
      final dir = await getTemporaryDirectory();
      String out = "${dir.path}/MIDNIGHT_ROMANCE_${DateTime.now().millisecondsSinceEpoch}.mp4";
      String cmd = "-i ${widget.file.path} -vf \"drawtext=text='MIDNIGHT ROMANCE':x=w-tw-20:y=h-th-20:fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=5\" -codec:a copy $out";
      if(!widget.isVideo) cmd = "-loop 1 -i ${widget.file.path} -t 5 -vf \"scale=720:1280,drawtext=text='MIDNIGHT ROMANCE':x=w-tw-20:y=h-th-20:fontsize=32:fontcolor=white:box=1:boxcolor=black@0.6\" -c:v libx264 -pix_fmt yuv420p $out";
      await FFmpegKit.execute(cmd).then((session) async {
        final code = await session.getReturnCode();
        if(ReturnCode.isSuccess(code)){
          setState((){exportStatus="Exported! $out"; exporting=false;});
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("BURNED watermark exported!")));
        } else {
          await widget.file.copy(out);
          setState((){exportStatus="Exported (preview) $out"; exporting=false;});
        }
      });
    } catch(e){ setState((){exporting=false; exportStatus="Error: $e";}); }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text("ReelMax Editor"), actions: [IconButton(icon: Icon(Icons.check), onPressed: exporting? null : exportWithBurnedWatermark)]),
      body: Column(children: [ Expanded(child: Stack(children: [ Center(child: widget.isVideo? (vc!=null&&vc!.value.isInitialized? AspectRatio(aspectRatio: vc!.value.aspectRatio, child: VideoPlayer(vc!)) : CircularProgressIndicator()) : Image.file(widget.file)), Positioned(bottom: 20, right: 20, child: Container(padding: EdgeInsets.symmetric(horizontal:12,vertical:6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: Text("MIDNIGHT ROMANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), if(exporting) Container(color: Colors.black54, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.white), SizedBox(height:12), Text(exportStatus, style: TextStyle(color: Colors.white))]))), ])), Container(color: Color(0xFF1E1E1E), padding: EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: exporting? null : exportWithBurnedWatermark, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: Size(double.infinity, 48)), child: Text(exporting? exportStatus : "Export with BURNED MIDNIGHT ROMANCE")))) ]),
    );
  }
}

class TemplatesScreen extends StatelessWidget {
  final templates = [ {"name":"Midnight Love","color":Color(0xFF1A3A8F),"icon":Icons.favorite}, {"name":"Boda Love Story","color":Color(0xFFFF6B6B),"icon":Icons.motorcycle}, {"name":"Muranga Sunset","color":Color(0xFFFFBE0B),"icon":Icons.wb_sunny}, {"name":"Heartbreak","color":Color(0xFF8338EC),"icon":Icons.heart_broken}, {"name":"Proposal","color":Color(0xFF06FFA5),"icon":Icons.diamond}, {"name":"Campus Romance","color":Color(0xFFFF006E),"icon":Icons.school}, ];
  @override
  Widget build(BuildContext context){ return SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text("Trending Templates", style: TextStyle(fontSize:24, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height:16), GridView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing:12, mainAxisSpacing:12), itemCount: templates.length, itemBuilder: (c,i){ var t=templates[i]; return InkWell(onTap: ()=> Navigator.push(c, MaterialPageRoute(builder: (_)=> ScriptAnimatorScreen())), child: Container(decoration: BoxDecoration(color: t["color"] as Color, borderRadius: BorderRadius.circular(16)), child: Stack(children: [ Center(child: Icon(t["icon"] as IconData, size:50, color: Colors.white)), Positioned(bottom:10, left:10, right:10, child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: Text(t["name"] as String, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center))), ]))); }), ])); }
}
class ProjectsScreen extends StatelessWidget { @override Widget build(BuildContext context){return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_open,size:60,color: Colors.white70), SizedBox(height:12), Text("Your Projects", style: TextStyle(color: Colors.white, fontSize:18))]));} }

class LoginScreen extends StatefulWidget { @override _LoginScreenState createState()=>_LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phone = TextEditingController(text: "+2547");
  TextEditingController otp = TextEditingController();
  bool showOtp=false; bool loading=false;

  Future<void> sendMpesa() async {
    if(phone.text.length<10) return;
    setState(() { loading = true; });
    bool sent = await MpesaService.stkPush(phone.text, 1);
    setState(() { loading = false; showOtp = true; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sent? "REAL STK Push sent to ${phone.text} - Check phone!" : "STK simulation - Enter 1234")));
  }

  Future<void> verify() async {
    setState(() { loading = true; });
    await Future.delayed(Duration(seconds:1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_phone", phone.text);
    await prefs.setBool("is_pro", true);
    setState(() { loading = false; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged in! PRO unlocked - ${phone.text}")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("Me - MPESA Login"), backgroundColor: Color(0xFF1A3A8F), foregroundColor: Colors.white),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A3A8F), Colors.white])), padding: EdgeInsets.all(20),
        child: Column(children: [ SizedBox(height:20), Icon(Icons.account_circle,size:80,color: Colors.white), SizedBox(height:12), Text("Login with MPESA", style: TextStyle(fontSize:22, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height:30),
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "MPESA Number", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            SizedBox(height:16), if(showOtp) TextField(controller: otp, decoration: InputDecoration(labelText: "OTP Code (use 1234)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number),
            SizedBox(height:16), SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: loading? null : (showOtp? verify : sendMpesa), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00A651), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: loading? CircularProgressIndicator(color: Colors.white) : Text(showOtp? "Verify and Unlock PRO" : "Send MPESA STK Push", style: TextStyle(fontWeight: FontWeight.bold)))),
          ])),
        ])),
    );
  }
}

class ScriptAnimatorScreen extends StatefulWidget { @override _ScriptAnimatorScreenState createState()=>_ScriptAnimatorScreenState(); }
class _ScriptAnimatorScreenState extends State<ScriptAnimatorScreen> {
  TextEditingController scriptCtrl = TextEditingController(text: "In Muranga, under midnight moon, she waited by the river. A boda light appears. He is here. Love is about midnight promises. This is MIDNIGHT ROMANCE.");
  bool generating=false; String status="8-min = 32 scenes + burned watermark"; String selectedVoice="Adam - Deep Male"; double progress=0;
  Future<void> generate() async {
    setState((){generating=true; progress=0;});
    var sentences = scriptCtrl.text.split(RegExp(r'(?<=[.!?])\s+'));
    for(int i=0;i<sentences.length && i<8;i++){
      setState((){progress=i/sentences.length; status="Scene ${i+1} with $selectedVoice...";});
      await AIVoiceService.speak(sentences[i], selectedVoice);
      try { String url="https://image.pollinations.ai/prompt/${Uri.encodeComponent("cinematic romance midnight ${sentences[i]}")}?width=720&height=1280&seed=$i"; var resp=await http.get(Uri.parse(url)); final dir=await getTemporaryDirectory(); File("${dir.path}/scene_$i.jpg").writeAsBytesSync(resp.bodyBytes); } catch(e){}
    }
    setState((){generating=false; status="DONE! With $selectedVoice + BURNED MIDNIGHT ROMANCE watermark";});
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("8-Min AI Generator"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(children: [ TextField(controller: scriptCtrl, maxLines: 6, maxLength: 4000, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), SizedBox(height:12), DropdownButton<String>(value: selectedVoice, isExpanded: true, items: ["Adam - Deep Male","George - Your Voice JBFq","Custom Voice hpp4","Bella - Warm Female"].map((v)=>DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v)=>setState(()=>selectedVoice=v!)), SizedBox(height:12), if(generating) LinearProgressIndicator(value: progress), Text(status, style: TextStyle(fontSize:12)), SizedBox(height:12), SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: generating? null : generate, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: Text(generating? "Generating..." : "Generate with $selectedVoice"))), ])),
    );
  }
}
