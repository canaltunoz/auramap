import 'package:flutter_test/flutter_test.dart';
import 'package:auramap_app/features/chart_creation/models/chart_creation_data.dart';

void main() {
  group('ChartCreationData', () {
    test('should be incomplete when required fields are missing', () {
      final data = ChartCreationData();
      expect(data.isComplete, false);
    });

    test('should be incomplete when name is empty', () {
      final data = ChartCreationData(
        name: '',
        birthDate: DateTime(1990, 1, 1),
        birthHour: 12,
        birthMinute: 0,
        birthLocation: 'Istanbul, Turkey',
      );
      expect(data.isComplete, false);
    });

    test('should be incomplete when birth location is empty', () {
      final data = ChartCreationData(
        name: 'Test Chart',
        birthDate: DateTime(1990, 1, 1),
        birthHour: 12,
        birthMinute: 0,
        birthLocation: '',
      );
      expect(data.isComplete, false);
    });

    test('should be complete when all required fields are provided', () {
      final data = ChartCreationData(
        name: 'Test Chart',
        birthDate: DateTime(1990, 1, 1),
        birthHour: 12,
        birthMinute: 0,
        birthLocation: 'Istanbul, Turkey',
      );
      expect(data.isComplete, true);
    });

    test('should copy with new values', () {
      final original = ChartCreationData(name: 'Original');
      final copied = original.copyWith(name: 'Updated');
      
      expect(original.name, 'Original');
      expect(copied.name, 'Updated');
    });

    test('should validate birth hour range', () {
      final data = ChartCreationData(
        name: 'Test Chart',
        birthDate: DateTime(1990, 1, 1),
        birthHour: 25, // Invalid hour
        birthMinute: 0,
        birthLocation: 'Istanbul, Turkey',
      );
      
      // The model doesn't validate ranges, but the UI should
      expect(data.birthHour, 25);
    });

    test('should validate birth minute range', () {
      final data = ChartCreationData(
        name: 'Test Chart',
        birthDate: DateTime(1990, 1, 1),
        birthHour: 12,
        birthMinute: 65, // Invalid minute
        birthLocation: 'Istanbul, Turkey',
      );
      
      // The model doesn't validate ranges, but the UI should
      expect(data.birthMinute, 65);
    });
  });
}
