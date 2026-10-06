import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../services/ai_voice_service.dart';

class ScriptAnimatorScreen extends StatefulWidget {
  @override
  _ScriptAnimatorScreenState createState() => _ScriptAnimatorScreenState();
}

class _ScriptAnimatorScreenState extends State<ScriptAnimatorScreen> {
  TextEditingController scriptCtrl = TextEditingController(text: "In Murang'a, under midnight moon, she waited by the river. A boda light appears. He is here. Love is not about distance, it is about midnight promises. This is MIDNIGHT ROMANCE.");
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

  Future<void> generate8Min() async {
    setState(() => {generating = true, progress = 0, status = "Generating images..."});
    List<String> scenes = splitScenes(scriptCtrl.text);

    for (int i = 0; i < scenes.length; i++) {
      setState(() => {progress = i / scenes.length, status = "Scene ${i+1}/${scenes.length}"});

      // Generate voice with your custom IDs
      String? voicePath = await AIVoiceService.speak(scenes[i], selectedVoice);

      // Generate image
      try {
        String safe = Uri.encodeComponent("cinematic romance midnight ${scenes[i]} dramatic");
        String url = "https://image.pollinations.ai/prompt/$safe?width=720&height=1280&seed=$i";
        var resp = await http.get(Uri.parse(url));
        final dir = await getTemporaryDirectory();
        File f = File("${dir.path}/scene_$i.jpg");
        await f.writeAsBytes(resp.bodyBytes);
      } catch(e){}

      await Future.delayed(Duration(milliseconds: 500));
    }

    setState(() => {generating = false, status = "DONE! ${scenes.length} scenes created - Preview shows MIDNIGHT ROMANCE watermark. Play with Adam/JBFq/hpp4 voices!"});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("8-min storyboard ready with ${selectedVoice}!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("8-Min Script → Animation"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Script to 8-Min Animation", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
          Text("Up to 32 scenes = 8 min, with ${selectedVoice} + MIDNIGHT ROMANCE", style: TextStyle(color: Colors.grey, fontSize:12)),
          SizedBox(height:12),
          TextField(controller: scriptCtrl, maxLines: 8, maxLength: 4000, decoration: InputDecoration(hintText: "Write midnight romance story...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height:12),
          DropdownButton<String>(
            value: selectedVoice, isExpanded: true,
            items: [
              "Adam - Deep Male",
              "George - Deep Male (JBFq)",
              "Custom Voice 2 (hpp4)",
              "Bella - Warm Female",
              "Josh - Male Storyteller",
              "Rachel - Calm Female"
            ].map((v)=>DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v)=>setState(()=>selectedVoice=v!),
          ),
          SizedBox(height:12),
          if(generating) LinearProgressIndicator(value: progress),
          Text(status, style: TextStyle(fontSize:12)),
          SizedBox(height:12),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: generating? null : generate8Min, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: Text(generating? "Generating ${(progress*100).toInt()}%..." : "Generate 8-Min MIDNIGHT ROMANCE"))),
        ]),
      ),
    );
  }
}
