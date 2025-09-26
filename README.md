# AuraMap

AuraMap is a full-stack application with a NestJS backend and Flutter mobile app, designed for mapping and location-based services.

## Project Structure

```
auramap/
├── backend/          # NestJS REST API backend
│   ├── src/          # Source code
│   ├── test/         # Backend tests
│   ├── package.json  # Node.js dependencies
│   └── ...
├── app/              # Flutter mobile application
│   ├── lib/          # Dart source code
│   ├── test/         # Flutter tests
│   ├── android/      # Android platform files
│   ├── ios/          # iOS platform files
│   ├── pubspec.yaml  # Flutter dependencies
│   └── ...
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

## Technology Stack

### Backend (NestJS)

- **Framework**: NestJS (Node.js)
- **Language**: TypeScript
- **Package Manager**: npm
- **Testing**: Jest
- **Linting**: ESLint

### Frontend (Flutter)

- **Framework**: Flutter
- **Language**: Dart
- **Platform**: Cross-platform (iOS, Android, Web, Desktop)
- **Testing**: Flutter Test

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)

### Backend Setup

1. Navigate to the backend directory:

   ```bash
   cd backend
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run start:dev
   ```

The backend API will be available at `http://localhost:3000`

### Flutter App Setup

1. Navigate to the app directory:

   ```bash
   cd app
   ```

2. Get Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Development Workflow

### Git Branches

- `main`: Production-ready code
- `dev`: Development branch for ongoing work

### Available Scripts

#### Backend

- `npm run start`: Start the application
- `npm run start:dev`: Start in development mode with hot reload
- `npm run start:debug`: Start in debug mode
- `npm run build`: Build the application
- `npm run test`: Run unit tests
- `npm run test:e2e`: Run end-to-end tests

#### Flutter App

- `flutter run`: Run the app in development mode
- `flutter build`: Build the app for production
- `flutter test`: Run unit tests
- `flutter analyze`: Analyze code for issues

## Contributing

1. Create a feature branch from `dev`
2. Make your changes
3. Test your changes
4. Submit a pull request to `dev`

## License

This project is licensed under the terms specified in the LICENSE file.
