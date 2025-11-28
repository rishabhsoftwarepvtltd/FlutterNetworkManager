# RSPL Network Manager

`RSPLNetworkManager` is a production-ready networking wrapper for Flutter apps, built on top of Dio. It simplifies HTTP requests with built-in logging, token management, offline support, and automatic token refreshing.

## Features
- **Configurable Logging**: Detailed logs of web-service calls with optional file output.
- **Token Management**: Seamless token persistence and automatic injection into requests.
- **Offline Support**: Mock API interceptor for development and testing without a backend.
- **Automatic Refresh**: Built-in mechanism to refresh expired access tokens automatically.
- **Connectivity Checks**: Automatically checks for internet connection before making requests.
- **Proxy Support**: Easy configuration for proxy settings during debugging.

## Platform Support

- **Android** — API Level: 21+
- **iOS** — iOS 12.0+
- **macOS** — macOS 10.14+
- **Windows** — Windows 10+
- **Linux** — Any modern distribution
- **Web** — All modern browsers

## Requirements

- **Dart**: >=3.5.0 <4.0.0
- **Flutter**: Flutter 3.24.0+
- **Dio**: ^5.0.0

## Permissions Required

- **Android**: `INTERNET` permission in `AndroidManifest.xml`
- **iOS**: No explicit permissions required for basic networking
- **macOS**: `com.apple.security.network.client` entitlement

## Description

`RSPLNetworkManager` provides a robust networking layer for Flutter applications. It abstracts away common boilerplate code associated with HTTP clients, offering a clean API for handling authentication, logging, error handling, and connectivity states. It is designed to be modular and easily extensible.

## Highlights / Features

• 📝 ** comprehensive Logging**: Debug your network traffic with ease using configurable logging levels.

• 🔐 **Secure Token Storage**: Abstracted token persistence with a default secure storage implementation.

• 🔄 **Auto Token Refresh**: Never worry about expired tokens again with the built-in refresh interceptor.

• 🛠️ **Mock API Support**: Develop faster by mocking API responses when the backend isn't ready.

• 📡 **Connectivity Awareness**: Prevent failed requests by checking network status beforehand.

• 🧪 **Testable**: Designed with dependency injection in mind, making it easy to unit test your networking logic.

## Getting Started

### 1) Install

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  rspl_network_manager: ^1.0.11
```

Then run:

```bash
flutter pub get
```

### 2) Import

```dart
import 'package:rspl_network_manager/rspl_network_manager.dart';
```

## Usage

### Minimal Setup

```dart
// Create a DioFactory instance
final dioFactory = DioFactory('https://api.example.com');

// Create a Dio client
final dio = dioFactory.create();
```

### Advanced Setup with Interceptors

```dart
import 'package:dio/dio.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';
import 'package:get_it/get_it.dart';

void main() {
  // 1. Configure Dio factory
  const dioFactory = DioFactory('https://api.example.com');

  // 2. Setup Token Interceptor
  final tokenInterceptor = TokenInterceptor(
    tokenPersister: GetIt.I<ITokenPersister>(),
    exceptionList: ['/auth/login', '/auth/register'], // Endpoints that don't need tokens
  );

  // 3. Setup Logger Interceptor
  final loggerInterceptor = WSLoggerInterceptor(
    requestBody: true,
    requestHeader: true,
    error: true,
    responseHeader: true,
  );

  // 4. Register Dio client
  GetIt.I.registerSingleton<Dio>(
    dioFactory.create()
      ..interceptors.add(ConnectivityInterceptor())
      ..interceptors.add(tokenInterceptor)
      ..interceptors.add(loggerInterceptor),
  );
}
```

## Configuration

| Component | Description |
|-----------|-------------|
| `DioFactory` | Factory class to create pre-configured Dio instances. |
| `TokenInterceptor` | Injects `Authorization` header with Bearer token. |
| `WSLoggerInterceptor` | Logs request and response details to console. |
| `ConnectivityInterceptor` | Checks for internet connectivity before request. |
| `TokenRefreshInterceptorWrapper` | Handles 401 errors and refreshes tokens. |
| `ITokenPersister` | Interface for persisting tokens (save, read, delete). |

## Folder Structure

```
rspl_network_manager/
├─ lib/
│  ├─ rspl_network_manager.dart           # Main package export
│  └─ src/
│     ├─ dio_factory.dart         # Dio instance creator
│     ├─ interceptors/            # Network interceptors
│     │  ├─ token_interceptor.dart
│     │  ├─ logger_interceptor.dart
│     │  └─ ...
│     ├─ token/                   # Token management
│     │  ├─ token_persister.dart
│     │  └─ token_refresher.dart
│     └─ ...
├─ example/                       # Complete example app
├─ test/                          # Unit tests
├─ CHANGELOG.md                   # Version history
├─ LICENSE                        # MIT License
└─ README.md                      # Documentation
```

## Example

For a complete example, including login, profile fetching, and token refresh, see the [example](example) directory.

## Contributing

Contributions welcome! Please read:

• [CONTRIBUTING.md](CONTRIBUTING.md) – setup, branch strategy, commit convention

• [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

• Run checks before push:
  - `dart format .`
  - `flutter analyze`
  - `flutter test`

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## User Privacy Notes

• This package does not collect any user information or share data with third-party services.

## Author, Maintainers & Acknowledgements

• Developed by **Rishabh Software**.
• Thanks to the Flutter community for the amazing packages used in this project.

## Keywords and Tags

flutter dart networking dio http api token-refresh logging interceptor connectivity offline-support

## License

This package is licensed under the MIT License.

## Made by RSPL Team

[Github](https://github.com/rishabhsoftwarepvtltd) • [Website](https://www.rishabhsoft.com)
