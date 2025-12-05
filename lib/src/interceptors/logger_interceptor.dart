import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Configurable logging interceptor for Dio HTTP requests and responses.
///
/// This interceptor provides detailed logging of HTTP requests, responses, and errors
/// with customizable output options. Logs can be printed to console and/or streamed
/// for file logging.
///
/// **Features:**
/// - Request/response logging with configurable detail levels
/// - Pretty-printed JSON formatting
/// - Compact or expanded output modes
/// - Stream-based logging for file writing
/// - Configurable log width
///
/// **Configuration Options:**
/// - [enableConsoleLog]: Enable/disable console output (default: true)
/// - [request]: Log request info (default: true)
/// - [requestHeader]: Log request headers (default: false)
/// - [requestBody]: Log request body (default: false)
/// - [responseBody]: Log response body (default: true)
/// - [responseHeader]: Log response headers (default: false)
/// - [error]: Log errors (default: true)
/// - [compact]: Use compact JSON format (default: true)
/// - [maxWidth]: Maximum width for log lines (default: 90)
///
/// Example:
/// ```dart
/// final loggerInterceptor = WSLoggerInterceptor(
///   request: true,
///   requestBody: true,
///   responseBody: true,
///   error: true,
/// );
/// dio.interceptors.add(loggerInterceptor);
///
/// // Listen to log stream for file writing
/// loggerInterceptor.newLogStream.listen((log) {
///   // Write log to file
/// });
/// ```
class WSLoggerInterceptor extends Interceptor {
  /// Creates a [WSLoggerInterceptor] with configurable logging options.
  ///
  /// All parameters are optional with sensible defaults for typical usage.
  WSLoggerInterceptor({
    this.enableConsoleLog = true,
    this.request = true,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
  }) {
    _logPrint = printStrategy;
    _newLogStreamController = StreamController<String>.broadcast();
    newLogStream = _newLogStreamController.stream;
  }

  /// Enable console logging using [debugPrint] (default: true).
  final bool enableConsoleLog;

  /// Print request [Options] info.
  final bool request;

  /// Print request headers [Options.headers].
  final bool requestHeader;

  /// Print request body [Options.data].
  final bool requestBody;

  /// Print response body [Response.data].
  final bool responseBody;

  /// Print response headers [Response.headers].
  final bool responseHeader;

  /// Print error messages.
  final bool error;

  /// Initial tab count for JSON formatting.
  static const int initialTab = 1;

  /// Tab step size (4 spaces).
  static const String tabStep = '    ';

  /// Use compact JSON format for smaller output.
  final bool compact;

  /// Maximum width per log line.
  final int maxWidth;

  /// Stream of log messages for file writing or custom handling.
  ///
  /// Listen to this stream to write logs to a file or process them elsewhere.
  late Stream<String> newLogStream;

  late StreamController<String> _newLogStreamController;
  late void Function(String object) _logPrint;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      _printRequestHeader(options);
    }
    if (requestHeader) {
      _printMapAsTable(options.queryParameters, header: 'Query Parameters');
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout;
      requestHeaders['receiveTimeout'] = options.receiveTimeout;
      _printMapAsTable(requestHeaders, header: 'Headers');
      _printMapAsTable(options.extra, header: 'Extras');
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) _printMapAsTable(options.data as Map?, header: 'Body');
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}');
        }
        // coverage:ignore-start
        // Reason: Edge case for non-Map, non-FormData request bodies (e.g., raw strings, bytes).
        // Rarely used in practice and difficult to test comprehensively without complex setup.
        else {
          _printBlock(data.toString());
        }
        // coverage:ignore-end
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      if (err.type == DioExceptionType.badResponse) {
        final uri = err.response?.requestOptions.uri;
        _printBoxed(
            header:
                'DioException ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage}',
            text: uri.toString());
        if (err.response != null && err.response?.data != null) {
          _logPrint('╔ ${err.type.toString()}');
          _printResponse(err.response!);
        }
        _printLine('╚');
        _logPrint('');
      } else {
        _printBoxed(header: 'DioException ║ ${err.type}', text: err.message);
      }
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printResponseHeader(response);
    if (responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers
          .forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(responseHeaders, header: 'Headers');
    }

    if (responseBody) {
      _logPrint('╔ Body');
      _logPrint('║');
      _printResponse(response);
      _logPrint('║');
      _printLine('╚');
    }
    super.onResponse(response, handler);
  }

  void printStrategy(String message) {
    if (enableConsoleLog) {
      debugPrint(message);
    }

    if (_newLogStreamController.hasListener) {
      _newLogStreamController.sink.add(message);
    }
  }

  void _printBoxed({String? header, String? text}) {
    _logPrint('');
    _logPrint('╔╣ $header');
    _logPrint('║  $text');
    _printLine('╚');
  }

  void _printResponse(Response response) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map);
      } else if (response.data is List) {
        _logPrint('║${_indent()}[');
        _printList(response.data as List);
        _logPrint('║${_indent()}[');
      }
      // coverage:ignore-start
      // Reason: Edge case for non-Map, non-List response bodies (e.g., raw strings, primitives).
      // Uncommon in REST APIs and difficult to test without specific API setup.
      else {
        _printBlock(response.data.toString());
      }
      // coverage:ignore-end
    }
  }

  void _printResponseHeader(Response response) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    _printBoxed(
        header:
            'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}',
        text: uri.toString());
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(header: 'Request ║ $method ', text: uri.toString());
  }

  void _printLine([String pre = '', String suf = '╝']) =>
      _logPrint('$pre${'═' * maxWidth}$suf');

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      _logPrint(pre);
      _printBlock(msg);
    } else {
      _logPrint('$pre$msg');
    }
  }

  void _printBlock(String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      _logPrint((i >= 0 ? '║ ' : '') +
          msg.substring(i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length)));
    }
  }

  String _indent([int tabCount = initialTab]) => tabStep * tabCount;

  void _printPrettyMap(
    Map data, {
    int tabs = initialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    var tabs0 = tabs;
    final isRoot = tabs0 == initialTab;
    final initialIndent = _indent(tabs0);
    tabs0++;

    if (isRoot || isListItem) _logPrint('║$initialIndent{');

    data.keys.toList().asMap().forEach((index, dynamic key) {
      final isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          _logPrint('║${_indent(tabs0)} $key: $value${!isLast ? ',' : ''}');
        } else {
          _logPrint('║${_indent(tabs0)} $key: {');
          _printPrettyMap(value, tabs: tabs0);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          _logPrint('║${_indent(tabs0)} $key: ${value.toString()}');
        } else {
          _logPrint('║${_indent(tabs0)} $key: [');
          _printList(value, tabs: tabs0);
          _logPrint('║${_indent(tabs0)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs0);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            _logPrint(
                '║${_indent(tabs0)} ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
          _logPrint('║${_indent(tabs0)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    });

    _logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = initialTab}) {
    list.asMap().forEach((i, dynamic e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (compact && _canFlattenMap(e)) {
          _logPrint('║${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(e, tabs: tabs + 1, isListItem: true, isLast: isLast);
        }
      } else {
        _logPrint('║${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  bool _canFlattenMap(Map map) {
    return map.values
            .where((dynamic val) => val is Map || val is List)
            .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    _logPrint('╔ $header ');
    map.forEach(
        (dynamic key, dynamic value) => _printKV(key.toString(), value));
    _printLine('╚');
  }
}
