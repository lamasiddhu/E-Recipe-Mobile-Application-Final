import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppResult', () {
    test('success fold calls success branch', () {
      const result = ResultSuccess(7);
      expect(result.fold((_) => -1, (value) => value), 7);
    });
    test('failure fold calls failure branch', () {
      const result = ResultFailure<int>(ApiFailure(message: 'failed'));
      expect(result.fold((failure) => failure.message, (_) => ''), 'failed');
    });
    test('API failure preserves status code', () {
      const failure = ApiFailure(statusCode: 403, message: 'Forbidden');
      expect(failure.statusCode, 403);
    });
    test('local failure preserves custom message', () {
      const failure = LocalDatabaseFailure(message: 'Offline');
      expect(failure.message, 'Offline');
    });
  });
}
