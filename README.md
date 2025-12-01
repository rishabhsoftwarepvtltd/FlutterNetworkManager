# RSPL Network Manager

[![pub package](https://img.shields.io/pub/v/rspl_network_manager.svg)](https://pub.dev/packages/rspl_network_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`RSPLNetworkManager` is a production-ready networking wrapper for Flutter apps, built on top of Dio. It simplifies HTTP requests with built-in logging, token management, offline support, and automatic token refreshing.

It abstracts away common boilerplate code associated with HTTP clients, offering a clean API for handling authentication, logging, error handling, and connectivity states. It is designed to be modular and easily extensible.

## Table of Contents

- [Features](#features)
- [Platform Support](#platform-support)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Configuration](#configuration)
- [Folder Structure](#folder-structure)
- [Contributing](#contributing)
- [License](#license)

## Features

- 📝 **Configurable Logging**: Debug your network traffic with ease using configurable logging levels (request/response headers, body, errors).
- 🔐 **Secure Token Storage**: Seamless token persistence using `flutter_secure_storage` with automatic injection into requests.
- 🔄 **Auto Token Refresh**: Built-in mechanism to handle 401 errors and refresh expired access tokens automatically.
- 🛠️ **Mock API Support**: Develop faster by mocking API responses when the backend isn't ready.
- 📡 **Connectivity Awareness**: Automatically checks for internet connection before making requests to prevent unnecessary failures.
- 🔌 **Proxy Support**: Easy configuration for proxy settings during debugging.
- 🧪 **Testable**: Designed with dependency injection in mind, making it easy to unit test your networking logic.

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

### Permissions

- **Android**: Add `INTERNET` permission in `AndroidManifest.xml`.
- **iOS**: No explicit permissions required for basic networking.
- **macOS**: Add `com.apple.security.network.client` entitlement.

## Getting Started

### 1. Install

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  rspl_network_manager: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### 2. Import

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
│  ├─ rspl_network_manager.dart   # Main package export
│  └─ src/
│     ├─ dio_factory.dart         # Dio instance creator
│     ├─ interceptors/            # Network interceptors
│     │  ├─ token_interceptor.dart
│     │  ├─ logger_interceptor.dart
│     │  └─ ...
│     ├─ token/                   # Token management
│     │  ├─ token_persister.dart
│     │  ├─ token_refresher.dart
│     └─ ...
├─ example/                       # Complete example app
├─ test/                          # Unit tests
├─ CHANGELOG.md                   # Version history
├─ LICENSE                        # MIT License
└─ README.md                      # Documentation
```

## Example

For a complete example, including login, profile fetching, and token refresh, see the [example](example) directory.

> **Note:**  
> The example app uses a public mock API with demo login credentials:
> ```json
> {
>   "email": "john@mail.com",
>   "password": "changeme"
> }
> ```
> These credentials are provided by the Platzi Fake API and may change over time.  
> If the example app throws authentication or API errors, verify the latest valid credentials on the official API documentation:  
> **https://fakeapi.platzi.com/en/rest/auth-jwt/**

## Contributing

Contributions welcome! Please read:

- [CONTRIBUTING.md](CONTRIBUTING.md) – setup, branch strategy, commit convention
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

Run checks before push:
- `dart format .`
- `flutter analyze`
- `flutter test`

## User Privacy Notes

- This package does not collect any user information or share data with third-party services.

## Author, Maintainers & Acknowledgements

- Developed by **Rishabh Software**.
- Thanks to the Flutter community for the amazing packages used in this project.

## License

This package is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Made by RSPL Team

[Github](https://github.com/rishabhsoftwarepvtltd) • [Website](https://www.rishabhsoft.com)
