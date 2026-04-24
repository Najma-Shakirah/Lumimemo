import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:async';
import '../apptheme.dart';
import '../services/convai_service.dart';
import 'web_avatar.dart';

class AvatarScreen extends StatefulWidget {
  final String patientName;
  final String? memoryPrompt;

  const AvatarScreen({
    super.key,
    required this.patientName,
    this.memoryPrompt,
  });

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  WebViewController? _controller;
  bool _avatarReady = false;
  double _loadingProgress = 0.0;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _useFastMode = false;
  Timer? _loadingTimeout;
  String _statusText = 'Waking up your companion...';
  final List<Map<String, String>> _chatHistory = []; // For fast mode display

  final String _apiKey = (dotenv.env['CONVAI_API_KEY'] ?? '').replaceAll('"', '').replaceAll("'", '');
  final String _characterId = (dotenv.env['CONVAI_CHARACTER_ID'] ?? '').replaceAll('"', '').replaceAll("'", '');

  @override
  void initState() {
    super.initState();
    // Start timeout timer for web or mobile
    _startTimeoutTimer();
    
    if (kIsWeb) {
      // Web avatar initializes via iframe instantly
      setState(() {
        _loadingProgress = 1.0;
        _avatarReady = true;
      });
    } else {
      // Increased delay to allow the UI thread and GPU to stabilize before loading 3D assets on mobile
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_useFastMode) _initWebView();
      });
    }
  }

  void _startTimeoutTimer() {
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 12), () {
      if (mounted && !_avatarReady && !_useFastMode) {
        setState(() {
          _statusText = 'Still waking up... Connection might be slow.';
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    // Explicitly navigate to blank to kill WebGL/GPU bridge before closing
    _controller?.loadRequest(Uri.parse('about:blank'));
    _controller = null;
    super.dispose();
  }

  Future<void> _initWebView() async {
    // High-performance LiveKit-powered ConvAI Embed
    final embedUrl = 'https://api.convai.com/character/embed/?charId=$_characterId';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F0E17))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          if (mounted) setState(() => _loadingProgress = progress / 100.0);
        },
        onPageFinished: (_) {
          if (mounted) setState(() {
            _avatarReady = true;
            _statusText = 'Ready to talk';
          });
        },
      ))
      ..loadRequest(Uri.parse(embedUrl));

    if (mounted) setState(() => _controller = controller);
  }

  void _sendInitMessage() {
    if (_controller == null) return;

    final payload = jsonEncode({
      'type': 'init',
      'apiKey': _apiKey,
      'characterId': _characterId,
      'patientName': widget.patientName,
      'greeting': widget.memoryPrompt, // Pass dynamic memory as greeting
    });

    _controller!.runJavaScript(
      'window.dispatchEvent(new MessageEvent("message", { data: $payload }))'
    );
  }

  void _onJsMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message);
    final type = data['type'] as String?;

    if (!mounted) return;

    setState(() {
      switch (type) {
        case 'ready':
          _avatarReady = true;
          _statusText = 'Ready to talk';
          break;
        case 'speaking':
          _isSpeaking = true;
          _isListening = false;
          break;
        case 'idle':
          _isSpeaking = false;
          _statusText = 'Ready to talk';
          break;
        case 'user_speech':
          _statusText = 'You said: "${data['transcript']}"';
          break;
        case 'error':
          _isListening = false;
          _isSpeaking = false;
          _statusText = data['message'] ?? 'Connection error';
          break;
      }
    });
  }

  void _speakText(String text) {
    if (!_avatarReady) return;
    
    if (kIsWeb) {
      speakWebAvatar(text);
      return;
    }
    
    if (_controller != null) {
      final payload = jsonEncode({'type': 'speak', 'text': text});
      _controller!.runJavaScript(
        'window.dispatchEvent(new MessageEvent("message", { data: $payload }))'
      );
    }
  }

  void _stopSpeaking() {
    if (kIsWeb) {
      stopListeningWebAvatar(); // Stop logic uses idle
      return;
    }
    _controller?.runJavaScript(
      'window.dispatchEvent(new MessageEvent("message", { data: {"type": "idle"} }))'
    );
  }

  void _toggleListening() {
    if (!_avatarReady) return;
    
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _statusText = 'Listening...';
        if (kIsWeb) {
          startListeningWebAvatar();
        } else if (_controller != null) {
          _controller!.runJavaScript(
            'window.dispatchEvent(new MessageEvent("message", { data: {"type": "start_listening"} }))'
          );
        }
      } else {
        _statusText = 'Processing...';
        if (kIsWeb) {
          stopListeningWebAvatar();
        } else if (_controller != null) {
          _controller!.runJavaScript(
            'window.dispatchEvent(new MessageEvent("message", { data: {"type": "stop_listening"} }))'
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                if (!kIsWeb && _controller != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    child: WebViewWidget(controller: _controller!),
                  ),
                if (kIsWeb)
                   ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    child: buildWebAvatar(
                      apiKey: _apiKey,
                      characterId: _characterId,
                      patientName: widget.patientName,
                      memoryPrompt: widget.memoryPrompt,
                      onMessage: (msg) {
                        // Official embed handle its own messages
                      },
                    ),
                  ),
                if (!_avatarReady && !_useFastMode)
                  _buildLoadingOverlay(),
                if (_isSpeaking)
                  Positioned(bottom: 24, left: 0, right: 0, child: Center(child: _PulseRing(color: AppTheme.primary))),
                if (_isSpeaking)
                  _buildStopButton(),
                if (!_avatarReady && !_useFastMode)
                  Positioned(
                    bottom: 40, left: 0, right: 0,
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _useFastMode = true),
                        icon: Icon(Icons.bolt, color: AppTheme.primary),
                        label: Text('Switch to Fast Mode', style: GoogleFonts.dmSans(color: AppTheme.primary)),
                        style: TextButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _useFastMode ? _buildFastModeChat() : _buildControlsPanel(),
        ],
      ),
    );
  }

  Widget _buildFastModeChat() {
    return Expanded(
      flex: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text('Fast Mode Active', style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => setState(() => _useFastMode = false), icon: const Icon(Icons.refresh, size: 16, color: Colors.white54)),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = _chatHistory[index];
                  final isUser = chat['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(chat['text'] ?? '', style: GoogleFonts.dmSans(color: isUser ? Colors.black : Colors.white)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onSubmitted: (val) async {
                if (val.isEmpty) return;
                setState(() {
                  _chatHistory.add({'role': 'user', 'text': val});
                  _statusText = 'Companion is typing...';
                });
                final reply = await ConvaiService.getResponse(val);
                setState(() {
                  _chatHistory.add({'role': 'bot', 'text': reply});
                  _statusText = 'Ready';
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: AppTheme.surfaceAlt,
                  color: AppTheme.primary,
                  minHeight: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(_statusText, style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14)),
            if (_loadingProgress > 0)
              Text('${(_loadingProgress * 100).toInt()}%', style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return Positioned(
      top: 16, right: 16,
      child: GestureDetector(
        onTap: _stopSpeaking,
        child: CircleAvatar(
          backgroundColor: AppTheme.surface.withOpacity(0.8),
          child: Icon(Icons.stop_rounded, color: AppTheme.error, size: 24),
        ),
      ),
    );
  }

  Widget _buildControlsPanel() {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${widget.patientName} 👋', style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 24)),
            Text(_statusText, style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            Text('RECALL A MEMORY', style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _MemoryChip(label: '🎉 Last Raya', onTap: () => _speakText('We had a wonderful Hari Raya last year at your home in Johor Bahru.')),
                _MemoryChip(label: '🏡 The Garden', onTap: () => _speakText('The mango tree you planted is doing very well.')),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _avatarReady ? _toggleListening : null,
                icon: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded),
                label: Text(_isListening ? 'Listening...' : 'Talk to Companion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? AppTheme.error : AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ── Pulse Ring ────────────────────────────────────────────────────────────────
class _PulseRing extends StatefulWidget {
  final Color color;
  const _PulseRing({required this.color});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _scale = Tween(begin: 0.8, end: 1.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween(begin: 0.6, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(_opacity.value),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Memory Chip ───────────────────────────────────────────────────────────────
class _MemoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MemoryChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceAlt),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}