import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../theme/app_colors.dart';
import '../widgets/ad_banner.dart';
import '../widgets/numeric_keypad.dart';

/// একটা স্ক্যান করা রোল — রোল নম্বর + GSM মান
class GsmRollItem {
  int rollNo;
  double gsm;
  GsmRollItem({required this.rollNo, required this.gsm});
}

/// GSM Scanner — ইন-অ্যাপ (বিল্ট-ইন) ক্যামেরা দিয়ে ফেব্রিক ট্যাগের GSM
/// সংখ্যা স্ক্যান করে। ফোনের নিজস্ব ক্যামেরা অ্যাপ কখনো খোলে না — এই
/// স্ক্রিনের ভেতরেই CameraPreview লাইভ দেখা যায় এবং সরাসরি এখান থেকেই
/// ছবি তুলে OCR (টেক্সট রিকগনিশন) চালানো হয়।
///
/// 🔧 এখানে নিচের ভ্যারিয়েবলগুলো বদলে সাইজ/স্পেসিং নিয়ন্ত্রণ করুন।
class GsmScannerScreen extends StatefulWidget {
  const GsmScannerScreen({super.key});

  @override
  State<GsmScannerScreen> createState() => _GsmScannerScreenState();
}

class _GsmScannerScreenState extends State<GsmScannerScreen>
    with WidgetsBindingObserver {
  // 🔧 সাইজ কনফিগারেশন
  static const double _headerIconSize = 17;
  static const double _cameraFlex = 7;
  static const double _listFlex = 3;

  // 👇 হেডার টাইটেল ("GSM SCANNER") কতটা নিচে বসবে — বাড়ালে আরও নিচে নামবে
  static const double _headerTitleTopPadding = 29;

  // 👇 ক্যামেরা প্রিভিউ + পাশের GSM লিস্ট — এই দুই কন্টেইনার জুড়ে কতটা
  // উপরে-নিচে ফাঁকা জায়গা রাখা হবে। বাড়ালে দুটো কন্টেইনারই ছোট হয়ে
  // যাবে (উচ্চতা কমবে), কমালে বড় হবে।
  static const double _cameraListVerticalInset = 0;

  CameraController? _cameraController;
  Future<void>? _initFuture;
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  bool _isProcessing = false;
  String? _cameraError;
  final List<GsmRollItem> _allRolls = [];

  // ✏️ এডিট মোড — null মানে কিপ্যাড হাইড থাকবে
  int? _editingIndex;
  String _editingValue = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = 'No camera found on this device.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) return;
      setState(() => _cameraController = controller);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cameraError = 'Camera could not start: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      setState(() => _cameraController = null);
    } else if (state == AppLifecycleState.resumed) {
      _initFuture = _initCamera();
      setState(() {});
    }
  }

  // 🔍 ৩ ডিজিটের GSM সংখ্যা স্ক্যান লজিক — পাশের ২ ডিজিটের width নম্বর
  // স্বয়ংক্রিয়ভাবেই বাদ পড়ে যায়, কারণ length==3 filter করা হচ্ছে।
  Future<void> _scanCurrentFrame() async {
    final controller = _cameraController;
    if (_isProcessing ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }
    setState(() => _isProcessing = true);

    try {
      final XFile imageFile = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final List<double> newGsmValues = [];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final cleanText = line.text.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleanText.length == 3) {
            final val = double.tryParse(cleanText);
            if (val != null && val >= 100 && val <= 500) {
              newGsmValues.add(val);
            }
          }
        }
      }

      if (newGsmValues.isNotEmpty) {
        setState(() {
          for (final gsm in newGsmValues) {
            _allRolls.add(GsmRollItem(rollNo: _allRolls.length + 1, gsm: gsm));
          }
        });
      } else {
        _showSnack('কোনো ৩-সংখ্যার GSM পাওয়া যায়নি, আবার চেষ্টা করুন।');
      }
    } catch (e) {
      _showSnack('স্ক্যান ব্যর্থ হয়েছে: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // 📊 লাইভ ক্যালকুলেশন
  double get _averageGsm {
    if (_allRolls.isEmpty) return 0;
    final sum = _allRolls.fold<double>(0, (p, e) => p + e.gsm);
    return sum / _allRolls.length;
  }

  int get _minGsm => _allRolls.isEmpty
      ? 0
      : _allRolls.map((e) => e.gsm.toInt()).reduce((a, b) => a < b ? a : b);

  int get _maxGsm => _allRolls.isEmpty
      ? 0
      : _allRolls.map((e) => e.gsm.toInt()).reduce((a, b) => a > b ? a : b);

  // ✏️ তালিকায় ট্যাপ করলে — হাইড থাকা কিপ্যাড পপআপ হয়ে উঠে আসে
  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _editingValue = _allRolls[index].gsm.toInt().toString();
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
      // এডিট শুরুর আগে বর্তমান মান সেভ করে তারপর পরের/আগের রোলে যাওয়া হয়
      final val = double.tryParse(_editingValue);
      if (val != null) _allRolls[_editingIndex!].gsm = val;
      final next =
          (_editingIndex! + direction + _allRolls.length) % _allRolls.length;
      _editingIndex = next;
      _editingValue = _allRolls[next].gsm.toInt().toString();
    });
  }

  void _resetAll() {
    setState(() {
      _allRolls.clear();
      _editingIndex = null;
      _editingValue = '';
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
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
                      const SizedBox(height: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: _cameraListVerticalInset),
                          child: Row(
                            children: [
                              Expanded(
                                flex: _cameraFlex.toInt(),
                                child: _buildCameraPane(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: _listFlex.toInt(),
                                child: _buildRollsList(),
                              ),
                            ],
                          ),
                        ),
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
                      'GSM SCANNER',
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

  Widget _buildCameraPane() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.hardEdge,
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (_cameraError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _cameraError!,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final controller = _cameraController;
          if (controller == null || !controller.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize?.height ?? 100,
                  height: controller.value.previewSize?.width ?? 100,
                  child: CameraPreview(controller),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: _isProcessing ? null : _scanCurrentFrame,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.camera_alt_rounded, size: 16),
                    label: Text(
                      _isProcessing ? 'Scanning...' : 'Scan Page',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRollsList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14342B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.darkGreen,
            child: Text(
              'Rolls: ${_allRolls.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11),
            ),
          ),
          Expanded(
            child: _allRolls.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        'No GSM\nscanned yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 10.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _allRolls.length,
                    itemBuilder: (context, index) {
                      final roll = _allRolls[index];
                      final selected = _editingIndex == index;
                      return InkWell(
                        onTap: () => _startEdit(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 9),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withOpacity(0.08)
                                : Colors.transparent,
                            border: const Border(
                              bottom: BorderSide(color: Colors.white12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('#${roll.rollNo}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 10.5)),
                              Text(
                                '${roll.gsm.toInt()}',
                                style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13),
                              ),
                              const Icon(Icons.edit_rounded,
                                  color: Colors.white38, size: 11),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
              _allRolls.isEmpty ? '0 – 0' : '$_minGsm – $_maxGsm',
              Colors.amberAccent),
        ],
      ),
    );
  }

  Widget _resultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 19, fontWeight: FontWeight.w800)),
      ],
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
