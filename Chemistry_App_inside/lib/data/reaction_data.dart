// lib/data/reaction_data.dart

final List<Map<String, dynamic>> reactionLibrary = [
  // ============= EXISTING CONVERSIONS (KEPT) =============

  // 1. Ethanol → Ethyl Acetate (3 steps)
  {
    "start": "Ethanol",
    "target": "Ethyl Acetate",
    "flow": {
      "Ethanol": {
        "Conc. H2SO4, 170°C": "Ethene",
        "KMnO4 / H+": "Ethanoic Acid",
      },
      "Ethene": {"H2O / H+": "Ethanol"},
      "Ethanoic Acid": {"Ethanol / H+": "Ethyl Acetate"},
    },
  },

  // 2. Ethene → Ethane
  {
    "start": "Ethene",
    "target": "Ethane",
    "flow": {
      "Ethene": {"H2 / Ni": "Ethane"},
    },
  },

  // 3. Benzyl alcohol → Benzaldehyde
  {
    "start": "Benzyl alcohol",
    "target": "Benzaldehyde",
    "flow": {
      "Benzyl alcohol": {"PCC / CH2Cl2": "Benzaldehyde"},
    },
  },

  // 4. Benzaldehyde → Benzoic acid
  {
    "start": "Benzaldehyde",
    "target": "Benzoic acid",
    "flow": {
      "Benzaldehyde": {"KMnO4 / H+": "Benzoic acid"},
    },
  },

  // 5. Toluene → Benzaldehyde
  {
    "start": "Toluene",
    "target": "Benzaldehyde",
    "flow": {
      "Toluene": {"CrO2Cl2 (Etard reaction)": "Benzaldehyde"},
    },
  },

  // 6. Ethanol → Ethene
  {
    "start": "Ethanol",
    "target": "Ethene",
    "flow": {
      "Ethanol": {"Conc. H2SO4, 170°C": "Ethene"},
    },
  },

  // 7. Ethene → Ethanol
  {
    "start": "Ethene",
    "target": "Ethanol",
    "flow": {
      "Ethene": {"H2O / H+": "Ethanol"},
    },
  },

  // 8. Ethanol → Ethanoic acid
  {
    "start": "Ethanol",
    "target": "Ethanoic acid",
    "flow": {
      "Ethanol": {"KMnO4 / H+": "Ethanoic acid"},
    },
  },

  // 9. Ethanoic acid → Ethanol
  {
    "start": "Ethanoic acid",
    "target": "Ethanol",
    "flow": {
      "Ethanoic acid": {"LiAlH4 / ether then H2O": "Ethanol"},
    },
  },

  // 10. Methane → Methanol (3 steps)
  {
    "start": "Methane",
    "target": "Methanol",
    "flow": {
      "Methane": {"Cl2 / hv": "Chloromethane"},
      "Chloromethane": {"NaOH (aq)": "Methanol"},
    },
  },

  // 11. Methanol → Methanal
  {
    "start": "Methanol",
    "target": "Methanal",
    "flow": {
      "Methanol": {"Cu / 300°C": "Methanal"},
    },
  },

  // 12. Propanone → Propan-2-ol
  {
    "start": "Propanone",
    "target": "Propan-2-ol",
    "flow": {
      "Propanone": {"NaBH4 / H2O": "Propan-2-ol"},
    },
  },

  // 13. Propan-2-ol → Propanone
  {
    "start": "Propan-2-ol",
    "target": "Propanone",
    "flow": {
      "Propan-2-ol": {"K2Cr2O7 / H+": "Propanone"},
    },
  },

  // 14. Benzene → Nitrobenzene
  {
    "start": "Benzene",
    "target": "Nitrobenzene",
    "flow": {
      "Benzene": {"Conc. HNO3 / Conc. H2SO4": "Nitrobenzene"},
    },
  },

  // 15. Nitrobenzene → Aniline
  {
    "start": "Nitrobenzene",
    "target": "Aniline",
    "flow": {
      "Nitrobenzene": {"Sn / HCl then NaOH": "Aniline"},
    },
  },

  // 16. Aniline → Benzene
  {
    "start": "Aniline",
    "target": "Benzene",
    "flow": {
      "Aniline": {"NaNO2 / HCl (0-5°C) then H3PO2": "Benzene"},
    },
  },

  // 17. Benzene → Chlorobenzene
  {
    "start": "Benzene",
    "target": "Chlorobenzene",
    "flow": {
      "Benzene": {"Cl2 / FeCl3": "Chlorobenzene"},
    },
  },

  // 18. Chlorobenzene → Phenol
  {
    "start": "Chlorobenzene",
    "target": "Phenol",
    "flow": {
      "Chlorobenzene": {"NaOH (350°C, 200 atm) then H+": "Phenol"},
    },
  },

  // 19. Phenol → Benzene
  {
    "start": "Phenol",
    "target": "Benzene",
    "flow": {
      "Phenol": {"Zn dust / heat": "Benzene"},
    },
  },

  // 20. Ethene → Ethanal
  {
    "start": "Ethene",
    "target": "Ethanal",
    "flow": {
      "Ethene": {"PdCl2 / CuCl2 / O2 (Wacker process)": "Ethanal"},
    },
  },

  // 21. Ethanal → Ethanoic acid
  {
    "start": "Ethanal",
    "target": "Ethanoic acid",
    "flow": {
      "Ethanal": {"Tollens' reagent": "Ethanoic acid"},
    },
  },

  // 22. Ethanoic acid → Ethanoic anhydride
  {
    "start": "Ethanoic acid",
    "target": "Ethanoic anhydride",
    "flow": {
      "Ethanoic acid": {"P2O5 / heat": "Ethanoic anhydride"},
    },
  },

  // 23. Ethyl acetate → Ethanoic acid
  {
    "start": "Ethyl acetate",
    "target": "Ethanoic acid",
    "flow": {
      "Ethyl acetate": {"NaOH (aq) / heat then H+": "Ethanoic acid"},
    },
  },

  // 24. Bromoethane → Ethanol
  {
    "start": "Bromoethane",
    "target": "Ethanol",
    "flow": {
      "Bromoethane": {"NaOH (aq) / heat": "Ethanol"},
    },
  },

  // 25. Ethanol → Bromoethane
  {
    "start": "Ethanol",
    "target": "Bromoethane",
    "flow": {
      "Ethanol": {"PBr3": "Bromoethane"},
    },
  },

  // ============= NEW COMPLEX CONVERSIONS (26-50) =============

  // 26. Benzene → Paracetamol (Acetaminophen) - 6 steps
  {
    "start": "Benzene",
    "target": "Paracetamol",
    "flow": {
      "Benzene": {"Conc. HNO3 / Conc. H2SO4": "Nitrobenzene"},
      "Nitrobenzene": {"Sn / HCl then NaOH": "Aniline"},
      "Aniline": {"CH3COCl / pyridine": "Acetanilide"},
      "Acetanilide": {"Conc. HNO3 / Conc. H2SO4": "p-Nitroacetanilide"},
      "p-Nitroacetanilide": {"Sn / HCl then NaOH": "p-Aminophenol"},
      "p-Aminophenol": {"CH3COCl / pyridine": "Paracetamol"},
    },
  },

  // 27. Benzene → Aspirin (Acetylsalicylic acid) - 5 steps
  {
    "start": "Benzene",
    "target": "Aspirin",
    "flow": {
      "Benzene": {"CH3Cl / AlCl3 (Friedel-Crafts)": "Toluene"},
      "Toluene": {"KMnO4 / H+": "Benzoic acid"},
      "Benzoic acid": {"Phenol / PCl3": "Phenyl benzoate"},
      "Phenyl benzoate": {"NaOH / H2O then H+": "Salicylic acid"},
      "Salicylic acid": {"CH3COCl / pyridine": "Aspirin"},
    },
  },

  // 28. Glucose → Ethanol (Fermentation) - 4 steps
  {
    "start": "Glucose",
    "target": "Ethanol",
    "flow": {
      "Glucose": {"Zymase (yeast)": "Pyruvate"},
      "Pyruvate": {"Decarboxylase": "Acetaldehyde"},
      "Acetaldehyde": {"Alcohol dehydrogenase": "Ethanol"},
    },
  },

  // 29. Benzene → p-Nitroaniline - 4 steps
  {
    "start": "Benzene",
    "target": "p-Nitroaniline",
    "flow": {
      "Benzene": {"Conc. HNO3 / Conc. H2SO4": "Nitrobenzene"},
      "Nitrobenzene": {"Sn / HCl then NaOH": "Aniline"},
      "Aniline": {"CH3COCl": "Acetanilide"},
      "Acetanilide": {"Conc. HNO3 / Conc. H2SO4 then HCl": "p-Nitroaniline"},
    },
  },

  // 30. Ethene → Polyethylene - 2 steps (polymerization)
  {
    "start": "Ethene",
    "target": "Polyethylene",
    "flow": {
      "Ethene": {"Ziegler-Natta catalyst": "Polyethylene"},
    },
  },

  // 31. Benzene → Cyclohexane - 2 steps
  {
    "start": "Benzene",
    "target": "Cyclohexane",
    "flow": {
      "Benzene": {"H2 / Ni (high pressure)": "Cyclohexane"},
    },
  },

  // 32. Ethyne → Benzene (Trimerization) - 2 steps
  {
    "start": "Ethyne",
    "target": "Benzene",
    "flow": {
      "Ethyne": {"Red hot iron tube (873K)": "Benzene"},
    },
  },

  // 33. Propene → Polypropylene - 2 steps
  {
    "start": "Propene",
    "target": "Polypropylene",
    "flow": {
      "Propene": {"Ziegler-Natta catalyst": "Polypropylene"},
    },
  },

  // 34. Phenol → Picric acid (2,4,6-trinitrophenol) - 3 steps
  {
    "start": "Phenol",
    "target": "Picric acid",
    "flow": {
      "Phenol": {"Conc. H2SO4": "Phenol-2,4-disulfonic acid"},
      "Phenol-2,4-disulfonic acid": {"Conc. HNO3": "2,4-Dinitrophenol"},
      "2,4-Dinitrophenol": {"Conc. HNO3 / Conc. H2SO4": "Picric acid"},
    },
  },

  // 35. Ethanol → Diethyl ether - 2 steps
  {
    "start": "Ethanol",
    "target": "Diethyl ether",
    "flow": {
      "Ethanol": {"Conc. H2SO4 (140°C)": "Diethyl ether"},
    },
  },

  // 36. Acetylene → Acetaldehyde - 2 steps
  {
    "start": "Acetylene",
    "target": "Acetaldehyde",
    "flow": {
      "Acetylene": {"H2O / HgSO4 / H2SO4": "Acetaldehyde"},
    },
  },

  // 37. Acetaldehyde → Acetic acid - 2 steps
  {
    "start": "Acetaldehyde",
    "target": "Acetic acid",
    "flow": {
      "Acetaldehyde": {"O2 / Mn(OAc)2": "Acetic acid"},
    },
  },

  // 38. Glycerol → Acrolein - 2 steps
  {
    "start": "Glycerol",
    "target": "Acrolein",
    "flow": {
      "Glycerol": {"KHSO4 (dehydration)": "Acrolein"},
    },
  },

  // 39. Benzene → Styrene (for polystyrene) - 3 steps
  {
    "start": "Benzene",
    "target": "Styrene",
    "flow": {
      "Benzene": {"C2H4 / AlCl3": "Ethylbenzene"},
      "Ethylbenzene": {"O2 / catalyst": "Ethylbenzene hydroperoxide"},
      "Ethylbenzene hydroperoxide": {"Then H+ / heat": "Styrene"},
    },
  },

  // 40. Toluene → m-Nitrotoluene - 3 steps
  {
    "start": "Toluene",
    "target": "m-Nitrotoluene",
    "flow": {
      "Toluene": {"Conc. H2SO4 (sulfonation)": "p-Toluenesulfonic acid"},
      "p-Toluenesulfonic acid": {
        "Conc. HNO3 / Conc. H2SO4": "3-Nitro-p-toluenesulfonic acid",
      },
      "3-Nitro-p-toluenesulfonic acid": {"H2O / heat": "m-Nitrotoluene"},
    },
  },

  // 41. Cyclohexanol → Adipic acid (for Nylon 66) - 3 steps
  {
    "start": "Cyclohexanol",
    "target": "Adipic acid",
    "flow": {
      "Cyclohexanol": {"K2Cr2O7 / H+": "Cyclohexanone"},
      "Cyclohexanone": {"HNO3 / Cu catalyst": "Nitrocyclohexane"},
      "Nitrocyclohexane": {"HNO3 (oxidation)": "Adipic acid"},
    },
  },

  // 42. Methane → Formaldehyde - 3 steps
  {
    "start": "Methane",
    "target": "Formaldehyde",
    "flow": {
      "Methane": {"O2 / 400°C / catalyst": "Methanol"},
      "Methanol": {"Cu / 300°C": "Formaldehyde"},
    },
  },

  // 43. Ethanol → Butadiene (for synthetic rubber) - 4 steps
  {
    "start": "Ethanol",
    "target": "1,3-Butadiene",
    "flow": {
      "Ethanol": {"Al2O3 (dehydration)": "Ethene"},
      "Ethene": {"O2 / PdCl2 / CuCl2": "Acetaldehyde"},
      "Acetaldehyde": {"NaOH (aldol)": "Acetaldol"},
      "Acetaldol": {"H+ / heat": "1,3-Butadiene"},
    },
  },

  // 44. Phenol → Bisphenol A (for epoxy resins) - 3 steps
  {
    "start": "Phenol",
    "target": "Bisphenol A",
    "flow": {
      "Phenol": {"Acetone / HCl catalyst": "Bisphenol A"},
    },
  },

  // 45. Ethylene → Ethylene oxide - 2 steps
  {
    "start": "Ethylene",
    "target": "Ethylene oxide",
    "flow": {
      "Ethylene": {"O2 / Ag catalyst": "Ethylene oxide"},
    },
  },

  // 46. Toluene → Terephthalic acid (for PET) - 3 steps
  {
    "start": "Toluene",
    "target": "Terephthalic acid",
    "flow": {
      "Toluene": {"CH3Cl / AlCl3": "p-Xylene"},
      "p-Xylene": {"KMnO4 / H+": "p-Toluic acid"},
      "p-Toluic acid": {"KMnO4 / H+": "Terephthalic acid"},
    },
  },

  // 47. Acetone → Methyl methacrylate (Plexiglas) - 3 steps
  {
    "start": "Acetone",
    "target": "Methyl methacrylate",
    "flow": {
      "Acetone": {"HCN": "Acetone cyanohydrin"},
      "Acetone cyanohydrin": {"CH3OH / H2SO4": "Methyl methacrylate"},
    },
  },

  // 48. Cellulose → Cellulose acetate (textile fiber) - 3 steps
  {
    "start": "Cellulose",
    "target": "Cellulose acetate",
    "flow": {
      "Cellulose": {"Acetic anhydride / H2SO4": "Cellulose triacetate"},
      "Cellulose triacetate": {"Partial hydrolysis": "Cellulose acetate"},
    },
  },

  // 49. Vegetable oil → Glycerol + Fatty acids (saponification) - 1 step
  {
    "start": "Vegetable oil",
    "target": "Glycerol",
    "flow": {
      "Vegetable oil": {"NaOH (aq) / heat": "Glycerol"},
    },
  },

  // 50. Glucose → Gluconic acid - 2 steps
  {
    "start": "Glucose",
    "target": "Gluconic acid",
    "flow": {
      "Glucose": {"Br2 / H2O": "Gluconic acid"},
    },
  },
];
