/// Data fetched from the PubChem PUG REST API for a given compound.
///
/// This is a *read-only enrichment model* — it supplements the
/// local [Compound] model with real-world chemical metadata
/// without replacing any local data.
class PubChemCompound {
  final int cid;
  final String iupacName;
  final String molecularFormula;
  final double molecularWeight;
  final String? description;
  final String? imageUrl;

  const PubChemCompound({
    required this.cid,
    required this.iupacName,
    required this.molecularFormula,
    required this.molecularWeight,
    this.description,
    this.imageUrl,
  });

  /// Parses from the PubChem PropertyTable JSON response.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "PropertyTable": {
  ///     "Properties": [{ "CID": ..., "MolecularFormula": ..., ... }]
  ///   }
  /// }
  /// ```
  factory PubChemCompound.fromPropertyJson(Map<String, dynamic> json) {
    final props =
        (json['PropertyTable']['Properties'] as List).first as Map<String, dynamic>;

    final cid = props['CID'] as int;

    return PubChemCompound(
      cid: cid,
      iupacName: props['IUPACName'] as String? ?? '',
      molecularFormula: props['MolecularFormula'] as String? ?? '',
      molecularWeight:
          double.tryParse('${props['MolecularWeight']}') ?? 0.0,
      // 2D structure image from PubChem (free, no key required)
      imageUrl:
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG',
    );
  }

  /// Returns a copy with [description] populated from a separate API call.
  PubChemCompound copyWithDescription(String desc) {
    return PubChemCompound(
      cid: cid,
      iupacName: iupacName,
      molecularFormula: molecularFormula,
      molecularWeight: molecularWeight,
      description: desc,
      imageUrl: imageUrl,
    );
  }

  @override
  String toString() =>
      'PubChemCompound($iupacName, CID: $cid, MW: $molecularWeight)';
}
