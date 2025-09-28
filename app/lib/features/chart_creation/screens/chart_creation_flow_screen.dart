import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            if (state.currentStep > 0) {
              ref.read(chartCreationProvider.notifier).previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.chartCreationTitle,
          style: GoogleFonts.gotu(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            icon: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: AppLocalizations.of(context)!.profile,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${state.currentStep + 1}/4',
                style: GoogleFonts.gotu(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
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
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
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
