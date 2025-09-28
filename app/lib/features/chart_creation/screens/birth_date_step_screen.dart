import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chart_creation_provider.dart';

class BirthDateStepScreen extends ConsumerStatefulWidget {
  const BirthDateStepScreen({super.key});

  @override
  ConsumerState<BirthDateStepScreen> createState() =>
      _BirthDateStepScreenState();
}

class _BirthDateStepScreenState extends ConsumerState<BirthDateStepScreen> {
  int selectedDay = 27;
  int selectedMonthIndex = 10; // November (0-based)
  int selectedYear = 1993;

  final List<String> months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  // Scroll controllers for wheel pickers
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  static const int _startYear = 1970;
  static const int _yearCount = 55; // 1970-2024

  @override
  void initState() {
    super.initState();
    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController = FixedExtentScrollController(
      initialItem: selectedMonthIndex,
    );
    yearController = FixedExtentScrollController(
      initialItem: selectedYear - _startYear,
    );
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _updateDate() {
    final date = DateTime(selectedYear, selectedMonthIndex + 1, selectedDay);

    final currentData = ref.read(chartCreationProvider).data;
    ref
        .read(chartCreationProvider.notifier)
        .updateData(currentData.copyWith(birthDate: date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Content area
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'Doğum Tarihi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gotu(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Doğum anın, benzersiz tasarımının anahtarıdır.\nKendi BodyGraph\'ını görebilmen için doğum\ntarihini bizimle paylaş',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gotu(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Date selection scroll wheels
                    _buildDateScrollWheels(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _updateDate();
                  ref.read(chartCreationProvider.notifier).nextStep();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Devam Et',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateScrollWheels() {
    // Three independent scroll wheels with a shared selection highlight
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // shared selection highlight matching mockup
          Positioned.fill(
            child: Center(
              child: Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFF4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 0.0;
              const double dayW = 60.0;
              const double monthW = 128.0;
              const double yearW = 76.0;
              final double groupWidth = dayW + monthW + yearW + (2 * spacing);
              return Center(
                child: SizedBox(
                  width: groupWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: dayW,
                        child: CupertinoPicker(
                          scrollController: dayController,
                          itemExtent: 48,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedDay = index + 1;
                            });
                            _updateDate();
                          },
                          children: List.generate(
                            31,
                            (i) => Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${i + 1}',
                                style: GoogleFonts.gotu(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: spacing),
                      SizedBox(
                        width: monthW,
                        child: CupertinoPicker(
                          scrollController: monthController,
                          itemExtent: 48,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedMonthIndex = index;
                            });
                            _updateDate();
                          },
                          children: months
                              .map(
                                (m) => Center(
                                  child: Text(
                                    m,
                                    style: GoogleFonts.gotu(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(width: spacing),
                      SizedBox(
                        width: yearW,
                        child: CupertinoPicker(
                          scrollController: yearController,
                          itemExtent: 48,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedYear = _startYear + index;
                            });
                            _updateDate();
                          },
                          children: List.generate(_yearCount, (i) {
                            final year = _startYear + i;
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$year',
                                style: GoogleFonts.gotu(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
