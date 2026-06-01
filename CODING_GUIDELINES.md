# Coding Guidelines

## Logging

### Use AppLogger Instead of print
Always use the `AppLogger` class from `src/utils/app_loger.dart` for logging instead of using `print` statements. This ensures consistent logging throughout the application and better control over log levels.

```dart
// ❌ Don't use print
print('User logged in');

// ✅ Use AppLogger instead
AppLogger.d('User logged in');
```

### Log Levels
Use the appropriate log level based on the type of information:

- `AppLogger.v()` - Verbose: Detailed information for debugging
- `AppLogger.d()` - Debug: Development-related information
- `AppLogger.i()` - Info: General information about app flow
- `AppLogger.w()` - Warning: Potentially harmful situations
- `AppLogger.e()` - Error: Errors that need immediate attention
- `AppLogger.wtf()` - Assert: Errors that should never happen

### Error Logging
When logging errors, include both the error object and stack trace:

```dart
try {
  // Some code that might throw
} catch (e, stackTrace) {
  AppLogger.e('Operation failed', e, stackTrace);
}
```

## Best Practices for Logging

### DO
- Use meaningful and descriptive log messages
- Include relevant context in log messages
- Use proper log levels based on severity
- Log exceptions with stack traces
- Log important state changes and user actions

### DON'T
- Use print statements
- Log sensitive information (passwords, tokens, etc.)
- Overuse logging in production
- Leave debug logs in production code
- Log personally identifiable information (PII)

### Examples

```dart
// Authentication
AppLogger.i('User login attempt'); // Beginning of process
AppLogger.d('Login validation passed'); // Debug info
AppLogger.e('Login failed', error, stackTrace); // Errors with context

// Network Calls
AppLogger.d('API request started: ${endpoint}');
AppLogger.i('API request successful');
AppLogger.w('API request retry attempt: $retryCount');

// State Changes
AppLogger.d('Product state updated: ${newState}');
AppLogger.i('Navigation: ${routeName}');

// Important Operations
AppLogger.i('Payment process started');
AppLogger.w('Low storage space warning');
```

## Additional Notes
- Configure log levels appropriately for different environments (development, staging, production)
- Review logs periodically for debugging and monitoring
- Consider implementing crash reporting integration with logs
- Keep logs concise and meaningful
- Use structured logging when possible

Remember that proper logging is crucial for debugging, monitoring, and maintaining the application. Use `AppLogger` consistently throughout the codebase to maintain a standardized logging approach.
