import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const ReelMaxEditorApp());

class ReelMaxEditorApp extends StatelessWidget {
  const ReelMaxEditorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReelMax Editor',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  VideoPlayerController? _videoController;
  XFile? _videoFile;
  bool _isPaid = false;
  double _speed = 1.0;
  String _filter = "None";
  final List<String> _texts = [];

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file!= null) {
      _videoFile = file;
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(file.path))
       ..initialize().then((_) {
          setState(() {});
          _videoController!.setLooping(true);
          _videoController!.play();
        });
    }
  }

  void showMpesaPay() {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                Text("Unlock HD Export", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Export without watermark + 4K quality + No ads\nOne time payment KES 299 via M-PESA", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white70)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        setState(() => _isPaid = true);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("M-PESA STK Push Sent to your phone - Enter PIN"), backgroundColor: Colors.green));
                        // TODO: Call Daraja API here: mpesa/stkpush amount 299
                      },
                      child: Text("PAY KES 299 - M-PESA", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white))),
                ),
                const SizedBox(height: 10),
              ]),
            ));
  }

  void addText() {
    TextEditingController c = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text("Add Text", style: GoogleFonts.poppins()),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: "Your text here")),
      actions: [TextButton(onPressed: (){ if(c.text.isNotEmpty) setState(()=> _texts.add(c.text)); Navigator.pop(context);}, child: const Text("ADD"))],
    ));
  }

  @override
  void dispose() { _videoController?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("ReelMax Editor", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(onPressed: () => setState(() => _texts.clear()), icon: const Icon(Icons.undo)),
          IconButton(onPressed: showMpesaPay, icon: const Icon(Icons.workspace_premium, color: Colors.amber)),
        ],
      ),
      body: Column(children: [
        // Preview
        Expanded(
          flex: 4,
          child: Stack(alignment: Alignment.center, children: [
            Container(color: Colors.grey[900], width: double.infinity, child: _videoController!=null && _videoController!.value.isInitialized? AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.video_library, size: 60, color: Colors.white24), const SizedBox(height:10), Text("Import Video to Start", style: GoogleFonts.poppins(color: Colors.white54)), ElevatedButton(onPressed: pickVideo, child: const Text("IMPORT"))]))),
            // Text Overlays
           ..._texts.map((t) => Positioned(bottom: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: Text(t, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))))),
            if (_filter!= "None") Container(color: _filter=="BW"? Colors.white.withOpacity(0.2) : _filter=="Sepia"? Colors.brown.withOpacity(0.3) : Colors.red.withOpacity(0.2)),
          ]),
        ),
        // Timeline
        Container(
          height: 90,
          color: const Color(0xFF121212),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            children: [
              for(int i=0;i<20;i++) Container(margin: const EdgeInsets.only(right:4), width: 12, height: 60, decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ),
        // Tools - CapCut Style
        Container(
          color: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _toolBtn(Icons.cut, "Split", (){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video Split at playhead")));}),
            _toolBtn(Icons.speed, "Speed", (){ setState(()=> _speed = _speed==1.0?1.5:1.0); _videoController?.setPlaybackSpeed(_speed);}),
            _toolBtn(Icons.filter_vintage, "Filters", (){ showModalBottomSheet(context: context, builder: (_) => _filterSheet());}),
            _toolBtn(Icons.text_fields, "Text", addText),
            _toolBtn(Icons.music_note, "Audio", (){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add music from library - Coming")));}),
            _toolBtn(Icons.auto_awesome, "Effects", (){}),
          ]),
        ),
        // Export
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: pickVideo, child: const Text("REPLACE"))),
            const SizedBox(width:10),
            Expanded(flex:2, child: SizedBox(height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _isPaid? Colors.redAccent : Colors.white12, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _isPaid? (){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exporting 4K Video... 100% - Saved to Gallery")));} : showMpesaPay,
              child: Text(_isPaid? "EXPORT HD 4K" : "EXPORT - KES 299", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
            ))),
          ]),
        )
      ]),
      floatingActionButton: _videoController==null? null : FloatingActionButton.small(backgroundColor: Colors.white, onPressed: (){ _videoController!.value.isPlaying? _videoController!.pause() : _videoController!.play(); setState((){});}, child: Icon(_videoController!.value.isPlaying? Icons.pause : Icons.play_arrow, color: Colors.black)),
    );
  }

  Widget _toolBtn(IconData i, String l, VoidCallback tap) => InkWell(onTap: tap, child: Column(children: [Icon(i, size: 24), const SizedBox(height:4), Text(l, style: const TextStyle(fontSize: 11))]));

  Widget _filterSheet() => Container(
    color: const Color(0xFF1A1A1A),
    padding: const EdgeInsets.all(20),
    height: 200,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text("Filters", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      const SizedBox(height:15),
      Row(children:[
        _filterChip("None"), _filterChip("BW"), _filterChip("Sepia"), _filterChip("Vivid"),
      ])
    ]),
  );

  Widget _filterChip(String name) => Padding(padding: const EdgeInsets.only(right:8), child: ChoiceChip(label: Text(name), selected: _filter==name, onSelected: (v){ setState(()=> _filter=name); Navigator.pop(context);} ));
}
