import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class BodyToRibScreen extends StatefulWidget {
  const BodyToRibScreen({super.key});

  @override
  State<BodyToRibScreen> createState() => _BodyToRibScreenState();
}

class _BodyToRibScreenState extends State<BodyToRibScreen> {
  final ctrl = KeypadFieldController(['refBody', 'refRib', 'newBody']);

  double? _ribPercent;
  double? _requiredRib;
  double? _totalFabric;

  void _recalc() {
    final refBody = ctrl.number('refBody');
    final refRib = ctrl.number('refRib');
    final newBody = ctrl.number('newBody');

    setState(() {
      if (refBody != null && refBody > 0 && refRib != null) {
        final ribPct = (refRib / refBody) * 100;
        _ribPercent = ribPct;
        if (newBody != null) {
          final reqRib = (ribPct / 100) * newBody;
          _requiredRib = reqRib;
          _totalFabric = newBody + reqRib;
        } else {
          _requiredRib = null;
          _totalFabric = null;
        }
      } else {
        _ribPercent = null;
        _requiredRib = null;
        _totalFabric = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'BODY TO RIB\nFABRIC RATIO',
      icon: Icons.compare_arrows_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      content: Padding(
        // আপনার পছন্দমতো প্যাডিং সেট করার জায়গা
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 25.0,
          bottom: 10.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.layers_rounded,
              label: 'Reference Body',
              subLabel: 'Order Body Fabric',
              value: ctrl.values['refBody']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'refBody',
              onTap: () => setState(() => ctrl.setActive('refBody')),
            ),
            const SizedBox(height: 4.0), // কার্ডগুলোর স্পেসিং
            InputCard(
              icon: Icons.texture_rounded,
              label: 'Reference Rib',
              subLabel: 'Order Rib Fabric',
              value: ctrl.values['refRib']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.tealIconGradient,
              accentColor: AppColors.teal,
              active: ctrl.activeId == 'refRib',
              onTap: () => setState(() => ctrl.setActive('refRib')),
            ),
            const SizedBox(height: 4.0),
            InputCard(
              icon: Icons.fitness_center_rounded,
              label: 'New Body Qty',
              subLabel: 'Target Body Qty',
              value: ctrl.values['newBody']!,
              unit: 'kg',
              placeholder: '0.0',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'newBody',
              onTap: () => setState(() => ctrl.setActive('newBody')),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ResultBox(
                    label: 'Rib %',
                    value: _ribPercent != null
                        ? '${_ribPercent!.toStringAsFixed(2)}%'
                        : '0%',
                    borderColor: _ribPercent != null
                        ? AppColors.teal
                        : AppColors.inputBorder,
                    live: _ribPercent != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultBox(
                    label: 'Required Rib',
                    value: '${_requiredRib?.toStringAsFixed(2) ?? '0.00'} kg',
                    borderColor: _requiredRib != null
                        ? AppColors.darkTeal
                        : AppColors.inputBorder,
                    textColor: AppColors.darkTeal,
                    live: _requiredRib != null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ResultBox(
              label: 'Total Fabric (Body + Rib)',
              value: '${_totalFabric?.toStringAsFixed(2) ?? '0.00'} kg',
              borderColor: _totalFabric != null
                  ? AppColors.green
                  : AppColors.inputBorder,
              live: _totalFabric != null,
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
