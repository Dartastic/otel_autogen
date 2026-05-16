// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_autogen_suppression.dart';

const _tracerName = 'dartastic_otel_libs_autogen';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AutoGenResult {
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

class AutoGenCallResult<T> {
  const AutoGenCallResult({required this.value, this.result});
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
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.runtime != null) {
        extras.add(OTel.attributeString('autogen.runtime', res.runtime!));
      }
      if (res.teamKind != null) {
        extras.add(OTel.attributeString('autogen.team.kind', res.teamKind!));
      }
      if (res.teamName != null) {
        extras.add(OTel.attributeString('autogen.team.name', res.teamName!));
      }
      if (res.agentName != null) {
        extras.add(OTel.attributeString(
          'autogen.agent.name',
          res.agentName!,
        ));
      }
      if (res.agentRole != null) {
        extras.add(OTel.attributeString(
          'autogen.agent.role',
          res.agentRole!,
        ));
      }
      if (res.modelProvider != null) {
        extras.add(OTel.attributeString(
          'autogen.model.provider',
          res.modelProvider!,
        ));
      }
      if (res.modelName != null) {
        extras.add(OTel.attributeString(
          'autogen.model.name',
          res.modelName!,
        ));
      }
      if (res.taskId != null) {
        extras.add(OTel.attributeString('autogen.task.id', res.taskId!));
      }
      if (res.turn != null) {
        extras.add(OTel.attributeInt('autogen.turn', res.turn!));
      }
      if (res.maxTurns != null) {
        extras.add(OTel.attributeInt('autogen.max_turns', res.maxTurns!));
      }
      if (res.terminationReason != null) {
        extras.add(OTel.attributeString(
          'autogen.termination.reason',
          res.terminationReason!,
        ));
      }
      if (res.toolName != null) {
        extras.add(OTel.attributeString('autogen.tool.name', res.toolName!));
      }
      if (res.toolCallCount != null) {
        extras.add(OTel.attributeInt(
          'autogen.tool.call_count',
          res.toolCallCount!,
        ));
      }
      if (res.promptTokens != null) {
        extras.add(OTel.attributeInt(
          'autogen.usage.prompt_tokens',
          res.promptTokens!,
        ));
      }
      if (res.completionTokens != null) {
        extras.add(OTel.attributeInt(
          'autogen.usage.completion_tokens',
          res.completionTokens!,
        ));
      }
      if (res.totalTokens != null) {
        extras.add(OTel.attributeInt(
          'autogen.usage.total_tokens',
          res.totalTokens!,
        ));
      }
      if (res.estCostMicros != null) {
        extras.add(OTel.attributeInt(
          'autogen.usage.est_cost_micros',
          res.estCostMicros!,
        ));
      }
      if (res.streamed != null) {
        extras.add(OTel.attributeBool('autogen.streamed', res.streamed!));
      }
      if (res.humanInputRequired != null) {
        extras.add(OTel.attributeBool(
          'autogen.human_input.required',
          res.humanInputRequired!,
        ));
      }
      if (res.errorKind != null) {
        extras.add(OTel.attributeString(
          'autogen.error.kind',
          res.errorKind!,
        ));
        span.setStatus(SpanStatusCode.Error, 'AutoGen ${res.errorKind}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'autogen.error.message',
          res.errorMessage!,
        ));
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
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
