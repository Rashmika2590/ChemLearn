import '../models/compound.dart';
import '../models/reaction.dart';
import '../models/lesson.dart';

/// Provides hard-coded seed data for the MVP.
///
/// In production this data lives in Firestore. During development
/// (or if Firestore is unreachable) the app falls back to this data
/// so the UI is always populated.
class SeedData {
  SeedData._();

  // ══════════════════════════════════════════════════════════
  // COMPOUNDS  (10 entries)
  // ══════════════════════════════════════════════════════════
  static const List<Compound> compounds = [
    Compound(
      id: 'c1',
      name: 'Methane',
      formula: 'CH₄',
      type: 'alkane',
      level: 1,
      description:
          'The simplest alkane. A colourless, odourless gas and the main component of natural gas.',
    ),
    Compound(
      id: 'c2',
      name: 'Ethane',
      formula: 'C₂H₆',
      type: 'alkane',
      level: 1,
      description:
          'A two-carbon alkane found in natural gas. Used as a feedstock for ethylene production.',
    ),
    Compound(
      id: 'c3',
      name: 'Ethene',
      formula: 'C₂H₄',
      type: 'alkene',
      level: 1,
      description:
          'The simplest alkene, containing a C=C double bond. Widely used in polymerisation.',
    ),
    Compound(
      id: 'c4',
      name: 'Propene',
      formula: 'C₃H₆',
      type: 'alkene',
      level: 1,
      description:
          'A three-carbon alkene used to manufacture polypropylene plastics.',
    ),
    Compound(
      id: 'c5',
      name: 'Ethanol',
      formula: 'C₂H₅OH',
      type: 'alcohol',
      level: 1,
      description:
          'A common alcohol found in beverages and used as a fuel additive and solvent.',
    ),
    Compound(
      id: 'c6',
      name: 'Methanol',
      formula: 'CH₃OH',
      type: 'alcohol',
      level: 1,
      description:
          'The simplest alcohol. Toxic to humans. Used as an industrial solvent.',
    ),
    Compound(
      id: 'c7',
      name: 'Hydrogen Bromide',
      formula: 'HBr',
      type: 'acid',
      level: 1,
      description:
          'A strong hydrohalic acid used as a reagent in addition reactions with alkenes.',
    ),
    Compound(
      id: 'c8',
      name: 'Bromoethane',
      formula: 'C₂H₅Br',
      type: 'haloalkane',
      level: 1,
      description:
          'A haloalkane produced by adding HBr across ethene. Used in organic synthesis.',
    ),
    Compound(
      id: 'c9',
      name: 'Water',
      formula: 'H₂O',
      type: 'other',
      level: 1,
      description:
          'Essential molecule. Acts as a reagent in hydration reactions of alkenes.',
    ),
    Compound(
      id: 'c10',
      name: '2-Bromopropane',
      formula: 'CH₃CHBrCH₃',
      type: 'haloalkane',
      level: 1,
      description:
          'A secondary haloalkane formed by addition of HBr to propene (Markovnikov\'s rule).',
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // REACTIONS  (10 entries)
  // ══════════════════════════════════════════════════════════
  static const List<Reaction> reactions = [
    // 1 ── Ethene + HBr → Bromoethane
    Reaction(
      id: 'r1',
      reactants: ['c3', 'c7'], // Ethene + HBr
      conditions: ['Room temperature'],
      product: 'c8', // Bromoethane
      type: 'addition',
      level: 1,
      explanation:
          'HBr adds across the C=C double bond of ethene in an electrophilic addition reaction, producing bromoethane.',
    ),
    // 2 ── Propene + HBr → 2-Bromopropane
    Reaction(
      id: 'r2',
      reactants: ['c4', 'c7'], // Propene + HBr
      conditions: ['Room temperature'],
      product: 'c10', // 2-Bromopropane
      type: 'addition',
      level: 1,
      explanation:
          'HBr adds to propene following Markovnikov\'s rule. The H attaches to the carbon with more hydrogens, and Br to the other.',
    ),
    // 3 ── Ethene + H₂O → Ethanol
    Reaction(
      id: 'r3',
      reactants: ['c3', 'c9'], // Ethene + Water
      conditions: ['H₃PO₄ catalyst', 'High temperature'],
      product: 'c5', // Ethanol
      type: 'addition',
      level: 1,
      explanation:
          'Water adds across the double bond of ethene in the presence of a phosphoric acid catalyst. This is called hydration.',
    ),
    // 4 ── Ethanol → Ethene + Water (dehydration / elimination)
    Reaction(
      id: 'r4',
      reactants: ['c5'], // Ethanol
      conditions: ['H₂SO₄ catalyst', 'High temperature'],
      product: 'c3', // Ethene
      type: 'elimination',
      level: 2,
      explanation:
          'Ethanol loses a water molecule (dehydration) when heated with concentrated sulfuric acid, producing ethene.',
    ),
    // 5 ── Methane + Br₂ → Bromomethane (simplified)
    Reaction(
      id: 'r5',
      reactants: ['c1'], // Methane
      conditions: ['UV light'],
      product: 'c8', // Simplified: using bromoethane as closest match
      type: 'substitution',
      level: 2,
      explanation:
          'In UV light, a bromine radical replaces one hydrogen on methane. This is free-radical substitution.',
    ),
    // 6 ── Propene + H₂O → Propanol (simplified)
    Reaction(
      id: 'r6',
      reactants: ['c4', 'c9'], // Propene + Water
      conditions: ['H₃PO₄ catalyst', 'High temperature'],
      product: 'c5', // Simplified mapping
      type: 'addition',
      level: 1,
      explanation:
          'Water adds to propene via acid-catalysed hydration, producing an alcohol (propan-2-ol by Markovnikov\'s rule).',
    ),
    // 7 ── Ethene + H₂ → Ethane (hydrogenation)
    Reaction(
      id: 'r7',
      reactants: ['c3'], // Ethene
      conditions: ['Ni catalyst', 'High temperature'],
      product: 'c2', // Ethane
      type: 'addition',
      level: 1,
      explanation:
          'Hydrogen gas adds across the C=C double bond in the presence of a nickel catalyst, converting ethene to ethane.',
    ),
    // 8 ── Combustion of Methane
    Reaction(
      id: 'r8',
      reactants: ['c1'], // Methane
      conditions: ['Ignition'],
      product: 'c9', // Water (simplified product)
      type: 'combustion',
      level: 1,
      explanation:
          'Methane burns in oxygen to produce carbon dioxide and water. This is complete combustion.',
    ),
    // 9 ── Combustion of Ethanol
    Reaction(
      id: 'r9',
      reactants: ['c5'], // Ethanol
      conditions: ['Ignition'],
      product: 'c9', // Water (simplified product)
      type: 'combustion',
      level: 1,
      explanation:
          'Ethanol burns in excess oxygen to produce CO₂ and H₂O. Ethanol is used as a biofuel.',
    ),
    // 10 ── Bromoethane + NaOH → Ethanol (nucleophilic substitution)
    Reaction(
      id: 'r10',
      reactants: ['c8'], // Bromoethane
      conditions: ['NaOH (aq)', 'Heat'],
      product: 'c5', // Ethanol
      type: 'substitution',
      level: 2,
      explanation:
          'The hydroxide ion (OH⁻) replaces the bromine atom via nucleophilic substitution, producing ethanol.',
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // LESSONS  (3 entries)
  // ══════════════════════════════════════════════════════════
  static const List<Lesson> lessons = [
    Lesson(
      id: 'l1',
      title: 'Introduction to Alkanes',
      level: 1,
      relatedReactions: ['r5', 'r8'],
      content: '''
Alkanes are the simplest family of hydrocarbons — molecules made of only carbon and hydrogen atoms.

🔑 Key Facts:
• General formula: CₙH₂ₙ₊₂
• All bonds are single bonds (C–C and C–H)
• They are saturated hydrocarbons
• Relatively unreactive compared to alkenes

📝 Examples:
• Methane (CH₄) — the simplest alkane
• Ethane (C₂H₆) — two carbons
• Propane (C₃H₈) — three carbons

⚗️ Typical Reactions:
• Combustion — alkanes burn in oxygen to produce CO₂ and H₂O
• Free-radical substitution — in UV light, halogens can replace hydrogen atoms

💡 Tip: Alkanes are found in fossil fuels like natural gas and petroleum.
''',
    ),
    Lesson(
      id: 'l2',
      title: 'Introduction to Alkenes',
      level: 1,
      relatedReactions: ['r1', 'r2', 'r3', 'r7'],
      content: '''
Alkenes contain at least one carbon–carbon double bond (C=C), which makes them much more reactive than alkanes.

🔑 Key Facts:
• General formula: CₙH₂ₙ
• They are unsaturated hydrocarbons
• The double bond is the functional group
• They can undergo addition reactions

📝 Examples:
• Ethene (C₂H₄) — the simplest alkene
• Propene (C₃H₆) — three carbons

⚗️ Typical Reactions:
• Electrophilic addition — HBr, H₂O, H₂, or Br₂ can add across the double bond
• Hydrogenation — adding H₂ to form an alkane
• Hydration — adding H₂O to form an alcohol

💡 Tip: The double bond makes a region of high electron density that attracts electrophiles.
''',
    ),
    Lesson(
      id: 'l3',
      title: 'Introduction to Alcohols',
      level: 1,
      relatedReactions: ['r3', 'r4', 'r9', 'r10'],
      content: '''
Alcohols contain the hydroxyl (–OH) functional group bonded to a carbon atom.

🔑 Key Facts:
• General formula: CₙH₂ₙ₊₁OH
• The –OH group is the functional group
• They are polar molecules — soluble in water
• They can be primary, secondary, or tertiary

📝 Examples:
• Methanol (CH₃OH) — simplest, toxic
• Ethanol (C₂H₅OH) — found in drinks, used as fuel

⚗️ Typical Reactions:
• Combustion — burn to produce CO₂ and H₂O
• Dehydration — lose water to form alkenes (elimination)
• Substitution — the –OH can be replaced by halogens

💡 Tip: Ethanol can be made by fermentation of sugars or by hydration of ethene.
''',
    ),
  ];

  // ── Helper to look up compounds by ID ────────────────────
  static Compound? compoundById(String id) {
    try {
      return compounds.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
