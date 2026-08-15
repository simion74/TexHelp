import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/formula_guide_button.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';

/// Meter / Yard / Feet কনভার্টার
/// -----------------------------
/// তিনটি ফিল্ডের যেকোনো একটিতে সংখ্যা লিখলেই বাকি দুইটা স্বয়ংক্রিয়ভাবে
/// (dynamically) হিসাব হয়ে বসে যাবে। অ্যাপের বাকি সব ক্যালকুলেটরের মতোই
/// একই ব্যাকগ্রাউন্ড ফ্রেম (CalcScaffold), একই কিপ্যাড (NumericKeypad) এবং
/// হেডারের ডান কোনায় একই ধরনের FormulaGuideButton ব্যবহার করা হয়েছে
/// (four_point_screen.dart এর সাথে হুবহু একই প্যাটার্ন)।
class LengthUnitConverterScreen extends StatefulWidget {
  const LengthUnitConverterScreen({super.key});

  @override
  State<LengthUnitConverterScreen> createState() =>
      _LengthUnitConverterScreenState();
}

class _LengthUnitConverterScreenState
    extends State<LengthUnitConverterScreen> {
  // 🔢 মিটার ভিত্তি (base unit) ধরে বাকি দুইটার কনভার্শন ফ্যাক্টর
  static const Map<String, double> _toMeter = {
    'meter': 1.0,
    'yard': 0.9144,
    'feet': 0.3048,
  };

  static const List<String> _order = ['meter', 'yard', 'feet'];

  final ctrl = KeypadFieldController(_order);

  // 👉 active ফিল্ডে যা লেখা হচ্ছে সেটাই raw রাখা হয়, বাকি ফিল্ডগুলো
  // থেকে ঐ ভ্যালু থেকে হিসাব করে ফরম্যাট করে বসানো হয়।
  void _recalcFrom(String changedId) {
    final raw = ctrl.number(changedId);
    if (raw == null) {
      for (final id in _order) {
        if (id != changedId) ctrl.setValue(id, '');
      }
      return;
    }
    final meters = raw * _toMeter[changedId]!;
    for (final id in _order) {
      if (id == changedId) continue;
      final val = meters / _toMeter[id]!;
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
      title: 'METER / YARD / FEET\nCONVERTER',
      icon: Icons.straighten_rounded,
      // হোম স্ক্রিনে এই ফিচারের জন্য যে ছবিটা ব্যবহার হয়েছে, হেডারের
      // লোগো বক্সেও এখন সেই একই ছবি দেখাবে।
      iconAsset: 'assets/homeicon/LengthUnitConverter.webp',
      // 📖 হেডারের ডান কোনায় গাইড আইকন — চাপলে বটম-শিটে সংজ্ঞা, ফরমুলা ও
      // ম্যানুয়ালি হিসাব করার নিয়ম দেখানো হয় (4 Point Inspection এর
      // FormulaGuideButton এর মতোই একই প্যাটার্ন)।
      extraHeaderAction: FormulaGuideButton(
        title: 'Meter / Yard / Feet Converter',
        sections: [
          FormulaGuideSection(
            heading: 'সংজ্ঞা (Definition)',
            body: 'Meter, Yard ও Feet — তিনটিই দৈর্ঘ্য মাপার একক। '
                'টেক্সটাইলে ফেব্রিক লেংথ, রোল লেংথ, বা কাটিং লেংথ '
                'হিসাব করার সময় বিভিন্ন বায়ার বা মেশিন বিভিন্ন এককে '
                'মাপ চায় — তাই দ্রুত কনভার্ট করার প্রয়োজন হয়।\n\n'
                'যেকোনো একটি বক্সে সংখ্যা লিখলেই বাকি দুইটা এককে সাথে '
                'সাথে হিসাব হয়ে বসে যাবে।',
          ),
          FormulaGuideSection(
            heading: 'কনভার্শন ফরমুলা (Formula)',
            body: 'Yard = Meter × 1.0936133\n'
                'Feet = Meter × 3.2808399\n\n'
                'Meter = Yard × 0.9144\n'
                'Feet = Yard × 3\n\n'
                'Meter = Feet × 0.3048\n'
                'Yard = Feet ÷ 3',
          ),
          FormulaGuideSection(
            heading: 'ম্যানুয়ালি কীভাবে বের করবেন?',
            body: '১ মিটার = ১.০৯৩৬ গজ (প্রায় ১.০৯ গজ) — এই সংখ্যাটা '
                'মুখস্থ রাখলে যেকোনো মিটার-মাপ গজে সহজে বের করা যায়।\n\n'
                '১ গজ = ৩ ফুট — এটা একদম সরাসরি হিসাব, কোনো দশমিক লাগে '
                'না। তাই গজ ও ফুটের মধ্যে কনভার্ট করাই সবচেয়ে সহজ।\n\n'
                '১ ফুট = ০.৩০৪৮ মিটার (প্রায় ৩০.৫ সেন্টিমিটার)।',
          ),
          FormulaGuideSection(
            heading: 'উদাহরণ (Example)',
            body: 'ধরুন একটি ফেব্রিক রোলের দৈর্ঘ্য ৫০ মিটার।\n\n'
                'Yard = 50 × 1.0936133 = 54.6807 yard\n'
                'Feet = 50 × 3.2808399 = 164.042 feet\n\n'
                'অ্যাপে শুধু "Meter" বক্সে 50 লিখলেই বাকি দুইটা বক্সে '
                'এই ফলাফল স্বয়ংক্রিয়ভাবে বসে যাবে।',
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
              icon: Icons.straighten_rounded,
              label: 'Meter',
              subLabel: 'Length in Meter',
              value: ctrl.values['meter']!,
              unit: 'm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'meter',
              onTap: () => setState(() => ctrl.setActive('meter')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Yard',
              subLabel: 'Length in Yard',
              value: ctrl.values['yard']!,
              unit: 'yd',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'yard',
              onTap: () => setState(() => ctrl.setActive('yard')),
            ),
            const SizedBox(height: 8.0),
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Feet',
              subLabel: 'Length in Feet',
              value: ctrl.values['feet']!,
              unit: 'ft',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'feet',
              onTap: () => setState(() => ctrl.setActive('feet')),
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
