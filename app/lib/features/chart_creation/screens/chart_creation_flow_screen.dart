import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chart_creation_provider.dart';
import 'birth_date_step_screen.dart';
import 'birth_time_step_screen.dart';
import 'birth_location_step_screen.dart';

class ChartCreationFlowScreen extends ConsumerWidget {
  const ChartCreationFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartCreationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            if (state.currentStep > 0) {
              ref.read(chartCreationProvider.notifier).previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Vücut Grafiği',
          style: GoogleFonts.gotu(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${state.currentStep + 1}/4',
                style: GoogleFonts.gotu(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Gold pill progress bar under the title (W86 H10 r=40)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: SizedBox(
              width: 291,
              height: 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Unfilled track
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  // Filled portion
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (state.currentStep + 1) / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: state.currentStep,
              children: const [
                BirthDateStepScreen(),
                BirthTimeStepScreen(),
                BirthLocationStepScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
