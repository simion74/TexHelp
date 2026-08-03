import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class GsmChangeCalculatorScreen extends StatefulWidget {
  const GsmChangeCalculatorScreen({super.key});

  @override
  State<GsmChangeCalculatorScreen> createState() =>
      _GsmChangeCalculatorScreenState();
}

class _GsmChangeCalculatorScreenState
    extends State<GsmChangeCalculatorScreen> {
  final ctrl = KeypadFieldController(['greyGsm', 'finishedGsm']);
  double? _changePercent;

  void _recalc() {
    final grey = ctrl.number('greyGsm');
    final finished = ctrl.number('finishedGsm');

    setState(() {
      if (grey != null && grey > 0 && finished != null && finished > 0) {
        // GSM Change % = ((Finished GSM − Grey GSM) ÷ Grey GSM) × 100
        _changePercent = ((finished - grey) / grey) * 100;
      } else {
        _changePercent = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIncrease = (_changePercent ?? 0) >= 0;

    return CalcScaffold(
      title: 'GSM CHANGE %\n(GREY vs FINISHED)',
      icon: Icons.compare_arrows_rounded,
      iconAsset: 'assets/homeicon/gsm_change_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'GSM Change % (Grey vs Finished)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Finishing প্রসেসের (যেমন Compacting, Heat Setting, '
                'Resin Finish) কারণে ফেব্রিকের GSM (Grams per Square '
                'Meter) Grey স্টেজের তুলনায় বেড়ে বা কমে যেতে পারে। এই '
                'পরিবর্তনের শতাংশ জানা থাকলে Grey GSM অর্ডার করার সময় '
                'সঠিক টার্গেট রাখা সহজ হয়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'GSM Change % = ((Finished GSM − Grey GSM) ÷ Grey GSM) '
                '× 100\n\n'
                'ফলাফল পজিটিভ (+) হলে GSM বেড়েছে (Finishing-এ '
                'Compacting/Shrinkage-এর কারণে সাধারণ), নেগেটিভ (−) '
                'হলে GSM কমেছে।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. Grey (ফিনিশিং-এর আগের) ফেব্রিকের GSM মাপুন\n'
                '২. একই ফেব্রিকের Finishing-এর পরের GSM মাপুন\n'
                '৩. পার্থক্যটা Grey GSM দিয়ে ভাগ করে ১০০ দিয়ে গুণ করলেই '
                'পরিবর্তনের শতাংশ পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Grey GSM = 160 এবং Finished GSM = 180\n'
                'GSM Change % = ((180 − 160) ÷ 160) × 100 = 12.5%\n\n'
                'অর্থাৎ Finishing-এর পর ফেব্রিকের GSM ১২.৫% বৃদ্ধি '
                'পেয়েছে — এটা Grey ফেব্রিক অর্ডার করার সময় হিসাবে '
                'রাখা প্রয়োজন।',
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
              icon: Icons.texture_rounded,
              label: 'Grey GSM',
              subLabel: 'Finishing-এর আগে',
              value: ctrl.values['greyGsm']!,
              unit: 'g/m²',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'greyGsm',
              onTap: () => setState(() => ctrl.setActive('greyGsm')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.check_circle_outline_rounded,
              label: 'Finished GSM',
              subLabel: 'Finishing-এর পরে',
              value: ctrl.values['finishedGsm']!,
              unit: 'g/m²',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'finishedGsm',
              onTap: () => setState(() => ctrl.setActive('finishedGsm')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'GSM CHANGE %',
              value: _changePercent != null
                  ? '${isIncrease ? '+' : ''}${_changePercent!.toStringAsFixed(1)}%'
                  : '0%',
              borderColor: _changePercent != null
                  ? (isIncrease ? AppColors.green : AppColors.gradeCRed)
                  : AppColors.inputBorder,
              textColor: _changePercent != null
                  ? (isIncrease ? AppColors.darkGreen : AppColors.gradeCRed)
                  : AppColors.darkGreen,
              live: _changePercent != null,
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
