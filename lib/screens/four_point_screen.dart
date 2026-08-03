import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class FourPointScreen extends StatefulWidget {
  const FourPointScreen({super.key});

  @override
  State<FourPointScreen> createState() => _FourPointScreenState();
}

class _FourPointScreenState extends State<FourPointScreen> {
  final ctrl = KeypadFieldController(['points', 'width', 'length']);

  double? _pts100Yd;
  String _grade = 'N/A';

  void _recalculate() {
    final pts = ctrl.number('points');
    final wid = ctrl.number('width');
    final lenM = ctrl.number('length');

    if (pts != null && wid != null && wid > 0 && lenM != null && lenM > 0) {
      final lenYards = lenM * 1.09361;
      final total = (pts * 3600) / (lenYards * wid);
      setState(() {
        _pts100Yd = total;
        if (total <= 20) {
          _grade = 'GRADE A';
        } else if (total <= 40) {
          _grade = 'GRADE B';
        } else {
          _grade = 'GRADE C';
        }
      });
    } else {
      setState(() {
        _pts100Yd = null;
        _grade = 'N/A';
      });
    }
  }

  Color get _gradeColor {
    switch (_grade) {
      case 'GRADE A':
        return AppColors.gradeAGreen;
      case 'GRADE B':
        return AppColors.gradeBYellow;
      case 'GRADE C':
        return AppColors.gradeCRed;
      default:
        return AppColors.darkGreen;
    }
  }

  Color get _gradeBg {
    switch (_grade) {
      case 'GRADE A':
        return AppColors.gradeAGreenBg;
      case 'GRADE B':
        return AppColors.gradeBYellowBg;
      case 'GRADE C':
        return AppColors.gradeCRedBg;
      default:
        return Colors.white;
    }
  }

