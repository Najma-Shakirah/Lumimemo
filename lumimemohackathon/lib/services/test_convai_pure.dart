import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('Loading environment variables...');
  final envLines = File('.env').readAsLinesSync();
  String apiKey = '';
  String charId = '';
  
  for (var line in envLines) {
    if (line.startsWith('CONVAI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
    } else if (line.startsWith('CONVAI_CHARACTER_ID=')) {
      charId = line.split('=')[1].trim();
    }
  }
  
  print('Testing ConvAI REST API...');
  print('API Key: ${apiKey.substring(0, 5)}...');
  print('Char ID: $charId');
  
  final _baseUrl = 'https://api.convai.com/character/getResponse';
  final userText = 'Hello! Are you there?';
  
  try {
    var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.headers['CONVAI-API-KEY'] = apiKey;
    request.fields['charID'] = charId;
    request.fields['sessionID'] = '-1';
    request.fields['voiceResponse'] = 'False';
    request.fields['userText'] = userText;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
      
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\nSUCCESS! Companion says:');
      print('"${data['text']}"');
    } else {
      print('\nAPI ERROR: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('\nCONNECTION ERROR:');
    print(e);
  }
}
