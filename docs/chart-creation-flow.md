# Chart Creation Flow

This document describes the new 3-step chart creation flow implemented for the AuraMap Flutter application.

## Overview

The chart creation flow is automatically triggered after user login when they don't have any existing charts. It consists of 3 sequential steps to collect the user's birth information needed to generate their Human Design chart.

## Flow Steps

### Step 1: Birth Date Collection
- **Screen**: `BirthDateStepScreen`
- **Purpose**: Collect the user's birth date
- **UI Components**: 
  - Day picker (1-31)
  - Month picker (localized month names)
  - Year picker (current year - 100 years)
- **Validation**: 
  - Date cannot be in the future
  - All fields must be selected

### Step 2: Birth Time Collection
- **Screen**: `BirthTimeStepScreen`
- **Purpose**: Collect the user's birth time
- **UI Components**:
  - Hour picker (0-23)
  - Minute picker (0-59)
- **Validation**:
  - Hour must be 0-23
  - Minute must be 0-59

### Step 3: Birth Location Collection
- **Screen**: `BirthLocationStepScreen`
- **Purpose**: Collect the user's birth location
- **UI Components**:
  - Location search field
  - Location suggestions dropdown
- **Validation**:
  - Location field cannot be empty
  - Location must be selected or entered

## Technical Implementation

### Frontend (Flutter)

#### Key Files
- `app/lib/features/chart_creation/screens/chart_creation_flow_screen.dart` - Main flow controller
- `app/lib/features/chart_creation/providers/chart_creation_provider.dart` - State management
- `app/lib/features/chart_creation/models/chart_creation_data.dart` - Data model

#### State Management
- Uses Riverpod for state management
- `ChartCreationProvider` manages the flow state and data
- Supports navigation between steps and data persistence

#### Navigation Integration
- Integrated with existing splash screen logic
- Automatically routes new users through the flow
- Routes to charts screen after completion

### Backend (NestJS)

#### New API Endpoints
- `GET /charts/has-charts` - Check if user has existing charts
- `POST /charts/flow` - Create chart from flow data

#### Data Processing
- Combines separate date and time into ISO datetime
- Validates all required fields
- Stores chart data in existing Chart model

## Localization

The flow supports both English and Turkish languages with the following new keys:

### English (`app_en.arb`)
```json
{
  "chartCreationTitle": "Create Your Chart",
  "birthDateTitle": "Birth Date",
  "birthDateSubtitle": "Birth date is essential for creating your BodyGraph...",
  "birthTimeTitle": "Birth Time",
  "birthTimeSubtitle": "Birth time is essential for creating your BodyGraph...",
  "birthLocationTitle": "Birth Location",
  "birthLocationSubtitle": "Birth location is essential for creating your BodyGraph...",
  "continueButton": "Continue",
  "finish": "Finish"
}
```

### Turkish (`app_tr.arb`)
```json
{
  "chartCreationTitle": "Vücut Grafiği",
  "birthDateTitle": "Doğum Tarihi",
  "birthDateSubtitle": "Doğum anın, benzersiz tasarımının anahtarıdır...",
  "birthTimeTitle": "Doğum Saati",
  "birthTimeSubtitle": "Doğum anın, benzersiz tasarımının anahtarıdır...",
  "birthLocationTitle": "Doğum Yeri",
  "birthLocationSubtitle": "Doğum anın, benzersiz tasarımının anahtarıdır...",
  "continueButton": "Devam Et",
  "finish": "Bitir"
}
```

## Design

The UI follows the provided mockup design with:
- Clean, minimal interface
- Gold accent color (#D4AF37)
- Progress indicator showing current step (1/3, 2/3, 3/3)
- Consistent typography and spacing
- Material 3 design principles

## Testing

Unit tests are included for the data model:
- `app/test/chart_creation_test.dart`
- Tests validation logic and data completeness
- Ensures proper data copying and state management

## Error Handling

- Form validation at each step
- Network error handling with user-friendly messages
- Graceful fallbacks for API failures
- Loading states and progress indicators

## Future Enhancements

1. **Location Services**: Integrate with real geocoding API (Google Places, Mapbox)
2. **Timezone Detection**: Automatically detect timezone based on location
3. **Data Persistence**: Save partial progress locally
4. **Advanced Validation**: More sophisticated date/time validation
5. **Accessibility**: Enhanced accessibility features
6. **Analytics**: Track flow completion rates and drop-off points
