import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class GsmWithoutCutterScreen extends StatefulWidget {
  const GsmWithoutCutterScreen({super.key});

  @override
  State<GsmWithoutCutterScreen> createState() => _GsmWithoutCutterScreenState();
}

class _GsmWithoutCutterScreenState extends State<GsmWithoutCutterScreen> {
  final ctrl = KeypadFieldController(['length', 'width', 'reading']);
  double? _actualGsm;

  void _recalc() {
    final l = ctrl.number('length');
    final w = ctrl.number('width');
    final r = ctrl.number('reading');

    setState(() {
      if (l != null && l > 0 && w != null && w > 0 && r != null && r > 0) {
        _actualGsm = (r * 100) / (l * w);
      } else {
        _actualGsm = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'GSM (WITHOUT\nGSM CUTTER)',
      icon: Icons.crop_free_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      content: Padding(
        // ইচ্ছেমতো প্যাডিং সেট করার জায়গা
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 30.0,
          bottom: 10.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.straighten_rounded,
              label: 'Fabric Length',
              subLabel: 'Sample Length',
              value: ctrl.values['length']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'length',
              onTap: () => setState(() => ctrl.setActive('length')),
            ),
            const SizedBox(height: 4.0), // কার্ডগুলোর স্পেসিং
            InputCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Fabric Width',
              subLabel: 'Sample Width',
              value: ctrl.values['width']!,
              unit: 'cm',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'width',
              onTap: () => setState(() => ctrl.setActive('width')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.monitor_weight_rounded,
              label: 'Machine GSM Reading',
              subLabel: 'GSM Balance Scale Reading',
              value: ctrl.values['reading']!,
              unit: 'gsm',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'reading',
              onTap: () => setState(() => ctrl.setActive('reading')),
            ),
            const SizedBox(height: 12),
            ResultBox(
              label: 'ACTUAL GSM',
              value: _actualGsm?.toStringAsFixed(2) ?? '0.00',
              borderColor:
                  _actualGsm != null ? AppColors.green : AppColors.inputBorder,
              live: _actualGsm != null,
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
