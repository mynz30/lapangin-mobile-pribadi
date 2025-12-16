class RatingStats {
  final double average;
  final int count1;
  final int count2;
  final int count3;
  final int count4;
  final int count5;
  final int total;

  RatingStats({
    required this.average,
    required this.count1,
    required this.count2,
    required this.count3,
    required this.count4,
    required this.count5,
    required this.total,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      average: (json['average'] ?? 0).toDouble(),
      count1: json['count_1'] ?? 0,
      count2: json['count_2'] ?? 0,
      count3: json['count_3'] ?? 0,
      count4: json['count_4'] ?? 0,
      count5: json['count_5'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
