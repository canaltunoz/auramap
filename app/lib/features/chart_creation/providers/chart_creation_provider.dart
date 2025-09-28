import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chart_creation_data.dart';
import '../../charts/service/charts_service.dart';

class ChartCreationState {
  final ChartCreationData data;
  final int currentStep;
  final bool loading;
  final String? error;

  const ChartCreationState({
    required this.data,
    this.currentStep = 0,
    this.loading = false,
    this.error,
  });

  ChartCreationState copyWith({
    ChartCreationData? data,
    int? currentStep,
    bool? loading,
    String? error,
  }) {
    return ChartCreationState(
      data: data ?? this.data,
      currentStep: currentStep ?? this.currentStep,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ChartCreationNotifier extends Notifier<ChartCreationState> {
  @override
  ChartCreationState build() {
    return ChartCreationState(data: ChartCreationData());
  }

  void updateData(ChartCreationData newData) {
    state = state.copyWith(data: newData);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }

  Future<bool> submitChart() async {
    if (!state.data.isComplete) {
      state = state.copyWith(error: 'Please complete all steps');
      return false;
    }

    state = state.copyWith(loading: true, error: null);

    try {
      final chartsService = ref.read(chartsServiceProvider);
      await chartsService.createFromFlow(
        name: state.data.name!,
        birthDate: _formatDate(state.data.birthDate!),
        birthHour: state.data.birthHour!,
        birthMinute: state.data.birthMinute!,
        birthLocation: state.data.birthLocation!,
        latitude: state.data.latitude,
        longitude: state.data.longitude,
        timezone: state.data.timezone,
      );

      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      String errorMessage = 'Failed to create chart';
      if (e.toString().contains('400')) {
        errorMessage = 'Invalid data provided. Please check your inputs.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }
      state = state.copyWith(loading: false, error: errorMessage);
      return false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void reset() {
    state = ChartCreationState(data: ChartCreationData());
  }
}

final chartCreationProvider =
    NotifierProvider<ChartCreationNotifier, ChartCreationState>(
      ChartCreationNotifier.new,
    );

// Provider for charts service
final chartsServiceProvider = Provider<ChartsService>((ref) => ChartsService());
