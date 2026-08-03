import 'package:flutter/material.dart';
import '../data/fabric_type_data.dart';
import '../theme/app_colors.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';

class FabricTypeDetailScreen extends StatefulWidget {
  final FabricTypeItem fabric;
  final bool initialIsEnglish;

  const FabricTypeDetailScreen({
    super.key,
    required this.fabric,
    this.initialIsEnglish = true,
  });

  @override
  State<FabricTypeDetailScreen> createState() => _FabricTypeDetailScreenState();
}

class _FabricTypeDetailScreenState extends State<FabricTypeDetailScreen> {
  late bool _isEnglish;

  @override
  void initState() {
    super.initState();
    _isEnglish = widget.initialIsEnglish;
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fabric;

    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: f.nameEn, // ফেব্রিকের নাম সবসময় ইংরেজি (টেকনিক্যাল নাম)
        isBack: true,
        onLeadingTap: () => Navigator.of(context).pop(),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          // 🖼️ ছবি — থাম্বনেইলের সাথে একই ছবি, সবসময় ১৬:৯
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LibraryThumbnail(
              imagePath: f.image,
              icon: f.icon,
              color: _categoryColor(f.categoryEn),
              borderRadius: 16,
            ),
          ),
          const SizedBox(height: 14),

          // 🏷️ Category
          _InfoCard(
            bgColor: const Color(0xFFF1F8E9),
            icon: Icons.sell_rounded,
            iconColor: AppColors.green,
            titleColor: AppColors.green,
            title: 'Category',
            child: Text(
              _isEnglish ? f.categoryEn : f.categoryBn,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),

          // 📌 Structure & Identification
          _InfoCard(
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.push_pin_rounded,
            iconColor: AppColors.teal,
            titleColor: AppColors.teal,
            title: 'Structure & Identification',
            child: Text(
              _isEnglish ? f.structureEn : f.structureBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          // ⚙️ Technical Specs
          _InfoCard(
            bgColor: const Color(0xFFF3E8FF),
            icon: Icons.settings_rounded,
            iconColor: AppColors.purple,
            titleColor: AppColors.purple,
            title: 'Technical Specs',
            child: Row(
              children: [
                const Text(
                  'GSM Range: ',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  f.gsmRange,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.purple),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 👕 Common Uses
          _InfoCard(
            bgColor: const Color(0xFFFFF3E0),
            icon: Icons.checkroom_rounded,
            iconColor: AppColors.orange,
            titleColor: AppColors.orange,
            title: 'Common Uses',
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final use in f.commonUses)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      use,
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

Color _categoryColor(String categoryEn) {
  switch (categoryEn) {
    case 'Knitted Fabric':
      return AppColors.teal;
    case 'Woven Fabric':
      return AppColors.purple;
    case 'Composite Fabric':
      return AppColors.orange;
    case 'Openwork Fabric':
      return AppColors.pink;
    default:
      return AppColors.green;
  }
}

class _InfoCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration:
                    BoxDecoration(color: iconColor, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
