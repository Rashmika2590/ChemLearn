import 'package:flutter/material.dart';

class McqQuestion {
  final int id;
  final String questionEn;
  final String questionSi;
  final List<String> optionsEn;
  final List<String> optionsSi;
  final String correctAnswer;

  McqQuestion({
    required this.id,
    required this.questionEn,
    required this.questionSi,
    required this.optionsEn,
    required this.optionsSi,
    required this.correctAnswer,
  });

  String getQuestion(BuildContext context) {
    final isSinhala = Localizations.localeOf(context).languageCode == 'si';
    return isSinhala ? questionSi : questionEn;
  }

  List<String> getOptions(BuildContext context) {
    final isSinhala = Localizations.localeOf(context).languageCode == 'si';
    return isSinhala ? optionsSi : optionsEn;
  }

  factory McqQuestion.fromJson(Map<String, dynamic> json) {
    return McqQuestion(
      id: json['id'],
      questionEn: json['questionEn'],
      questionSi: json['questionSi'],
      optionsEn: List<String>.from(json['optionsEn']),
      optionsSi: List<String>.from(json['optionsSi']),
      correctAnswer: json['correctAnswer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionEn': questionEn,
      'questionSi': questionSi,
      'optionsEn': optionsEn,
      'optionsSi': optionsSi,
      'correctAnswer': correctAnswer,
    };
  }
}

class PastPaperYear {
  final int year;
  final List<McqQuestion> questions;

  PastPaperYear({required this.year, required this.questions});

  factory PastPaperYear.fromJson(Map<String, dynamic> json) {
    return PastPaperYear(
      year: json['year'],
      questions: (json['questions'] as List)
          .map((q) => McqQuestion.fromJson(q))
          .toList(),
    );
  }
}
