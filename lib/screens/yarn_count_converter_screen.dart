import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';

class YarnCountConverterScreen extends StatefulWidget {
  const YarnCountConverterScreen({super.key});

  @override
  State<YarnCountConverterScreen> createState() =>
      _YarnCountConverterScreenState();
}

class _YarnCountConverterScreenState extends State<YarnCountConverterScreen> {
  final ctrl = KeypadFieldController(['ne', 'denier', 'tex', 'nm']);

  void _recalc() {
    final val = ctrl.number(ctrl.activeId);
    if (val == null || val <= 0) {
      for (final id in ctrl.ids) {
        if (id != ctrl.activeId) ctrl.setValue(id, '');
      }
      setState(() {});
      return;
    }

    double ne, den, tex, nm;
    switch (ctrl.activeId) {
      case 'ne':
        ne = val;
        den = 5314.87 / ne;
        tex = 590.541 / ne;
        nm = ne * 1.6934;
        break;
      case 'denier':
        den = val;
        ne = 5314.87 / den;
        tex = den / 9;
        nm = 9000 / den;
        break;
      case 'tex':
        tex = val;
        ne = 590.541 / tex;
        den = tex * 9;
        nm = 1000 / tex;
        break;
      case 'nm':
      default:
        nm = val;
        ne = nm / 1.6934;
        den = 9000 / nm;
        tex = 1000 / nm;
        break;
    }

    setState(() {
      if (ctrl.activeId != 'ne') ctrl.setValue('ne', ne.toStringAsFixed(2));
      if (ctrl.activeId != 'denier')
        ctrl.setValue('denier', den.toStringAsFixed(2));
      if (ctrl.activeId != 'tex') ctrl.setValue('tex', tex.toStringAsFixed(2));
      if (ctrl.activeId != 'nm') ctrl.setValue('nm', nm.toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'YARN COUNT\nCONVERTER',
      icon: Icons.texture_rounded,
      onReset: () => setState(() => ctrl.resetAll()),
      content: Padding(
        // আপনার সুবিধামত প্যাডিং পরিবর্তনের সুযোগ রাখা হয়েছে
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: 26.0,
          bottom: 12.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.tag_rounded,
              label: 'English Count',
              subLabel: 'Indirect System',
              value: ctrl.values['ne']!,
              unit: 'Ne',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'ne',
              onTap: () => setState(() => ctrl.setActive('ne')),
            ),
            const SizedBox(
                height: 4.0), // কার্ডগুলোর মাঝের দূরত্ব অ্যাডজাস্ট করার জন্য
            InputCard(
              icon: Icons.blur_circular_rounded,
              label: 'Denier',
              subLabel: 'Direct System (Synthetics)',
              value: ctrl.values['denier']!,
              unit: 'D',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'denier',
              onTap: () => setState(() => ctrl.setActive('denier')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.monitor_weight_rounded,
              label: 'Tex',
              subLabel: 'Direct System (Universal)',
              value: ctrl.values['tex']!,
              unit: 'Tex',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'tex',
              onTap: () => setState(() => ctrl.setActive('tex')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Metric Count',
              subLabel: 'Indirect System',
              value: ctrl.values['nm']!,
              unit: 'Nm',
              iconGradient: AppColors.darkTealIconGradient,
              accentColor: AppColors.darkTeal,
              active: ctrl.activeId == 'nm',
              onTap: () => setState(() => ctrl.setActive('nm')),
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
