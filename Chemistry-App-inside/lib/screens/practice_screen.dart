import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/chemistry_provider.dart';
import '../services/pubchem_service.dart';

/// Interactive practice lab with Autocomplete search
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Lab'),
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
                // ── Instructions ─────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFFA78BFA),
                        size: 22,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Search and select reactants, then tap "React!" to analyze.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Reactant A (Autocomplete) ──────────
                const _SectionLabel(label: 'Reactant A', icon: Icons.science),
                const SizedBox(height: 10),
                _CompoundSearchField(
                  hint: 'e.g. Propene',
                  onSelected: provider.selectReactantA,
                ),
                const SizedBox(height: 22),

                // ── Reactant B (Autocomplete) ──────────
                const _SectionLabel(
                  label: 'Reactant B (optional)',
                  icon: Icons.science,
                ),
                const SizedBox(height: 10),
                _CompoundSearchField(
                  hint: 'e.g. Water',
                  onSelected: provider.selectReactantB,
                ),
                const SizedBox(height: 22),

                // ── Condition ────────────────────────────
                const _SectionLabel(
                  label: 'Reaction Condition',
                  icon: Icons.thermostat,
                ),
                const SizedBox(height: 10),
                _ConditionDropdown(
                  value: provider.selectedCondition,
                  conditions: provider.availableConditions,
                  onChanged: provider.selectCondition,
                ),
                const SizedBox(height: 32),

                // ── React Button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: provider.isEnriching
                        ? null
                        : () => provider.checkReaction(),
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
                      provider.isEnriching ? 'Analyzing...' : 'React!',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                if (provider.isEnriching) const _LoadingShimmerCard(),
                if (!provider.isEnriching && provider.lastResult != null) ...[
                  _ResultCard(result: provider.lastResult!),
                  const SizedBox(height: 16),
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
}

// ═══════════════════════════════════════════════════════════════
// NEW HELPER: Autocomplete Search Field
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// Updated: Autocomplete Search Field (Fixed for latest flutter_typeahead)
// ═══════════════════════════════════════════════════════════════

class _CompoundSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onSelected;

  const _CompoundSearchField({required this.hint, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      // 1. decoration එක වෙනස් වෙලා තියෙන්නේ මෙහෙමයි
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: AppTheme.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
          ),
        );
      },
      // 2. suggestionsCallback එක තියෙන්නේ මෙහෙමයි
      suggestionsCallback: (pattern) async =>
          await PubChemService.getSuggestions(pattern),

      // 3. itemBuilder එකේ item එක වෙනුවට suggestion දාන්න
      itemBuilder: (context, suggestion) => ListTile(
        title: Text(suggestion, style: const TextStyle(color: Colors.white)),
      ),

      // 4. අලුත් version එකේ නම 'onSelected' පමණයි
      onSelected: onSelected,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXISTING HELPERS (Updated slightly)
// ═══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: const Text(
            'Select condition',
            style: TextStyle(color: Colors.white30, fontSize: 14),
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
}

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
                isCorrect ? 'Reaction Occurred!' : 'No Reaction',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Groq Llama 3',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
                          'Product: ${result.product!.name}',
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
                'AI is formulating response...',
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
              const Text(
                'PubChem Data',
                style: TextStyle(
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
          _propertyRow('IUPAC Name', compound.iupacName),
          _propertyRow('Formula', compound.molecularFormula),
          if (compound.molecularWeight > 0.0)
            _propertyRow(
              'Molecular Weight',
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
