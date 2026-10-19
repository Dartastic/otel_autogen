// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_autogen/otel_autogen.dart';

/// Traces AutoGen calls with OpenTelemetry.
///
/// `otel_autogen` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each AutoGen call in
/// [tracedAutoGen]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'autogen-example');

  // Wraps an AutoGen call in a CLIENT span.
  final autoGenId = await tracedAutoGen<String>(
    operation: 'model.create',
    invoke: () async {
      // Make the AutoGen call here, then report what it returned.
      const id = 'autogen_8f3a2c';
      return const AutoGenCallResult(
          value: id,
          result: AutoGenResult(
              runtime: 'single_threaded',
              teamKind: 'RoundRobinGroupChat',
              teamName: 'example',
              agentName: 'AssistantAgent',
              agentRole: 'example',
              modelProvider: 'standard',
              modelName: 'standard',
              taskId: 'task_8f3a2c',
              turn: 1,
              maxTurns: 1,
              terminationReason: 'max_turns_reached',
              toolName: 'example',
              toolCallCount: 3,
              promptTokens: 128,
              completionTokens: 128,
              totalTokens: 128,
              estCostMicros: 1,
              streamed: true,
              humanInputRequired: true,
              errorKind: 'max_turns_exceeded',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAutoGen model.create returned $autoGenId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAutoGenInstrumentationAsync.
  await runWithoutAutoGenInstrumentationAsync(
    () => tracedAutoGen<String>(
      operation: 'model.create',
      invoke: () async {
        const id = 'autogen_8f3a2c';
        return const AutoGenCallResult(
            value: id,
            result: AutoGenResult(
                runtime: 'single_threaded',
                teamKind: 'RoundRobinGroupChat',
                teamName: 'example',
                agentName: 'AssistantAgent',
                agentRole: 'example',
                modelProvider: 'standard',
                modelName: 'standard',
                taskId: 'task_8f3a2c',
                turn: 1,
                maxTurns: 1,
                terminationReason: 'max_turns_reached',
                toolName: 'example',
                toolCallCount: 3,
                promptTokens: 128,
                completionTokens: 128,
                totalTokens: 128,
                estCostMicros: 1,
                streamed: true,
                humanInputRequired: true,
                errorKind: 'max_turns_exceeded',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
