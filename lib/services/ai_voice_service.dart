import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AIVoiceService {
  // YOUR REAL KEY FROM SCREENSHOT - KEEP PRIVATE!
  static const String apiKey = "sk_6a0eab5c052308c5e89e94ee70d9455ecda45c73f8226208";

  static const Map<String, String> voices = {
    "Adam - Deep Male": "pNInz6obpgDQGcFmaJgB",
    "George - Deep Male (JBFq)": "JBFqnCBsd6RMkjVDRZzb", // Your 1st custom
    "Custom Voice 2 (hpp4)": "hpp4J3VqNfWAUOO0d1Us", // Your 2nd custom
    "Bella - Warm Female": "EXAVITQu4vr4xnSDxMaL",
    "Josh - Male Storyteller": "TxGEqnHWrfWFTfGW9XjX",
    "Rachel - Calm Female": "21m00Tcm4TlvDq8ikWAM",
  };

  static Future<String?> speak(String text, String voiceName) async {
    String voiceId = voices[voiceName]?? "pNInz6obpgDQGcFmaJgB";
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
      return file.path;
    } else {
      print("ElevenLabs error: ${response.body}");
      return null;
    }
  }

  static Future<void> play(String filePath) async {
    final player = AudioPlayer();
    await player.play(DeviceFileSource(filePath));
  }
}
