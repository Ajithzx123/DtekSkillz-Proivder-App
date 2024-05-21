class CategoryStatesModel {
  CategoryStatesModel({
    required this.name,
    required this.totalCount,
  });

  factory CategoryStatesModel.fromMap(Map<String, dynamic> map) {
    return CategoryStatesModel(
      name: map['name'],
      totalCount: map['totalCount'],
    );
  }
  final String name;
  final double totalCount;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'totalCount': totalCount,
    };
  }

  @override
  String toString() =>
      'CategoryStatesModel(name: $name, totalCount: $totalCount)';
}
