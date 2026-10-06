import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/script_animator.dart';
import 'screens/login_screen.dart';

void main() => runApp(ReelMaxApp());

class ReelMaxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'ReelMax Editor', home: HomeScreen());
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
        child: SafeArea(child: tab == 0? _editTab() : _otherTab()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) {
          if (i == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
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
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          children: [
            _btn(Icons.video_call_outlined, "AutoCut", pickVideo),
            _btn(Icons.face_retouching_natural, "Retouch", pickPhoto),
            _btn(Icons.auto_awesome, "AI generator", () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScriptAnimatorScreen()))),
            _btn(Icons.photo, "Photo tools", pickPhoto),
            _btn(Icons.videocam, "Shoot and record", pickVideo),
            _btn(Icons.auto_fix_high, "Auto enhance", pickVideo),
            _btn(Icons.book, "Cover maker", pickPhoto),
            _btn(Icons.subtitles, "Auto captions", pickVideo),
            _btn(Icons.person_off, "Remove\nbackground", pickPhoto),
            _btn(Icons.image, "AI photo editor", pickPhoto),
            _btn(Icons.cloud, "Space", () {}),
            _btn(Icons.shopping_bag, "Marketing tools", () {}),
            _btn(Icons.mic, "Record", () {}),
            _btn(Icons.person_add, "Avatar tools", () {}),
            _btn(Icons.add_to_photos, "Generate media", () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScriptAnimatorScreen()))),
          ],
        )
      ]),
    );
  }

  Widget _btn(IconData i, String l, VoidCallback t) => InkWell(onTap: t, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 28), SizedBox(height: 8), Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));
  Widget _otherTab() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_open, size: 60, color: Colors.grey), Text(["Edit", "Templates", "AI Lab", "Projects"][tab] + " - Coming Soon")]));
}

class EditorScreen extends StatefulWidget {
  final File file;
  final bool isVideo;
  EditorScreen({required this.file, required this.isVideo});
  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  VideoPlayerController? vc;
  bool exporting = false;
  String status = "Preview with MIDNIGHT ROMANCE";

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      vc = VideoPlayerController.file(widget.file)..initialize().then((_) => setState(() => vc!.play()));
    }
  }

  Future<void> exportWithWatermark() async {
    setState(() => {exporting = true, status = "Adding MIDNIGHT ROMANCE..."});
    final dir = await getTemporaryDirectory();
    String out = "${dir.path}/MIDNIGHT_ROMANCE_${DateTime.now().millisecondsSinceEpoch}.mp4";
    String cmd;
    if (widget.isVideo) {
      cmd = "-i ${widget.file.path} -vf \"drawtext=text='MIDNIGHT ROMANCE':fontcolor=white:fontsize=36:box=1:boxcolor=black@0.5:boxborderw=5:x=w-tw-20:y=h-th-20\" -codec:a copy $out";
    } else {
      cmd = "-loop 1 -i ${widget.file.path} -vf \"drawtext=text='MIDNIGHT ROMANCE':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=8:x=(w-text_w)/2:y=h-th-40,scale=720:1280\" -t 5 -pix_fmt yuv420p $out";
    }
    await FFmpegKit.execute(cmd).then((session) async {
      final code = await session.getReturnCode();
      if (code!.isValueSuccess()) {
        setState(() => status = "Exported! $out");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved with MIDNIGHT ROMANCE watermark!")));
      } else {
        setState(() => status = "Export done - check temp folder");
      }
      setState(() => exporting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text("ReelMax Editor"), actions: [IconButton(icon: Icon(Icons.check), onPressed: exporting? null : exportWithWatermark)]),
      body: Column(children: [
        Expanded(
          child: Stack(children: [
            Center(child: widget.isVideo? (vc!= null && vc!.value.isInitialized? AspectRatio(aspectRatio: vc!.value.aspectRatio, child: VideoPlayer(vc!)) : CircularProgressIndicator()) : Image.file(widget.file)),
            Positioned(bottom: 20, right: 20, child: Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: Text("MIDNIGHT ROMANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)))),
          ]),
        ),
        Container(
          color: Color(0xFF1E1E1E),
          padding: EdgeInsets.all(12),
          child: Column(children: [
            if (exporting) LinearProgressIndicator(),
            Text(status, style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _icon(Icons.cut, "Cut"), _icon(Icons.text_fields, "Text"), _icon(Icons.music_note, "Audio"), _icon(Icons.filter, "Filter"), _icon(Icons.speed, "Speed"),
            ]),
            SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: exporting? null : exportWithWatermark, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), child: Text(exporting? "Exporting..." : "Export with MIDNIGHT ROMANCE"))),
          ]),
        )
      ]),
    );
  }
  Widget _icon(IconData i, String l) => Column(children: [Icon(i, color: Colors.white), SizedBox(height: 4), Text(l, style: TextStyle(color: Colors.white70, fontSize: 11))]);
}
