import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner.dart';
import '../widgets/numeric_keypad.dart';

/// একটা এন্ট্রি করা রোল — রোল নম্বর + GSM মান
class GsmRollItem {
  int rollNo;
  double? gsm; // null মানে এখনো এন্ট্রি করা হয়নি (খালি বক্স)
  GsmRollItem({required this.rollNo, this.gsm});
}

/// GSM Scanner — ক্যামেরা/OCR নেই, সম্পূর্ণ ম্যানুয়াল এন্ট্রি সিস্টেম।
///
/// সবার উপরে একটি চিকন সেটিংস কন্টেইনার থাকে যেখানে ফ্যাক্টরির নিজস্ব
/// Record GSM (টার্গেট মান) ও Approved Range% (+/-) সেট করে "Save" করা
/// যায়। এই সেভ করা মান দিয়ে নিচের প্রতিটি রোল-এন্ট্রি অটো যাচাই হয় —
/// রেঞ্জের ভেতরে থাকলে কালো/সবুজ, বাইরে গেলে লাল টেক্সট।
///
/// নিচে প্রতিটি রোলের জন্য একটি করে লম্বা ইনপুট কন্টেইনার (রোল নং সহ),
/// ট্যাপ করলে কাস্টম NumericKeypad খুলে যায়। রেজাল্ট বার-এ Average GSM,
/// Finishing GSM (Min–Max) ও Total Roll — এন্ট্রি দেওয়ার সাথে সাথেই
/// ডায়নামিকভাবে আপডেট হয়।
///
/// 🔧 এখানে নিচের ভ্যারিয়েবলগুলো বদলে সাইজ/স্পেসিং নিয়ন্ত্রণ করুন।
class AverageGsmCalculateScreen extends StatefulWidget {
  const AverageGsmCalculateScreen({super.key});

  @override
  State<AverageGsmCalculateScreen> createState() => _AverageGsmCalculateScreenState();
}

class _AverageGsmCalculateScreenState extends State<AverageGsmCalculateScreen> {
  // 🔧 সাইজ কনফিগারেশন
  static const double _headerIconSize = 17;

  // 👇 হেডার টাইটেল ("GSM ENTRY") কতটা নিচে বসবে — বাড়ালে আরও নিচে নামবে
  static const double _headerTitleTopPadding = 29;

  // 👇 উপরের লম্বা ইনপুট কন্টেইনারগুলোর height ও মাঝের গ্যাপ
  static const double _inputBoxHeight = 46;
  static const double _inputBoxSpacing = 10;

  // 👇 শুরুতে কয়টা খালি ইনপুট বক্স দেখানো হবে (প্রয়োজনে + বাটন দিয়ে
  // আরও যোগ করা যাবে)
  static const int _initialRollCount = 5;

  // 👇 সবার উপরের চিকন সেটিংস কন্টেইনারের height
  static const double _settingsBarHeight = 46;

  final List<GsmRollItem> _allRolls = [];

  // ⚙️ Record GSM + Approved Range% — এই ৩টা কন্ট্রোলার সেটিংস বার-এর
  // জন্য। Save চাপার আগ পর্যন্ত এগুলো শুধু টাইপ করার জন্য থাকে, Save করার
  // পরেই _savedRecordGsm/_savedRangePlus/_savedRangeMinus আপডেট হয়ে
  // যাচাই (validation) শুরু হয়।
  final TextEditingController _recordGsmController = TextEditingController();
  final TextEditingController _rangePlusController =
      TextEditingController(text: '5');
  final TextEditingController _rangeMinusController =
      TextEditingController(text: '5');

  double? _savedRecordGsm;
  double _savedRangePlus = 5;
  double _savedRangeMinus = 5;

