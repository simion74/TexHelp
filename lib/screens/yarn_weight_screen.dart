import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

enum _CountSystem { ne, nm, tex, denier }

enum _LengthUnit { meter, yard, feet }

/// Yarn Weight Calculator (Spinning)
/// ----------------------------------
/// Yarn Count (Ne/Nm/Tex/Denier যেকোনো একটা সিস্টেমে) ও Yarn Length
/// (Meter/Yard/Feet যেকোনো এককে) দিলে সুতার ওজন (g ও kg) বের করে দেয়।
/// Number of Ends/Yarns (ঐচ্ছিক) দিলে একসাথে একাধিক সুতার মোট ওজনও
/// বের করা যায় (যেমন ওয়ার্প বিমের মোট সুতা)। অ্যাপের বাকি সব
/// ক্যালকুলেটরের মতোই একই CalcScaffold, একই NumericKeypad এবং হেডারে
/// একই FormulaGuideButton ব্যবহার করা হয়েছে।
class YarnWeightScreen extends StatefulWidget {
  const YarnWeightScreen({super.key});

  @override
  State<YarnWeightScreen> createState() => _YarnWeightScreenState();
}

class _YarnWeightScreenState extends State<YarnWeightScreen> {
  final ctrl = KeypadFieldController(['count', 'length', 'ends']);

  _CountSystem _countSystem = _CountSystem.ne;
  _LengthUnit _lengthUnit = _LengthUnit.meter;

  double? _weightG;

  static const Map<_LengthUnit, double> _toMeter = {
    _LengthUnit.meter: 1.0,
    _LengthUnit.yard: 0.9144,
    _LengthUnit.feet: 0.3048,
  };

  void _recalc() {
    final countVal = ctrl.number('count');
    final lengthVal = ctrl.number('length');
    final endsVal = ctrl.number('ends') ?? 1.0;

    if (countVal == null ||
        countVal <= 0 ||
        lengthVal == null ||
        lengthVal <= 0 ||
        endsVal <= 0) {
      setState(() => _weightG = null);
      return;
    }

    final lengthM = lengthVal * _toMeter[_lengthUnit]!;
    double weightG;

    switch (_countSystem) {
      case _CountSystem.tex:
        // Tex = গ্রাম প্রতি ১০০০ মিটার
        weightG = (lengthM / 1000) * countVal;
        break;
      case _CountSystem.denier:
        // Denier = গ্রাম প্রতি ৯০০০ মিটার
        weightG = (lengthM / 9000) * countVal;
        break;
      case _CountSystem.nm:
        // Nm = মিটার প্রতি গ্রাম (indirect)
        weightG = lengthM / countVal;
        break;
      case _CountSystem.ne:
        // Ne = ৮৪০ গজের হ্যাংক সংখ্যা প্রতি পাউন্ড (indirect)
        final lengthYards = lengthM / 0.9144;
        final weightLb = lengthYards / (840 * countVal);
        weightG = weightLb * 453.592;
        break;
    }

    setState(() => _weightG = weightG * endsVal);
  }

  String get _countUnitLabel {
    switch (_countSystem) {
      case _CountSystem.ne:
        return 'Ne';
      case _CountSystem.nm:
        return 'Nm';
      case _CountSystem.tex:
        return 'tex';
      case _CountSystem.denier:
        return 'denier';
    }
  }

