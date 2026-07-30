import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/result_box.dart';

class GsmByYarnCountScreen extends StatefulWidget {
  const GsmByYarnCountScreen({super.key});

  @override
  State<GsmByYarnCountScreen> createState() => _GsmByYarnCountScreenState();
}

class _GsmByYarnCountScreenState extends State<GsmByYarnCountScreen> {
  final ctrl = KeypadFieldController(['count', 'stitch']);
  double? _gsm;

  // নিটিং-এর স্ট্যান্ডার্ড কনস্ট্যান্ট ফ্যাক্টর (সিঙ্গেল জার্সির জন্য প্রচলিত মান)
  static const double _constantFactor = 4100;

  void _recalc() {
    final ne = ctrl.number('count');
    final sl = ctrl.number('stitch');

    setState(() {
      if (ne != null && ne > 0 && sl != null && sl > 0) {
        _gsm = _constantFactor / (ne * sl);
      } else {
        _gsm = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'GSM (BY\nYARN COUNT)',
      icon: Icons.tag_rounded,
      onReset: () => setState(() {
        ctrl.resetAll();
        _recalc();
      }),
      content: Padding(
        // আপনার পছন্দমতো প্যাডিং সেট করার জায়গা
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: 28.0,
          bottom: 12.0,
        ),
        child: Column(
          children: [
            InputCard(
              icon: Icons.numbers_rounded,
              label: 'Yarn Count',
              subLabel: 'English Count (Ne)',
              value: ctrl.values['count']!,
              unit: 'Ne',
              placeholder: 'e.g. 26',
              iconGradient: AppColors.greenIconGradient,
              accentColor: AppColors.green,
              active: ctrl.activeId == 'count',
              onTap: () => setState(() => ctrl.setActive('count')),
            ),
            const SizedBox(
                height: 6.0), // পছন্দমতো কার্ড স্পেসিং সেট করতে পারবেন
            InputCard(
              icon: Icons.linear_scale_rounded,
              label: 'Stitch Length',
              subLabel: 'Loop Length',
              value: ctrl.values['stitch']!,
              unit: 'mm',
              placeholder: 'e.g. 2.8',
              iconGradient: AppColors.purpleIconGradient,
              accentColor: AppColors.purple,
              active: ctrl.activeId == 'stitch',
              onTap: () => setState(() => ctrl.setActive('stitch')),
            ),
            const SizedBox(height: 14),
            ResultBox(
              label: 'ESTIMATED GSM (Single Jersey)',
              value: _gsm?.toStringAsFixed(2) ?? '0.00',
              borderColor:
                  _gsm != null ? AppColors.purple : AppColors.inputBorder,
              textColor: AppColors.purple,
              live: _gsm != null,
            ),
            const SizedBox(height: 8),
            const Text(
              'কনস্ট্যান্ট ফ্যাক্টর ব্যবহার করা হয়েছে: 4100',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.black45),
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
