import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../widgets/sheet_field.dart';

/// ✂️ Cutting / Marker Sheet — Marker-এর তথ্য ফিল-আপ করে Marker
/// Efficiency % এবং প্রতি পিস ফেব্রিক কনজাম্পশন হিসাব করে সরাসরি
/// Excel/PDF/Image এক্সপোর্ট করা যায়।
class CuttingSheetScreen extends StatefulWidget {
  const CuttingSheetScreen({super.key});

  @override
  State<CuttingSheetScreen> createState() => _CuttingSheetScreenState();
}

class _CuttingSheetScreenState extends State<CuttingSheetScreen> {
  final _styleNo = TextEditingController();
  final _markerNo = TextEditingController();
  final _fabricType = TextEditingController();
  final _markerLength = TextEditingController();
  final _markerWidth = TextEditingController();
  final _gsm = TextEditingController();
  final _garmentsInMarker = TextEditingController();
  final _patternArea = TextEditingController();

  final GlobalKey _summaryKey = GlobalKey();

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  double get _markerArea => _d(_markerLength) * _d(_markerWidth);
  double get _totalWeightG => _markerArea * _d(_gsm);
  double get _consumptionPerPcG =>
      _d(_garmentsInMarker) > 0 ? _totalWeightG / _d(_garmentsInMarker) : 0;
  double get _consumptionPerPcKg => _consumptionPerPcG / 1000;
  double get _markerEfficiency =>
      _markerArea > 0 && _d(_patternArea) > 0
          ? (_d(_patternArea) / _markerArea) * 100
          : 0;

  @override
  void dispose() {
    _styleNo.dispose();
    _markerNo.dispose();
    _fabricType.dispose();
    _markerLength.dispose();
    _markerWidth.dispose();
    _gsm.dispose();
    _garmentsInMarker.dispose();
    _patternArea.dispose();
    super.dispose();
  }

  List<String> get _headers => ['Item', 'Value'];

  List<List<String>> get _rows => [
        ['Style No', _styleNo.text],
        ['Marker No', _markerNo.text],
        ['Fabric Type', _fabricType.text],
        ['Marker Length (m)', _markerLength.text],
        ['Marker Width (m)', _markerWidth.text],
        ['Fabric GSM', _gsm.text],
        ['Garments in Marker', _garmentsInMarker.text],
        ['Marker Area (m²)', _markerArea.toStringAsFixed(2)],
        ['Total Pattern Area (m²)', _patternArea.text],
        [
          'Marker Efficiency %',
          _markerEfficiency > 0 ? _markerEfficiency.toStringAsFixed(1) : '-'
        ],
        ['Consumption/pc (g)', _consumptionPerPcG.toStringAsFixed(1)],
        ['Consumption/pc (kg)', _consumptionPerPcKg.toStringAsFixed(3)],
      ];

  Future<void> _exportExcel() async {
    await ExportService.exportExcel(
      fileName:
          'Cutting_Sheet_${_markerNo.text.isEmpty ? 'Draft' : _markerNo.text}',
      sheetTitle: 'Cutting Sheet',
      headers: _headers,
      rows: _rows,
    );
  }

  Future<void> _exportPdf() async {
    await ExportService.exportPdf(
      fileName:
          'Cutting_Sheet_${_markerNo.text.isEmpty ? 'Draft' : _markerNo.text}',
      title: 'Cutting / Marker Sheet',
      headers: _headers,
      rows: _rows,
    );
  }

  Future<void> _exportImage() async {
    await ExportService.exportImage(
      repaintKey: _summaryKey,
      fileName:
          'Cutting_Sheet_${_markerNo.text.isEmpty ? 'Draft' : _markerNo.text}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F4),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    14, statusBarHeight > 0 ? 2 : 10, 14, 10),
                child: Row(
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
                              color: AppColors.darkGreen, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/homeicon/cutting_sheet.webp',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Cutting / Marker Sheet',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('মার্কার তথ্য'),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                                label: 'Style No',
                                controller: _styleNo,
                                onChanged: (_) => setState(() {})),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                                label: 'Marker No',
                                controller: _markerNo,
                                onChanged: (_) => setState(() {})),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SheetField(
                        label: 'Fabric Type',
                        controller: _fabricType,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('মার্কার মাপ'),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                              label: 'Marker Length',
                              controller: _markerLength,
                              unit: 'm',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                              label: 'Marker Width',
                              controller: _markerWidth,
                              unit: 'm',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                              label: 'Fabric GSM',
                              controller: _gsm,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                              label: 'Garments in Marker',
                              controller: _garmentsInMarker,
                              unit: 'pcs',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SheetField(
                        label: 'Total Pattern Area (ঐচ্ছিক)',
                        controller: _patternArea,
                        unit: 'm²',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      RepaintBoundary(
                        key: _summaryKey,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset('assets/icon/app_icon.png',
                                      width: 16, height: 16),
                                  const SizedBox(width: 6),
                                  const Text('TexHelp — Cutting Summary',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkGreen)),
                                ],
                              ),
                              const Divider(height: 18),
                              if (_markerNo.text.isNotEmpty)
                                _summaryRow('Marker No', _markerNo.text),
                              _summaryRow('Marker Area',
                                  '${_markerArea.toStringAsFixed(2)} m²'),
                              if (_markerEfficiency > 0)
                                _summaryRow('Marker Efficiency',
                                    '${_markerEfficiency.toStringAsFixed(1)}%'),
                              const Divider(height: 18),
                              _summaryRow(
                                  'Consumption/pc',
                                  '${_consumptionPerPcKg.toStringAsFixed(3)} kg',
                                  bold: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ExportButtonRow(
                        onExcel: _exportExcel,
                        onPdf: _exportPdf,
                        onImage: _exportImage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.green),
        ),
      );

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: bold ? 13 : 12,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  color: bold ? AppColors.darkGreen : Colors.black54)),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 13 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen)),
        ],
      ),
    );
  }
}
