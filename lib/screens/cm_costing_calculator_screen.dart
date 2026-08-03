import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class CmCostingCalculatorScreen extends StatefulWidget {
  const CmCostingCalculatorScreen({super.key});

  @override
  State<CmCostingCalculatorScreen> createState() =>
      _CmCostingCalculatorScreenState();
}

class _CmCostingCalculatorScreenState
    extends State<CmCostingCalculatorScreen> {
  final ctrl = KeypadFieldController(['smv', 'hourlyCost']);
  double? _cmCost;

  void _recalc() {
    final smv = ctrl.number('smv');
    final hourlyCost = ctrl.number('hourlyCost');

    setState(() {
      if (smv != null && smv > 0 && hourlyCost != null && hourlyCost > 0) {
        final costPerMinute = hourlyCost / 60;
        // CM Cost = SMV × Cost per Minute
        _cmCost = smv * costPerMinute;
      } else {
        _cmCost = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'CM (CUT & MAKE)\nCOSTING CALCULATOR',
      icon: Icons.payments_rounded,
      iconAsset: 'assets/homeicon/cm_costing_calculator.webp',
      showIconBackground: false,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'CM (Cut & Make) Costing',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body: 'CM (Cut & Make) Cost হলো একটা গার্মেন্ট তৈরি করতে '
                'শুধুমাত্র শ্রম (labor) খাতে কত খরচ হয়েছে, তার একটা '
                'বেসিক হিসাব — এটা SMV এবং প্রতি মিনিটে শ্রম খরচের ওপর '
                'ভিত্তি করে বের করা হয়।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'Cost per Minute = Hourly Labor Cost ÷ 60\n\n'
                'CM Cost (per piece) = SMV × Cost per Minute',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. প্রোডাক্টের SMV (মিনিটে) লিখুন\n'
                '২. ফ্যাক্টরির গড় ঘণ্টাপ্রতি শ্রম খরচ (বেতন + সুযোগ-'
                'সুবিধা মিলিয়ে, নিজের মুদ্রায়) লিখুন\n'
                '৩. অ্যাপ স্বয়ংক্রিয়ভাবে প্রতি পিসের CM Cost দেখাবে',
          ),
          FormulaGuideSection(
            heading: '⚠️ গুরুত্বপূর্ণ নোট',
            body: 'এটা শুধু সরাসরি শ্রম খরচের (Direct Labor Cost) '
                'একটা বেসিক হিসাব। প্রকৃত ফ্যাক্টরি CM Cost-এ সাধারণত '
                'ওভারহেড খরচ (বিদ্যুৎ, ভাড়া, প্রশাসনিক খরচ), লাভের '
                'মার্জিন ইত্যাদিও যোগ হয় — এই ক্যালকুলেটর শুধু বেস '
                'লেবার কস্টের দ্রুত আন্দাজের জন্য।',
          ),
          FormulaGuideSection(
            heading: '💡 উদাহরণ',
            body: 'ধরুন, SMV = 12 min, Hourly Labor Cost = 60 (টাকা/মুদ্রা)\n'
                'Cost per Minute = 60 ÷ 60 = 1.0\n'
                'CM Cost = 12 × 1.0 = 12.0 (প্রতি পিস)',
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
              icon: Icons.timer_rounded,
              label: 'SMV',
              subLabel: 'Standard Minute Value',
              value: ctrl.values['smv']!,
              unit: 'min',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'smv',
              onTap: () => setState(() => ctrl.setActive('smv')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.attach_money_rounded,
              label: 'Hourly Labor Cost',
              subLabel: 'গড় ঘণ্টাপ্রতি শ্রম খরচ',
              value: ctrl.values['hourlyCost']!,
              unit: '/hr',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'hourlyCost',
              onTap: () => setState(() => ctrl.setActive('hourlyCost')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'CM COST (PER PIECE)',
              value: _cmCost?.toStringAsFixed(3) ?? '0.000',
              borderColor:
                  _cmCost != null ? AppColors.green : AppColors.inputBorder,
              live: _cmCost != null,
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
