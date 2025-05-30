import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pzsp/controllers/dance_controller.dart';
import 'package:pzsp/models/dance.dart';
import 'package:pzsp/service/supabase_service.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class DanceControllerPartialMock extends DanceController {
  final SupabaseService mockService;

  DanceControllerPartialMock(this.mockService);

  @override
  Future<List<Dance>> loadDances() {
    return mockService.fetchDances();
  }
}

void main() {
  late MockSupabaseService mockService;
  late DanceControllerPartialMock controller;

  setUp(() {
    mockService = MockSupabaseService();
    controller = DanceControllerPartialMock(mockService);
  });

  test('loadDances from mocked SupabaseService', () async {
    final mockDances = [
      Dance(title: 'Taniec1', description: 'aaaaaaaa', length: 40.0),
      Dance(title: 'Taniec2', description: 'dance', length: 50.0),
    ];

    when(() => mockService.fetchDances()).thenAnswer((_) async => mockDances);

    final result = await controller.loadDances();

    expect(result, mockDances);
    verify(() => mockService.fetchDances()).called(1);
  });
}
