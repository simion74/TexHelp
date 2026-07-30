import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
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
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalculate();
      }),
      // ১. ইচ্ছা মতো প্যাডিং কমানো বা বাড়ানোর জন্য পুরো content-কে Padding দিয়ে র‍্যাপ করা হয়েছে:
      content: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 28.0,
          bottom:
              16.0, // <-- এই মান পরিবর্তন করে কি-প্যাডের সাথে গ্যাপ কমানো/বাড়ানো যাবে
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

            // ২. ইনপুট কার্ডগুলোর মধ্যবর্তী ফাঁকা জায়গা নিয়ন্ত্রণ করতে SizedBox ব্যবহার করুন:
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
