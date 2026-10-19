// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_autogen/otel_autogen.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_autogen-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('team.run records team + turns + tokens', () async {
    await tracedAutoGen<String>(
      operation: 'team.run',
      invoke: () async => const AutoGenCallResult(
        value: 'ok',
        result: AutoGenResult(
          runtime: 'single_threaded',
          teamKind: 'SelectorGroupChat',
          teamName: 'research',
          modelProvider: 'openai',
          modelName: 'gpt-4o',
          turn: 7,
          maxTurns: 10,
          terminationReason: 'function_call',
          totalTokens: 12500,
          toolCallCount: 4,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('autogen team.run')!);
    expect(a['autogen.team.kind'], 'SelectorGroupChat');
    expect(a['autogen.turn'], 7);
    expect(a['autogen.termination.reason'], 'function_call');
  });

  test('max_turns_exceeded sets span error', () async {
    await tracedAutoGen<String>(
      operation: 'team.run',
      invoke: () async => const AutoGenCallResult(
        value: 'ok',
        result: AutoGenResult(
          errorKind: 'max_turns_exceeded',
          maxTurns: 10,
          turn: 10,
        ),
      ),
    );
    expect(
      spans.findSpanByName('autogen team.run')!.status,
      SpanStatusCode.Error,
    );
  });

  test('human_input.required does NOT set span error', () async {
    await tracedAutoGen<String>(
      operation: 'agent.onMessages',
      invoke: () async => const AutoGenCallResult(
        value: 'ok',
        result: AutoGenResult(
          agentName: 'UserProxyAgent',
          humanInputRequired: true,
        ),
      ),
    );
    expect(
      spans.findSpanByName('autogen agent.onMessages')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutAutoGenInstrumentationAsync(() async {
      await tracedAutoGen<String>(
        operation: 'runtime.start',
        invoke: () async => const AutoGenCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('autogen '), isEmpty);
  });
}
