# RSPL Network Manager
[![pub package](https://img.shields.io/pub/v/rspl_network_manager.svg)](https://pub.dev/packages/rspl_network_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.0%2B-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.0%2B-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Coverage](https://img.shields.io/badge/coverage-87%25-success.svg)](https://github.com/rishabhsoftwarepvtltd/FlutterNetworkManager)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios%20|%20macos%20|%20windows%20|%20web-blue.svg)](https://pub.dev/packages/rspl_network_manager)

`RSPLNetworkManager` is a production-ready networking wrapper for Flutter apps, built on top of [Dio](https://pub.dev/packages/dio). It simplifies HTTP requests with built-in logging, token management, offline support, and automatic token refreshing.

It abstracts away common boilerplate code associated with HTTP clients, offering a clean API for handling authentication, logging, error handling, and connectivity states.

## Table of Contents

- [Features](#features)
- [Platform Support](#platform-support)
- [Requirements](#requirements)
- [Dependencies & Configuration](#dependencies--configuration)
- [Getting Started](#getting-started)
- [Detailed Usage](#detailed-usage)
  - [1. Creating a Client (DioFactory)](#1-creating-a-client-diofactory)
  - [2. Logging Network Traffic](#2-logging-network-traffic)
  - [3. Checking Connectivity](#3-checking-connectivity)
  - [4. Token Management](#4-token-management)
    - [Secure Storage](#secure-storage)
    - [Injecting Tokens](#injecting-tokens)
    - [Automatic Token Refresh (Deep Dive)](#automatic-token-refresh-deep-dive)
  - [5. Advanced Configuration](#5-advanced-configuration)
    - [Proxy Support (Debugging)](#proxy-support-debugging)
    - [Custom Timeouts](#custom-timeouts)
- [Folder Structure](#folder-structure)
- [Contributing](#contributing)
- [License](#license)

## Features

- 📝 **Configurable Logging**: Debug your network traffic with ease using configurable logging levels (request/response headers, body, errors).
- 🔐 **Secure Token Storage**: Seamless token persistence using `flutter_secure_storage` with automatic injection into requests.
- 🔄 **Auto Token Refresh**: Built-in mechanism to handle 401 errors and refresh expired access tokens automatically.
- 📡 **Connectivity Awareness**: Automatically checks for internet connection before making requests to prevent unnecessary failures.
- 🔌 **Proxy Support**: Easy configuration for proxy settings during debugging.
- 🧪 **Testable**: Designed with dependency injection in mind, making it easy to unit test your networking logic.

## Platform Support

- **Android** — API Level: 21+
- **iOS** — iOS 12.0+
- **macOS** — macOS 10.14+
- **Windows** — Windows 10+
- **Web** — All modern browsers

## Requirements

- **Dart**: >=3.5.0 <4.0.0
- **Flutter**: Flutter 3.24.0+
- **Dio**: ^5.0.0

### Permissions

- **Android**: Add `INTERNET` permission in `AndroidManifest.xml`.
- **iOS**: No explicit permissions required for basic networking.
- **macOS**: Add `com.apple.security.network.client` entitlement.

## Dependencies & Configuration

This package relies on the following core dependencies. Please review their documentation for any specific platform configurations:

| Package | Purpose |
|---------|---------|
| [dio](https://pub.dev/packages/dio) | Core HTTP client for making network requests. |
| [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | Secure storage for persisting authentication tokens. |
| [dio_smart_retry](https://pub.dev/packages/dio_smart_retry) | Flexible retry logic for failed requests. |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus) | Network connectivity detection. |

### Important Configuration Notes

#### flutter_secure_storage
- **macOS**: You must add the `Keychain Sharing` capability in Xcode and enable `keychain-access-groups` in your entitlements file (as shown in the example app).
- **Android**: Can be configured to use `EncryptedSharedPreferences`.

#### connectivity_plus
- **Android**: Uses `ConnectivityManager`. Ensure `ACCESS_NETWORK_STATE` permission is in your manifest (usually added automatically).
- **iOS/macOS**: Uses `NWPathMonitor`. No extra configuration needed for basic usage.



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

## Detailed Usage

### 1. Creating a Client (DioFactory)

The `DioFactory` class simplifies creating a `Dio` instance with common configurations like base URL, timeouts, and headers.

```dart
// Simple setup
final dioFactory = DioFactory('https://api.example.com');
final dio = dioFactory.create();

// With custom headers
final dio = dioFactory.create(
  headers: {
    'ApiKey': 'your-api-key',
    'Accept-Language': 'en-US',
  },
);
```

### 2. Logging Network Traffic

Use `WSLoggerInterceptor` to see detailed logs of your network requests in the console. This is crucial for debugging.

```dart
dio.interceptors.add(
  WSLoggerInterceptor(
    request: true,        // Log request method and URL
    requestHeader: true,  // Log request headers
    requestBody: true,    // Log request body
    responseHeader: true, // Log response headers
    responseBody: true,   // Log response body
    error: true,          // Log errors
    compact: true,        // Use compact format for cleaner logs
  ),
);
```

### 3. Checking Connectivity

The `ConnectivityInterceptor` checks for an active internet connection *before* attempting a request. If offline, it throws a `NoInternetConnectionException` immediately.

```dart
dio.interceptors.add(ConnectivityInterceptor());

// Handling the exception
try {
  await dio.get('/endpoint');
} on DioException catch (e) {
  if (e.error is NoInternetConnectionException) {
    print('No internet connection! Please check your settings.');
  }
}
```

### 4. Token Management

This package handles the entire lifecycle of authentication tokens: storage, injection, and refreshing.

#### Secure Storage

Use `KeyChainTokenPersister` to securely save tokens. It uses `flutter_secure_storage` under the hood.

```dart
final tokenPersister = KeyChainTokenPersister();

// Save tokens after login
await tokenPersister.save(
  token: 'access_token_value',
  refreshToken: 'refresh_token_value',
);

// Clear tokens on logout
await tokenPersister.remove();
```

#### Injecting Tokens

The `TokenInterceptor` automatically adds the `Authorization: Bearer <token>` header to your requests. You can exclude specific paths (like login or register) where a token isn't needed.

```dart
dio.interceptors.add(
  TokenInterceptor(
    tokenPersister: tokenPersister,
    exceptionList: [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
    ],
  ),
);
```

#### Automatic Token Refresh (Deep Dive)

This is one of the most powerful features. When an API returns a `401 Unauthorized` error (usually meaning the access token expired), the package can automatically:
1.  **Catch** the error.
2.  **Refresh** the token using your refresh token.
3.  **Retry** the original request with the new token.

This happens seamlessly; the user (and your calling code) never knows it failed!

**The 3 Key Components:**

1.  **`ITokenRefresher`**: An interface you implement to tell the package *how* to call your specific refresh API.
2.  **`TokenRetryEvaluator`**: Logic that decides *when* to retry (e.g., "If status is 401, try to refresh").
3.  **`TokenRefreshInterceptorWrapper`**: The manager that ties it all together.

---

**Step 1: Implement `ITokenRefresher`**

Create a class that implements `ITokenRefresher`. This is where you put your API call to refresh the token.

```dart
class MyTokenRefresher implements ITokenRefresher {
  final Dio dio;
  final ITokenPersister tokenPersister;

  MyTokenRefresher(this.dio, this.tokenPersister);

  @override
  Future<bool> refreshToken() async {
    try {
      // 1. Get the refresh token from storage
      final refreshToken = await tokenPersister.refreshToken;
      if (refreshToken == null) return false;

      // 2. Call your backend's refresh endpoint
      // Note: We use the same Dio instance, but the 'TokenRetryEvaluator' 
      // ensures this request doesn't trigger a loop (see Step 2).
      final response = await dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        // 3. Save the NEW tokens
        await tokenPersister.save(
          token: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );
        return true; // Success!
      }
      return false;
    } catch (e) {
      return false; // Failed
    }
  }
}
```

---

**Step 2: Configure `TokenRetryEvaluator`**

The `TokenRetryEvaluator` is a helper class provided by the package. It checks if the error is a 401/403 and triggers the refresher.

> **CRITICAL**: You MUST provide `exceptionalUris`. These are endpoints that should **NEVER** trigger a retry loop. Always include your login and refresh endpoints here!

```dart
final retryEvaluator = TokenRetryEvaluator(
  tokenRefresher: myTokenRefresher,
  retryCodes: [401, 403], // Retry on these codes
  exceptionalUris: [
    '/auth/login',         // Don't retry login
    '/auth/refresh-token'  // CRITICAL: Don't retry the refresh endpoint itself!
  ],
).evaluate;
```

---

**Step 3: Tie it all together**

Now, add the `TokenRefreshInterceptorWrapper` to your Dio instance.

> **Important**: Add this interceptor **FIRST** (index 0). In Dio, response interceptors are executed in reverse order (Last In, First Out). Adding it first ensures it's the *last* to see the error, allowing other interceptors (like Loggers) to see the 401 error before it's "fixed" by the refresh logic.

```dart
// 1. Setup dependencies
final tokenPersister = KeyChainTokenPersister();
final dio = DioFactory('https://api.example.com').create();

// 2. Create your refresher
final refresher = MyTokenRefresher(dio, tokenPersister);

// 3. Create the wrapper
final refreshWrapper = TokenRefreshInterceptorWrapper(
  dio: dio,
  tokenRefresher: refresher,
  retryEvaluator: TokenRetryEvaluator(
    tokenRefresher: refresher,
    retryCodes: [401, 403],
    exceptionalUris: ['/auth/login', '/auth/refresh-token'],
  ).evaluate,
);

// 4. Add interceptors (Order matters!)
dio.interceptors.add(refreshWrapper.interceptor); // Add FIRST
dio.interceptors.add(ConnectivityInterceptor());
dio.interceptors.add(WSLoggerInterceptor(...));
dio.interceptors.add(TokenInterceptor(...));      // Add LAST
```

### 5. Advanced Configuration

#### Proxy Support (Debugging)

**What is it?**
A proxy allows you to route your app's network traffic through a tool like **Charles Proxy**, **Fiddler**, or **Wireshark**.

**Why use it?**
Sometimes console logs aren't enough. You might need to inspect the exact raw bytes being sent, modify requests on the fly, or simulate slow networks.

**How to use it:**

```dart
final dio = dioFactory.create(
  proxyConfig: ProxyConfig(
    ip: '192.168.1.10', // Your computer's local IP address
    port: 8888,         // The port your proxy tool is listening on
  ),
);
```

> **Note**: Ensure your device and computer are on the same Wi-Fi network.

#### Custom Timeouts

By default, `DioFactory` sets reasonable timeouts (15s receive/send, 5s connect). If you need to change these, use `createWithOptions`:

```dart
final options = BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
);

final dio = dioFactory.createWithOptions(options);
```

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

For a complete, working example including login, profile fetching, and automatic token refresh, see the [example](example) directory.

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
