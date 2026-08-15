import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';

/// mm / cm / inch কনভার্টার (ছোট মাপ)
/// -------------------------------------
/// তিনটি ফিল্ডের যেকোনো একটিতে সংখ্যা লিখলেই বাকিগুলো স্বয়ংক্রিয়ভাবে
/// (dynamically) হিসাব হয়ে বসে যাবে। অ্যাপের বাকি সব ক্যালকুলেটরের মতোই
/// একই ব্যাকগ্রাউন্ড ফ্রেম (CalcScaffold), একই কিপ্যাড (NumericKeypad) এবং
/// হেডারের ডান কোনায় একই ধরনের FormulaGuideButton ব্যবহার করা হয়েছে
/// (four_point_screen.dart এর সাথে হুবহু একই প্যাটার্ন)। পরে আরও ইউনিট
/// (যেমন point/line) লাগলে _order এবং _toMm ম্যাপে যোগ করলেই একই
/// প্যাটার্নে কাজ করবে।
class SmallMeasurementConverterScreen extends StatefulWidget {
  const SmallMeasurementConverterScreen({super.key});

  @override
  State<SmallMeasurementConverterScreen> createState() =>
      _SmallMeasurementConverterScreenState();
}

class _SmallMeasurementConverterScreenState
    extends State<SmallMeasurementConverterScreen> {
  // 🔢 মিলিমিটার ভিত্তি (base unit) ধরে বাকিগুলোর কনভার্শন ফ্যাক্টর
  static const Map<String, double> _toMm = {
    'mm': 1.0,
    'cm': 10.0,
    'inch': 25.4,
  };

  static const List<String> _order = ['mm', 'cm', 'inch'];

  final ctrl = KeypadFieldController(_order);

  void _recalcFrom(String changedId) {
    final raw = ctrl.number(changedId);
    if (raw == null) {
      for (final id in _order) {
        if (id != changedId) ctrl.setValue(id, '');
      }
      return;
    }
    final mm = raw * _toMm[changedId]!;
    for (final id in _order) {
      if (id == changedId) continue;
      final val = mm / _toMm[id]!;
      ctrl.setValue(id, _fmt(val));
    }
  }

  String _fmt(double v) {
    if (v == 0) return '';
    var s = v.toStringAsFixed(4);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  void _onDigit(String v) => setState(() {
        ctrl.appendDigit(v);
        _recalcFrom(ctrl.activeId);
      });

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'MM / CM / INCH\nCONVERTER',
      icon: Icons.square_foot_rounded,
      // হোম স্ক্রিনে এই ফিচারের জন্য যে ছবিটা ব্যবহার হয়েছে, হেডারের
      // লোগো বক্সেও এখন সেই একই ছবি দেখাবে।
      iconAsset: 'assets/homeicon/SmallMeasurement.webp',
      // 📖 হেডারের ডান কোনায় গাইড আইকন — চাপলে বটম-শিটে সংজ্ঞা, ফরমুলা ও
      // ম্যানুয়ালি হিসাব করার নিয়ম দেখানো হয় (4 Point Inspection এর
      // FormulaGuideButton এর মতোই একই প্যাটার্ন)।
      extraHeaderAction: FormulaGuideButton(
        title: 'MM / CM / Inch Converter',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'Millimeter (mm), Centimeter (cm) ও Inch — এই তিনটি '
                'ছোট মাপের একক টেক্সটাইলে বোতাম সাইজ, ট্রিম, সেলাই '
                'অ্যালাউন্স, লেবেল সাইজ, ও ছোট ছোট এক্সেসরিজ মাপার জন্য '
                'ব্যবহার হয়।\n\n'
                'যেকোনো একটি বক্সে সংখ্যা লিখলেই বাকি এককগুলোতে সাথে '
                'সাথে হিসাব হয়ে বসে যাবে।',
          ),
          FormulaGuideSection(
            heading: 'কনভার্শন ফরমুলা (Formula)',
            body: 'cm = mm ÷ 10\n'
                'inch = mm ÷ 25.4\n\n'
                'mm = cm × 10\n'
                'inch = cm ÷ 2.54\n\n'
                'mm = inch × 25.4\n'
                'cm = inch × 2.54',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১ ইঞ্চি = ২.৫৪ সেন্টিমিটার = ২৫.৪ মিলিমিটার — এই '
                'তিনটি সংখ্যা মুখস্থ রাখলেই ক্যালকুলেটর ছাড়াই যেকোনো '
                'মাপ ম্যানুয়ালি বের করা যায়।\n\n'
                '১ সেন্টিমিটার = ১০ মিলিমিটার — এটা সরাসরি হিসাব, '
                'কোনো দশমিক লাগে না।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন একটি বোতামের ব্যাস ১৫ মিলিমিটার।\n\n'
                'cm = 15 ÷ 10 = 1.5 cm\n'
                'inch = 15 ÷ 25.4 = 0.5906 inch\n\n'
                'অ্যাপে শুধু "Millimeter" বক্সে 15 লিখলেই বাকি দুইটা '
                'বক্সে এই ফলাফল স্বয়ংক্রিয়ভাবে বসে যাবে।',
          ),
        ],
      ),
      onReset: () => setState(() => ctrl.resetAll()),
      content: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 28.0,
          bottom: 16.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.square_foot_rounded,
              label: 'Millimeter',
              subLabel: 'Length in mm',
              value: ctrl.values['mm']!,
              unit: 'mm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'mm',
              onTap: () => setState(() => ctrl.setActive('mm')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.square_foot_rounded,
              label: 'Centimeter',
              subLabel: 'Length in cm',
              value: ctrl.values['cm']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'cm',
              onTap: () => setState(() => ctrl.setActive('cm')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.square_foot_rounded,
              label: 'Inch',
              subLabel: 'Length in Inch',
              value: ctrl.values['inch']!,
              unit: 'in',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'inch',
              onTap: () => setState(() => ctrl.setActive('inch')),
            ),
          ],
        ),
      ),
      keypad: NumericKeypad(
        onDigit: _onDigit,
        onBackspace: () => setState(() {
          ctrl.backspace();
          _recalcFrom(ctrl.activeId);
        }),
        onClear: () => setState(() {
          ctrl.clearActive();
          _recalcFrom(ctrl.activeId);
        }),
        onUp: () => setState(() => ctrl.moveField(-1)),
        onDown: () => setState(() => ctrl.moveField(1)),
      ),
    );
  }
}
