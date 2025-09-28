import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chart_creation_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auramap_app/l10n/app_localizations.dart';

class BirthLocationStepScreen extends ConsumerStatefulWidget {
  const BirthLocationStepScreen({super.key});

  @override
  ConsumerState<BirthLocationStepScreen> createState() =>
      _BirthLocationStepScreenState();
}

class _BirthLocationStepScreenState
    extends ConsumerState<BirthLocationStepScreen> {
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocus = FocusNode();
  List<String> _suggestions = [];

  // Mock location suggestions
  final List<String> _mockLocations = [
    'Istanbul, Turkey',
    'Ankara, Turkey',
    'Izmir, Turkey',
    'Bursa, Turkey',
    'Antalya, Turkey',
    'London, United Kingdom',
    'New York, United States',
    'Paris, France',
    'Berlin, Germany',
    'Tokyo, Japan',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(chartCreationProvider);
    if (state.data.birthLocation != null) {
      _locationController.text = state.data.birthLocation!;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  void _searchLocations(String query) {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() {
      _suggestions = _mockLocations
          .where(
            (location) => location.toLowerCase().contains(query.toLowerCase()),
          )
          .take(5)
          .toList();
    });
  }

  void _updateLocation() {
    final currentData = ref.read(chartCreationProvider).data;
    ref
        .read(chartCreationProvider.notifier)
        .updateData(
          currentData.copyWith(birthLocation: _locationController.text),
        );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_suggestions.isEmpty) const Spacer(),

                  // Title
                  Text(
                    AppLocalizations.of(context)!.birthLocationTitle,
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
                    AppLocalizations.of(context)!.birthLocationSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.gotu(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Location search field
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _locationController,
                      focusNode: _locationFocus,
                      onChanged: _searchLocations,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.searchCountryCity,
                        hintStyle: GoogleFonts.gotu(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).hintColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Suggestions
                  if (_suggestions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            title: Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              _locationController.text = suggestion;
                              setState(() => _suggestions = []);
                              _locationFocus.unfocus();
                            },
                          );
                        },
                      ),
                    )
                  else
                    const Spacer(),
                ],
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
                onPressed: _locationController.text.isNotEmpty
                    ? () {
                        _updateLocation();
                        ref.read(chartCreationProvider.notifier).nextStep();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Theme.of(context).disabledColor,
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
          ),
        ],
      ),
    );
  }
}
