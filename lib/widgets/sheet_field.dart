import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 📝 Costing/Cutting/Order Sheet স্ক্রিনগুলোর জন্য কমন ইনপুট ফিল্ড —
/// সাধারণ কীবোর্ড (টেক্সট/সংখ্যা) দিয়ে ফিল-আপ করা যায়, ক্যালকুলেটরের
/// কাস্টম ডিজিট কিপ্যাডের থেকে আলাদা — কারণ এখানে Style No, Buyer Name-এর
/// মতো টেক্সট ফিল্ডও লাগে।
class SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? unit;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const SheetField({
    super.key,
    required this.label,
    required this.controller,
    this.unit,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.black54),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            suffixText: unit,
            suffixStyle:
                const TextStyle(fontSize: 12, color: Colors.black45),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// 📤 তিনটা ফরম্যাটে এক্সপোর্টের জন্য কমন বাটন রো (Excel / PDF / Image)
class ExportButtonRow extends StatelessWidget {
  final VoidCallback onExcel;
  final VoidCallback onPdf;
  final VoidCallback onImage;

  const ExportButtonRow({
    super.key,
    required this.onExcel,
    required this.onPdf,
    required this.onImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ExportButton(
            icon: Icons.grid_on_rounded,
            label: 'Excel',
            color: AppColors.green,
            onTap: onExcel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ExportButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            color: AppColors.gradeCRed,
            onTap: onPdf,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ExportButton(
            icon: Icons.image_rounded,
            label: 'Image',
            color: AppColors.purple,
            onTap: onImage,
          ),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
