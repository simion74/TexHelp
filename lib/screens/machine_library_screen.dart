import 'package:flutter/material.dart';
import '../data/department.dart';
import '../data/machine_library_data.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_result_card.dart';
import '../widgets/ai_search_box.dart';
import '../widgets/department_filter_chips.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/library_thumbnail.dart';
import '../widgets/library_wave_header.dart';
import 'machine_detail_screen.dart';

class MachineLibraryScreen extends StatefulWidget {
  const MachineLibraryScreen({super.key});

  @override
  State<MachineLibraryScreen> createState() => _MachineLibraryScreenState();
}

class _MachineLibraryScreenState extends State<MachineLibraryScreen> {
  bool _isEnglish = true;
  String? _selectedDept; // null = All

  // 🤖 AI Support সার্চের স্টেট — এখানে যা সার্চ করা হবে তা আমাদের বিল্ড-ইন
  // মেশিন লাইব্রেরিতে না থাকলেও Gemini AI থেকে ডিটেইলস নিয়ে আসবে
  bool _aiLoading = false;
  String? _aiError;
  Map<String, dynamic>? _aiMachine;

  // 🔧 গ্রিড কনফিগারেশন — এখানেই কার্ডের সাইজ/সংখ্যা নিয়ন্ত্রণ করুন
  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

  List<MachineItem> get _filtered {
    if (_selectedDept == null) return kMachines;
    return kMachines.where((m) => m.departmentId == _selectedDept).toList();
  }

  Future<void> _searchMachineWithAi(String query) async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _aiMachine = null;
    });

    final prompt = '''
You are an expert Textile & Garments Machinery Engineer. Provide technical
details for the machine: "$query".

Respond ONLY with a JSON object in exactly this structure, no markdown, no extra text:
{
  "machine_name": "Full name of the machine",
  "category": "Category (e.g. Spinning, Knitting, Weaving, Dyeing, Garments, Finishing)",
  "primary_function": "One or two sentences on what this machine is used for",
  "inputs": "Raw materials or inputs given to this machine",
  "outputs": "Final output produced by this machine",
  "safety_and_maintenance": ["Tip 1", "Tip 2", "Tip 3"]
}
If the machine name is unrecognized or unclear, make the best reasonable guess
based on the closest matching real textile/garments machine.
''';

    try {
      final data = await GeminiService.generateJson(prompt);
      setState(() {
        _aiMachine = data;
        _aiLoading = false;
      });
    } on AiException catch (e) {
      setState(() {
        _aiError = e.message;
        _aiLoading = false;
      });
    } catch (_) {
      setState(() {
        _aiError = 'মেশিনটি সম্পর্কে তথ্য পাওয়া যায়নি। আবার চেষ্টা করুন।';
        _aiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return LibraryScaffold(
      header: LibraryWaveHeader(
        title: 'Machine Library',
        subtitle: 'Textile Machine Reference',
        isBack: false,
        onLeadingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        isEnglish: _isEnglish,
        onLanguageChanged: (v) => setState(() => _isEnglish = v),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        children: [
          // 🤖 AI Support সার্চ বক্স — শত শত মেশিনের মধ্যে যেটা আমাদের
          // বিল্ড-ইন লাইব্রেরিতে নেই, সেটাও AI থেকে খুঁজে দেখাবে
          AiSearchBox(
            hintText: 'Ask AI: e.g. Stenter, Autoconer, Overlock...',
            accentColor: Colors.indigo,
            isLoading: _aiLoading,
            onSearch: _searchMachineWithAi,
          ),
          if (_aiLoading || _aiError != null || _aiMachine != null) ...[
            const SizedBox(height: 12),
            if (_aiLoading || _aiError != null)
              AiStatusPanel(
                  isLoading: _aiLoading,
                  errorMessage: _aiError,
                  accentColor: Colors.indigo)
            else if (_aiMachine != null)
              AiInfoCard(
                title:
                    (_aiMachine!['machine_name'] as String?) ?? 'Machine Info',
                tag: _aiMachine!['category'] as String?,
                accentColor: Colors.indigo,
                description: _aiMachine!['primary_function'] as String?,
                sections: [
                  AiInfoSection(
                    heading: 'Input / Output',
                    icon: Icons.compare_arrows_rounded,
                    items: [
                      'Input: ${_aiMachine!['inputs'] ?? '—'}',
                      'Output: ${_aiMachine!['outputs'] ?? '—'}',
                    ],
                  ),
                  AiInfoSection(
                    heading: 'Safety & Maintenance',
                    icon: Icons.shield_rounded,
                    iconColor: Colors.deepOrange,
                    items: ((_aiMachine!['safety_and_maintenance'] as List?)
                            ?.map((e) => e.toString())
                            .toList()) ??
                        const [],
                  ),
                ],
              ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Department Filter',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          DepartmentFilterChips(
            selectedId: _selectedDept,
            onSelected: (id) => setState(() => _selectedDept = id),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDept == null
                    ? 'All'
                    : findDepartment(_selectedDept!)?.nameEn ?? '',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen),
              ),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                  children: [
                    const TextSpan(text: 'Total: '),
                    TextSpan(
                      text: '${filtered.length} Machines',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: AppColors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount,
              crossAxisSpacing: _gridSpacing,
              mainAxisSpacing: _gridSpacing,
              childAspectRatio: _cardAspectRatio,
            ),
            itemBuilder: (context, i) {
              final m = filtered[i];
              final dept = findDepartment(m.departmentId);
              return _MachineCard(
                machine: m,
                deptColor: dept?.color ?? AppColors.green,
                deptIcon: dept?.icon ?? Icons.factory_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MachineDetailScreen(
                        machine: m,
                        initialIsEnglish: _isEnglish,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final MachineItem machine;
  final Color deptColor;
  final IconData deptIcon;
  final VoidCallback onTap;

  const _MachineCard({
    required this.machine,
    required this.deptColor,
    required this.deptIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7),
      elevation: 1.5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🖼️ থাম্বনেইল — সবসময় ১৬:৯ অনুপাতে
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LibraryThumbnail(
                  imagePath:
                      machine.images.isNotEmpty ? machine.images.first : null,
                  icon: machine.icon,
                  color: deptColor,
                  borderRadius: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                machine.nameEn,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                    height: 1.15),
              ),
              const SizedBox(height: 4),
              Container(
                width: 15,
                height: 15,
                decoration:
                    BoxDecoration(color: deptColor, shape: BoxShape.circle),
                child: Icon(deptIcon, color: Colors.white, size: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
