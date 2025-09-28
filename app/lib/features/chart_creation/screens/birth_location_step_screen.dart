import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chart_creation_provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.white,
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
                    'Doğum Yeri',
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
                    'Doğduğun yer çok önemlidir. Bu bilgi sayesinde\nkaderinde iz bırakan gezegenlerin ve yıldızların\ntam konumunu belirleyebiliriz.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.gotu(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Location search field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _locationController,
                      focusNode: _locationFocus,
                      onChanged: _searchLocations,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ülke yada şehir arayın',
                        hintStyle: GoogleFonts.gotu(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.black54,
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
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
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  'Devam Et',
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
