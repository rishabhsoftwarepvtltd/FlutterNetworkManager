# RSPL Network Manager Example App

This example application demonstrates the capabilities of the `rspl_network_manager` package in a real-world scenario. It implements a complete authentication flow with automatic token refreshing, secure storage, and authenticated API requests.

## 🚀 Features Demonstrated

- **Authentication Flow**: Login with username/password using `api.escuelajs.co`.
- **Secure Token Storage**: Access and refresh tokens are securely stored using `KeyChainTokenPersister`.
- **Automatic Token Refresh**: Seamlessly handles 401 Unauthorized errors by refreshing tokens and retrying requests.
- **Authenticated Requests**: Fetches user profile data using the stored access token.
- **Network Logging**: detailed logs of all HTTP requests and responses.
- **Connectivity Handling**: Checks for internet connection before making requests.

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK installed
- An emulator or physical device

### Running the App

1.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Run the app**:
    ```bash
    flutter run
    ```

### Login Credentials

Use the following credentials to log in (provided by [Fake Platzi API](https://fakeapi.platzi.com/)):

- **Email**: `john@mail.com`
- **Password**: `changeme`

## 🧩 Key Components

### 1. Dependency Injection (`lib/app/get_it_setup.dart`)

Demonstrates how to set up `Dio`, `TokenInterceptor`, `TokenRefresher`, and repositories using `GetIt`.

```dart
// Setup Dio with interceptors
GetIt.I.registerSingleton<Dio>(
  dioFactory.create()
    ..interceptors.add(ConnectivityInterceptor())
    ..interceptors.add(tokenInterceptor)
    ..interceptors.add(loggerInterceptor),
);
```

### 2. Token Refresh Mechanism (`lib/core/token/token_refresher.dart`)

The `TokenRefresher` class implements the logic to refresh tokens when a 401 error occurs.

- **Automatic**: The `TokenRefreshInterceptorWrapper` automatically calls `refreshToken()` on 401 responses.
- **Manual Testing**: The Profile page includes an **"Expire Token"** button to manually corrupt the access token, allowing you to verify the refresh logic.

### 3. Profile Feature (`lib/profile/`)

Demonstrates a clean architecture approach (Domain, Data, Application, Presentation) for fetching and displaying authenticated user data.

## 🧪 Testing Token Refresh

1.  Log in with the credentials above.
2.  Go to the **Profile** page.
3.  Tap the **"Expire Token"** button (orange icon). This invalidates your current access token.
4.  Tap the **"Refresh"** button.
5.  Observe the console logs:
    - The initial request fails with `401`.
    - `TokenRefresher` requests a new token.
    - The original request is retried with the new token and succeeds.

## 📂 Project Structure

```
lib/
├── app/                # App configuration and DI setup
├── core/               # Shared utilities (TokenRefresher, Models)
├── login/              # Login feature (Bloc, UI, Repository)
├── profile/            # Profile feature (Bloc, UI, Repository)
└── route/              # Navigation configuration
```