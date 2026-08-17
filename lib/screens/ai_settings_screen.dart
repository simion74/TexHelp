import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gemini_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_icon.dart';

/// 🤖 AI Settings — সাইড মেনু থেকে ওপেন হয়। এখানে ইউজার নিজের Gemini API
/// Key পেস্ট করে সেভ করবে (একবার সেভ করলেই সবসময়ের জন্য সেভ থাকবে), সাথে
/// ধাপে ধাপে গাইডলাইনও দেওয়া আছে কীভাবে ফ্রি Key জেনারেট করতে হয়।
class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _isActive = false;
  bool _obscure = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await GeminiService.getApiKey();
    if (!mounted) return;
    setState(() {
      _isActive = key != null;
      _keyController.text = key ?? '';
      _loading = false;
    });
  }

  Future<void> _openGoogleAiStudio() async {
    final uri = Uri.parse('https://aistudio.google.com/app/apikey');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('লিংকটি ওপেন করা যাচ্ছে না')),
      );
    }
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক API Key দিন')),
      );
      return;
    }
    await GeminiService.saveApiKey(key);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() => _isActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ API Key সফলভাবে সেভ হয়েছে! AI ফিচারগুলো এখন সক্রিয়।'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearKey() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Key মুছে ফেলবেন?'),
        content: const Text(
            'API Key মুছে ফেললে সব AI ফিচার (Machine Library, Fabric Type,Fabric Fault AI Support, ইত্যাদি) বন্ধ হয়ে যাবে।'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await GeminiService.clearApiKey();
    if (!mounted) return;
    setState(() {
      _isActive = false;
      _keyController.clear();
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F4),
        body: Column(
          children: [
            Container(height: statusBarHeight, color: AppColors.darkGreen),
            _header(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _statusBanner(),
                        const SizedBox(height: 16),
                        _guideCard(),
                        const SizedBox(height: 16),
                        _keyInputCard(),
                        if (_isActive) ...[
                          const SizedBox(height: 12),
                          _clearKeyButton(),
                        ],
                        const SizedBox(height: 16),
                        _offlineNote(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: AppColors.darkGreen,
      padding: const EdgeInsets.fromLTRB(10, 8, 16, 16),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(Icons.arrow_back_rounded,
                    color: AppColors.darkGreen, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const AiIcon(size: 26, borderRadius: BorderRadius.all(Radius.circular(7))),
          const SizedBox(width: 8),
          const Text(
            'AI Settings',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner() {
    final color = _isActive ? Colors.green : Colors.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(_isActive ? Icons.check_circle_rounded : Icons.info_rounded,
              color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isActive
                  ? 'AI ফিচার সক্রিয় (Active)। API Key সেভ করা আছে।'
                  : 'AI ফিচার এখনো সক্রিয় নয়। নিচের ধাপ অনুসরণ করে Key সেট করুন।',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color == Colors.green
                      ? Colors.green.shade800
                      : Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AiIcon(size: 20),
              const SizedBox(width: 8),
              const Text('কীভাবে সেটআপ করবেন',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'TexHelp-এর AI ফিচারগুলো (Machine Library, Fabric Fault, Fabric Type) চালাতে Google-এর Gemini AI ব্যবহার হয়। এটি সম্পূর্ণ ফ্রি — শুধু আপনার নিজের Google অ্যাকাউন্ট দিয়ে একটা API Key তৈরি করে এখানে একবার বসিয়ে দিলেই হবে।',
            style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 14),
          _stepTile('1', 'নিচের বাটনে চাপ দিন — সরাসরি Google AI Studio ওপেন হবে।'),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _openGoogleAiStudio,
              icon: const Icon(Icons.open_in_new_rounded,
                  size: 16, color: Colors.white),
              label: const Text('Get Free API Key (Google AI Studio)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),
          _stepTile('2', 'Google অ্যাকাউন্ট দিয়ে লগইন করে "Create API Key" বাটনে চাপ দিন।'),
          const SizedBox(height: 12),
          _troubleshootBox(),
          const SizedBox(height: 14),
          _stepTile('3', 'জেনারেট হওয়া Key-টি কপি করে নিচের বক্সে পেস্ট করুন এবং Save করুন।'),
        ],
      ),
    );
  }

  Widget _stepTile(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: AppColors.green, shape: BoxShape.circle),
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.4)),
        ),
      ],
    );
  }

  Widget _troubleshootBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '"Create API Key" বাটনে চাপ দিয়ে কিছু হচ্ছে না?',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.red.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'প্রথমবার AI Studio-তে ঢুকলে আপনার কোনো Google Cloud "Project" থাকে না তাই বাটনটি প্রথমে কাজ করবে না। আপনাকে আগে একটা প্রজেক্ট বানাতে হবে। প্রজেক্ট বানানো খুবই সহজ, এভাবে করুন:',
            style: TextStyle(fontSize: 11.5, color: AppColors.green, height: 1.45, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            '• "Create API Key" বাটনের পাশে/নিচে থাকা ড্রপডাউন থেকে "Create API key in new project" অপশনটি বেছে নিন।\n'
            '• সিলেক্ট করলেই Google নিজে থেকে একটি নতুন, ফ্রি প্রজেক্ট বানিয়ে সাথে সাথে আপনার Key জেনারেট করে দেবে — আলাদা করে কিছু সেটআপ করার দরকার নেই।\n'
            '• কোনো Billing/Card যুক্ত করার প্রয়োজন নেই, ফ্রি Tier-এই Key কাজ করে।',
            style: TextStyle(fontSize: 11.5, color: AppColors.green, height: 1.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _keyInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gemini API Key',
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          TextField(
            controller: _keyController,
            obscureText: _obscure,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'AIzaSy...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    size: 19, color: Colors.black45),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _saveKey,
              icon: const Icon(Icons.save_rounded, size: 17, color: Colors.white),
              label: const Text('Save Key',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clearKeyButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.shade200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _clearKey,
        icon: const Icon(Icons.delete_outline_rounded, size: 17),
        label: const Text('Remove Key', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _offlineNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wifi_rounded, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'শুধুমাত্র AI ফিচারগুলো ব্যবহার করতে ইন্টারনেট (মোবাইল ডাটা বা Wi-Fi) প্রয়োজন। অ্যাপের বাকি সব ক্যালকুলেটর সম্পূর্ণ অফলাইনে কাজ করবে।',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade900, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
