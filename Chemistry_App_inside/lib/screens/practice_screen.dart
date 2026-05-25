import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/chemistry_provider.dart';
import '../services/pubchem_service.dart';

/// Interactive practice lab with Autocomplete search and Visual Reaction Flow
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.practiceLab),
        actions: [
          Consumer<ChemistryProvider>(
            builder: (_, p, __) => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFF00E5FF),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${p.score}',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChemistryProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructions(context),
                const SizedBox(height: 28),

                const _SectionLabel(label: 'reactantA', icon: Icons.science),
                const SizedBox(height: 10),
                _CompoundSearchField(
                  hint: 'e.g. Propene',
                  onSelected: provider.selectReactantA,
                ),
                const SizedBox(height: 22),

                const _SectionLabel(label: 'reactantB', icon: Icons.science),
                const SizedBox(height: 10),
                _CompoundSearchField(
                  hint: 'e.g. Water',
                  onSelected: provider.selectReactantB,
                ),
                const SizedBox(height: 22),

                const _SectionLabel(
                  label: 'reactionCondition',
                  icon: Icons.thermostat,
                ),
                const SizedBox(height: 10),
                _ConditionDropdown(
                  value: provider.selectedCondition,
                  conditions: provider.availableConditions,
                  onChanged: provider.selectCondition,
                ),
                const SizedBox(height: 32),

                _buildReactButton(context, provider),
                const SizedBox(height: 28),

                // ── Visual Flow & Results ─────────
                if (provider.isEnriching) const _LoadingShimmerCard(),

                if (!provider.isEnriching && provider.lastResult != null) ...[
                  // මෙතනදී අර කලින් තිබ්බ පරාමිතීන් ඔක්කොම අයින් කරලා provider එක විතරක් යවන්න
                  _buildReactionVisualizer(provider),
                  _ResultCard(result: provider.lastResult!),
                ],

                if (!provider.isEnriching &&
                    provider.pubChemData != null &&
                    provider.lastResult?.isCorrect == true) ...[
                  _PubChemCard(compound: provider.pubChemData!),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper Widgets
  Widget _buildInstructions(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppTheme.cardDark,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Row(
      children: [
        const Icon(Icons.lightbulb_outline, color: Color(0xFFA78BFA), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.instructions,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildReactButton(
    BuildContext context,
    ChemistryProvider provider,
  ) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton.icon(
      onPressed: provider.isEnriching ? null : () => provider.checkReaction(),
      icon: provider.isEnriching
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.bolt_rounded),
      label: Text(
        provider.isEnriching
            ? AppLocalizations.of(context)!
                  .analyzing // දැන් මෙතන context වැඩ කරයි!
            : AppLocalizations.of(context)!.reactButton,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  // ── Visual Reaction Flow Widget ──────────────────────────
  Widget _buildReactionVisualizer(ChemistryProvider provider) {
    // දත්ත ලබා ගැනීම
    final compA = provider.compoundById(provider.selectedReactantA ?? '');
    final compB = provider.compoundById(provider.selectedReactantB ?? '');
    final condition = provider.selectedCondition;
    final resultName = provider.lastResult?.product?.name;
    final resultFormula = provider.lastResult?.product?.formula;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reactant A
            _buildMoleculeChip(compA?.name ?? '???', formula: compA?.formula),

            // Reactant B (තිබේ නම්)
            if (compB != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.add, color: Colors.white38),
              ),
              _buildMoleculeChip(compB.name, formula: compB.formula),
            ],

            // Condition
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  const Icon(Icons.arrow_forward, color: Colors.purpleAccent),
                  Text(
                    condition ?? 'Condition',
                    style: const TextStyle(fontSize: 8, color: Colors.white38),
                  ),
                ],
              ),
            ),

            // Result
            _buildMoleculeChip(
              resultName ?? 'Result',
              formula: resultFormula,
              isProduct: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoleculeChip(
    String name, {
    String? formula,
    bool isProduct = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isProduct
            ? Colors.purple.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isProduct ? Colors.purpleAccent : Colors.white24,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (formula != null && formula.isNotEmpty)
            Text(
              formula, // මෙතන තමයි සූත්‍රය (H2O වගේ) පේන්නේ
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Search Component
// ═══════════════════════════════════════════════════════════════
class _CompoundSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onSelected;
  const _CompoundSearchField({required this.hint, required this.onSelected});
  @override
  State<_CompoundSearchField> createState() => _CompoundSearchFieldState();
}

class _CompoundSearchFieldState extends State<_CompoundSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      controller: _controller,
      builder: (context, controller, focusNode) => TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: AppTheme.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
        ),
      ),
      suggestionsCallback: (pattern) async =>
          await PubChemService.getSuggestions(pattern),
      itemBuilder: (context, suggestion) => ListTile(
        title: Text(suggestion, style: const TextStyle(color: Colors.white)),
      ),
      onSelected: (suggestion) {
        _controller.text = suggestion;
        widget.onSelected(suggestion);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UI Helpers (Labels, Dropdowns, Cards) - Keep them as they are
// ═══════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: Colors.white38),
      const SizedBox(width: 8),
      Text(
        _getLocalizedLabel(context, label),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    ],
  );
}

String _getLocalizedLabel(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context)!;
  switch (key) {
    case 'reactantA':
      return l10n.reactantA;
    case 'reactantB':
      return l10n.reactantB;
    case 'reactionCondition':
      return l10n.reactionCondition;
    default:
      return key;
  }
}

class _ConditionDropdown extends StatelessWidget {
  final String? value;
  final List<String> conditions;
  final ValueChanged<String?> onChanged;
  const _ConditionDropdown({
    required this.value,
    required this.conditions,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppTheme.cardDark,
      borderRadius: BorderRadius.circular(14),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Text(
          AppLocalizations.of(context)!.selectCondition,
          style: const TextStyle(color: Colors.white30, fontSize: 14),
        ),
        dropdownColor: AppTheme.cardDark,
        items: conditions
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: const TextStyle(color: Colors.white)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

// ResultCard, LoadingShimmerCard, PubChemCard - (මම කලින් දීපු කෝඩ් එකේ තිබ්බ ඒවාම තමයි මචං මෙතනත් පාවිච්චි කරන්නේ)

// Result Card, Shimmer Card, PubChem Card classes stay the same...
// (මම කලින් දීපු ඒවම තමයි මචං, ඒවා මෙතනට ආයිත් පාවිච්චි කරන්න)

/// Dynamic Result Card displaying AI Response
class _ResultCard extends StatelessWidget {
  final dynamic result; // Accepts our custom dynamic ReactionResult object

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect as bool;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isCorrect
            ? AppTheme.successGradient
            : const LinearGradient(
                colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)],
              ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? AppTheme.accentGreen : AppTheme.errorRed)
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect
                    ? AppLocalizations.of(context)!.reactionOccurred
                    : AppLocalizations.of(context)!.noReaction,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withValues(alpha: 0.2),
              //     borderRadius: BorderRadius.circular(6),
              //   ),
              //   child: const Row(
              //     children: [
              //       Icon(Icons.auto_awesome, color: Colors.white, size: 12),
              //       SizedBox(width: 4),
              //       Text(
              //         'Groq Llama 3',
              //         style: TextStyle(
              //           fontSize: 10,
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 14),

          // Dynamic Product Badge (Only if a reaction actually happened)
          if (isCorrect && result.product != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.productName(result.product!.name),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (result.product!.formula.isNotEmpty)
                          Text(
                            result.product!.formula,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (result.reactionType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result.reactionType!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // AI Explanation Text Block
          Text(
            result.explanation ?? '',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),

          if (isCorrect) ...[
            const SizedBox(height: 12),
            Text(
              '+10 points 🎉',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loader placeholder displayed during active API inference
class _LoadingShimmerCard extends StatelessWidget {
  const _LoadingShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.aiFormulating,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 12,
              width: i == 2 ? 180 : double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows real compound data fetched from PubChem API.
class _PubChemCard extends StatelessWidget {
  final dynamic compound;

  const _PubChemCard({required this.compound});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.biotech_rounded,
                  color: Color(0xFFA78BFA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.pubChemData,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA78BFA),
                ),
              ),
              const Spacer(),
              if (compound.cid != 0)
                Text(
                  'CID: ${compound.cid}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Properties grid
          _propertyRow(
            AppLocalizations.of(context)!.iupacName,
            compound.iupacName,
          ),
          _propertyRow(
            AppLocalizations.of(context)!.formula,
            compound.molecularFormula,
          ),
          if (compound.molecularWeight > 0.0)
            _propertyRow(
              AppLocalizations.of(context)!.molecularWeight,
              '${compound.molecularWeight} g/mol',
            ),

          // Description
          if (compound.description != null &&
              compound.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              compound.description!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],

          // 2D Structure image from PubChem
          if (compound.imageUrl != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: 160,
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  compound.imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text(
                      'Structure image unavailable',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _propertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
