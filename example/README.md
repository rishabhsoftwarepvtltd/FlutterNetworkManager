# RSPL Network Manager - JWT Token Refresh Example

A simple, self-contained Flutter app demonstrating **automatic JWT token refresh** using the `rspl_network_manager` package with the [Platzi Fake API](https://fakeapi.platzi.com/).

## 🎯 What This Example Demonstrates

- **Login Flow**: Authenticate and securely store access + refresh tokens
- **Protected API Requests**: Fetch user profile using stored access token
- **Automatic Token Refresh**: Seamlessly handle 401 errors by refreshing tokens
- **Request Retry**: Automatically retry failed requests with new tokens
- **Activity Logging**: Visual log showing the complete token refresh flow
- **Dedicated Refresh Client**: Separate Dio instance prevents interceptor deadlocks

## 🚀 Quick Start

### Prerequisites
- Flutter SDK installed
- An emulator or physical device

### Running the App

```bash
cd example
flutter pub get
flutter run
```

### Test Credentials

Use these credentials to log in (provided by Platzi Fake API):

- **Email**: `john@mail.com`
- **Password**: `changeme`

> **Note**: These are public test credentials from the Platzi Fake API. If they stop working, check the [official API documentation](https://fakeapi.platzi.com/en/rest/auth-jwt/).

## 🧪 Testing Token Refresh

Follow these steps to see automatic token refresh in action:

1. **Login** with the test credentials above
2. **View Profile** - Your profile data will be displayed
3. **Expire Token** - Tap the "Expire Token" button (orange)
4. **Get Profile Again** - Tap the "Get Profile" button (green)
5. **Watch the Activity Log** - You'll see:
   ```
   ✅ Fetching profile...
   ❌ 401 Unauthorized - Token expired
   ℹ️  Attempting token refresh...
   ℹ️  Starting token refresh...
   ✅ Token refresh successful!
   ℹ️  Retrying request with new token...
   ✅ Profile loaded successfully
   ```

The entire flow happens automatically - no manual intervention needed!

## 🏗️ Architecture Highlights

### Dedicated JWT Refresh Client

This example uses **two separate Dio instances** to prevent interceptor recursion:

```dart
// Separate Dio instance for refresh-only operations
final tokenDio = Dio(BaseOptions(baseUrl: baseUrl));

// Main Dio with full interceptor chain
final mainDio = Dio(BaseOptions(baseUrl: baseUrl));
```

**Why Two Dio Instances?**

When a token refresh is triggered, if the refresh request uses the same Dio instance with interceptors, it can cause infinite loops:

```
API Request → 401 → TokenRefreshInterceptor triggers
  → Refresh request (using same Dio) → Goes through interceptors again
    → If refresh fails with 401 → TokenRefreshInterceptor triggers again
      → Infinite loop! 💥
```

**Solution:** Use a separate "clean" Dio instance (`tokenDio`) with NO interceptors for refresh calls only.

**Alternative Approach:**

You CAN use a single Dio instance if:
1. Your `TokenRefresher` creates its own internal Dio instance, OR
2. You add the refresh endpoint to `exceptionalUris` in `TokenRetryEvaluator`

Both approaches work, but using two separate instances makes the architecture more explicit and easier to understand.

### Custom 401 Retry Logic

```dart
retryEvaluator: (error, handler) async {
  // Only retry on 401 Unauthorized
  if (error.response?.statusCode != 401) return false;
  
  // Skip login/refresh endpoints (prevents infinite loops)
  final path = error.requestOptions.path;
  if (path.contains('/auth/login') || 
      path.contains('/auth/refresh-token')) {
    return false;
  }
  
  return true; // Proceed with refresh and retry
}
```

### Interceptor Order

The interceptors are configured in this specific order for optimal behavior:

1. **TokenRefreshInterceptorWrapper** - Handles 401 errors first
2. **ConnectivityInterceptor** - Checks internet connection
3. **WSLoggerInterceptor** - Logs requests/responses
4. **TokenInterceptor** - Adds access token to headers (last)

## 📡 API Endpoints Used

### 1. Login
```
POST https://api.escuelajs.co/api/v1/auth/login
Body: { "email": "john@mail.com", "password": "changeme" }
Response: { "access_token": "...", "refresh_token": "..." }
```

### 2. Get Profile (Protected)
```
GET https://api.escuelajs.co/api/v1/auth/profile
Headers: Authorization: Bearer {access_token}
Response: { "id": 1, "email": "...", "name": "...", "role": "...", "avatar": "..." }
```

### 3. Refresh Token
```
POST https://api.escuelajs.co/api/v1/auth/refresh-token
Body: { "refreshToken": "{refresh_token}" }
Response: { "access_token": "...", "refresh_token": "..." }
```

## 📂 Project Structure

```
example/
├── lib/
│   └── main.dart          # Complete example in one file (~600 lines)
├── pubspec.yaml           # Minimal dependencies
└── README.md              # This file
```

The entire example is contained in a single `main.dart` file for simplicity and clarity.

## 🔑 Key Components in main.dart

### JWTDemoPage
Main stateful widget managing the entire app state and UI.

### _CustomTokenRefresher
Implements `ITokenRefresher` interface to handle token refresh logic using the dedicated `tokenDio` instance.

### Activity Log
Visual feedback showing every network operation:
- 🟢 Success (green)
- 🔴 Error (red)
- 🟠 Warning (orange)
- 🔵 Info (blue)

## 🛠️ Troubleshooting

### "Invalid credentials" error
The test credentials may have changed. Check the [Platzi Fake API docs](https://fakeapi.platzi.com/en/rest/auth-jwt/) for current credentials.

### Token refresh not working
1. Check the activity log for error messages
2. Verify you're logged in before testing
3. Ensure you have internet connectivity
4. Check console logs for detailed Dio output

### App won't build
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Learn More

- [rspl_network_manager package](https://pub.dev/packages/rspl_network_manager)
- [Platzi Fake API Documentation](https://fakeapi.platzi.com/)
- [Dio Package](https://pub.dev/packages/dio)

## 💡 Tips

- The activity log is your friend - it shows exactly what's happening
- Use the "Expire Token" button to test refresh without waiting for real expiration
- Watch the console for detailed Dio logs
- The app works on all platforms (iOS, Android, Web, Desktop)

---

**Made with ❤️ by RSPL Team**