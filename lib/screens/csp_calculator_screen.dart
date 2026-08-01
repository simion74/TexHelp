import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class CspCalculatorScreen extends StatefulWidget {
  const CspCalculatorScreen({super.key});

  @override
  State<CspCalculatorScreen> createState() => _CspCalculatorScreenState();
}

class _CspCalculatorScreenState extends State<CspCalculatorScreen> {
  final ctrl = KeypadFieldController(['count', 'strength']);
  double? _csp;

  void _recalc() {
    final ne = ctrl.number('count');
    final str = ctrl.number('strength');

    setState(() {
      if (ne != null && ne > 0 && str != null && str > 0) {
        // CSP = Count × Lea Strength
        _csp = ne * str;
      } else {
        _csp = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'CSP\nCALCULATOR',
      icon: Icons.fitness_center_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'CSP (Count Strength Product)',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body:
                'CSP (Count Strength Product) হলো সুতার মান/গুণাগুণ যাচাই '
                'করার একটা গুরুত্বপূর্ণ সূচক। এটা দিয়ে বোঝা যায় নির্দিষ্ট '
                'কাউন্টের একটা সুতা কতটা মজবুত — যত বেশি CSP, সুতা তত ভালো '
                'মানের।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'CSP = Yarn Count (Ne) × Lea Strength (lbs)\n\n'
                'Lea Strength হলো ল্যাব টেস্টিং মেশিনে (Lea Strength Tester) '
                '১২০ গজ সুতার একটা লেয়া (Lea) ছেঁড়ার জন্য প্রয়োজনীয় বল '
                '(পাউন্ডে)।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. Yarn Count (Ne) নির্ণয় করুন\n'
                '২. Lea Strength Tester মেশিনে টেস্ট করে Lea Strength (lbs) '
                'বের করুন — সাধারণত একাধিক লেয়ার গড় মান নেওয়া হয়\n'
                '৩. দুটো মানকে গুণ করলেই CSP পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Yarn Count = 30 Ne এবং Lea Strength = 90 lbs\n'
                'তাহলে CSP = 30 × 90 = 2700\n\n'
                'নোট: গ্রহণযোগ্য CSP মান স্পিনিং মিল, ফাইবারের ধরন ও '
                'ব্যবহারের ওপর নির্ভর করে ভিন্ন হয়, তাই কোনো একক '
                'সর্বজনীন "ভালো" সংখ্যা নেই — নিজের মিলের স্ট্যান্ডার্ডের '
                'সাথে তুলনা করুন।',
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
              icon: Icons.tag_rounded,
              label: 'Yarn Count',
              subLabel: 'English Count (Ne)',
              value: ctrl.values['count']!,
              unit: 'Ne',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'count',
              onTap: () => setState(() => ctrl.setActive('count')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.bolt_rounded,
              label: 'Lea Strength',
              subLabel: 'Lea Strength Tester Reading',
              value: ctrl.values['strength']!,
              unit: 'lbs',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'strength',
              onTap: () => setState(() => ctrl.setActive('strength')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'CSP (COUNT STRENGTH PRODUCT)',
              value: _csp?.toStringAsFixed(0) ?? '0',
              borderColor:
                  _csp != null ? AppColors.green : AppColors.inputBorder,
              live: _csp != null,
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
