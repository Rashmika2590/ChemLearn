// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../core/theme/app_theme.dart';
// import '../models/lesson.dart';
// import '../providers/chemistry_provider.dart';

// /// Displays the full content of a single lesson.
// ///
// /// Shows the lesson content in a readable format and allows
// /// the user to mark it as completed.
// class LessonDetailScreen extends StatelessWidget {
//   final Lesson lesson;

//   const LessonDetailScreen({super.key, required this.lesson});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(lesson.title),
//       ),
//       body: Consumer<ChemistryProvider>(
//         builder: (context, provider, _) {
//           final isCompleted = provider.isLessonCompleted(lesson.id);

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Level Badge ────────────────────────────
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF00897B).withValues(alpha: 0.15),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'Level ${lesson.level}',
//                     style: const TextStyle(
//                       color: Color(0xFF00E5FF),
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // ── Lesson Content ─────────────────────────
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(22),
//                   decoration: BoxDecoration(
//                     color: AppTheme.cardDark,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.white.withValues(alpha: 0.06),
//                     ),
//                   ),
//                   child: Text(
//                     lesson.content.trim(),
//                     style: const TextStyle(
//                       fontSize: 15,
//                       height: 1.7,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // ── Related Reactions ──────────────────────
//                 if (lesson.relatedReactions.isNotEmpty) ...[
//                   Text(
//                     'Related Reactions',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: lesson.relatedReactions.map((id) {
//                       return Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color:
//                                 const Color(0xFF7C3AED).withValues(alpha: 0.3),
//                           ),
//                         ),
//                         child: Text(
//                           'Reaction $id',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             color: Color(0xFFA78BFA),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 28),
//                 ],

//                 // ── Mark Complete Button ───────────────────
//                 SizedBox(
//                   width: double.infinity,
//                   height: 54,
//                   child: ElevatedButton.icon(
//                     onPressed: isCompleted
//                         ? null
//                         : () {
//                             provider.markLessonCompleted(lesson.id);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: const Text(
//                                     '✅ Lesson marked as complete!'),
//                                 backgroundColor: AppTheme.accentGreen,
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );
//                           },
//                     icon: Icon(
//                       isCompleted
//                           ? Icons.check_circle
//                           : Icons.check_circle_outline,
//                     ),
//                     label: Text(
//                       isCompleted ? 'Completed' : 'Mark as Complete',
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isCompleted
//                           ? Colors.grey.shade800
//                           : const Color(0xFF00897B),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