  void _onDigit(String v) => setState(() {
        ctrl.appendDigit(v);
        _recalculate();
      });

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: '4 POINT FABRIC\nINSPECTION',
      icon: Icons.checkroom_rounded,
      // হোম স্ক্রিনে এই ক্যালকুলেটরের জন্য যে ছবিটা ব্যবহার হয়েছে,
      // হেডারের লোগো বক্সেও এখন সেই একই ছবি দেখাবে।
      iconAsset: 'assets/homeicon/4_point_inspection.webp',
      // 📖 হেডারের ডান কোনায় গাইড আইকন — চাপলে বটম-শিটে ৪ পয়েন্ট
      // ইনস্পেকশন সিস্টেমের সংজ্ঞা, পয়েন্ট অ্যালোকেশন, গ্রেড টেবিল,
      // ক্যালকুলেশন ফরমুলা ও ইনস্পেকশন টিপস দেখানো হয়।
      extraHeaderAction: FormulaGuideButton(
        title: '4 Point Inspection System',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: '4 Point Inspection System হলো Woven ও Knitted ফেব্রিকের '
                'কোয়ালিটি যাচাইয়ের সবচেয়ে বহুল ব্যবহৃত পদ্ধতি। ফেব্রিকের '
                'ত্রুটি (Defect)-এর আকারের ভিত্তিতে পয়েন্ট দেওয়া হয়, এবং '
                'মোট পয়েন্ট দিয়ে ফেব্রিকের সামগ্রিক মান (Grade) নির্ধারণ '
                'করা হয়।\n\n'
                'বিশেষ নিয়ম: একটি সিঙ্গেল ত্রুটি কখনোই ৪ পয়েন্টের বেশি '
                'পাবে না।',
          ),
          FormulaGuideSection(
            heading: 'Point Allocation (Defect Size)',
            body: 'ত্রুটির আকার অনুযায়ী পয়েন্ট নির্ধারণ:\n\n'
                '• Up to 3 inch (≤7.5 cm)  →  1 Point\n'
                '• Over 3 to 6 inch (>7.5–15 cm)  →  2 Points\n'
                '• Over 6 to 9 inch (>15–23 cm)  →  3 Points\n'
                '• Over 9 inch (>23 cm)  →  4 Points',
          ),
          FormulaGuideSection(
            heading: 'Hole / Cut / Open Defect',
            body: 'গর্ত বা কাটা অংশের (Hole/Cut) জন্য আলাদা পয়েন্ট নিয়ম:\n\n'
                '• Up to 1 inch  →  2 Points\n'
                '• Over 1 inch  →  4 Points',
          ),
          FormulaGuideSection(
            heading: 'Fabric Grade (Common Buyer Standard)',
            body: 'প্রতি 100 বর্গ গজে (Sq. Yard) মোট পয়েন্টের ভিত্তিতে '
                'গ্রেড নির্ধারণ করা হয়:\n\n'
                '• 0 – 20 Points  →  GRADE A (Accept)\n'
                '• 21 – 28 Points  →  GRADE B (Conditional Accept)*\n'
                '• Above 28 Points  →  GRADE C (Reject)\n\n'
                '*Conditional Accept: Buyer-এর Quality Requirement অনুযায়ী '
                'গ্রহণযোগ্য হতে পারে।\n\n'
                'Note: বিভিন্ন Buyer বা Brand-এর Acceptable Point Limit '
                'ভিন্ন হতে পারে (যেমন 20, 25, 30 বা 40 Points/100 yd²)।',
          ),
          FormulaGuideSection(
            heading: 'Calculation Formula',
            body: 'Points/100 yd² = (Total Points × 3600) ÷ '
                '(Fabric Width (inch) × Fabric Length (yard))\n\n'
                'উদাহরণ:\n'
                'Fabric Width = 60 inch\n'
                'Fabric Length = 100 yard\n'
                'Total Points = 30\n\n'
                'হিসাব: (30 × 3600) ÷ (60 × 100) = 18\n'
                'ফলাফল: 18 Points/100 Square Yard\n'
                'সিদ্ধান্ত: GRADE A (Accept)',
          ),
          FormulaGuideSection(
            heading: 'Inspection Tips',
            body: '• স্ট্যান্ডার্ড ইনস্পেকশন মেশিনে ফেব্রিক পরীক্ষা করুন।\n'
                '• প্রয়োজনে ফেব্রিকের উভয় পিঠ (Face ও Back) পরীক্ষা করুন।\n'
                '• পয়েন্ট দেওয়ার আগে ত্রুটির আকার সঠিকভাবে মাপুন।\n'
                '• একটি সিঙ্গেল ত্রুটিতে ৪ পয়েন্টের বেশি দেওয়া যাবে না।\n'
                '• চূড়ান্ত সিদ্ধান্ত নেওয়ার আগে Points per 100 Sq. Yard '
                'হিসাব করে নিন।',
          ),
        ],
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalculate();
      }),
      // ১. ইচ্ছা মতো প্যাডিং কমানো বা বাড়ানোর জন্য পুরো content-কে Padding দিয়ে র‍্যাপ করা হয়েছে:
      content: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 28.0,
          bottom:
              16.0, // <-- এই মান পরিবর্তন করে কি-প্যাডের সাথে গ্যাপ কমানো/বাড়ানো যাবে
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.gps_fixed_rounded,
              label: 'Total Point',
              subLabel: 'Penalty Points Sum',
              value: ctrl.values['points']!,
              unit: 'pts',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'points',
              onTap: () => setState(() => ctrl.setActive('points')),
            ),

            // ২. ইনপুট কার্ডগুলোর মধ্যবর্তী ফাঁকা জায়গা নিয়ন্ত্রণ করতে SizedBox ব্যবহার করুন:
            const SizedBox(height: 8.0),

            InputCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Width / Dia',
              subLabel: 'Fabric Width',
              value: ctrl.values['width']!,
              unit: 'inch',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'width',
              onTap: () => setState(() => ctrl.setActive('width')),
            ),

            const SizedBox(height: 8.0),

            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Length',
              subLabel: 'Fabric Length',
              value: ctrl.values['length']!,
              unit: 'mtr',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'length',
              onTap: () => setState(() => ctrl.setActive('length')),
            ),

            const SizedBox(height: 10.0),

            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Points/100 Sq. Yd',
                    value: _pts100Yd?.toStringAsFixed(2) ?? '0.00',
                    borderColor:
                        _pts100Yd != null ? _gradeColor : AppColors.inputBorder,
                    bgColor: _pts100Yd != null ? _gradeBg : Colors.white,
                    textColor:
                        _pts100Yd != null ? _gradeColor : AppColors.darkGreen,
                    live: _pts100Yd != null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ResultBox(
                    label: 'Fabric Grade',
                    value: _grade,
                    borderColor:
                        _grade != 'N/A' ? _gradeColor : AppColors.inputBorder,
                    bgColor: _grade != 'N/A' ? _gradeBg : Colors.white,
                    textColor: _gradeColor,
                    live: _grade != 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        onDigit: _onDigit,
        onBackspace: () => setState(() {
          ctrl.backspace();
          _recalculate();
        }),
        onClear: () => setState(() {
          ctrl.clearActive();
          _recalculate();
        }),
        onUp: () => setState(() => ctrl.moveField(-1)),
        onDown: () => setState(() => ctrl.moveField(1)),
      ),
    );
  }
}
