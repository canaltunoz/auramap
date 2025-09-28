import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import '../providers/chart_creation_provider.dart';

class BirthTimeStepScreen extends ConsumerStatefulWidget {
  const BirthTimeStepScreen({super.key});

  @override
  ConsumerState<BirthTimeStepScreen> createState() =>
      _BirthTimeStepScreenState();
}

class _BirthTimeStepScreenState extends ConsumerState<BirthTimeStepScreen> {
  int selectedHour = 12;
  int selectedMinute = 0;
  // Scroll controllers for wheel pickers
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(chartCreationProvider);
    if (state.data.birthHour != null) {
      selectedHour = state.data.birthHour!;
    }
    if (state.data.birthMinute != null) {
      selectedMinute = state.data.birthMinute!;
    }
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  void _updateTime() {
    final currentData = ref.read(chartCreationProvider).data;
    ref
        .read(chartCreationProvider.notifier)
        .updateData(
          currentData.copyWith(
            birthHour: selectedHour,
            birthMinute: selectedMinute,
          ),
        );
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                      AppLocalizations.of(context)!.birthTimeTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gotu(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      AppLocalizations.of(context)!.birthTimeSubtitle,
                      style: GoogleFonts.gotu(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Time selection scroll wheels
                    _buildTimeScrollWheels(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom actions: Emin Değilim + Devam Et
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emin Değilim (secondary)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedHour = 12;
                        selectedMinute = 0;
                      });
                      _updateTime();
                      ref.read(chartCreationProvider.notifier).nextStep();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.notSure,
                      style: GoogleFonts.gotu(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Devam Et (primary)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _updateTime();
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
                    child: Text(
                      AppLocalizations.of(context)!.continueButton,
                      style: GoogleFonts.gotu(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeScrollWheels() {
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing =
                  10.0; // increased spacing for better separation
              const double colonW = 10.0; // width reserved for ':' separator
              const double hourW = 76.0;
              const double minuteW = 76.0;
              final double groupWidth =
                  hourW + minuteW + (2 * spacing) + colonW;
              return Center(
                child: SizedBox(
                  width: groupWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: hourW,
                        child: CupertinoPicker(
                          scrollController: hourController,
                          itemExtent: 48,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHour = index;
                            });
                            _updateTime();
                          },
                          children: List.generate(
                            24,
                            (i) => Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$i'.padLeft(2, '0'),
                                style: GoogleFonts.gotu(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: spacing),
                      SizedBox(
                        width: colonW,
                        child: Center(
                          child: Text(
                            ':',
                            style: GoogleFonts.gotu(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: spacing),
                      SizedBox(
                        width: minuteW,
                        child: CupertinoPicker(
                          scrollController: minuteController,
                          itemExtent: 48,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedMinute = index;
                            });
                            _updateTime();
                          },
                          children: List.generate(
                            60,
                            (i) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$i'.padLeft(2, '0'),
                                style: GoogleFonts.gotu(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
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
