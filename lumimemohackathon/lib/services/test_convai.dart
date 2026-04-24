import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'convai_service.dart';

void main() async {
  print('Loading environment variables...');
  await dotenv.load(fileName: '.env');
  
  print('Testing ConvAI REST API...');
  print('API Key: ${dotenv.env['CONVAI_API_KEY']?.substring(0, 5)}...');
  print('Char ID: ${dotenv.env['CONVAI_CHARACTER_ID']}');
  
  try {
    final response = await ConvaiService.getResponse('Hello! Are you there?');
    print('\nSUCCESS! Companion says:');
    print('"$response"');
  } catch (e) {
    print('\nERROR:');
    print(e);
  }
}
