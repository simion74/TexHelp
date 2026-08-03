import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// 📊 AQL Sampling Plan Calculator — ANSI/ASQ Z1.4 (ISO 2859-1) স্ট্যান্ডার্ড
/// অনুযায়ী, শুধুমাত্র **General Inspection Level II, Normal Inspection**
/// (গার্মেন্টস QC-তে সবচেয়ে বেশি ব্যবহৃত ডিফল্ট) কভার করে। ডাটা সরাসরি
/// অফিসিয়াল স্ট্যান্ডার্ড টেবিল থেকে যাচাই করে নেওয়া।
///
/// ⚠️ এটা Special Levels (S-1 থেকে S-4), Tightened, বা Reduced Inspection
/// কভার করে না — সেসব ক্ষেত্রে অফিসিয়াল ANSI/ASQ Z1.4 ডকুমেন্ট দেখুন।
class AqlSamplingCalculatorScreen extends StatefulWidget {
  const AqlSamplingCalculatorScreen({super.key});

  @override
  State<AqlSamplingCalculatorScreen> createState() =>
      _AqlSamplingCalculatorScreenState();
}

class _LotRange {
  final int min;
  final int max;
  final String code;
  const _LotRange(this.min, this.max, this.code);
}

class _CodeLetterPlan {
  final int sampleSize;
  final Map<double, List<int?>> acRe;
  const _CodeLetterPlan(this.sampleSize, this.acRe);
}

