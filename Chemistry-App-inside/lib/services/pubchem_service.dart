import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pubchem_compound.dart';

/// Fetches real chemical data from the PubChem PUG REST API.
///
/// **Completely free — no API key required.**
///
/// Implements:
/// - In-memory caching (avoids duplicate network calls)
/// - Rate limiting (max 5 requests/sec per PubChem policy)
/// - Graceful error handling (returns `null` on failure)
class PubChemService {
  static const _baseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';

  /// In-memory cache: compound name or formula → PubChemCompound.
  final Map<String, PubChemCompound> _cache = {};

  /// Timestamps of recent requests for rate limiting.
  final List<DateTime> _requestTimestamps = [];

  /// PubChem policy: max 5 requests per second.
  static const _maxRequestsPerSecond = 5;

  // ────────────────────────────────────────────────────────────
  // PUBLIC API
  // ────────────────────────────────────────────────────────────

  /// Fetches compound properties + description from PubChem by name.
  ///
  /// Returns a [PubChemCompound] or `null` if the compound isn't found
  /// or the network is unavailable. Results are cached for the session.
  Future<PubChemCompound?> getCompound(String compoundName) async {
    // Normalise the name for cache lookup
    final key = compoundName.trim().toLowerCase();

    // Return cached result if available
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      // Step 1: Fetch properties (formula, MW, IUPAC name)
      final properties = await _fetchProperties(compoundName);
      if (properties == null) return null;

      // Step 2: Fetch description (optional enrichment)
      final description = await _fetchDescription(compoundName);

      // Combine into final model
      final compound = description != null
          ? properties.copyWithDescription(description)
          : properties;

      // Cache the result
      _cache[key] = compound;
      return compound;
    } catch (e) {
      debugPrint('PubChemService: Error fetching "$compoundName": $e');
      return null;
    }
  }

  /// 🧪 NEW: Fetches compound properties using a Chemical Formula (e.g., "C3H8O").
  ///
  /// This is used as a fallback when Gemini predicts a dynamic reaction product.
  Future<PubChemCompound?> fetchCompoundProperties(String formula) async {
    final cleanFormula = formula.replaceAll(' ', '');
    final key = 'formula_$cleanFormula'.toLowerCase();

    // Cache lookup
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final url = Uri.parse(
      '$_baseUrl/compound/fastformula/$cleanFormula/property/IUPACName,MolecularWeight,CID/JSON',
    );

    final body = await _getJson(url);
    if (body == null) return null;

    try {
      final propertiesList = body['PropertyTable']?['Properties'];
      if (propertiesList != null && propertiesList.isNotEmpty) {
        final firstResult = propertiesList[0];
        final cid = firstResult['CID'] as int? ?? 0;

        // 🎯 ඔයාගේ PubChemCompound Model එකට 100% ක්ම ගැලපෙන්න මෙතන වෙනස් කළා:
        final compound = PubChemCompound(
          cid: cid,
          iupacName: firstResult['IUPACName'] as String? ?? 'Unknown Compound',
          molecularFormula: cleanFormula,
          molecularWeight:
              double.tryParse('${firstResult['MolecularWeight']}') ??
              0.0, // String ටික double කලා
          imageUrl:
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG',
          description: '', // Will be filled by Gemini explanation later
        );

        _cache[key] = compound;
        return compound;
      }
    } catch (e) {
      debugPrint('PubChemService: Error parsing formula "$formula": $e');
    }
    return null;
  }

  /// Returns the 2D structure image URL for a compound by Name.
  ///
  /// Does not make a network call — just constructs the URL.
  String getStructureImageUrl(String compoundName) {
    final encoded = Uri.encodeComponent(compoundName);
    return '$_baseUrl/compound/name/$encoded/PNG';
  }

  /// Clears the in-memory cache.
  void clearCache() {
    _cache.clear();
  }

  // ────────────────────────────────────────────────────────────
  // INTERNAL HELPERS
  // ────────────────────────────────────────────────────────────

  /// Fetches molecular properties from PubChem.
  Future<PubChemCompound?> _fetchProperties(String name) async {
    final encoded = Uri.encodeComponent(name);
    final url = Uri.parse(
      '$_baseUrl/compound/name/$encoded/property/'
      'MolecularFormula,MolecularWeight,IUPACName/JSON',
    );

    final body = await _getJson(url);
    if (body == null) return null;

    return PubChemCompound.fromPropertyJson(body);
  }

  /// Fetches the best available text description from PubChem.
  Future<String?> _fetchDescription(String name) async {
    final encoded = Uri.encodeComponent(name);
    final url = Uri.parse('$_baseUrl/compound/name/$encoded/description/JSON');

    final body = await _getJson(url);
    if (body == null) return null;

    try {
      final infoList = body['InformationList']['Information'] as List;

      // Find the longest/most useful description (skip empty title-only entries)
      String? best;
      for (final info in infoList) {
        final desc = info['Description'] as String?;
        if (desc != null && (best == null || desc.length > best.length)) {
          best = desc;
        }
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  /// Makes a rate-limited HTTP GET and returns parsed JSON, or `null`.
  Future<Map<String, dynamic>?> _getJson(Uri url) async {
    await _enforceRateLimit();

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      // 404 = compound not found (expected for some names)
      if (response.statusCode == 404) {
        debugPrint('PubChemService: Compound not found at $url');
        return null;
      }

      debugPrint('PubChemService: HTTP ${response.statusCode} for $url');
      return null;
    } on TimeoutException {
      debugPrint('PubChemService: Timeout for $url');
      return null;
    } catch (e) {
      debugPrint('PubChemService: Network error: $e');
      return null;
    }
  }

  /// Enforces the PubChem rate limit (max 5 requests/second).
  Future<void> _enforceRateLimit() async {
    final now = DateTime.now();
    final windowStart = now.subtract(const Duration(seconds: 1));

    // Remove timestamps outside the 1-second window
    _requestTimestamps.removeWhere((t) => t.isBefore(windowStart));

    // If at capacity, wait until the oldest request exits the window
    if (_requestTimestamps.length >= _maxRequestsPerSecond) {
      final waitUntil = _requestTimestamps.first.add(
        const Duration(seconds: 1),
      );
      final delay = waitUntil.difference(DateTime.now());
      if (delay.isNegative == false) {
        await Future.delayed(delay);
      }
    }

    // Record this request
    _requestTimestamps.add(DateTime.now());
  }

  // Compound name suggestion (Autocomplete)
  static Future<List<String>> getSuggestions(String query) async {
    if (query.length < 2) return []; // අඩුම අකුරු 2ක්වත් ඕනේ

    final url = Uri.parse(
      'https://pubchem.ncbi.nlm.nih.gov/rest/autocomplete/compound/$query/json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // PubChem වලින් එන JSON එකේ "terms" කියන array එක අරගන්නවා
        final List<dynamic> terms = data['dictionary_terms']['compound'];
        return terms.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Autocomplete Error: $e');
    }
    return [];
  }
}
