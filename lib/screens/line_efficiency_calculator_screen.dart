import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class LineEfficiencyCalculatorScreen extends StatefulWidget {
  const LineEfficiencyCalculatorScreen({super.key});

  @override
  State<LineEfficiencyCalculatorScreen> createState() =>
      _LineEfficiencyCalculatorScreenState();
}

class _LineEfficiencyCalculatorScreenState
    extends State<LineEfficiencyCalculatorScreen> {
  final ctrl =
      KeypadFieldController(['producedPcs', 'smv', 'operators', 'minutes']);
  double? _efficiency;

  void _recalc() {
    final pcs = ctrl.number('producedPcs');
    final smv = ctrl.number('smv');
    final operators = ctrl.number('operators');
    final minutes = ctrl.number('minutes');

    setState(() {
      if (pcs != null &&
          pcs > 0 &&
          smv != null &&
          smv > 0 &&
          operators != null &&
          operators > 0 &&
          minutes != null &&
          minutes > 0) {
        final producedMinutes = pcs * smv;
        final availableMinutes = operators * minutes;
        // Efficiency % = (Produced Minutes ÷ Available Minutes) × 100
        _efficiency = (producedMinutes / availableMinutes) * 100;
      } else {
        _efficiency = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'LINE EFFICIENCY %\nCALCULATOR',
      icon: Icons.trending_up_rounded,
      iconAsset: 'assets/homeicon/line_efficiency_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Line Efficiency % Calculator',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'Line Efficiency % দিয়ে বোঝা যায় একটা সেলাই লাইন '
                'তার সর্বোচ্চ সম্ভাব্য উৎপাদন ক্ষমতার (Operators × '
                'Available Time) কত শতাংশ প্রকৃতপক্ষে ব্যবহার করতে '
                'পেরেছে (Produced Pcs × SMV অনুযায়ী)।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Produced Minutes = Produced Pcs × SMV\n'
                'Available Minutes = Operators × Working Minutes\n\n'
                'Efficiency % = (Produced Minutes ÷ Available Minutes) '
                '× 100',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. নির্দিষ্ট সময়ে (যেমন একটা শিফটে) মোট কতটা পিস '
                'উৎপাদন হয়েছে লিখুন\n'
                '২. প্রোডাক্টের SMV লিখুন\n'
                '৩. লাইনের মোট অপারেটর সংখ্যা লিখুন\n'
                '৪. সেই সময়ে কাজের মোট মিনিট (যেমন ৮ ঘণ্টা = 480 '
                'মিনিট) লিখুন\n'
                '৫. অ্যাপ স্বয়ংক্রিয়ভাবে Line Efficiency % দেখাবে',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, Produced Pcs = 1200, SMV = 0.5, Operators = 30, '
                'Working Minutes = 480\n'
                'Produced Minutes = 1200 × 0.5 = 600\n'
                'Available Minutes = 30 × 480 = 14,400\n'
                'Efficiency % = (600 ÷ 14,400) × 100 ≈ 4.2%\n\n'
                '(এই উদাহরণে সংখ্যাগুলো শুধু হিসাব বোঝানোর জন্য, বাস্তব '
                'লাইন এফিশিয়েন্সি সাধারণত ৫০-৭৫% রেঞ্জে থাকে)',
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 26.0,
          bottom: 8.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.inventory_2_rounded,
              label: 'Produced Pieces',
              subLabel: 'মোট উৎপাদিত পিস',
              value: ctrl.values['producedPcs']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              dense: true,
              active: ctrl.activeId == 'producedPcs',
              onTap: () => setState(() => ctrl.setActive('producedPcs')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.timer_rounded,
              label: 'SMV',
              subLabel: 'Standard Minute Value',
              value: ctrl.values['smv']!,
              unit: 'min',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              dense: true,
              active: ctrl.activeId == 'smv',
              onTap: () => setState(() => ctrl.setActive('smv')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.people_alt_rounded,
              label: 'No. of Operators',
              subLabel: 'লাইনের অপারেটর সংখ্যা',
              value: ctrl.values['operators']!,
              unit: 'pcs',
              placeholder: '0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              dense: true,
              active: ctrl.activeId == 'operators',
              onTap: () => setState(() => ctrl.setActive('operators')),
            ),
            const SizedBox(height: 3.0),
            InputCard(
              icon: Icons.schedule_rounded,
              label: 'Working Minutes',
              subLabel: 'যেমন ৮ ঘণ্টা = 480 মিনিট',
              value: ctrl.values['minutes']!,
              unit: 'min',
              placeholder: '0.0',
              iconGradient: AppColors.darkTealIconGradient,
              accentColor: AppColors.darkTeal,
              dense: true,
              active: ctrl.activeId == 'minutes',
              onTap: () => setState(() => ctrl.setActive('minutes')),
            ),
            const SizedBox(height: 10),
            ResultBox(
              label: 'LINE EFFICIENCY %',
              value: _efficiency != null
                  ? '${_efficiency!.toStringAsFixed(1)}%'
                  : '0%',
              borderColor: _efficiency != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _efficiency != null,
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        height: 190,
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
