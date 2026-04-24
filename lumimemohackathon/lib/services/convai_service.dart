import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConvaiService {
  static final String _apiKey = (dotenv.env['CONVAI_API_KEY'] ?? '').replaceAll('"', '').replaceAll("'", '');
  static final String _charID = (dotenv.env['CONVAI_CHARACTER_ID'] ?? '').replaceAll('"', '').replaceAll("'", '');
  static final String _baseUrl = 'https://api.convai.com/character/getResponse';

  static String _sessionID = '-1';

  /// Sends text to ConvAI and returns the text response instantly.
  static Future<String> getResponse(String userText) async {
    if (_apiKey.isEmpty || _charID.isEmpty) {
      return "Error: API Key or Character ID missing in .env";
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.headers['CONVAI-API-KEY'] = _apiKey;
      request.fields['charID'] = _charID;
      request.fields['sessionID'] = _sessionID;
      request.fields['voiceResponse'] = 'False'; // Must be string 'True' or 'False'
      request.fields['userText'] = userText;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionID = data['sessionID'] ?? _sessionID;
        return data['text'] ?? "I'm not sure how to respond to that.";
      } else {
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}
