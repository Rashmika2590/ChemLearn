import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/chemistry_provider.dart';

/// AI-powered chemistry tutor chat screen.
class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChemistryProvider provider) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    provider.askTutor(text);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chemistryTutor),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: AppLocalizations.of(context)!.clearChat,
            onPressed: () {
              context.read<ChemistryProvider>().clearTutorChat();
            },
          ),
        ],
      ),
      body: Consumer<ChemistryProvider>(
        builder: (context, provider, _) {
          if (!provider.isAiAvailable) {
            return _buildOfflineMessage();
          }

          return Column(
            children: [
              Expanded(
                child: provider.tutorMessages.isEmpty
                    ? _buildEmptyState(provider) // මෙතනට provider එක pass කළා
                    : _buildMessageList(provider),
              ),
              if (provider.isTutorTyping) _buildTypingIndicator(),
              _buildInputBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppTheme.accentOrange,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.aiTutorUnavailable,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.aiTutorRequiresKey,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 වෙනස් කළ කොටස: මෙතනදී දැනට තියෙන Locale එක බලලා ප්‍රශ්න ටික සිංහලෙන් හෝ ඉංග්‍රීසියෙන් පෙන්වනවා
  Widget _buildEmptyState(ChemistryProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    // දැනට ඇප් එක සිංහලද කියලා බලාගන්න ක්‍රමය (උඹේ ChemistryProvider එකේ තියෙන logic එක)
    final bool isSinhalaActive =
        Localizations.localeOf(context).languageCode == 'si';

    // භාෂාව අනුව ප්‍රශ්න ලැයිස්තුව වෙනස් කිරීම
    final suggestedQuestions = isSinhalaActive
        ? [
            "මාර්කොව්නිකොව් නියමය යනු කුමක්ද?",
            "ඉලෙක්ට්‍රොෆිලික ආකලන ප්‍රතික්‍රියා පැහැදිලි කරන්න",
            "ඇල්කීන යනු මොනවාද?",
          ]
        : [
            "What is Markovnikov's rule?",
            "Explain electrophilic addition",
            "What are alkenes?",
          ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Color(0xFF00E5FF),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.askAnything,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.iCanExplain,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Dynamic Suggested Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestedQuestions.map((question) {
                return _SuggestedChip(
                  label: question,
                  onTap: (text) {
                    _controller.text = text;
                    _sendMessage(context.read<ChemistryProvider>());
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ChemistryProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: provider.tutorMessages.length,
      itemBuilder: (context, index) {
        final msg = provider.tutorMessages[index];
        // Find the preceding user question for AI responses
        String? userQuestion;
        if (!msg.isUser && index > 0) {
          final prev = provider.tutorMessages[index - 1];
          if (prev.isUser) userQuestion = prev.text;
        }
        return _MessageBubble(message: msg, userQuestion: userQuestion);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withAlpha(128),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.thinking,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ChemistryProvider provider) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: Colors.white.withAlpha(15))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.askAQuestion,
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(provider),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, size: 20),
              color: Colors.white,
              onPressed: provider.isTutorTyping
                  ? null
                  : () => _sendMessage(provider),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final TutorMessage message;
  final String? userQuestion;
  const _MessageBubble({required this.message, this.userQuestion});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isReporting = false;

  @override
  void initState() {
    super.initState();
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  // ── Text-to-Speech ──────────────────────────────────────────
  Future<void> _toggleTts() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      // 1. Text එකේ තියෙන ** අයින් කරන්න මෙන්න මේ පේළිය දාන්න:
      String cleanText = widget.message.text.replaceAll(RegExp(r'\*\*'), '');

      // 2. අනිත් markdown symbols අයින් කරන්න ඕන නම් මේකත් දාන්න:
      cleanText = cleanText.replaceAll(RegExp(r'#'), ''); // Heading symbols

      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
      setState(() => _isSpeaking = true);

      // 3. Clean කරපු text එක කියවන්න
      await _flutterTts.speak(cleanText);
    }
  }

  // ── Copy to Clipboard ──────────────────────────────────────
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.text));
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Copied to Clipboard'),
          ],
        ),
        backgroundColor: const Color(0xFF00897B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Report Dialog with Firestore ────────────────────────────
  void _showReportDialog() {
    String? selectedReason;
    final reasons = [
      'Incorrect Answer',
      'Inappropriate Content',
      'Incomplete Response',
      'Misleading Information',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              title: const Row(
                children: [
                  Icon(Icons.flag_rounded, color: Color(0xFFFFA726), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Report Response',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a reason for reporting:',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  ...reasons.map((reason) {
                    final isSelected = selectedReason == reason;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () =>
                            setDialogState(() => selectedReason = reason),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00897B).withAlpha(40)
                                : AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00ACC1)
                                  : Colors.white.withAlpha(15),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? const Color(0xFF00E5FF)
                                    : Colors.white30,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                reason,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: selectedReason != null ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton.icon(
                    onPressed: selectedReason == null || _isReporting
                        ? null
                        : () async {
                            setState(() => _isReporting = true);
                            setDialogState(() {});
                            try {
                              await FirebaseFirestore.instance
                                  .collection('reports')
                                  .add({
                                    'question':
                                        widget.userQuestion ??
                                        'Unknown question',
                                    'aiResponse': widget.message.text,
                                    'reportReason': selectedReason,
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'userId': null, // No auth configured
                                  });

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                              if (mounted) {
                                setState(() => _isReporting = false);
                                ScaffoldMessenger.of(
                                  this.context,
                                ).removeCurrentSnackBar();
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Report submitted. Thank you!'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF00897B),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isReporting = false);
                                ScaffoldMessenger.of(
                                  this.context,
                                ).removeCurrentSnackBar();
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Failed to submit report.'),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.errorRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                    icon: _isReporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 16),
                    label: Text(_isReporting ? 'Submitting...' : 'Submit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Action Button Helper ────────────────────────────────────
  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 17,
              color: iconColor ?? Colors.white.withAlpha(100),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // ── Message Bubble ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.primaryGradient : null,
                color: isUser ? null : AppTheme.cardDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: isUser
                  ? Text(
                      widget.message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    )
                  : SelectableText(
                      widget.message.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
            ),

            // ── Action Row (AI responses only) ──
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton(
                      icon: _isSpeaking
                          ? Icons.stop_circle_rounded
                          : Icons.volume_up_rounded,
                      tooltip: _isSpeaking ? 'Stop' : 'Read Aloud',
                      onPressed: _toggleTts,
                      iconColor: _isSpeaking ? const Color(0xFF00E5FF) : null,
                    ),
                    const SizedBox(width: 2),
                    _actionButton(
                      icon: Icons.copy_rounded,
                      tooltip: 'Copy',
                      onPressed: _copyToClipboard,
                    ),
                    const SizedBox(width: 2),
                    _actionButton(
                      icon: Icons.flag_outlined,
                      tooltip: 'Report',
                      onPressed: _showReportDialog,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedChip extends StatelessWidget {
  final String label;
  final ValueChanged<String> onTap;
  const _SuggestedChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
