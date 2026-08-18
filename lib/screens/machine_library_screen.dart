import 'package:flutter/material.dart';
import '../data/department.dart';
import '../data/machine_library_data.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_icon.dart';
import '../widgets/ai_result_card.dart';
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
  String _query = '';

  // 🤖 AI Support সার্চের স্টেট — এখানে যা সার্চ করা হবে তা আমাদের বিল্ড-ইন
  // মেশিন লাইব্রেরিতে না থাকলেও Gemini AI থেকে ডিটেইলস নিয়ে আসবে
  bool _aiLoading = false;
  String? _aiError;
  Map<String, dynamic>? _aiMachine;

  // 🔧 গ্রিড কনফিগারেশন — এখানেই কার্ডের সাইজ/সংখ্যা নিয়ন্ত্রণ করুন
  static const int _crossAxisCount = 4;
  static const double _gridSpacing = 10;
  static const double _cardAspectRatio = 0.86;

  // 🔎 টাইপ করার সাথে সাথেই বিল্ড-ইন তালিকা ফিল্টার হবে (অফলাইনেও কাজ করে)
  // ⚠️ Department filter সরিয়ে দেওয়া হয়েছে — এখন শুধু সার্চ কোয়েরি দিয়েই
  // ফিল্টার হয়, সব মেশিন একসাথে একটাই লিস্টে দেখানো হয়।
  List<MachineItem> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) return kMachines;
    return kMachines.where((m) {
      return m.nameEn.toLowerCase().contains(q) || m.nameBn.contains(_query);
    }).toList();
  }

  Future<void> _searchMachineWithAi(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _aiLoading = true;
      _aiError = null;
      _aiMachine = null;
    });

    final languageInstruction = _isEnglish
        ? 'Respond entirely in simple, clear English.'
        : 'মূল বাক্য গঠন স্বাভাবিক, সহজ বাংলায় লিখুন। তবে টেক্সটাইল/গার্মেন্টস '
            'ইন্ডাস্ট্রির প্রচলিত টেকনিক্যাল শব্দ (মেশিনের নাম, প্রযুক্তিগত '
            'টার্ম) ইংরেজিতেই রাখুন — জোর করে এগুলোর বাংলা অনুবাদ করবেন না, '
            'কারণ ইন্ডাস্ট্রিতে এই শব্দগুলো ইংরেজিতেই ব্যবহৃত হয়।';

    final prompt = '''
You are an expert Textile & Garments Machinery Engineer. Provide technical
details for the machine: "$query".

$languageInstruction

Respond ONLY with a JSON object in exactly this structure, no markdown, no extra text:
{
  "machine_name": "Full name of the machine",
  "category": "Category (e.g. Spinning, Knitting, Weaving, Dyeing, Garments, Finishing)",
  "primary_function": "One or two sentences on what this machine is used for",
  "inputs": "Raw materials or inputs given to this machine",
  "outputs": "Final output produced by this machine",
  "safety_and_maintenance": ["Tip 1", "Tip 2", "Tip 3"]
}
All text values inside the JSON (machine_name, category, primary_function,
inputs, outputs, safety_and_maintenance) must follow the language instruction above.
If the machine name is unrecognized or unclear, make the best reasonable guess
based on the closest matching real textile/garments machine.
''';

    try {
      final data = await GeminiService.generateJson(prompt);
      // 🛡️ ইউজার রেসপন্স আসার আগেই স্ক্রিন থেকে বেরিয়ে গেলে (widget dispose
      // হয়ে গেলে) setState() কল করলে ক্র্যাশ হয় — তাই আগে mounted চেক।
      if (!mounted) return;
      setState(() {
        _aiMachine = data;
        _aiLoading = false;
      });
    } on AiException catch (e) {
      if (!mounted) return;
      setState(() {
        _aiError = e.message;
        _aiLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
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
          // 🔎 বাম পাশে "AI Support" লেবেল + ডান পাশে সার্চ বক্স। এখানে টাইপ
          // করলে নিচের বিল্ড-ইন গ্রিড সাথে সাথে ফিল্টার হয় (অফলাইনেও কাজ
          // করে), আর Enter/AI আইকনে চাপলে Gemini AI থেকেও ডিটেইলস আনা হয়।
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.withOpacity(0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AiIcon(size: 16),
                    const SizedBox(height: 2),
                    const Text(
                      'AI Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          color: Colors.indigo),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: _searchMachineWithAi,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Ask AI: e.g. Stenter, Autoconer, Overlock...',
                      hintStyle: const TextStyle(
                          fontSize: 11, color: Colors.black38),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.black45, size: 18),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 0,
                      ),
                      suffixIcon: _aiLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.indigo),
                              ),
                            )
                          : IconButton(
                              tooltip: 'Ask AI',
                              icon: const AiIcon(size: 18),
                              onPressed: () => _searchMachineWithAi(_query),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                    ),
                  ),
                ),
              ),
            ],
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
                    heading: _isEnglish ? 'Input / Output' : 'ইনপুট / আউটপুট',
                    icon: Icons.compare_arrows_rounded,
                    items: [
                      '${_isEnglish ? 'Input' : 'ইনপুট'}: ${_aiMachine!['inputs'] ?? '—'}',
                      '${_isEnglish ? 'Output' : 'আউটপুট'}: ${_aiMachine!['outputs'] ?? '—'}',
                    ],
                  ),
                  AiInfoSection(
                    heading: _isEnglish
                        ? 'Safety & Maintenance'
                        : 'সেফটি ও রক্ষণাবেক্ষণ',
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

          // 📋 এখন সরাসরি সার্চ বক্সের নিচেই সম্পূর্ণ মেশিন লিস্ট — কোনো
          // department filter chip নেই, কারণ মেশিন সংখ্যা কম এবং AI Support
          // দিয়ে যেকোনো মেশিন খোঁজা সম্ভব।
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Machines',
                style: TextStyle(
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
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  _isEnglish
                      ? 'No machine found. Try Ask AI above.'
                      : 'কোনো মেশিন পাওয়া যায়নি। উপরে Ask AI ব্যবহার করুন।',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ),
            )
          else
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
              // 🖼️ থাম্বনেইল — machine.images এর প্রথম ছবিটাই এখানে দেখানো
              // হয়, ডিটেইলস স্ক্রিনেও একই images লিস্ট ব্যবহার হয় বলে
              // প্রথম ছবিটা দুই স্ক্রিনেই এক থাকে।
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
