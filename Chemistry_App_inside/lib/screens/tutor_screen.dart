import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                color: AppTheme.accentOrange.withOpacity(0.15),
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
                color: const Color(0xFF00897B).withOpacity(0.15),
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
        return _MessageBubble(message: msg);
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
                color: Colors.white.withOpacity(0.5),
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
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
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

class _MessageBubble extends StatelessWidget {
  final TutorMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 10),
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
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
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
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
