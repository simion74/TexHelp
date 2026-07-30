import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class YarnRequirementScreen extends StatefulWidget {
  const YarnRequirementScreen({super.key});

  @override
  State<YarnRequirementScreen> createState() => _YarnRequirementScreenState();
}

class _YarnRequirementScreenState extends State<YarnRequirementScreen> {
  final ctrl = KeypadFieldController(['fabric', 'wastage']);
  double? _totalYarn;

  void _recalc() {
    final fabric = ctrl.number('fabric') ?? 0;
    final wastage = ctrl.number('wastage') ?? 0;
    setState(() {
      _totalYarn = fabric > 0 ? fabric * (1 + (wastage / 100)) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'YARN\nREQUIREMENT',
      icon: Icons.inventory_2_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      content: Padding(
        // পছন্দমতো পেডিং পরিবর্তন করার জায়গা
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: 60.0,
          bottom: 15.0, // ইচ্ছেমতো বাড়াতে/কমাতে পারবেন
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.checkroom_rounded,
              label: 'Fabric Qty',
              subLabel: 'Total Fabric Required',
              value: ctrl.values['fabric']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'fabric',
              onTap: () => setState(() => ctrl.setActive('fabric')),
            ),
            InputCard(
              icon: Icons.percent_rounded,
              label: 'Wastage %',
              subLabel: 'Total Knitting Wastage',
              value: ctrl.values['wastage']!,
              unit: '%',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'wastage',
              onTap: () => setState(() => ctrl.setActive('wastage')),
            ),
            const SizedBox(height: 10),
            ResultBox(
              label: 'Total Yarn Required (With Wastage)',
              value: '${_totalYarn?.toStringAsFixed(2) ?? '0.00'} kg',
              borderColor:
                  _totalYarn != null ? AppColors.green : AppColors.inputBorder,
              live: _totalYarn != null,
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
