import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JWT Token Refresh Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const JWTDemoPage(),
    );
  }
}

/// Main demo page showing JWT token refresh flow
class JWTDemoPage extends StatefulWidget {
  const JWTDemoPage({super.key});

  @override
  State<JWTDemoPage> createState() => _JWTDemoPageState();
}

class _JWTDemoPageState extends State<JWTDemoPage> {
  // Controllers
  final _emailController = TextEditingController(text: 'john@mail.com');
  final _passwordController = TextEditingController(text: 'changeme');
  final _activityLog = <ActivityLogEntry>[];
  final _scrollController = ScrollController();

  // State
  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _profileData;

  // Network components
  late final ITokenPersister _tokenPersister;
  late final Dio _mainDio;
  late final Dio _tokenDio; // Dedicated Dio for token refresh only

  @override
  void initState() {
    super.initState();
    _initializeNetworking();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    _mainDio.close();
    _tokenDio.close();
    super.dispose();
  }

  // ============================================================================
  // CORE NETWORKING METHODS
  // ============================================================================

  /// Initialize all networking components
  void _initializeNetworking() {
    // 1. Token Persister - secure storage for tokens
    _tokenPersister = const KeyChainTokenPersister();

    // 2. Base URL for Platzi Fake API
    const baseUrl = 'https://api.escuelajs.co';

    // 3. Create dedicated Dio instance for token refresh ONLY
    // This prevents interceptor recursion and deadlocks during token refresh.
    //
    // WHY TWO DIO INSTANCES?
    // ----------------------
    // When using TokenRefreshInterceptor, if the refresh request itself uses
    // the same Dio instance with interceptors, it can cause infinite loops:
    //
    // Request → 401 → Refresh (using same Dio) → 401 → Refresh → 401 → ∞
    //
    // SOLUTION: Use a separate "clean" Dio instance for refresh calls only.
    // This instance has NO interceptors, preventing recursion.
    //
    // ALTERNATIVE APPROACH:
    // You CAN use a single Dio instance if your TokenRefresher implementation
    // creates its own internal Dio, or if you add the refresh endpoint to
    // exceptionalUris in TokenRetryEvaluator. Both approaches work, but using
    // two separate instances makes the architecture more explicit and clear.
    _tokenDio = Dio(BaseOptions(baseUrl: baseUrl));

    // 4. Create main Dio instance with full interceptor chain
    _mainDio = Dio(BaseOptions(baseUrl: baseUrl));

    // 5. Setup interceptors in correct order
    _setupInterceptors();

    _addLog('System initialized', LogType.info);
  }

  /// Configure interceptor chain: Refresh → Connectivity → Logger → Token
  void _setupInterceptors() {
    // Create the custom token refresher instance
    final customTokenRefresher = _CustomTokenRefresher(
      tokenPersister: _tokenPersister,
      tokenDio: _tokenDio,
      onLog: _addLog,
    );

    // FIRST: Token Refresh Interceptor
    // Handles 401 errors and automatically refreshes tokens
    final tokenRefreshInterceptor = TokenRefreshInterceptorWrapper(
      dio: _mainDio,
      tokenRefresher: customTokenRefresher,
      retries: 1,
      retryEvaluator: (error, handler) async {
        // Only retry on 401 Unauthorized
        if (error.response?.statusCode != 401) {
          return false;
        }

        // Don't retry login or refresh endpoints (prevents infinite loops)
        final path = error.requestOptions.path;
        if (path.contains('/auth/login') || path.contains('/auth/refresh-token')) {
          return false;
        }

        _addLog('401 Unauthorized - Token expired', LogType.error);
        _addLog('Attempting token refresh...', LogType.info);

        // Actually call the refresh method and return its result
        return await customTokenRefresher.refreshToken();
      },
    );

    // SECOND: Connectivity Interceptor
    // Checks internet connection before making requests
    final connectivityInterceptor = ConnectivityInterceptor();

    // THIRD: Logger Interceptor
    // Logs all requests and responses
    final loggerInterceptor = WSLoggerInterceptor(
      requestBody: true,
      requestHeader: true,
      error: true,
      responseHeader: true,
    );

    // FOURTH: Token Interceptor
    // Adds access token to request headers (except login)
    final tokenInterceptor = TokenInterceptor(
      tokenPersister: _tokenPersister,
      exceptionList: ['/api/v1/auth/login'],
    );

    // Add interceptors in order
    _mainDio.interceptors.add(tokenRefreshInterceptor.interceptor);
    _mainDio.interceptors.add(connectivityInterceptor);
    _mainDio.interceptors.add(loggerInterceptor);
    _mainDio.interceptors.add(tokenInterceptor);
  }