  // ✏️ এডিট মোড — null মানে কিপ্যাড হাইড থাকবে
  int? _editingIndex;
  String _editingValue = '';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _initialRollCount; i++) {
      _allRolls.add(GsmRollItem(rollNo: i + 1));
    }
  }

  @override
  void dispose() {
    _recordGsmController.dispose();
    _rangePlusController.dispose();
    _rangeMinusController.dispose();
    super.dispose();
  }

  // 💾 সেটিংস সেভ — Record GSM ও Approved Range% সেভ করে, এবং এটা নিচের
  // "রিসেট/ক্লিয়ার" বাটনের প্রভাব থেকে আলাদা থাকে (রোল লিস্ট ক্লিয়ার করলেও
  // এই সেভ করা রেকর্ড/রেঞ্জ মুছে যায় না)।
  void _saveSettings() {
    final record = double.tryParse(_recordGsmController.text);
    final plus = double.tryParse(_rangePlusController.text) ?? 0;
    final minus = double.tryParse(_rangeMinusController.text) ?? 0;
    setState(() {
      _savedRecordGsm = record;
      _savedRangePlus = plus;
      _savedRangeMinus = minus;
    });
    FocusScope.of(context).unfocus();
    _showSnack(record == null
        ? 'Range saved. Set Record GSM to enable color check.'
        : 'Record GSM $record  (+${plus.toStringAsFixed(0)}% / -${minus.toStringAsFixed(0)}%) saved.');
  }

  void _clearField(TextEditingController controller) {
    setState(() => controller.clear());
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ✅ একটা GSM মান approved রেঞ্জের ভেতরে আছে কিনা
  bool? _isWithinRange(double gsm) {
    if (_savedRecordGsm == null) return null; // এখনো রেকর্ড সেট হয়নি
    final low = _savedRecordGsm! * (1 - _savedRangeMinus / 100);
    final high = _savedRecordGsm! * (1 + _savedRangePlus / 100);
    return gsm >= low && gsm <= high;
  }

  // 📊 লাইভ ক্যালকুলেশন — শুধু পূরণ করা (non-null) মানগুলো নিয়ে হিসাব হবে
  List<double> get _filledValues =>
      _allRolls.where((r) => r.gsm != null).map((r) => r.gsm!).toList();

  double get _averageGsm {
    final values = _filledValues;
    if (values.isEmpty) return 0;
    final sum = values.fold<double>(0, (p, e) => p + e);
    return sum / values.length;
  }

  int get _minGsm {
    final values = _filledValues;
    if (values.isEmpty) return 0;
    return values.map((e) => e.toInt()).reduce((a, b) => a < b ? a : b);
  }

  int get _maxGsm {
    final values = _filledValues;
    if (values.isEmpty) return 0;
    return values.map((e) => e.toInt()).reduce((a, b) => a > b ? a : b);
  }

  // ✏️ ইনপুট বক্সে ট্যাপ করলে — হাইড থাকা কিপ্যাড পপআপ হয়ে উঠে আসে
  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _editingValue = _allRolls[index].gsm == null
          ? ''
          : _allRolls[index].gsm!.toInt().toString();
    });
  }

  void _closeEdit() {
    setState(() {
      _editingIndex = null;
      _editingValue = '';
    });
  }

  void _deleteEditingRoll() {
    if (_editingIndex == null) return;
    setState(() {
      _allRolls.removeAt(_editingIndex!);
      // বাকি রোলগুলোর নম্বর নতুন করে বসানো
      for (var i = 0; i < _allRolls.length; i++) {
        _allRolls[i].rollNo = i + 1;
      }
      _editingIndex = null;
      _editingValue = '';
    });
  }

  void _moveEditField(int direction) {
    if (_editingIndex == null || _allRolls.isEmpty) return;
    setState(() {
      // এডিট শুরুর আগে বর্তমান মান সেভ করে তারপর পরের/আগের বক্সে যাওয়া হয়
      final val = double.tryParse(_editingValue);
      _allRolls[_editingIndex!].gsm = val;
      final next =
          (_editingIndex! + direction + _allRolls.length) % _allRolls.length;
      _editingIndex = next;
      _editingValue = _allRolls[next].gsm == null
          ? ''
          : _allRolls[next].gsm!.toInt().toString();
    });
  }

  void _addRoll() {
    setState(() {
      _allRolls.add(GsmRollItem(rollNo: _allRolls.length + 1));
    });
  }

  // 🔁 শুধু রোল লিস্ট রিসেট হয় — উপরের সেভ করা Record GSM/Range অক্ষত
  // থাকে, যাতে প্রতিবার নতুন ব্যাচ শুরু করলে ফ্যাক্টরির সেট করা রেঞ্জ আবার
  // নতুন করে বসাতে না হয়।
  void _resetAll() {
    setState(() {
      _allRolls
        ..clear()
        ..addAll(List.generate(
            _initialRollCount, (i) => GsmRollItem(rollNo: i + 1)));
      _editingIndex = null;
      _editingValue = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isEditing = _editingIndex != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Column(
          children: [
            // স্ট্যাটাস বার স্ট্রিপ — বাকি ক্যালকুলেটর স্ক্রিনের মতোই
            Container(height: statusBarHeight, color: AppColors.darkGreen),
            Expanded(
              child: Container(
                // 🖼️ ব্যাগ্রাউন্ড ফ্রেম — বাকি সব স্ক্রিনের মতোই একই ফ্রেম
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_frame.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 6),
                      _buildSettingsBar(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildInputList(),
                      ),
                      const SizedBox(height: 8),
                      _buildResultBar(),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: isEditing
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _buildEditKeypad(),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                      const SizedBox(height: 4),
                      const ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        child: AdBannerWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkGreen, size: _headerIconSize),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: _headerTitleTopPadding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          gradient: AppColors.tealIconGradient,
                          borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.document_scanner_rounded,
                          color: Colors.white, size: 15),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AVERAGE GSM CALCULATE',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _resetAll,
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(Icons.refresh_rounded,
                  color: AppColors.darkGreen, size: _headerIconSize),
            ),
          ),
        ),
      ],
    );
  }

  // ⚙️ সবার উপরে চিকন সেটিংস কন্টেইনার — Record GSM + Approved Range%(+/-)
  // + Save বাটন। এখানে সেভ করা মান নিচের রোল ক্লিয়ার/রিসেট করলেও মুছে
  // যায় না, শুধু "Save" চাপলেই বদলায়।
  Widget _buildSettingsBar() {
    return Container(
      height: _settingsBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _settingsLabel('Record GSM'),
          const SizedBox(width: 4),
          _settingsField(_recordGsmController, flex: 3),
          const SizedBox(width: 8),
          _settingsLabel('Range%'),
          const SizedBox(width: 4),
          _settingsField(_rangePlusController,
              flex: 2, prefix: '+', color: AppColors.green),
          const SizedBox(width: 4),
          _settingsField(_rangeMinusController,
              flex: 2, prefix: '-', color: Colors.red),
          const SizedBox(width: 8),
          Material(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _saveSettings,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text('Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen),
    );
  }

  // 🔤 সেটিংস বার-এর ছোট ইনপুট বক্স — পাশে ছোট্ট "X" ক্লিয়ার বাটন সহ
  Widget _settingsField(TextEditingController controller,
      {required int flex, String? prefix, Color? color}) {
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: 32,
        child: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: false),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.darkGreen),
          decoration: InputDecoration(
            isDense: true,
            prefixText: prefix,
            prefixStyle: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return InkWell(
                  onTap: () => _clearField(controller),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: Colors.black38),
                );
              },
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 22, minHeight: 22),
          ),
        ),
      ),
    );
  }

  // 📋 উপরে থেকে নিচে সাজানো লম্বা ইনপুট কন্টেইনার — প্রতিটার পাশে রোল
  // নং, ট্যাপ করলেই সিলেক্ট হয়ে নিচে কিপ্যাড খুলবে। রেকর্ড GSM + রেঞ্জ
  // সেভ করা থাকলে ভ্যালু অটো সবুজ/লাল রঙে ধরা পড়ে।
  Widget _buildInputList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: _allRolls.length + 1, // শেষে "+ Add Roll" বাটন
      itemBuilder: (context, index) {
        if (index == _allRolls.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _addRoll,
              child: Container(
                width: double.infinity,
                height: _inputBoxHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.green.withOpacity(0.6), width: 1.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.green, size: 18),
                    SizedBox(width: 6),
                    Text('Add Roll',
                        style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          );
        }

        final roll = _allRolls[index];
        final selected = _editingIndex == index;
        final hasValue = roll.gsm != null;

        // ✅❌ রেঞ্জ চেক — true হলে সবুজ, false হলে লাল, null হলে
        // (রেকর্ড এখনো সেট হয়নি) ডিফল্ট কালো
        final withinRange = hasValue ? _isWithinRange(roll.gsm!) : null;
        final valueColor = !hasValue
            ? AppColors.darkGreen.withOpacity(0.35)
            : withinRange == null
                ? AppColors.darkGreen
                : withinRange
                    ? AppColors.green
                    : Colors.red;

        return Padding(
          padding: const EdgeInsets.only(bottom: _inputBoxSpacing),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _startEdit(index),
            child: Container(
              width: double.infinity,
              height: _inputBoxHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.green : AppColors.inputBorder,
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text('Roll ${roll.rollNo}',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen)),
                  const Spacer(),
                  Text(
                    hasValue ? '${roll.gsm!.toInt()}' : 'Tap to enter GSM',
                    style: TextStyle(
                      fontSize: hasValue ? 18 : 12.5,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_rounded,
                      color: AppColors.darkGreen.withOpacity(0.4), size: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _resultStat('Average GSM', _averageGsm.toStringAsFixed(1),
              Colors.greenAccent),
          Container(width: 1, height: 32, color: Colors.white24),
          _resultStat(
              'Finish GSM (Min–Max)',
              _filledValues.isEmpty ? '0 – 0' : '$_minGsm – $_maxGsm',
              Colors.amberAccent),
          Container(width: 1, height: 32, color: Colors.white24),
          _resultStat(
              'Total Roll', '${_allRolls.length}', Colors.lightBlueAccent),
        ],
      ),
    );
  }

  Widget _resultStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ⌨️ এডিট কিপ্যাড — লিস্টে ট্যাপ করার আগ পর্যন্ত হাইড থাকে, ট্যাপ করলেই
  // এখানে পপআপ হয়ে ভেসে ওঠে। আমাদের বিল্ট-ইন NumericKeypad ব্যবহার করা হয়েছে।
  Widget _buildEditKeypad() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Edit Roll #${_editingIndex != null ? _allRolls[_editingIndex!].rollNo : ''}',
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _deleteEditingRoll,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 16),
                label: const Text('Delete',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
              TextButton(
                onPressed: _closeEdit,
                child: const Text('Done',
                    style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5)),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Text(
              _editingValue.isEmpty ? '0' : _editingValue,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen),
            ),
          ),
          // 🎹 আপনার ডিজাইন করা কাস্টম কিপ্যাড — সরাসরি লিংক করা
          NumericKeypad(
            height: 190,
            onDigit: (v) => setState(() {
              if (_editingValue.length < 3) _editingValue += v;
              final val = double.tryParse(_editingValue);
              if (val != null && _editingIndex != null) {
                _allRolls[_editingIndex!].gsm = val;
              }
            }),
            onBackspace: () => setState(() {
              if (_editingValue.isNotEmpty) {
                _editingValue =
                    _editingValue.substring(0, _editingValue.length - 1);
              }
              final val = double.tryParse(_editingValue);
              if (val != null && _editingIndex != null) {
                _allRolls[_editingIndex!].gsm = val;
              }
            }),
            onClear: () => setState(() => _editingValue = ''),
            onUp: () => _moveEditField(-1),
            onDown: () => _moveEditField(1),
          ),
        ],
      ),
    );
  }
}
