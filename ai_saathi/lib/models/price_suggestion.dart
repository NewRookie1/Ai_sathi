class PriceSuggestion {
  final double suggestedPrice;
  final String currency;
  final PriceRange priceRange;
  final String reasoning;
  final double confidence;
  final Map<String, dynamic>? inputData;
  final bool isEstimate;
  final DateTime generatedAt;

  PriceSuggestion({
    required this.suggestedPrice,
    this.currency = 'INR',
    required this.priceRange,
    required this.reasoning,
    required this.confidence,
    this.inputData,
    this.isEstimate = false,
    required this.generatedAt,
  });

  factory PriceSuggestion.fromJson(Map<String, dynamic> json) {
    return PriceSuggestion(
      suggestedPrice: (json['suggested_price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      priceRange: PriceRange.fromJson(json['price_range'] ?? {}),
      reasoning: json['reasoning'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      inputData: json['input_data'],
      isEstimate: json['is_estimate'] ?? false,
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suggested_price': suggestedPrice,
      'currency': currency,
      'price_range': priceRange.toJson(),
      'reasoning': reasoning,
      'confidence': confidence,
      'input_data': inputData,
      'is_estimate': isEstimate,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

class PriceRange {
  final double min;
  final double max;

  PriceRange({
    required this.min,
    required this.max,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}
