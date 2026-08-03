import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class RftCalculatorScreen extends StatefulWidget {
  const RftCalculatorScreen({super.key});

  @override
  State<RftCalculatorScreen> createState() => _RftCalculatorScreenState();
}

class _RftCalculatorScreenState extends State<RftCalculatorScreen> {
  final ctrl = KeypadFieldController(['passed', 'total']);
  double? _rft;

  void _recalc() {
    final passed = ctrl.number('passed');
    final total = ctrl.number('total');

    setState(() {
      if (passed != null &&
          passed >= 0 &&
          total != null &&
          total > 0 &&
          passed <= total) {
        // RFT % = (রিপেয়ার ছাড়া পাস হওয়া পিস ÷ মোট চেক করা পিস) × 100
        _rft = (passed / total) * 100;
      } else {
        _rft = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'RFT %\n(RIGHT FIRST TIME)',
      icon: Icons.verified_rounded,
      iconAsset: 'assets/homeicon/rft_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'RFT % (Right First Time)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'RFT% (Right First Time) দিয়ে বোঝা যায় প্রথমবার '
                'ইন্সপেকশনেই কোনো রিপেয়ার/অল্টারেশন ছাড়া কত শতাংশ পিস '
                'পাস হয়েছে। এটা প্রোডাকশন লাইনের কোয়ালিটি ও কর্মদক্ষতার '
                'একটা গুরুত্বপূর্ণ সূচক — যত বেশি RFT%, ততই কম রিওয়ার্ক '
                'ও কম সময়ের অপচয়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'RFT % = (রিপেয়ার ছাড়া প্রথমবারেই পাস হওয়া পিস ÷ '
                'মোট চেক করা পিস) × 100',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. একটা নির্দিষ্ট সময়ে/ব্যাচে মোট কতগুলো পিস '
                'ইন্সপেকশনে চেক করা হয়েছে তা লিখুন\n'
                '২. এর মধ্যে কতগুলো পিস কোনো রকম রিপেয়ার/অল্টারেশন ছাড়াই '
                'সরাসরি পাস হয়েছে তা লিখুন\n'
                '৩. অ্যাপ স্বয়ংক্রিয়ভাবে RFT% বের করে দেবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, মোট ৫০০ পিস চেক করা হয়েছে, তার মধ্যে ৪৬৫টা পিস '
                'প্রথমবারেই কোনো রিপেয়ার ছাড়া পাস হয়েছে\n'
                'RFT % = (465 ÷ 500) × 100 = 93%\n\n'
                'নোট: বাকি ৭% পিস হয় রিপেয়ার প্রয়োজন হয়েছে অথবা রিজেক্ট '
                'হয়েছে — এই দুই ধরনের পিস এই ক্যালকুলেশনে "Not RFT" '
                'হিসেবে গণ্য হবে।',
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
              icon: Icons.check_circle_rounded,
              label: 'Passed Without Repair',
              subLabel: 'প্রথমবারে পাস হওয়া পিস',
              value: ctrl.values['passed']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'passed',
              onTap: () => setState(() => ctrl.setActive('passed')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.checklist_rounded,
              label: 'Total Pieces Checked',
              subLabel: 'মোট চেক করা পিস',
              value: ctrl.values['total']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'total',
              onTap: () => setState(() => ctrl.setActive('total')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'RFT % (RIGHT FIRST TIME)',
              value: _rft != null ? '${_rft!.toStringAsFixed(1)}%' : '0%',
              borderColor:
                  _rft != null ? AppColors.green : AppColors.inputBorder,
              live: _rft != null,
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