  String get _lengthUnitLabel {
    switch (_lengthUnit) {
      case _LengthUnit.meter:
        return 'm';
      case _LengthUnit.yard:
        return 'yd';
      case _LengthUnit.feet:
        return 'ft';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'YARN WEIGHT\nCALCULATOR',
      icon: Icons.linear_scale_rounded,
      // হোম স্ক্রিনে এই ফিচারের জন্য যে ছবিটা ব্যবহার হবে, হেডারের লোগো
      // বক্সেও এখন সেই একই ছবি দেখাবে (কোনো এক্সট্রা ব্যাকগ্রাউন্ড
      // কন্টেইনার ছাড়া — শুধু ছবি)।
      iconAsset: 'assets/homeicon/yarn_weight.webp',
      extraHeaderAction: FormulaGuideButton(
        title: 'Yarn Weight Calculator',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'সুতার কাউন্ট মূলত দুই ধরনের সিস্টেমে মাপা হয়:\n\n'
                '• Direct System (Tex, Denier) — সংখ্যা যত বেশি, সুতা তত '
                'মোটা। এখানে সংখ্যাটা নির্দিষ্ট দৈর্ঘ্যে কত গ্রাম ওজন তা '
                'নির্দেশ করে।\n\n'
                '• Indirect System (Ne, Nm) — সংখ্যা যত বেশি, সুতা তত '
                'চিকন। এখানে সংখ্যাটা নির্দিষ্ট ওজনে কত দৈর্ঘ্য তা '
                'নির্দেশ করে।\n\n'
                'তাই কাউন্ট সিস্টেম অনুযায়ী ওজন বের করার ফরমুলাও ভিন্ন '
                'হয়।',
          ),
          FormulaGuideSection(
            heading: 'ফরমুলা (Formula)',
            body: 'Tex সিস্টেমে (গ্রাম/১০০০ মিটার):\n'
                'Weight (g) = (Length in Meter ÷ 1000) × Tex\n\n'
                'Denier সিস্টেমে (গ্রাম/৯০০০ মিটার):\n'
                'Weight (g) = (Length in Meter ÷ 9000) × Denier\n\n'
                'Nm সিস্টেমে (মিটার/গ্রাম):\n'
                'Weight (g) = Length in Meter ÷ Nm\n\n'
                'Ne সিস্টেমে (৮৪০ গজের হ্যাংক/পাউন্ড):\n'
                'Weight (lb) = Length in Yard ÷ (840 × Ne)\n'
                'Weight (g) = Weight (lb) × 453.592',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: 'সবচেয়ে বেশি ব্যবহৃত Ne (কটন কাউন্ট) দিয়ে উদাহরণ:\n\n'
                '১) দৈর্ঘ্যকে গজে (yard) নিয়ে আসুন — মিটার হলে ১.০৯৩৬ '
                'দিয়ে গুণ করুন।\n'
                '২) গজকে ৮৪০ দিয়ে ভাগ করুন — এটা হলো মোট হ্যাংক সংখ্যা।\n'
                '৩) হ্যাংক সংখ্যাকে Ne (কাউন্ট) দিয়ে ভাগ করুন — এটা হলো '
                'ওজন পাউন্ডে।\n'
                '৪) পাউন্ডকে ৪৫৩.৫৯২ দিয়ে গুণ করলে গ্রামে ওজন পাওয়া '
                'যাবে।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন Yarn Count = 30 Ne, Yarn Length = 5000 yard।\n\n'
                'হ্যাংক সংখ্যা = 5000 ÷ 840 = 5.952\n'
                'ওজন (lb) = 5.952 ÷ 30 = 0.1984 lb\n'
                'ওজন (g) = 0.1984 × 453.592 = 89.99 g\n\n'
                'অ্যাপে শুধু Count সিস্টেমে "Ne" সিলেক্ট করে 30, Length '
                'এককে "Yard" সিলেক্ট করে 5000 লিখলেই এই ফলাফল অটো বের '
                'হয়ে যাবে।',
          ),
          FormulaGuideSection(
            heading: 'Number of Ends/Yarns টিপস',
            body: 'একসাথে একাধিক সুতা (যেমন ওয়ার্প বিমের সব এন্ড, বা '
                'প্লাইড ইয়ার্ন) থাকলে "Number of Ends" ফিল্ডে সংখ্যা '
                'দিন — মোট ওজন সেই অনুযায়ী গুণ হয়ে বের হবে। একটামাত্র '
                'সুতার ওজন জানতে চাইলে এই ফিল্ড খালি রাখুন (ডিফল্ট '
                'হিসেবে ১ ধরা হবে)।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _countSystem = _CountSystem.ne;
        _lengthUnit = _LengthUnit.meter;
        _weightG = null;
      }),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 28.0,
          bottom: 16.0,
        ),
        child: Column(
          children: [
            _SegmentedToggle<_CountSystem>(
              value: _countSystem,
              options: const {
                _CountSystem.ne: 'Ne',
                _CountSystem.nm: 'Nm',
                _CountSystem.tex: 'Tex',
                _CountSystem.denier: 'Denier',
              },
              onChanged: (v) => setState(() {
                _countSystem = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.donut_large_rounded,
              label: 'Yarn Count',
              subLabel: 'Count Value',
              value: ctrl.values['count']!,
              unit: _countUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'count',
              onTap: () => setState(() => ctrl.setActive('count')),
            ),
            const SizedBox(height: 14.0),
            _SegmentedToggle<_LengthUnit>(
              value: _lengthUnit,
              options: const {
                _LengthUnit.meter: 'Meter',
                _LengthUnit.yard: 'Yard',
                _LengthUnit.feet: 'Feet',
              },
              onChanged: (v) => setState(() {
                _lengthUnit = v;
                _recalc();
              }),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Yarn Length',
              subLabel: 'Length Value',
              value: ctrl.values['length']!,
              unit: _lengthUnitLabel,
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'length',
              onTap: () => setState(() => ctrl.setActive('length')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.filter_none_rounded,
              label: 'Number of Ends/Yarns',
              subLabel: 'Optional — default 1',
              value: ctrl.values['ends']!,
              unit: 'pcs',
              placeholder: '1',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'ends',
              onTap: () => setState(() => ctrl.setActive('ends')),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Yarn Weight (g)',
                    value: _weightG != null
                        ? '${_weightG!.toStringAsFixed(2)} g'
                        : '0.00 g',
                    borderColor:
                        _weightG != null ? AppColors.green : AppColors.inputBorder,
                    live: _weightG != null,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Yarn Weight (kg)',
                    value: _weightG != null
                        ? '${(_weightG! / 1000).toStringAsFixed(4)} kg'
                        : '0.0000 kg',
                    borderColor:
                        _weightG != null ? AppColors.green : AppColors.inputBorder,
                    live: _weightG != null,
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
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
        onUp: () => setState(() => ctrl.moveField(-1)),
        onDown: () => setState(() => ctrl.moveField(1)),
      ),
    );
  }
}

/// N-অপশনের সেগমেন্টেড টগল (Count System / Length Unit বেছে নেওয়ার জন্য) —
/// process_loss_screen.dart-এর _ModeToggle এর মতোই ডিজাইন ভাষা, শুধু
/// generic করে যেকোনো সংখ্যক অপশনের জন্য বানানো হয়েছে।
class _SegmentedToggle<T> extends StatelessWidget {
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const _SegmentedToggle({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: options.entries.map((entry) {
          final selected = entry.key == value;
          return Expanded(
            child: Material(
              color: selected ? AppColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => onChanged(entry.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.darkGreen,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
