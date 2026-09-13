class MarketAnalysis {
  final String category;
  final double demandScore;
  final double averagePrice;
  final int totalListings;
  final List<TrendData> trends;
  final String summary;
  final String? recommendation;
  final double confidence;
  final DateTime analyzedAt;

  MarketAnalysis({
    required this.category,
    required this.demandScore,
    required this.averagePrice,
    required this.totalListings,
    required this.trends,
    required this.summary,
    this.recommendation,
    required this.confidence,
    required this.analyzedAt,
  });

  factory MarketAnalysis.fromJson(Map<String, dynamic> json) {
    return MarketAnalysis(
      category: json['category'],
      demandScore: (json['demand_score'] ?? 0).toDouble(),
      averagePrice: (json['average_price'] ?? 0).toDouble(),
      totalListings: json['total_listings'] ?? 0,
      trends: (json['trends'] as List?)
          ?.map((e) => TrendData.fromJson(e))
          .toList() ?? [],
      summary: json['summary'] ?? '',
      recommendation: json['recommendation'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      analyzedAt: DateTime.parse(json['analyzed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'demand_score': demandScore,
      'average_price': averagePrice,
      'total_listings': totalListings,
      'trends': trends.map((e) => e.toJson()).toList(),
      'summary': summary,
      'recommendation': recommendation,
      'confidence': confidence,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
}

class TrendData {
  final String period;
  final double value;
  final double changePercent;

  TrendData({
    required this.period,
    required this.value,
    required this.changePercent,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      period: json['period'],
      value: (json['value'] ?? 0).toDouble(),
      changePercent: (json['change_percent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'value': value,
      'change_percent': changePercent,
    };
  }
}
