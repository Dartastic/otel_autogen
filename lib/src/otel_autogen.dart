// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_autogen_suppression.dart';

const _tracerName = 'dartastic_otel_libs_autogen';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class AutoGenResult {
  /// Creates a result.
  const AutoGenResult({
    this.runtime,
    this.teamKind,
    this.teamName,
    this.agentName,
    this.agentRole,
    this.modelProvider,
    this.modelName,
    this.taskId,
    this.turn,
    this.maxTurns,
    this.terminationReason,
    this.toolName,
    this.toolCallCount,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.estCostMicros,
    this.streamed,
    this.humanInputRequired,
    this.errorKind,
    this.errorMessage,
  });

  /// `single_threaded`, `worker`, `cluster`, `grpc`.
  final String? runtime;

  /// `RoundRobinGroupChat`, `SelectorGroupChat`, `Swarm`, `MagenticOne`,
  /// `MagenticOrch`, `Custom`.
  final String? teamKind;

  final String? teamName;

  /// `AssistantAgent`, `UserProxyAgent`, `CodeExecutorAgent`,
  /// `WebSurferAgent`, `FileSurferAgent`, `MagenticOrch`, `Custom`.
  final String? agentName;
  final String? agentRole;

  /// Underlying model client.
  final String? modelProvider;
  final String? modelName;

  final String? taskId;

  /// Current turn number in the conversation.
  final int? turn;
  final int? maxTurns;

  /// `max_turns_reached`, `text_mention`, `function_call`, `stop_message`,
  /// `external_termination`, `handoff`.
  final String? terminationReason;

  final String? toolName;
  final int? toolCallCount;

  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  /// LLM cost estimate in millionths of a USD.
  final int? estCostMicros;

  final bool? streamed;

  /// `UserProxyAgent` requested input from a human.
  final bool? humanInputRequired;

  /// `max_turns_exceeded`, `tool_error`, `model_error`,
  /// `code_execution_failed`, `permission_denied`, `serialization_error`.
  final String? errorKind;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AutoGenCallResult<T> {
  /// Creates a call result.
  const AutoGenCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AutoGenResult? result;
}

/// Wraps an AutoGen call in a CLIENT span. [operation] is one of
/// `team.run`, `team.runStream`, `team.reset`, `team.pause`,
/// `team.resume`, `agent.onMessages`, `agent.onMessagesStream`,
/// `agent.handoff`, `tool.invoke`, `model.create`, `model.createStream`,
/// `codeExecutor.execute`, `magentic.run`, `runtime.start`,
/// `runtime.stop`, `runtime.publishMessage`.
Future<T> tracedAutoGen<T>({
  required String operation,
  required Future<AutoGenCallResult<T>> Function() invoke,
}) async {
  if (autoGenInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'autogen',
    'rpc.method': operation,
    'autogen.operation': operation,
  };

  final span = _tracer().startSpan(
    'autogen $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.runtime != null) {
        extras.add(OTelAPI.attributeString('autogen.runtime', res.runtime!));
      }
      if (res.teamKind != null) {
        extras.add(OTelAPI.attributeString('autogen.team.kind', res.teamKind!));
      }
      if (res.teamName != null) {
        extras.add(OTelAPI.attributeString('autogen.team.name', res.teamName!));
      }
      if (res.agentName != null) {
        extras.add(OTelAPI.attributeString(
          'autogen.agent.name',
          res.agentName!,
        ));
      }
      if (res.agentRole != null) {
        extras.add(OTelAPI.attributeString(
          'autogen.agent.role',
          res.agentRole!,
        ));
      }
      if (res.modelProvider != null) {
        extras.add(OTelAPI.attributeString(
          'autogen.model.provider',
          res.modelProvider!,
        ));
      }
      if (res.modelName != null) {
        extras.add(OTelAPI.attributeString(
          'autogen.model.name',
          res.modelName!,
        ));
      }
      if (res.taskId != null) {
        extras.add(OTelAPI.attributeString('autogen.task.id', res.taskId!));
      }
      if (res.turn != null) {
        extras.add(OTelAPI.attributeInt('autogen.turn', res.turn!));
      }
      if (res.maxTurns != null) {
        extras.add(OTelAPI.attributeInt('autogen.max_turns', res.maxTurns!));
      }
      if (res.terminationReason != null) {
        extras.add(OTelAPI.attributeString(
          'autogen.termination.reason',
          res.terminationReason!,
        ));
      }
      if (res.toolName != null) {
        extras.add(OTelAPI.attributeString('autogen.tool.name', res.toolName!));
      }
      if (res.toolCallCount != null) {
        extras.add(OTelAPI.attributeInt(
          'autogen.tool.call_count',
          res.toolCallCount!,
        ));
      }
      if (res.promptTokens != null) {
        extras.add(OTelAPI.attributeInt(
          'autogen.usage.prompt_tokens',
          res.promptTokens!,
        ));
      }
      if (res.completionTokens != null) {
        extras.add(OTelAPI.attributeInt(
          'autogen.usage.completion_tokens',
          res.completionTokens!,
        ));
      }
      if (res.totalTokens != null) {
        extras.add(OTelAPI.attributeInt(
          'autogen.usage.total_tokens',
          res.totalTokens!,
        ));
      }
      if (res.estCostMicros != null) {
        extras.add(OTelAPI.attributeInt(
          'autogen.usage.est_cost_micros',
          res.estCostMicros!,
        ));
      }
      if (res.streamed != null) {
        extras.add(OTelAPI.attributeBool('autogen.streamed', res.streamed!));
      }
      if (res.humanInputRequired != null) {
        extras.add(OTelAPI.attributeBool(
          'autogen.human_input.required',
          res.humanInputRequired!,
        ));
      }
      if (res.errorKind != null) {
        extras.add(OTelAPI.attributeString(
          'autogen.error.kind',
          res.errorKind!,
        ));
        span.setStatus(SpanStatusCode.Error, 'AutoGen ${res.errorKind}');
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'autogen.error.message',
          res.errorMessage!,
        ));
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
