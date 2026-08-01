import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class HankCountCalculatorScreen extends StatefulWidget {
  const HankCountCalculatorScreen({super.key});

  @override
  State<HankCountCalculatorScreen> createState() =>
      _HankCountCalculatorScreenState();
}

class _HankCountCalculatorScreenState
    extends State<HankCountCalculatorScreen> {
  final ctrl = KeypadFieldController(['length', 'weight']);
  double? _count;

  void _recalc() {
    final length = ctrl.number('length');
    final weight = ctrl.number('weight');

    setState(() {
      if (length != null &&
          length > 0 &&
          weight != null &&
          weight > 0) {
        // Ne = (Length in yards ÷ 840) ÷ Weight in lbs
        _count = (length / 840) / weight;
      } else {
        _count = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'HANK / COUNT\nCALCULATOR',
      icon: Icons.linear_scale_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Hank / Count Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'কটন কাউন্ট সিস্টেমে (English Count / Ne), একটা "Hank" হলো '
                '৮৪০ গজ সুতার একটা নির্দিষ্ট দৈর্ঘ্যের একক। Ne নির্ণয় করলে '
                'বোঝা যায় ১ পাউন্ড সুতায় কতগুলো ৮৪০-গজের Hank আছে — যত বেশি '
                'Ne, সুতা তত চিকন।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Ne = (দৈর্ঘ্য গজে ÷ 840) ÷ ওজন পাউন্ডে\n\n'
                'অর্থাৎ, প্রথমে মোট দৈর্ঘ্যকে ৮৪০ দিয়ে ভাগ করে Hank সংখ্যা '
                'বের করতে হয়, তারপর সেটাকে সুতার ওজন (পাউন্ডে) দিয়ে ভাগ '
                'করলে Ne পাওয়া যায়।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. একটা নির্দিষ্ট নমুনা সুতার দৈর্ঘ্য মাপুন (গজে)\n'
                '২. একই নমুনার ওজন মাপুন (পাউন্ডে)\n'
                '৩. দৈর্ঘ্যকে ৮৪০ দিয়ে ভাগ করে Hank সংখ্যা বের করুন\n'
                '৪. Hank সংখ্যাকে ওজন দিয়ে ভাগ করলেই Ne (Yarn Count) '
                'পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, নমুনা সুতার দৈর্ঘ্য = 8400 yards, ওজন = 0.5 lbs\n'
                'Hank সংখ্যা = 8400 ÷ 840 = 10\n'
                'Ne = 10 ÷ 0.5 = 20s\n\n'
                'অর্থাৎ এই সুতাটা 20 Ne কাউন্টের।',
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 30.0,
          bottom: 10.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Sample Length',
              subLabel: 'সুতার নমুনার দৈর্ঘ্য',
              value: ctrl.values['length']!,
              unit: 'yd',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'length',
              onTap: () => setState(() => ctrl.setActive('length')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.scale_rounded,
              label: 'Sample Weight',
              subLabel: 'সুতার নমুনার ওজন',
              value: ctrl.values['weight']!,
              unit: 'lbs',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'weight',
              onTap: () => setState(() => ctrl.setActive('weight')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'YARN COUNT (Ne)',
              value: _count != null ? '${_count!.toStringAsFixed(2)}s' : '0s',
              borderColor:
                  _count != null ? AppColors.green : AppColors.inputBorder,
              live: _count != null,
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
