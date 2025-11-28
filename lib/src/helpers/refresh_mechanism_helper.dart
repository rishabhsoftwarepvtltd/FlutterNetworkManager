/// A helper class for managing refreshing token mechanism in the application.
class RefreshMechanismHelper {
  /// Checks if a given value matches the specified expectation pattern.
  ///
  /// The [isValueMatchingExpectation] function is used to determine if the provided [value]
  /// matches the specified [expectation] pattern. It performs pattern matching based on
  /// placeholders {*} and {?}. The {*} placeholder matches any characters, and {?} matches
  /// alphanumeric characters and hyphens.
  ///
  /// The function returns `true` if the [value] matches the [expectation] pattern;
  /// otherwise, it returns `false`.
  static bool isValueMatchingExpectation({
    required String expectation,
    required String value,
  }) {
    assert(expectation.isNotEmpty, "Expectation must be valid");
    assert(value.isNotEmpty, "Value must be valid");

    final matches = _generateEffectiveRegex(
      expectation,
    ).allMatches(value).toList();
    if (matches.isNotEmpty) {
      for (var match in matches) {
        // If there are matches and all of them are at the start and end positions of the [value],
        // the function returns `true`. Otherwise, it returns `false`.
        final matchedValue = match.group(0);
        return matchedValue?.length == value.length;
      }
    }
    return false;
  }

  /// Method which converts expected string into regex with pre-defined set of rules.
  static RegExp _generateEffectiveRegex(String expectation) {
    // replaces all occurrences of `{*}` to `.*`.
    String pattern = expectation.replaceAll("{*}", ".*");
    // replaces all occurrences of `{?}` with a pattern that matches alphanumeric characters and hyphens.
    pattern = pattern.replaceAll("{?}", "(\\w|-)+");
    return RegExp(pattern);
  }
}
