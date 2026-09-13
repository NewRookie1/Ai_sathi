import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../models/market_analysis.dart';
import '../models/price_suggestion.dart';
import 'api_service.dart';

class MarketService extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<MarketAnalysis> _analyses = [];
  bool _isLoading = false;
  String? _error;

  List<MarketAnalysis> get analyses => _analyses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<MarketAnalysis?> getAnalysis(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.get<MarketAnalysis>(
        ApiConstants.marketAnalysis,
        queryParameters: {'category': category},
        fromJson: (data) => MarketAnalysis.fromJson(data),
      );

      if (result.success && result.data != null) {
        _isLoading = false;
        notifyListeners();
        return result.data;
      }

      _error = result.message;
    } catch (e) {
      _error = 'Failed to load market analysis';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<List<MarketAnalysis>> getTrends() async {
    try {
      final result = await _api.get<List<dynamic>>(
        ApiConstants.marketTrends,
        fromJson: (data) => (data as List)
            .map((e) => MarketAnalysis.fromJson(e))
            .toList(),
      );

      if (result.success && result.data != null) {
        _analyses = result.data!.cast<MarketAnalysis>();
        notifyListeners();
        return _analyses;
      }
    } catch (e) {
      _error = 'Failed to load trends';
    }
    return [];
  }

  Future<PriceSuggestion?> suggestPrice({
    required String productId,
    double? rawMaterialCost,
    double? laborCost,
  }) async {
    try {
      final result = await _api.post<PriceSuggestion>(
        ApiConstants.productPrice(productId),
        data: {
          if (rawMaterialCost != null) 'raw_material_cost': rawMaterialCost,
          if (laborCost != null) 'labor_cost': laborCost,
        },
        fromJson: (data) => PriceSuggestion.fromJson(data),
      );

      if (result.success && result.data != null) {
        return result.data;
      }

      _error = result.message;
    } catch (e) {
      _error = 'Failed to get price suggestion';
    }
    return null;
  }
}
