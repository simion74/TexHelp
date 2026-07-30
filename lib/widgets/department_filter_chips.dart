import 'package:flutter/material.dart';
import '../data/department.dart';
import '../theme/app_colors.dart';

/// "All" + প্রতিটা ডিপার্টমেন্টের ফিল্টার চিপ, wrap করে একাধিক লাইনে বসে।
/// 🔧 এই চিপের লেবেলগুলো (All, Spinning, Knitting...) ফিক্সড UI লেবেল —
/// এগুলো EN/বাংলা টগলে বদলায় না, সবসময় ইংরেজিতেই থাকে। শুধু মেশিন/ফল্টের
/// আসল নাম-বিবরণ (ডেটা) টগলে বদলাবে।
class DepartmentFilterChips extends StatelessWidget {
  final String? selectedId; // null মানে "All" সিলেক্টেড
  final ValueChanged<String?> onSelected;
  final List<String>? onlyDepartmentIds; // দিলে শুধু ওই ডিপার্টমেন্টগুলোই দেখাবে

  const DepartmentFilterChips({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.onlyDepartmentIds,
  });

  @override
  Widget build(BuildContext context) {
    final departments = onlyDepartmentIds == null
        ? kDepartments
        : kDepartments.where((d) => onlyDepartmentIds!.contains(d.id)).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _Chip(
          label: 'All',
          icon: Icons.grid_view_rounded,
          color: AppColors.green,
          selected: selectedId == null,
          onTap: () => onSelected(null),
        ),
        for (final d in departments)
          _Chip(
            label: d.nameEn,
            icon: d.icon,
            color: d.color,
            selected: selectedId == d.id,
            onTap: () => onSelected(d.id),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: selected ? 1.5 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: selected ? Colors.white : color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.darkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
