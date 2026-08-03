import 'package:flutter/material.dart';
import '../data/department.dart';
import '../data/machine_library_data.dart';
import '../theme/app_colors.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';

class MachineDetailScreen extends StatefulWidget {
  final MachineItem machine;
  final bool initialIsEnglish;

  const MachineDetailScreen({
    super.key,
    required this.machine,
    this.initialIsEnglish = true,
  });

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  late bool _isEnglish;
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _isEnglish = widget.initialIsEnglish;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.machine;
    final dept = findDepartment(m.departmentId);
    final images = m.images.isNotEmpty ? m.images : <String?>[null];

    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: m.nameEn,
        isBack: true,
        onLeadingTap: () => Navigator.of(context).pop(),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          // 🖼️ ছবির ক্যারোসেল — সবসময় ১৬:৯ অনুপাতে
          AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: LibraryThumbnail(
                  imagePath: images[i],
                  icon: m.icon,
                  color: dept?.color ?? AppColors.green,
                  borderRadius: 16,
                ),
              ),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.green : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 14),

          // 🏷️ Machine Name / Department কার্ড
          _WhiteInfoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledValue(
                    icon: Icons.sell_rounded,
                    iconColor: AppColors.green,
                    label: 'Machine Name',
                    labelColor: AppColors.green,
                    value: m.nameEn,
                  ),
                ),
                const SizedBox(
                    height: 46,
                    child: VerticalDivider(width: 24, thickness: 1)),
                Expanded(
                  child: _LabeledValue(
                    icon: Icons.factory_rounded,
                    iconColor: AppColors.purple,
                    label: 'Department',
                    labelColor: AppColors.purple,
                    value: dept?.nameEn ?? '-',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.menu_book_rounded,
            iconColor: AppColors.teal,
            titleColor: AppColors.teal,
            title: 'Introduction',
            child: Text(
              _isEnglish ? m.introEn : m.introBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFF1F8E9),
            icon: Icons.track_changes_rounded,
            iconColor: AppColors.green,
            titleColor: AppColors.green,
            title: 'Main Function',
            child: Text(
              _isEnglish ? m.functionEn : m.functionBn,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFFF3E0),
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.orange,
            titleColor: AppColors.orange,
            title: 'Input → Output',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _InputOutputBox(
                    label: 'Input',
                    value: _isEnglish ? m.inputEn : m.inputBn,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.orange, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: _InputOutputBox(
                    label: 'Output',
                    value: _isEnglish ? m.outputEn : m.outputBn,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFF3E8FF),
            icon: Icons.settings_rounded,
            iconColor: AppColors.purple,
            titleColor: AppColors.purple,
            title: 'Main Parts',
            child: Wrap(
              runSpacing: 6,
              children: [
                for (int i = 0; i < m.mainParts.length; i += 2)
                  Row(
                    children: [
                      Expanded(child: _BulletText(m.mainParts[i])),
                      if (i + 1 < m.mainParts.length)
                        Expanded(child: _BulletText(m.mainParts[i + 1])),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.tune_rounded,
            iconColor: AppColors.teal,
            titleColor: AppColors.teal,
            title: 'Important Operating Parameters',
            child: Wrap(
              runSpacing: 6,
              children: [
                for (int i = 0; i < m.operatingParams.length; i += 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _BulletText(
                          '${_isEnglish ? m.operatingParams[i].labelEn : m.operatingParams[i].labelBn}: ${m.operatingParams[i].value}',
                        ),
                      ),
                      if (i + 1 < m.operatingParams.length)
                        Expanded(
                          child: _BulletText(
                            '${_isEnglish ? m.operatingParams[i + 1].labelEn : m.operatingParams[i + 1].labelBn}: ${m.operatingParams[i + 1].value}',
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _ColorInfoCard(
            bgColor: const Color(0xFFFFF8E1),
            icon: Icons.shield_rounded,
            iconColor: AppColors.orange,
            titleColor: AppColors.orange,
            title: 'Safety Tips',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final tip
                    in (_isEnglish ? m.safetyTipsEn : m.safetyTipsBn))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _BulletText(tip, dotColor: AppColors.orange),
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

class _WhiteInfoCard extends StatelessWidget {
  final Widget child;
  const _WhiteInfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _ColorInfoCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final String title;
  final Widget child;

  const _ColorInfoCard({
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor),
                ),
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

class _LabeledValue extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final String value;

  const _LabeledValue({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: labelColor)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputOutputBox extends StatelessWidget {
  final String label;
  final String value;
  const _InputOutputBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  final Color dotColor;
  const _BulletText(this.text, {this.dotColor = AppColors.purple});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child:
                Text(text, style: const TextStyle(fontSize: 11, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