class _AqlSamplingCalculatorScreenState
    extends State<AqlSamplingCalculatorScreen> {
  final ctrl = KeypadFieldController(['lotSize']);
  double _selectedAql = 2.5;

  String? _codeLetter;
  int? _sampleSize;
  int? _accept;
  int? _reject;
  bool _tooSmallForAql = false;

  // 📊 Table 1 — Lot Size → Code Letter (General Level II only)
  static const List<_LotRange> _lotRanges = [
    _LotRange(2, 8, 'A'),
    _LotRange(9, 15, 'B'),
    _LotRange(16, 25, 'C'),
    _LotRange(26, 50, 'D'),
    _LotRange(51, 90, 'E'),
    _LotRange(91, 150, 'F'),
    _LotRange(151, 280, 'G'),
    _LotRange(281, 500, 'H'),
    _LotRange(501, 1200, 'J'),
    _LotRange(1201, 3200, 'K'),
    _LotRange(3201, 10000, 'L'),
    _LotRange(10001, 35000, 'M'),
    _LotRange(35001, 150000, 'N'),
    _LotRange(150001, 500000, 'P'),
    _LotRange(500001, 999999999, 'Q'),
  ];

  // 📊 Table 2 — Code Letter → Sample Size + Ac/Re (Normal Inspection)
  static const List<double> aqlOptions = [0.65, 1.0, 1.5, 2.5, 4.0, 6.5];

  // 🛠️ FIX: এটা 'const' রাখা যাবে না — কারণ Map-এর key হিসেবে 'double'
  // (0.65, 1.0, 2.5 ইত্যাদি) ব্যবহার করা হয়েছে, আর Dart-এর নিয়ম অনুযায়ী
  // const map-এ double টাইপের key রাখা যায় না (double নিজের ==/hashCode
  // override করে বলে)। 'final' করে দিলে ঠিক একইভাবে কাজ করবে, শুধু
  // runtime-এ initialize হবে (const-এর মতো compile-time এ নয়)।
  static final Map<String, _CodeLetterPlan> _table2 = {
    'A': _CodeLetterPlan(2, {
      0.65: [null, null],
      1.0: [null, null],
      1.5: [null, null],
      2.5: [0, 1],
      4.0: [0, 1],
      6.5: [0, 1],
    }),
    'B': _CodeLetterPlan(3, {
      0.65: [null, null],
      1.0: [null, null],
      1.5: [0, 1],
      2.5: [0, 1],
      4.0: [0, 1],
      6.5: [0, 1],
    }),
    'C': _CodeLetterPlan(5, {
      0.65: [null, null],
      1.0: [0, 1],
      1.5: [0, 1],
      2.5: [0, 1],
      4.0: [0, 1],
      6.5: [1, 2],
    }),
    'D': _CodeLetterPlan(8, {
      0.65: [0, 1],
      1.0: [0, 1],
      1.5: [0, 1],
      2.5: [0, 1],
      4.0: [1, 2],
      6.5: [1, 2],
    }),
    'E': _CodeLetterPlan(13, {
      0.65: [0, 1],
      1.0: [0, 1],
      1.5: [0, 1],
      2.5: [1, 2],
      4.0: [1, 2],
      6.5: [2, 3],
    }),
    'F': _CodeLetterPlan(20, {
      0.65: [0, 1],
      1.0: [0, 1],
      1.5: [1, 2],
      2.5: [1, 2],
      4.0: [2, 3],
      6.5: [3, 4],
    }),
    'G': _CodeLetterPlan(32, {
      0.65: [0, 1],
      1.0: [1, 2],
      1.5: [1, 2],
      2.5: [2, 3],
      4.0: [3, 4],
      6.5: [5, 6],
    }),
    'H': _CodeLetterPlan(50, {
      0.65: [1, 2],
      1.0: [1, 2],
      1.5: [2, 3],
      2.5: [3, 4],
      4.0: [5, 6],
      6.5: [7, 8],
    }),
    'J': _CodeLetterPlan(80, {
      0.65: [1, 2],
      1.0: [2, 3],
      1.5: [3, 4],
      2.5: [5, 6],
      4.0: [7, 8],
      6.5: [10, 11],
    }),
    'K': _CodeLetterPlan(125, {
      0.65: [2, 3],
      1.0: [3, 4],
      1.5: [5, 6],
      2.5: [7, 8],
      4.0: [10, 11],
      6.5: [14, 15],
    }),
    'L': _CodeLetterPlan(200, {
      0.65: [3, 4],
      1.0: [5, 6],
      1.5: [7, 8],
      2.5: [10, 11],
      4.0: [14, 15],
      6.5: [21, 22],
    }),
    'M': _CodeLetterPlan(315, {
      0.65: [5, 6],
      1.0: [7, 8],
      1.5: [10, 11],
      2.5: [14, 15],
      4.0: [21, 22],
      6.5: [21, 22],
    }),
    'N': _CodeLetterPlan(500, {
      0.65: [7, 8],
      1.0: [10, 11],
      1.5: [14, 15],
      2.5: [21, 22],
      4.0: [21, 22],
      6.5: [21, 22],
    }),
    'P': _CodeLetterPlan(800, {
      0.65: [10, 11],
      1.0: [14, 15],
      1.5: [21, 22],
      2.5: [21, 22],
      4.0: [21, 22],
      6.5: [21, 22],
    }),
    'Q': _CodeLetterPlan(1250, {
      0.65: [14, 15],
      1.0: [21, 22],
      1.5: [21, 22],
      2.5: [21, 22],
      4.0: [21, 22],
      6.5: [21, 22],
    }),
  };

  String? _codeLetterForLot(int lot) {
    for (final r in _lotRanges) {
      if (lot >= r.min && lot <= r.max) return r.code;
    }
    return null;
  }

  void _recalc() {
    final lot = ctrl.number('lotSize')?.toInt();

    setState(() {
      if (lot == null || lot < 2) {
        _codeLetter = null;
        _sampleSize = null;
        _accept = null;
        _reject = null;
        _tooSmallForAql = false;
        return;
      }
      final code = _codeLetterForLot(lot);
      _codeLetter = code;
      if (code == null) {
        _sampleSize = null;
        _accept = null;
        _reject = null;
        return;
      }
      final plan = _table2[code]!;
      _sampleSize = plan.sampleSize;
      final acRe = plan.acRe[_selectedAql]!;
      if (acRe[0] == null) {
        _accept = null;
        _reject = null;
        _tooSmallForAql = true;
      } else {
        _accept = acRe[0];
        _reject = acRe[1];
        _tooSmallForAql = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'AQL SAMPLING PLAN\n(GENERAL LEVEL II)',
      // 🖼️ TODO: CalcScaffold-এ image icon সাপোর্ট যোগ হলে এই লাইনে
      // icon: Icons.fact_check_rounded এর বদলে নিচের path বসাতে হবে:
      // imagePath: 'assets/homeicon/aql_sampling.webp'
      icon: Icons.fact_check_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _selectedAql = 2.5;
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'AQL Sampling Plan (General Level II)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'AQL (Acceptable Quality Limit) স্যাম্পলিং হলো পুরো '
                'লট ১০০% চেক না করে, একটা র‍্যান্ডম নমুনা পরীক্ষা করে '
                'পুরো শিপমেন্ট Accept/Reject করার একটা পরিসংখ্যানগত '
                'পদ্ধতি — ANSI/ASQ Z1.4 (ISO 2859-1) স্ট্যান্ডার্ড অনুযায়ী।',
          ),
          FormulaGuideSection(
            heading: '📝 কীভাবে কাজ করে',
            body: '১. Lot Size (মোট প্রস্তুত পিসের সংখ্যা) লিখুন\n'
                '২. AQL % বেছে নিন (Major defects-এর জন্য সাধারণত 2.5, '
                'Minor-এর জন্য 4.0 — গার্মেন্টস ইন্ডাস্ট্রিতে সবচেয়ে '
                'প্রচলিত)\n'
                '৩. অ্যাপ Table 1 থেকে Code Letter, তারপর Table 2 থেকে '
                'Sample Size ও Accept/Reject সংখ্যা বের করে দেখাবে\n'
                '৪. নমুনায় পাওয়া ডিফেক্ট সংখ্যা যদি Accept (Ac)-এর সমান '
                'বা কম হয় → লট পাস; Reject (Re)-এর সমান বা বেশি হলে → '
                'লট ফেল',
          ),
          FormulaGuideSection(
            heading: '⚠️ গুরুত্বপূর্ণ সীমাবদ্ধতা',
            body: 'এই ক্যালকুলেটর শুধুমাত্র **General Inspection Level II, '
                'Normal Inspection** কভার করে — এটাই সবচেয়ে বেশি '
                'ব্যবহৃত ডিফল্ট সেটিং। যদি আপনার বায়ার/মিল Special '
                'Level (S-1 থেকে S-4), Tightened, বা Reduced Inspection '
                'ব্যবহার করে, তাহলে অফিসিয়াল ANSI/ASQ Z1.4 ডকুমেন্ট বা '
                'বায়ারের নির্দিষ্ট নির্দেশনা অনুসরণ করুন — এই '
                'ক্যালকুলেটরের ফলাফল সেসব ক্ষেত্রে প্রযোজ্য না।\n\n'
                'ডাটা: ANSI/ASQ Z1.4 (ISO 2859-1) স্ট্যান্ডার্ড টেবিল '
                'থেকে যাচাই করে নেওয়া।',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Lot Size = 5000, AQL = 2.5%\n'
                'Code Letter = L\n'
                'Sample Size = 200\n'
                'Accept (Ac) = 10, Reject (Re) = 11\n\n'
                'অর্থাৎ ২০০ পিস র‍্যান্ডম চেক করে ১০টা বা তার কম ডিফেক্ট '
                'পেলে লট পাস, ১১টা বা তার বেশি পেলে লট ফেল।',
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 24.0,
          bottom: 8.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.inventory_2_rounded,
              label: 'Lot Size',
              subLabel: 'মোট প্রস্তুত পিসের সংখ্যা',
              value: ctrl.values['lotSize']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: true,
              onTap: () => setState(() => ctrl.setActive('lotSize')),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'AQL % বেছে নিন',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: aqlOptions.map((aql) {
                final selected = aql == _selectedAql;
                return ChoiceChip(
                  label: Text(
                    '${aql.toStringAsFixed(2).replaceAll(RegExp(r'0$'), '').replaceAll(RegExp(r'\.$'), '')}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.darkGreen,
                    ),
                  ),
                  selected: selected,
                  selectedColor: AppColors.green,
                  backgroundColor: AppColors.cardBg,
                  onSelected: (_) => setState(() {
                    _selectedAql = aql;
                    _recalc();
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (_tooSmallForAql)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'এই Lot Size ও AQL কম্বিনেশনে স্ট্যান্ডার্ড sampling plan '
                  'নেই (sample size খুবই ছোট) — বড় AQL % বেছে নিন অথবা '
                  '১০০% ইনস্পেকশন বিবেচনা করুন।',
                  style: TextStyle(
                      fontSize: 11, color: Colors.red[700], height: 1.4),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'CODE LETTER',
                    value: _codeLetter ?? '-',
                    borderColor: _codeLetter != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    textColor: AppColors.teal,
                    dense: true,
                    live: _codeLetter != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'SAMPLE SIZE',
                    value: _sampleSize?.toString() ?? '-',
                    borderColor: _sampleSize != null
                        ? AppColors.purple
                        : AppColors.inputBorder,
                    textColor: AppColors.purple,
                    dense: true,
                    live: _sampleSize != null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'ACCEPT (Ac)',
                    value: _accept?.toString() ?? '-',
                    borderColor: _accept != null
                        ? AppColors.green
                        : AppColors.inputBorder,
                    dense: true,
                    live: _accept != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'REJECT (Re)',
                    value: _reject?.toString() ?? '-',
                    borderColor: _reject != null
                        ? AppColors.gradeCRed
                        : AppColors.inputBorder,
                    textColor: AppColors.gradeCRed,
                    dense: true,
                    live: _reject != null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        height: 170,
        onDigit: (v) => setState(() {
          ctrl.appendDigit(v);
          _recalc();
        }),
        onBackspace: () => setState(() {
          ctrl.backspace();
          _recalc();
        }),
        onClear: () => setState(() {
          ctrl.clearActive();
          _recalc();
        }),
        onUp: () {},
        onDown: () {},
      ),
    );
  }
}
