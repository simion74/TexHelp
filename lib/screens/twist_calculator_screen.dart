import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class TwistCalculatorScreen extends StatefulWidget {
  const TwistCalculatorScreen({super.key});

  @override
  State<TwistCalculatorScreen> createState() => _TwistCalculatorScreenState();
}

class _TwistCalculatorScreenState extends State<TwistCalculatorScreen> {
  final ctrl = KeypadFieldController(['count', 'tm']);
  double? _tpi;

  void _recalc() {
    final ne = ctrl.number('count');
    final tm = ctrl.number('tm');

    setState(() {
      if (ne != null && ne > 0 && tm != null && tm > 0) {
        // TPI = TM × √Ne
        _tpi = tm * math.sqrt(ne);
      } else {
        _tpi = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'YARN TWIST\n(TPI) CALCULATOR',
      icon: Icons.sync_alt_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      extraHeaderAction: FormulaGuideButton(
        title: 'Yarn Twist / TPI',
        sections: const [
          FormulaGuideSection(
            heading: '📌 সংজ্ঞা (Definition)',
            body:
                'Twist হলো সুতার ফাইবারগুলোকে একসাথে ধরে রাখার জন্য দেওয়া '
                'প্যাঁচ। TPI (Twist Per Inch) মানে সুতার প্রতি ইঞ্চিতে কতগুলো '
                'প্যাঁচ দেওয়া আছে। TM (Twist Multiplier) হলো একটা ধ্রুবক '
                'সংখ্যা যা দিয়ে বোঝা যায় সুতাটা সফট, মিডিয়াম নাকি হার্ড '
                'টুইস্টেড।',
          ),
          FormulaGuideSection(
            heading: '🧮 ফরমুলা',
            body: 'TPI = TM × √(Count in Ne)\n\n'
                'অর্থাৎ, Twist Multiplier-কে ইংলিশ কাউন্টের বর্গমূল দিয়ে '
                'গুণ করলে TPI পাওয়া যায়।',
          ),
          FormulaGuideSection(
            heading: '📝 ধাপে ধাপে হিসাব',
            body: '১. প্রথমে সুতার Ne (English Count) বের করুন\n'
                '২. এরপর প্রয়োজনীয় Twist Multiplier (TM) নির্ধারণ করুন — '
                'এটা সাধারণত ফেব্রিকের ব্যবহার অনুযায়ী মিলে ঠিক করা থাকে\n'
                '৩. Count-এর বর্গমূল (√Ne) বের করুন\n'
                '৪. TM-কে সেই বর্গমূল দিয়ে গুণ করলেই TPI পাওয়া যাবে',
          ),
          FormulaGuideSection(
            heading: '💡 সাধারণ TM রেঞ্জ',
            body: 'সফট টুইস্ট (নিটিং ইয়ার্ন): TM ≈ 3.0 - 3.5\n'
                'মিডিয়াম টুইস্ট (সাধারণ উইভিং): TM ≈ 3.5 - 4.0\n'
                'হার্ড টুইস্ট (ক্রেপ/স্পেশাল ফেব্রিক): TM ≈ 4.5 এর বেশি\n\n'
                'নোট: এই রেঞ্জগুলো সাধারণ নির্দেশনা মাত্র, প্রতিটা মিল/ফেব্রিক '
                'অনুযায়ী পরিবর্তিত হতে পারে।',
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
              icon: Icons.tune_rounded,
              label: 'Twist Multiplier',
              subLabel: 'TM (Constant)',
              value: ctrl.values['tm']!,
              unit: 'TM',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'tm',
              onTap: () => setState(() => ctrl.setActive('tm')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'TWIST PER INCH (TPI)',
              value: _tpi?.toStringAsFixed(2) ?? '0.00',
              borderColor:
                  _tpi != null ? AppColors.green : AppColors.inputBorder,
              live: _tpi != null,
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
