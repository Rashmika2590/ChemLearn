import 'package:chemistry_app/screens/mcq_screen.dart';
import 'package:chemistry_app/services/ai_service.dart';
import 'package:chemistry_app/services/quiz_service.dart';
import 'package:chemistry_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PastPaperListScreen extends StatelessWidget {
  final List<int> years = List.generate(
    26,
    (index) => 2000 + index,
  ).reversed.toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pastPapers)),
      body: ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(years[index].toString().substring(2)),
            ),
            title: Text(l10n.chemistryYear(years[index])),
            onTap: () async {
              // Loading එක පෙන්වන්න
              showDialog(
                context: context,
                builder: (_) => Center(child: CircularProgressIndicator()),
              );

              // දත්ත ගන්න
              final paper = await QuizService().getPaperByYear(years[index]);

              // Dialog එක වහන්න
              Navigator.pop(context);

              if (paper != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      paper: paper,
                      aiService: context
                          .read<AiService>(), // හෝ උඹේ සර්විස් එක තියෙන විදිහට
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.questionsNotAvailable)),
                );
              }
            },
          );
        },
      ),
    );
  }
}
