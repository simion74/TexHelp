import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class DraftCalculatorScreen extends StatefulWidget {
  const DraftCalculatorScreen({super.key});

  @override
  State<DraftCalculatorScreen> createState() => _DraftCalculatorScreenState();
}

class _DraftCalculatorScreenState extends State<DraftCalculatorScreen> {
  final ctrl = KeypadFieldController(['feed', 'delivered']);
  double? _draft;

  void _recalc() {
    final feed = ctrl.number('feed');
    final delivered = ctrl.number('delivered');

    setState(() {
      if (feed != null && feed > 0 && delivered != null && delivered > 0) {
        // Draft = Delivered Count(Hank) ÷ Feed Count(Hank)
        _draft = delivered / feed;
      } else {
        _draft = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'DRAFT %\nCALCULATOR',
      icon: Icons.compress_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Draft % Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Draft হলো স্পিনিং প্রসেসের প্রতিটা স্টেজে (Blow Room → '
                'Card → Draw Frame → Speed Frame → Ring Frame) ফাইবার '
                'স্ট্র্যান্ডকে টেনে লম্বা ও চিকন করার অনুপাত। Feed material-এর '
                'তুলনায় Delivered material কতগুণ পাতলা হলো, সেটাই Draft।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Draft = Delivered Material-এর Count/Hank ÷ '
                'Feed Material-এর Count/Hank\n\n'
                'যেহেতু Count/Hank যত বেশি হয়, সুতা তত চিকন হয় — তাই '
                'Delivered-এর Count Feed-এর চেয়ে বেশি হলে Draft > 1 হবে, '
                'যা স্বাভাবিক (কারণ ড্রাফটিং-এ স্ট্র্যান্ড পাতলা হয়)।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. মেশিনে ঢোকার আগে Feed material-এর Hank/Count মাপুন\n'
                '২. মেশিন থেকে বের হওয়া Delivered material-এর Hank/Count '
                'মাপুন\n'
                '৩. Delivered-কে Feed দিয়ে ভাগ করলেই Draft পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Feed Hank = 0.12s এবং Delivered Hank = 6s\n'
                'তাহলে Draft = 6 ÷ 0.12 = 50\n\n'
                'অর্থাৎ, ফাইবার স্ট্র্যান্ডটা এই স্টেজে ৫০ গুণ টেনে লম্বা/চিকন '
                'করা হয়েছে।',
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
              icon: Icons.input_rounded,
              label: 'Feed Material',
              subLabel: 'Feed Hank / Count',
              value: ctrl.values['feed']!,
              unit: 'Ne',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'feed',
              onTap: () => setState(() => ctrl.setActive('feed')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.output_rounded,
              label: 'Delivered Material',
              subLabel: 'Delivered Hank / Count',
              value: ctrl.values['delivered']!,
              unit: 'Ne',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'delivered',
              onTap: () => setState(() => ctrl.setActive('delivered')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'DRAFT (X TIMES)',
              value: _draft != null ? '${_draft!.toStringAsFixed(2)}x' : '0x',
              borderColor:
                  _draft != null ? AppColors.green : AppColors.inputBorder,
              live: _draft != null,
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
