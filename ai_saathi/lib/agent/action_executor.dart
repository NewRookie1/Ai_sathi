import 'package:flutter/material.dart';
import '../models/agent_action.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class ActionExecutor extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isExecuting = false;
  String? _error;

  bool get isExecuting => _isExecuting;
  String? get error => _error;

  Future<Map<String, dynamic>?> execute(
    AgentAction action, {
    Map<String, dynamic>? context,
  }) async {
    _isExecuting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.post<Map<String, dynamic>>(
        '${ApiConstants.agentExecute}/tool',
        data: {
          'tool': action.tool,
          'parameters': action.parameters,
          if (context != null) 'context': context,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      if (result.success && result.data != null) {
        _isExecuting = false;
        notifyListeners();
        return result.data;
      }

      _error = result.message;
    } catch (e) {
      _error = 'Failed to execute action';
    }

    _isExecuting = false;
    notifyListeners();
    return null;
  }

  Future<List<Map<String, dynamic>>> executeAll(
    List<AgentAction> actions, {
    Map<String, dynamic>? context,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final action in actions) {
      if (action.requiresConfirmation) {
        results.add({
          'action': action.tool,
          'requires_confirmation': true,
          'message': action.confirmationMessage,
        });
        break;
      }

      final result = await execute(action, context: context);
      if (result != null) {
        results.add(result);
        context = {...?context, ...result};
      } else {
        break;
      }
    }

    return results;
  }
}
