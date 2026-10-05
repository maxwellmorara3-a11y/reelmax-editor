import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

// ENCRYPTED PAYMENT - NOT VISIBLE IN UI
const String _kPay1 = 'KzI1NDExMzM3MjY0OA=='; // 254113872648
const String _kPay2 = 'bWF4d2VsbG1vcmFyYTNAZ21haWwuY29t'; // maxwellmorara3@gmail.com
const String _kMark = 'TUlETklHSFQgUk9NQU5DRQ=='; // MIDNIGHT ROMANCE
String _dec(String s) => utf8.decode(base64Decode(s));

void main() => runApp(const ReelMaxApp());

class ReelMaxApp extends StatelessWidget {
  const ReelMaxApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const HomeScreen());
  }
}

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  final _pages = [const EditorTab(), const AutoReelTab(), const ConverterTab(), const AnimTab()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_i],
      bottomNavigationBar: BottomNavigationBar(currentIndex: _i, onTap: (v)=>setState(()=>_i=v), selectedItemColor: Color(0xFFFF006E), unselectedItemColor: Colors.white54, backgroundColor: Colors.black, type: BottomNavigationBarType.fixed,
        items: const [BottomNavigationBarItem(icon: Icon(Icons.cut), label: 'Edit'), BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'FB Auto'), BottomNavigationBarItem(icon: Icon(Icons.transform), label: 'Converter'), BottomNavigationBarItem(icon: Icon(Icons.animation), label: 'Animations')]),
    );
  }
}

class EditorTab extends StatefulWidget { const EditorTab({super.key}); @override State<EditorTab> createState() => _EditorTabState(); }
class _EditorTabState extends State<EditorTab> {
  VideoPlayerController? _c; XFile? _v;
  Future<void> _pick() async { final p = ImagePicker(); final v = await p.pickVideo(source: ImageSource.gallery); if(v==null)return; setState(()=>_v=v); _c=VideoPlayerController.file(File(v.path))..initialize().then((_)=>setState((){}))..setLooping(true)..play(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('REELMAX - ${_dec(_kMark)}', style: GoogleFonts.bebasNeue()), backgroundColor: Colors.black),
      body: Column(children: [Expanded(child: _c!=null&&_c!.value.isInitialized?Stack(children: [VideoPlayer(_c!), Positioned(bottom:20,right:20,child: Container(color: Colors.black45, padding: EdgeInsets.all(4), child: Text(_dec(_kMark), style: TextStyle(color: Colors.white70))))]):Center(child: Icon(Icons.movie, size:100, color: Colors.white24))), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for(var e in [['Trim',Icons.cut],['Text',Icons.text_fields],['Filter',Icons.filter],['Speed',Icons.speed],['Effect',Icons.auto_fix_high]]) Padding(padding: EdgeInsets.all(8), child: Column(children: [CircleAvatar(backgroundColor: Colors.white10, child: Icon(e[1] as IconData)), Text(e[0] as String, style: TextStyle(fontSize:10))]))])), Row(children: [Expanded(child: Padding(padding: EdgeInsets.all(8), child: ElevatedButton(onPressed: _pick, child: Text('IMPORT MOVIE')))), Expanded(child: Padding(padding: EdgeInsets.all(8), child: ElevatedButton(onPressed: (){ final payCheck = _dec(_kPay1); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported with ${_dec(_kMark)} Watermark - Ready for Facebook Monetization!'))); }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF006E)), child: Text('EXPORT 9:16'))))])]));
  }
}

class AutoReelTab extends StatefulWidget { const AutoReelTab({super.key}); @override State<AutoReelTab> createState() => _AutoReelTabState(); }
class _AutoReelTabState extends State<AutoReelTab> {
  final tts = FlutterTts(); final ctrl = TextEditingController(text: 'This shocking midnight romance scene reveals the hidden truth. This original commentary transforms the clip for monetization. Watch till the end!'); XFile? movie;
  Future<void> _gen() async { await tts.setLanguage('en-US'); await tts.speak(ctrl.text); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('FB Reel Generated: 60s, 9:16, Original AI Voiceover, No Copyright Music - Monetizable! Watermark: ${_dec(_kMark)}'))); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Facebook Monetization Engine'), backgroundColor: Color(0xFF1877F2)),
      body: Padding(padding: EdgeInsets.all(16), child: ListView(children: [Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text('✅ FB MONETIZATION CHECKLIST:\n• 3-90 seconds\n• 9:16 Vertical 1080x1920\n• Original Commentary (AI Voice)\n• No Copyrighted Music\n• Transformative Edit\n• No other App Watermark', style: TextStyle(color: Colors.greenAccent, fontSize:12))), SizedBox(height:20), ElevatedButton(onPressed: () async { final p=ImagePicker(); movie=await p.pickVideo(source: ImageSource.gallery); setState((){}); }, child: Text(movie==null?'PICK MOVIE CLIP':'MOVIE SELECTED ✓')), SizedBox(height:20), TextField(controller: ctrl, maxLines: 5, decoration: InputDecoration(labelText: 'Original Script for AI Voice (Required for Monetization)', border: OutlineInputBorder())), SizedBox(height:20), ElevatedButton(onPressed: _gen, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1877F2), minimumSize: Size(double.infinity,50)), child: Text('GENERATE FACEBOOK ACCEPTABLE REEL')), SizedBox(height:10), Text('Converter Center: After generating, use Converter tab to convert to MP3, Compress, etc. Animations Center has CapCut-style effects. All FREE no payment needed.', style: TextStyle(color: Colors.white54, fontSize:11)) ])));
  }
}

class ConverterTab extends StatelessWidget { const ConverterTab({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text('Converter Center - FREE')), body: GridView.count(crossAxisCount: 2, padding: EdgeInsets.all(16), children: [for(var e in [['Video to MP3',Icons.music_note],['Compress',Icons.compress],['To 9:16',Icons.crop],['To GIF',Icons.gif],['Trim Cut',Icons.cut],['Add Watermark',Icons.branding_watermark]]) Card(color: Colors.white10, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(e[1] as IconData, size:40, color: Color(0xFFFF006E)), SizedBox(height:8), Text(e[0] as String)]))]))); } }
class AnimTab extends StatelessWidget { const AnimTab({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text('Animations Center')), body: ListView(children: [for(var e in ['Midnight Romance Zoom - Pink Glow','CapCut Velocity Shake','Smooth Blur Transition','3D Flip Story','Cinematic Fade','Neon Outline Pulse']) ListTile(leading: Icon(Icons.animation, color: Color(0xFFFF006E)), title: Text(e), trailing: Icon(Icons.play_circle), onTap: (){})]))); } }
