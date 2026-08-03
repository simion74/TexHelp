import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_icon.dart';
import '../widgets/sheet_field.dart';

/// 💰 Garment Costing Sheet — Merchandiser ফোনেই সম্পূর্ণ কস্টিং শিট
/// ফিল-আপ করে সরাসরি Excel/PDF/Image হিসেবে এক্সপোর্ট ও শেয়ার করতে
/// পারবেন, কম্পিউটার ছাড়াই।
class CostingSheetScreen extends StatefulWidget {
  const CostingSheetScreen({super.key});

  @override
  State<CostingSheetScreen> createState() => _CostingSheetScreenState();
}

class _CostingSheetScreenState extends State<CostingSheetScreen> {
  final _styleNo = TextEditingController();
  final _buyer = TextEditingController();
  final _orderQty = TextEditingController();
  final _fabricConsumption = TextEditingController();
  final _fabricPrice = TextEditingController();
  final _trimsCost = TextEditingController();
  final _cmCost = TextEditingController();
  final _overheadPercent = TextEditingController();
  final _profitPercent = TextEditingController();

  final GlobalKey _summaryKey = GlobalKey();

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  double get _fabricCost => _d(_fabricConsumption) * _d(_fabricPrice);
  double get _subtotal => _fabricCost + _d(_trimsCost) + _d(_cmCost);
  double get _overheadAmount => _subtotal * (_d(_overheadPercent) / 100);
  double get _afterOverhead => _subtotal + _overheadAmount;
  double get _profitAmount => _afterOverhead * (_d(_profitPercent) / 100);
  double get _finalPrice => _afterOverhead + _profitAmount;
  double get _totalOrderValue => _finalPrice * _d(_orderQty);

  @override
  void dispose() {
    _styleNo.dispose();
    _buyer.dispose();
    _orderQty.dispose();
    _fabricConsumption.dispose();
    _fabricPrice.dispose();
    _trimsCost.dispose();
    _cmCost.dispose();
    _overheadPercent.dispose();
    _profitPercent.dispose();
    super.dispose();
  }

  List<String> get _headers => ['Item', 'Value'];

  List<List<String>> get _rows => [
        ['Style No', _styleNo.text],
        ['Buyer', _buyer.text],
        ['Order Quantity', _orderQty.text],
        ['Fabric Consumption', _fabricConsumption.text],
        ['Fabric Price/unit', _fabricPrice.text],
        ['Fabric Cost/pc', _fabricCost.toStringAsFixed(3)],
        ['Trims Cost/pc', _d(_trimsCost).toStringAsFixed(3)],
        ['CM Cost/pc', _d(_cmCost).toStringAsFixed(3)],
        ['Subtotal/pc', _subtotal.toStringAsFixed(3)],
        ['Overhead %', _overheadPercent.text],
        ['Overhead Amount/pc', _overheadAmount.toStringAsFixed(3)],
        ['Profit %', _profitPercent.text],
        ['Profit Amount/pc', _profitAmount.toStringAsFixed(3)],
        ['Final Price/pc', _finalPrice.toStringAsFixed(3)],
        ['Total Order Value', _totalOrderValue.toStringAsFixed(2)],
      ];

  Future<void> _exportExcel() async {
    await ExportService.exportExcel(
      fileName: 'Costing_Sheet_${_styleNo.text.isEmpty ? 'Draft' : _styleNo.text}',
      sheetTitle: 'Costing Sheet',
      headers: _headers,
      rows: _rows,
    );
  }

  Future<void> _exportPdf() async {
    await ExportService.exportPdf(
      fileName: 'Costing_Sheet_${_styleNo.text.isEmpty ? 'Draft' : _styleNo.text}',
      title: 'Garment Costing Sheet',
      headers: _headers,
      rows: _rows,
    );
  }

  Future<void> _exportImage() async {
    await ExportService.exportImage(
      repaintKey: _summaryKey,
      fileName:
          'Costing_Sheet_${_styleNo.text.isEmpty ? 'Draft' : _styleNo.text}',
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
                padding: EdgeInsets.fromLTRB(14, statusBarHeight > 0 ? 2 : 10,
                    14, 10),
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
                      'assets/homeicon/costing_sheet.webp',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Garment Costing Sheet',
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
                      _sectionTitle('অর্ডার তথ্য'),
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
                                label: 'Buyer',
                                controller: _buyer,
                                onChanged: (_) => setState(() {})),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SheetField(
                        label: 'Order Quantity',
                        controller: _orderQty,
                        unit: 'pcs',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('ফেব্রিক কস্ট'),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                              label: 'Consumption',
                              controller: _fabricConsumption,
                              unit: 'kg/pc',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                              label: 'Price/kg',
                              controller: _fabricPrice,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('অন্যান্য কস্ট (প্রতি পিস)'),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                              label: 'Trims Cost',
                              controller: _trimsCost,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                              label: 'CM Cost',
                              controller: _cmCost,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('ওভারহেড ও প্রফিট'),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                              label: 'Overhead %',
                              controller: _overheadPercent,
                              unit: '%',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                              label: 'Profit %',
                              controller: _profitPercent,
                              unit: '%',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
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
                                children: const [
                                  AiIcon(size: 16),
                                  SizedBox(width: 6),
                                  Text('TexHelp — Costing Summary',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkGreen)),
                                ],
                              ),
                              const Divider(height: 18),
                              if (_styleNo.text.isNotEmpty)
                                _summaryRow('Style No', _styleNo.text),
                              if (_buyer.text.isNotEmpty)
                                _summaryRow('Buyer', _buyer.text),
                              _summaryRow(
                                  'Fabric Cost/pc', _fabricCost.toStringAsFixed(3)),
                              _summaryRow('Trims Cost/pc',
                                  _d(_trimsCost).toStringAsFixed(3)),
                              _summaryRow(
                                  'CM Cost/pc', _d(_cmCost).toStringAsFixed(3)),
                              _summaryRow(
                                  'Subtotal/pc', _subtotal.toStringAsFixed(3)),
                              _summaryRow('Overhead Amount/pc',
                                  _overheadAmount.toStringAsFixed(3)),
                              _summaryRow('Profit Amount/pc',
                                  _profitAmount.toStringAsFixed(3)),
                              const Divider(height: 18),
                              _summaryRow(
                                  'Final Price/pc',
                                  _finalPrice.toStringAsFixed(3),
                                  bold: true),
                              _summaryRow(
                                  'Total Order Value',
                                  _totalOrderValue.toStringAsFixed(2),
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
