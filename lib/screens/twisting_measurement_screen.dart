import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

/// 🌀 Twisting (Spirality) Measurement — ফেব্রিকের প্যাঁচ/বাঁকা হওয়ার
/// শতাংশ মাপার জন্য আলাদা ক্যালকুলেটর (আগে এটা Shrinkage Measurement-এর
/// সাথে একসাথে ছিল, এখন আলাদা ফিচার হিসেবে ভাগ করা হয়েছে)।
class TwistingMeasurementScreen extends StatefulWidget {
  const TwistingMeasurementScreen({super.key});

  @override
  State<TwistingMeasurementScreen> createState() =>
      _TwistingMeasurementScreenState();
}

class _TwistingMeasurementScreenState
    extends State<TwistingMeasurementScreen> {
  final ctrl = KeypadFieldController(['refLength', 'displacement']);
  double? _twistPercent;

  void _recalc() {
    final length = ctrl.number('refLength');
    final d = ctrl.number('displacement');

    setState(() {
      if (length != null && length > 0 && d != null) {
        // Twist/Spirality % = (Displacement ÷ Reference Length) × 100
        _twistPercent = (d / length) * 100;
      } else {
        _twistPercent = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'TWISTING\nMEASUREMENT',
      icon: Icons.rotate_right_rounded,
      iconAsset: 'assets/homeicon/twisting_measurement.webp',
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Twisting (Spirality) Measurement',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা',
            body: 'Spirality (বা Twisting) হলো নিটেড ফেব্রিকের একটা '
                'সাধারণ সমস্যা, যেখানে ফেব্রিকের ওয়েল (Wale) সারিগুলো '
                'সোজা না থেকে কর্ণাকারে (তির্যকভাবে) বেঁকে যায়। এটা '
                'পরে তৈরি গার্মেন্টের সিম বাঁকা হয়ে যাওয়ার (twisted '
                'seam) কারণ হতে পারে।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Twist/Spirality % = (Displacement ÷ Reference Length) '
                '× 100\n\n'
                'Displacement হলো ফেব্রিকের ওয়েল লাইন সোজা রেখা থেকে '
                'কতটা সরে গেছে (cm-এ), আর Reference Length হলো যে '
                'দৈর্ঘ্যের ওপর এই বিচ্যুতি মাপা হয়েছে।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে',
            body: '১. ফেব্রিকের ওপর একটা নির্দিষ্ট Reference Length (cm) '
                'চিহ্নিত করুন — সাধারণত ওয়াশের আগে/পরে ফেব্রিকের দৈর্ঘ্য\n'
                '২. সেই দৈর্ঘ্যের মধ্যে ওয়েল লাইন সোজা রেখা থেকে কতটা '
                'কর্ণাকারে সরে গেছে (Displacement, cm) মাপুন\n'
                '৩. অ্যাপ স্বয়ংক্রিয়ভাবে Twist/Spirality % দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 নোট',
            body: 'সাধারণত ৫% এর নিচে Spirality গ্রহণযোগ্য ধরা হয়, তবে '
                'নির্দিষ্ট গ্রহণযোগ্যতা বায়ার/মিলের নিজস্ব স্ট্যান্ডার্ড '
                'অনুযায়ী ভিন্ন হতে পারে।',
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
              label: 'Reference Length',
              subLabel: 'যে দৈর্ঘ্যের ওপর মাপা হচ্ছে',
              value: ctrl.values['refLength']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'refLength',
              onTap: () => setState(() => ctrl.setActive('refLength')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.rotate_right_rounded,
              label: 'Displacement (D)',
              subLabel: 'ওয়েল লাইনের বিচ্যুতি',
              value: ctrl.values['displacement']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'displacement',
              onTap: () => setState(() => ctrl.setActive('displacement')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'TWIST / SPIRALITY %',
              value: _twistPercent != null
                  ? '${_twistPercent!.toStringAsFixed(2)}%'
                  : '0.00%',
              borderColor: _twistPercent != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _twistPercent != null,
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
