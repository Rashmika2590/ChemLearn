import 'package:chemistry_app/providers/chemistry_provider.dart';
import 'package:chemistry_app/widgets/score_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conversion_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/scoring_service.dart';

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _gameOverDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversionProvider>().setContext(context);
      context.read<ConversionProvider>().nextLevel();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversionProvider>();
    final chemistryProvider = context.watch<ChemistryProvider>();
    final l10n = AppLocalizations.of(context)!;

    // Show Game Over dialog only once
    if (provider.lives == 0 && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(
              l10n.gameOver,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.yourScore}: ${provider.localScore}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.totalScore}: ${chemistryProvider.score}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.stepsCompleted}: ${provider.steps.length}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _gameOverDialogShown = false;
                  provider.nextLevel();
                  Navigator.pop(context);
                },
                child: Text(
                  l10n.playAgain,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  l10n.exit,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      });
    }

    // Reset dialog flag when new level starts
    if (provider.lives > 0 && _gameOverDialogShown) {
      _gameOverDialogShown = false;
    }

    final List<String> allReagents = [
      // Original reagents
      "H2SO4",
      "KMnO4",
      "H2O",
      "H2",
      "Ethanol",
      "Conc. H2SO4, 170°C",
      "KMnO4 / H+",
      "Ethanol / H+",
      "H2 / Ni",
      "PCC / CH2Cl2",
      "CrO2Cl2 (Etard reaction)",
      "LiAlH4 / ether then H2O",
      "Cl2 / hv",
      "NaOH (aq)",
      "Cu / 300°C",
      "NaBH4 / H2O",
      "K2Cr2O7 / H+",
      "Conc. HNO3 / Conc. H2SO4",
      "Sn / HCl then NaOH",
      "NaNO2 / HCl (0-5°C) then H3PO2",
      "Cl2 / FeCl3",
      "NaOH (350°C, 200 atm) then H+",
      "Zn dust / heat",
      "PdCl2 / CuCl2 / O2 (Wacker process)",
      "Tollens' reagent",
      "P2O5 / heat",
      "PBr3",
      "CH3COCl / pyridine",
      "CH3Cl / AlCl3 (Friedel-Crafts)",
      "Phenol / PCl3",
      "Zymase (yeast)",
      "Decarboxylase",
      "Alcohol dehydrogenase",
      "Ziegler-Natta catalyst",
      "H2 / Ni (high pressure)",
      "Red hot iron tube (873K)",
      "Conc. H2SO4 (140°C)",
      "H2O / HgSO4 / H2SO4",
      "O2 / Mn(OAc)2",
      "KHSO4 (dehydration)",
      "C2H4 / AlCl3",
      "O2 / catalyst",
      "Then H+ / heat",
      "Conc. H2SO4 (sulfonation)",
      "3-Nitro-p-toluenesulfonic acid / H2O / heat",
      "HNO3 / Cu catalyst",
      "O2 / 400°C / catalyst",
      "Al2O3 (dehydration)",
      "NaOH (aldol)",
      "H+ / heat",
      "Acetone / HCl catalyst",
      "O2 / Ag catalyst",
      "HCN",
      "CH3OH / H2SO4",
      "Acetic anhydride / H2SO4",
      "Partial hydrolysis",
      "Br2 / H2O",
      "NaOH (aq) / heat then H+",
      "CH3COCl",
      "Then HCl",
    ];

    final filteredReagents = _searchQuery.isEmpty
        ? allReagents
        : allReagents
              .where(
                (r) => r.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return ScoreAnimationWidget(
      gameMode: GameMode.conversion,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          title: Text(
            l10n.conversions,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _gameOverDialogShown = false;
                provider.nextLevel();
              },
              tooltip: l10n.restart,
            ),
          ],
        ),
        body: Column(
          children: [
            // Header Cards
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  _compoundCard(
                    l10n.start,
                    provider.startingMaterial ?? "-",
                    Colors.greenAccent,
                  ),
                  const Icon(Icons.arrow_right_alt, color: Colors.white54),
                  _compoundCard(
                    l10n.current,
                    provider.currentIntermediate ?? "-",
                    Colors.cyanAccent,
                  ),
                  const Icon(Icons.arrow_right_alt, color: Colors.white54),
                  _compoundCard(
                    l10n.target,
                    provider.targetProduct ?? "-",
                    Colors.greenAccent,
                  ),
                ],
              ),
            ),

            // Feedback Message
            if (provider.feedbackMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient:
                      !provider.feedbackMessage!.contains("Incorrect") &&
                          !provider.feedbackMessage!.contains(l10n.gameOver)
                      ? const LinearGradient(
                          colors: [Color(0xFF00ACC1), Color(0xFF00838F)],
                        )
                      : null,
                  color: provider.feedbackMessage!.contains("Incorrect")
                      ? Colors.red.shade900
                      : (provider.feedbackMessage!.contains(l10n.gameOver)
                            ? Colors.grey.shade800
                            : null),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (provider.feedbackMessage!.contains("Complete") ||
                            provider.feedbackMessage!.contains("Excellent"))
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 24,
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.feedbackMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    if (provider.feedbackMessage!.contains(
                          l10n.excellentLevelComplete,
                        ) ||
                        provider.feedbackMessage!.contains(l10n.gameOver))
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            l10n.nextLevel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            _gameOverDialogShown = false;
                            provider.nextLevel();
                          },
                        ),
                      ),
                  ],
                ),
              ),

            // Hearts & Score
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          i < provider.lives
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Simple Row with just icons and scores
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current Score with Star
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${provider.localScore}",
                            style: TextStyle(
                              color: Colors.amber.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Total Score with Trophy
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Icons.emoji_events,
                      //       color: Colors.amber.shade600,
                      //       size: 20,
                      //     ),
                      //     const SizedBox(width: 6),
                      //     Text(
                      //       "${chemistryProvider.score}",
                      //       style: TextStyle(
                      //         color: Colors.amber.shade600,
                      //         fontSize: 18,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ],
              ),
            ),

            // Streak Indicator
            if (provider.getCurrentStreak() >= 3)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.getCurrentStreak()} Streak! 🔥',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // History
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: provider.steps.isEmpty
                    ? const Center(
                        child: Text(
                          'No steps yet.\nSelect a reagent to begin!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.steps.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.cyan.shade800,
                              radius: 16,
                              child: Text(
                                '${provider.steps.length - i}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            title: Text(
                              provider.steps[provider.steps.length - 1 - i],
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // Reagents (Search & Scroll)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.searchReagents,
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white30,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white30,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = "";
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredReagents.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final reagent = filteredReagents[index];
                        return ActionChip(
                          label: Text(
                            reagent,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 4,
                          onPressed: () {
                            provider.validateStep(reagent);
                            setState(() {
                              _searchQuery = "";
                              _searchController.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compoundCard(String label, String val, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white54),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
