import 'package:flutter/material.dart';

Widget buildWebAvatar({
  required String apiKey,
  required String characterId,
  required String patientName,
  String? memoryPrompt,
  required Function(dynamic) onMessage,
}) {
  return const Center(child: Text('Web Avatar not supported on mobile.'));
}

void speakWebAvatar(String text) {}
void startListeningWebAvatar() {}
void stopListeningWebAvatar() {}
