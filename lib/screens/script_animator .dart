import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import '../services/ai_voice_service.dart';

class ScriptAnimatorScreen extends StatefulWidget {
  @override
  _ScriptAnimatorScreenState createState() => _ScriptAnimatorScreenState();
}

class _ScriptAnimatorScreenState extends State<ScriptAnimatorScreen> {
  TextEditingController scriptCtrl = TextEditingController(text: "In Murang'a, under midnight moon, she waited by the river. A boda light appears through the mist. He is here. Love is not about distance, it is about midnight promises. Romance lives where the city sleeps. This is MIDNIGHT ROMANCE.");
  bool generating = false;
  double progress = 0;
  String status = "Enter script up to 4000 chars = 8 minutes";
  String selectedVoice = "Adam - Deep Male";

  List<String> splitScenes(String script) {
    var sentences = script.split(RegExp(r'(?<=[.!?])\s+'));
    List<String> scenes = [];
    String cur = "";
    for (var s in sentences) {
      if ((cur + s).length < 120) cur += " " + s;
      else { scenes.add(cur.trim()); cur = s; }
      if (scenes.length >= 32) break;
    }
    if (cur.isNotEmpty) scenes.add(cur.trim());
    return scenes;
  }

  Future<String> genImage(String prompt, int i) async {
    String safe = Uri.encodeComponent("cinematic romance midnight $prompt dramatic lighting 4k vertical");
    String url = "https://image.pollinations.ai/prompt/$safe?width=720&height=1280&seed=$i";
    var resp = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    File f = File("${dir.path}/scene_$i.jpg");
    await f.writeAsBytes(resp.bodyBytes);
    return f.path;
  }

  Future<void> generate8Min() async {
    if (scriptCtrl.text.length < 20) return;
    setState(() => {generating = true, progress = 0});
    List<String> scenes = splitScenes(scriptCtrl.text);
    int totalSec = scenes.length * 15;
    List<String> clips = [];
    for (int i = 0; i < scenes.length; i++) {
      setState(() => {progress = i / scenes.length, status = "Scene ${i + 1}/${scenes.length}: Generating..."});
      String img = await genImage(scenes[i], i);
      String? voicePath = await AIVoiceService.speak(scenes[i], selectedVoice);
      if (voicePath == null) {
        final dir = await getTemporaryDirectory();
        voicePath = "${dir.path}/voice_$i.mp3";
        await FFmpegKit.execute("-f lavfi -i anullsrc=r=44100:cl=mono -t 15 -q:a 9 -acodec libmp3lame $voicePath");
      }
      final dir = await getTemporaryDirectory();
      String clip = "${dir.path}/clip_$i.mp4";
      String cmd = "-loop 1 -i $img -i $voicePath -vf \"scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.0015,1.5)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='MIDNIGHT ROMANCE':fontcolor=white:fontsize=28:box=1:boxcolor=black@0.5:x=w-tw-15:y=h-th-15\" -c:v libx264 -t 15 -pix_fmt yuv420p -c:a aac -shortest $clip";
      await FFmpegKit.execute(cmd);
      clips.add(clip);
    }
    setState(() => status = "Merging ${clips.length} clips...");
    final dir = await getTemporaryDirectory();
    File list = File("${dir.path}/list.txt");
    await list.writeAsString(clips.map((p) => "file '$p'").join("\n"));
    String finalOut = "${dir.path}/MIDNIGHT_ROMANCE_${DateTime.now().millisecondsSinceEpoch}.mp4";
    await FFmpegKit.execute("-f concat -safe 0 -i ${list.path} -c copy $finalOut");
    setState(() => {generating = false, status = "DONE! ${totalSec ~/ 60}m ${totalSec % 60}s video: $finalOut"});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("8-min MIDNIGHT ROMANCE ready!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("8-Min Script → Animation"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Script to 8-Min Animation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text("Up to 32 scenes x 15s = 8 min, Adam deep voice, MIDNIGHT ROMANCE watermark", style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 12),
          TextField(controller: scriptCtrl, maxLines: 8, maxLength: 4000, decoration: InputDecoration(hintText: "Write midnight romance story...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height: 12),
          DropdownButton<String>(value: selectedVoice, isExpanded: true, items: ["Adam - Deep Male", "Bella - Warm Female"].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => selectedVoice = v!)),
          SizedBox(height: 12),
          if (generating) Column(children: [LinearProgressIndicator(value: progress), SizedBox(height: 8), Text(status, style: TextStyle(fontSize: 12))]),
          if (!generating) Text(status, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: generating? null : generate8Min, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: Text(generating? "Generating ${(progress * 100).toInt()}%..." : "Generate 8-Min MIDNIGHT ROMANCE"))),
        ]),
      ),
    );
  }
}
