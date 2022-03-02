import 'dart:async';
import 'dart:io';

import 'package:flutter_playground/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockWS extends Mock implements WebSocket {}

class MockRepo extends Mock implements Repo {}

void main() {
  testWidgets('auto reconnect', (WidgetTester tester) async {
    final ws = MockWS();
    final repo = MockRepo();
    final ctrl = StreamController();
    when(() => repo.websocket).thenAnswer((_) async => ws);
    when(() => ws.listen(
          any(),
          onDone: any(named: 'onDone'),
          onError: any(named: 'onError'),
          cancelOnError: any(named: 'cancelOnError'),
        )).thenAnswer((invocation) {
      return ctrl.stream.listen(
        invocation.positionalArguments[0],
        onDone: invocation.namedArguments['onDone'],
        onError: invocation.namedArguments['onError'],
        cancelOnError: invocation.namedArguments['cancelOnError'],
      );
    });
    when(() => ws.close()).thenAnswer((invocation) async => null);
    await tester.pumpWidget(Provider<Repo>.value(
      value: repo,
      child: MyApp(),
    ));
    await ctrl.close();
    await tester.pump(Duration(seconds: 20));
    verify(() => repo.websocket).called(2);
  });
}
