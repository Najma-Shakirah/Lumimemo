import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

bool _isInitialized = false;
html.IFrameElement? _iframe;

Widget buildWebAvatar({
  required String apiKey,
  required String characterId,
  required String patientName,
  String? memoryPrompt,
  required Function(Map<String, dynamic>) onMessage,
}) {
  final viewId = 'convai-embed-$characterId';

  if (!_isInitialized) {
    _isInitialized = true;
    final embedUrl = 'https://api.convai.com/character/embed/?charId=$characterId';
    
    _iframe = html.IFrameElement()
      ..src = embedUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#0F0E17'
      ..allow = 'microphone *';

    // Register factory for HtmlElementView
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) => _iframe!);
  }

  return HtmlElementView(viewType: viewId);
}
