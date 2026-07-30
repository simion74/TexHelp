import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// টেক্সটাইলের ডিপার্টমেন্ট — Machine Library ও Fabric Fault দুটো ফিচারেই
/// এই একই লিস্ট ফিল্টার হিসেবে ব্যবহৃত হয়।
class Department {
  final String id;
  final String nameEn;
  final String nameBn;
  final IconData icon;
  final Color color;

  const Department({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.icon,
    required this.color,
  });
}

/// 🔧 নতুন ডিপার্টমেন্ট যোগ করতে চাইলে এখানে একটা এন্ট্রি বাড়িয়ে দিন।
const List<Department> kDepartments = [
  Department(
    id: 'spinning',
    nameEn: 'Spinning',
    nameBn: 'স্পিনিং',
    icon: Icons.circle_outlined,
    color: AppColors.teal,
  ),
  Department(
    id: 'knitting',
    nameEn: 'Knitting',
    nameBn: 'নিটিং',
    icon: Icons.blur_on_rounded,
    color: AppColors.purple,
  ),
  Department(
    id: 'dyeing',
    nameEn: 'Dyeing',
    nameBn: 'ডাইং',
    icon: Icons.format_color_fill_rounded,
    color: AppColors.orange,
  ),
  Department(
    id: 'finishing',
    nameEn: 'Finishing',
    nameBn: 'ফিনিশিং',
    icon: Icons.brush_rounded,
    color: AppColors.darkTealLight,
  ),
  Department(
    id: 'garments',
    nameEn: 'Garments',
    nameBn: 'গার্মেন্টস',
    icon: Icons.checkroom_rounded,
    color: AppColors.pink,
  ),
  Department(
    id: 'printing',
    nameEn: 'Printing',
    nameBn: 'প্রিন্টিং',
    icon: Icons.print_rounded,
    color: Color(0xFF2979FF),
  ),
  Department(
    id: 'testing',
    nameEn: 'Testing',
    nameBn: 'টেস্টিং',
    icon: Icons.science_rounded,
    color: Color(0xFF5C6BC0),
  ),
];

Department? findDepartment(String id) {
  for (final d in kDepartments) {
    if (d.id == id) return d;
  }
  return null;
}
