// ignore_for_file: public_member_api_docs, sort_constructors_first

class ServiceFilterDataModel {
  final String? minBudget;
  final String? maxBudget;
  final String? rating;
  final String? categoryId;
  final String? caetgoryIds;
  ServiceFilterDataModel({
    this.minBudget,
    this.maxBudget,
    this.rating,
    this.categoryId,
    this.caetgoryIds,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'min_budget': minBudget.toString(),
      'max_budget': maxBudget.toString(),
      'rating': rating,
      'category_id': categoryId,
    };
    if (rating == null) {
      data.remove('rating');
    }
    if (categoryId == null) {
      data.remove('category_id');
    }
    if (caetgoryIds != null) {
      data['category_ids'] = caetgoryIds;
    }

    return data;
  }

  factory ServiceFilterDataModel.fromMap(Map<String, dynamic> map) {
    return ServiceFilterDataModel(
      minBudget: map['min_budget'],
      maxBudget: map['max_budget'],
      rating: map['rating'],
      categoryId: map['category_id'],
      caetgoryIds: map['caetgory_ids'],
    );
  }

  @override
  String toString() {
    return 'CategoryFilterDataModel(minBudget: $minBudget, maxBudget: $maxBudget, rating: $rating, categoryId: $categoryId, caetgoryIds: $caetgoryIds)';
  }
}
