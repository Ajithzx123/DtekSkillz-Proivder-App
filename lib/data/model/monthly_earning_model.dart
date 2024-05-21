class MonthlySalesModel {
  MonthlySalesModel({
    required this.name,
    required this.count,
  });

  factory MonthlySalesModel.fromMap(Map<String, dynamic> map) {
    return MonthlySalesModel(
      name: map['name'] as String,
      count: map['count'] as String,
    );
  }
  final String name;
  final String count;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'count': count,
    };
  }

  @override
  String toString() => 'MonthlyEarningModel(name: $name, count: $count)';
}
