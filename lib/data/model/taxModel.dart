class Taxes {
  Taxes({
    this.id,
    this.title,
    this.percentage,
  });

  factory Taxes.fromJson(Map<String, dynamic> json) {
    return Taxes(
      id: json['id'],
      title: json['title'],
      percentage: json['percentage'],
    );
  }

  final String? id;
  final String? title;
  final String? percentage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'percentage': percentage,
      };
}
