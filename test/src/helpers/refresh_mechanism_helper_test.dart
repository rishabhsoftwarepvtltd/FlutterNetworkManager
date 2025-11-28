import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/src/helpers/refresh_mechanism_helper.dart';

void main() {
  test(
    "isValueMatchingExpectation_ifExpectationIsEmpty_shallThrowAssertion",
    () {
      expect(
        () => RefreshMechanismHelper.isValueMatchingExpectation(
          expectation: "",
          value: "fake-value",
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  test(
    "isValueMatchingExpectation_ifValueIsEmpty_shallThrowAssertion",
    () {
      expect(
        () => RefreshMechanismHelper.isValueMatchingExpectation(
          expectation: "fake-value",
          value: "",
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  test(
    "isValueMatchingExpectation_whenBothValueAreDifferent_returnsFalse",
    () {
      final result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/login",
        value: "/project/workitems",
      );
      expect(result, isA<bool>());
      expect(result, isFalse);
    },
  );

  test(
    "isValueMatchingExpectation_whenBothValuesDoesNotRequireAnyRegexUpdateAndAreIdentical_returnsTrue",
    () {
      final result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/login",
        value: "/api/login",
      );
      expect(result, isA<bool>());
      expect(result, isTrue);
    },
  );

  test(
    "isValueMatchingExpectation_whenInterrogationOperatorProvidedAtEndAndValueIsAsPerExpectation_returnsTrue",
    () {
      bool result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/login/{?}",
        value: "/api/login/fake",
      );
      expect(result, isA<bool>());
      expect(result, isTrue);

      result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/projects/{?}",
        value: "/api/projects/fake-project-id",
      );
      expect(result, isA<bool>());
      expect(result, isTrue);
    },
  );

  test(
    "isValueMatchingExpectation_whenInterrogationOperatorProvidedAtEndAndValueIsNotAsPerExpectation_returnsFalse",
    () {
      bool result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/login/{?}",
        value: "/api/login/fake/mock",
      );
      expect(result, isA<bool>());
      expect(result, isFalse);

      result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/projects/{?}",
        value: "/api/workitems/fake-workitem-id",
      );
      expect(result, isA<bool>());
      expect(result, isFalse);
    },
  );

  test(
    "isValueMatchingExpectation_whenAsteriskOperatorProvidedAtEndAndValueIsAsPerExpectation_returnsTrue",
    () {
      bool result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/login/{*}",
        value: "/api/login/fake-id",
      );
      expect(result, isA<bool>());
      expect(result, isTrue);

      result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/projects/{*}",
        value: "/api/projects/fake-project-id/fake-id-again",
      );
      expect(result, isA<bool>());
      expect(result, isTrue);
    },
  );

  test(
    "isValueMatchingExpectation_whenAsteriskOperatorProvidedAtEndAndValueIsNotAsPerExpectation_returnsFalse",
    () {
      final result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/projects/{*}",
        value: "/api/workitems/fake-workitem-id",
      );
      expect(result, isA<bool>());
      expect(result, isFalse);
    },
  );

  test(
    "isValueMatchingExpectation_whenBothOperatorsGivenWithValidValues_returnsTrue",
    () {
      bool result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/projects/{?}/work-item/{*}",
        value: "/api/projects/fake-workitem-id/work-item/fake-id",
      );
      expect(result, isA<bool>());
      expect(result, isTrue);

      result = RefreshMechanismHelper.isValueMatchingExpectation(
        expectation: "/api/projects/{*}/work-item/{?}",
        value: "/api/projects/fake-workitem-id/work-item/fake-id",
      );
      expect(result, isA<bool>());
      expect(result, isTrue);
    },
  );
}