  /// Login with email and password
  Future<void> _login() async {
    setState(() => _isLoading = true);
    _addLog('Attempting login...', LogType.info);

    try {
      final response = await _mainDio.post(
        '/api/v1/auth/login',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
        options: Options(
          extra: {'disableRetry': true}, // Don't retry login requests
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;

        if (accessToken != null && refreshToken != null) {
          // Save tokens securely
          await _tokenPersister.save(
            token: accessToken,
            refreshToken: refreshToken,
          );

          _addLog('Login successful! Tokens saved.', LogType.success);
          setState(() => _isLoggedIn = true);

          // Auto-fetch profile after login
          await _fetchProfile();
        } else {
          _addLog('Login failed: Invalid response', LogType.error);
        }
      }
    } on DioException catch (e) {
      if (e.isInternetConnectionError) {
        _addLog('No internet connection', LogType.error);
      } else if (e.response?.statusCode == 401) {
        _addLog('Invalid credentials', LogType.error);
      } else {
        _addLog('Login error: ${e.message}', LogType.error);
      }
    } catch (e) {
      _addLog('Unexpected error: $e', LogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetch user profile (protected endpoint)
  Future<void> _fetchProfile() async {
    _addLog('Fetching profile...', LogType.info);

    try {
      final response = await _mainDio.get('/api/v1/auth/profile');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() => _profileData = data);
        _addLog('Profile loaded successfully', LogType.success);
      }
    } on DioException catch (e) {
      if (e.isInternetConnectionError) {
        _addLog('No internet connection', LogType.error);
      } else {
        _addLog('Profile fetch error: ${e.message}', LogType.error);
      }
    } catch (e) {
      _addLog('Unexpected error: $e', LogType.error);
    }
  }

  /// Manually expire access token for testing
  Future<void> _expireToken() async {
    _addLog('Manually expiring access token...', LogType.warning);

    final currentRefreshToken = await _tokenPersister.refreshToken;
    await _tokenPersister.save(
      token: 'expired_token_for_testing',
      refreshToken: currentRefreshToken,
    );

    _addLog('Access token expired! Next request will trigger refresh.', LogType.warning);
  }

  /// Logout and clear tokens
  Future<void> _logout() async {
    await _tokenPersister.remove();
    setState(() {
      _isLoggedIn = false;
      _profileData = null;
    });
    _addLog('Logged out successfully', LogType.info);
  }

  // ============================================================================
  // UI BUILDING METHODS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JWT Token Refresh Demo'),
        backgroundColor: Colors.blue,
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Login Section (if not logged in)
            if (!_isLoggedIn) _buildLoginSection(),

            // Profile Section (if logged in)
            if (_isLoggedIn) _buildProfileSection(),

            // Activity Log Section
            Expanded(child: _buildActivityLog()),
          ],
        ),
      ),
    );
  }

  /// Build login form
  Widget _buildLoginSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Login',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Test Credentials Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 Test Credentials',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Email: john@mail.com'),
                Text('Password: changeme'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Email Field
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Password Field
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),

          // Login Button
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Login', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// Build profile display and action buttons
  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Profile Data
          if (_profileData != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(_profileData!['avatar'] ?? ''),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profileData!['name'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _profileData!['email'] ?? 'N/A',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              'Role: ${_profileData!['role'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fetchProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Get Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _expireToken,
                  icon: const Icon(Icons.lock_clock),
                  label: const Text('Expire Token'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build activity log viewer
  Widget _buildActivityLog() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📋 Activity Log',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Clear Log Button
                TextButton.icon(
                  onPressed: _activityLog.isEmpty ? null : _clearLog,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _activityLog.isEmpty
                ? const Center(
                    child: Text(
                      'No activity yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _activityLog.length,
                    itemBuilder: (context, index) {
                      final entry = _activityLog[index];
                      return _buildLogEntry(entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build single log entry
  Widget _buildLogEntry(ActivityLogEntry entry) {
    Color color;
    IconData icon;

    switch (entry.type) {
      case LogType.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case LogType.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case LogType.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case LogType.info:
        color = Colors.blue;
        icon = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(entry.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Add entry to activity log
  void _addLog(String message, LogType type) {
    setState(() {
      _activityLog.add(ActivityLogEntry(
        message: message,
        type: type,
        timestamp: DateTime.now(),
      ));
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Clear activity log
  void _clearLog() {
    setState(() {
      _activityLog.clear();
    });
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}

// ==============================================================================
// CUSTOM TOKEN REFRESHER
// ==============================================================================

/// Custom token refresher implementation
class _CustomTokenRefresher implements ITokenRefresher {
  _CustomTokenRefresher({
    required this.tokenPersister,
    required this.tokenDio,
    required this.onLog,
  });

  final ITokenPersister tokenPersister;
  final Dio tokenDio;
  final Function(String message, LogType type) onLog;

  @override
  Future<bool> refreshToken() async {
    onLog('Starting token refresh...', LogType.info);

    try {
      // Get current refresh token
      final refreshToken = await tokenPersister.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        onLog('No refresh token available', LogType.error);
        return false;
      }

      // Call refresh endpoint using dedicated Dio instance
      final response = await tokenDio.post(
        '/api/v1/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          // Save new tokens
          await tokenPersister.save(
            token: newAccessToken,
            refreshToken: newRefreshToken,
          );

          onLog('Token refresh successful!', LogType.success);
          onLog('Retrying request with new token...', LogType.info);
          return true;
        }
      }

      onLog('Token refresh failed: Invalid response', LogType.error);
      return false;
    } on DioException catch (e) {
      onLog('Token refresh failed: ${e.message}', LogType.error);
      return false;
    } catch (e) {
      onLog('Token refresh error: $e', LogType.error);
      return false;
    }
  }
}

// ==============================================================================
// DATA MODELS
// ==============================================================================

/// Activity log entry model
class ActivityLogEntry {
  final String message;
  final LogType type;
  final DateTime timestamp;

  ActivityLogEntry({
    required this.message,
    required this.type,
    required this.timestamp,
  });
}

/// Log entry types
enum LogType {
  success,
  error,
  warning,
  info,
}
