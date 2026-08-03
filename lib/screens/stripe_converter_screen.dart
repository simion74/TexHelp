import 'package:flutter/material.dart';
import '../models/keypad_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/numeric_keypad.dart';

class StripeConverterScreen extends StatefulWidget {
  const StripeConverterScreen({super.key});

  @override
  State<StripeConverterScreen> createState() => _StripeConverterScreenState();
}

class _StripeConverterScreenState extends State<StripeConverterScreen> {
  final ctrl = KeypadFieldController(['mm', 'cm', 'inch', 'feeder']);
  final TextEditingController cpiController = TextEditingController(text: '50');

  static const _cpiGuide = [
    ['Light Jersey (120-140)', '30s/34s Combed', 54],
    ['Medium Jersey (160-180)', '30s/26s Combed', 50],
    ['Heavy Jersey (200-220)', '24s/20s Carded', 44],
    ['Pique / Lacoste (200-230)', '26s/24s Combed', 42],
    ['Rib / Interlock (220+)', '30s/40s', 46],
  ];

  double get _cpi {
    final v = double.tryParse(cpiController.text);
    return (v == null || v <= 0) ? 50 : v;
  }

  void _recalc() {
    final val = ctrl.number(ctrl.activeId);
    if (val == null || val <= 0) {
      for (final id in ctrl.ids) {
        if (id != ctrl.activeId) ctrl.setValue(id, '');
      }
      setState(() {});
      return;
    }

    double mm, cm, inch, feeder;
    switch (ctrl.activeId) {
      case 'mm':
        mm = val;
        cm = mm / 10;
        inch = cm / 2.54;
        feeder = inch * _cpi;
        break;
      case 'cm':
        cm = val;
        mm = cm * 10;
        inch = cm / 2.54;
        feeder = inch * _cpi;
        break;
      case 'inch':
        inch = val;
        cm = inch * 2.54;
        mm = cm * 10;
        feeder = inch * _cpi;
        break;
      case 'feeder':
      default:
        feeder = val;
        inch = feeder / _cpi;
        cm = inch * 2.54;
        mm = cm * 10;
        break;
    }

    setState(() {
      if (ctrl.activeId != 'mm') ctrl.setValue('mm', mm.toStringAsFixed(2));
      if (ctrl.activeId != 'cm') ctrl.setValue('cm', cm.toStringAsFixed(2));
      if (ctrl.activeId != 'inch') ctrl.setValue('inch', inch.toStringAsFixed(2));
      if (ctrl.activeId != 'feeder') ctrl.setValue('feeder', feeder.round().toString());
    });
  }

  void _openGuide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('GSM & CPI Guide',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Text(
                'বায়ারের দেওয়া ফেব্রিক টাইপ ও GSM অনুযায়ী তালিকা থেকে CPI বেছে নিন। '
                'সারিতে ট্যাপ করলে স্বয়ংক্রিয়ভাবে সেট হয়ে যাবে।',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              ..._cpiGuide.map((row) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(row[0] as String,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(row[1] as String, style: const TextStyle(fontSize: 11)),
                      trailing: Chip(
                        label: Text('${row[2]}',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                        backgroundColor: AppColors.green,
                      ),
                      onTap: () {
                        cpiController.text = '${row[2]}';
                        _recalc();
                        Navigator.pop(ctx);
                      },
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'STRIPE SIZE\nCONVERTER',
      icon: Icons.straighten_rounded,
      iconAsset: 'assets/homeicon/Stripe_Size converter.webp',
      extraHeaderAction: IconButton(
        onPressed: _openGuide,
        icon: const Icon(Icons.more_vert_rounded, color: AppColors.darkGreen),
        tooltip: 'GSM CPI Guide',
      ),
      onReset: () => setState(() {
        ctrl.resetAll();
        cpiController.text = '50';
      }),
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fabric CPI',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.darkGreen)),
                      Text('Courses Per Inch (Required for F)',
                          style: TextStyle(fontSize: 10, color: Colors.black54)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: cpiController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (_) => _recalc(),
                  ),
                ),
              ],
            ),
          ),
          InputCard(
            icon: Icons.straighten_rounded,
            label: 'Millimeter',
            subLabel: 'Very Micro Stripe',
            value: ctrl.values['mm']!,
            unit: 'mm',
            iconGradient: AppColors.greenIconGradient,
            accentColor: AppColors.green,
            active: ctrl.activeId == 'mm',
            dense: true,
            onTap: () => setState(() => ctrl.setActive('mm')),
          ),
          InputCard(
            icon: Icons.horizontal_rule_rounded,
            label: 'Centimeter',
            subLabel: 'Standard Stripe Size',
            value: ctrl.values['cm']!,
            unit: 'cm',
            iconGradient: AppColors.tealIconGradient,
            accentColor: AppColors.teal,
            active: ctrl.activeId == 'cm',
            dense: true,
            onTap: () => setState(() => ctrl.setActive('cm')),
          ),
          InputCard(
            icon: Icons.square_foot_rounded,
            label: 'Inch',
            subLabel: 'US Buyer Standard',
            value: ctrl.values['inch']!,
            unit: 'inch',
            iconGradient: AppColors.purpleIconGradient,
            accentColor: AppColors.purple,
            active: ctrl.activeId == 'inch',
            dense: true,
            onTap: () => setState(() => ctrl.setActive('inch')),
          ),
          InputCard(
            icon: Icons.settings_rounded,
            label: 'Feeder',
            subLabel: 'Knitting Machine Feeders',
            value: ctrl.values['feeder']!,
            unit: 'F',
            iconGradient: AppColors.darkTealIconGradient,
            accentColor: AppColors.darkTeal,
            active: ctrl.activeId == 'feeder',
            dense: true,
            onTap: () => setState(() => ctrl.setActive('feeder')),
          ),
        ],
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
