# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0]

### ⚠️ BREAKING CHANGE: Dependency Upgrades
- **flutter_secure_storage:** Upgraded from `^9.2.4` to `^10.3.1` (major version bump).
  - The deprecated `AndroidOptions(encryptedSharedPreferences: true)` option was removed from `KeyChainTokenPersister`'s default storage; v10 encrypts data with custom ciphers on Android and migrates existing data automatically on first access.
  - If you pass a custom `FlutterSecureStorage` instance, review the [flutter_secure_storage v10 migration notes](https://pub.dev/packages/flutter_secure_storage/changelog).

### Changed
- Raised minimum Dart SDK requirement to `^3.9.0`.
- Upgraded `dio` to `^5.10.0`.
- Upgraded `connectivity_plus` to `^7.2.0`.
- Verified compatibility with the latest stable Flutter SDK (3.44.x / Dart 3.12).

---

## [1.0.0]

### ⚠️ BREAKING CHANGE: License Update
- **License:** Changed from MIT License to **Rishabh Software Source Available License (Non-Commercial) v1.0**.
  - Free for personal projects, learning, academic purposes, and evaluation
  - Modification and forking allowed for non-commercial use
  - Commercial use requires a separate license from Rishabh Software
  - For licensing inquiries, refer to [LICENSE](LICENSE) for contact details.

### Changed
- Added contact information section in README.

---

## [0.0.2]

### Added
- `TokenRefreshFailedException` with categorized failure reasons:  
  `refreshTokenExpired`, `networkError`, `serverError`, `noRefreshToken`, `unknown`.
- Expanded test suite (119 tests; **89.6% coverage**).
- macOS network client support in the example application.

### Changed
- **Platform Support:** Dropped Linux and Windows; now supports **Android, iOS, macOS, Web**.
- Simplified example app to focus on JWT token refresh workflow.
- Improved documentation for `ITokenRefresher`, including exception-handling examples.
- Updated example app to highlight token refresh patterns and error handling.
- Enhanced README with detailed usage guides for token management and interceptors.

### Fixed
- Improved error handling logic in the token refresh flow.

---

## [0.0.1]

### Added
- Initial release of `rspl_network_manager`.
- Secure token persistence.
- Automatic token injection for outgoing requests.
- Token refresh and retry mechanism.
- Internet connectivity detection.
- Proxy configuration support.
- Configurable logging.
- Mock API support for testing.
