// ignore_for_file: public_member_api_docs, sort_constructors_first
class RatingsModel {
  String? totalRatings;
  String? averageRating;
  String? rating5;
  String? rating4;
  String? rating3;
  String? rating2;
  String? rating1;

  RatingsModel({
    this.totalRatings,
    this.averageRating,
    this.rating5,
    this.rating4,
    this.rating3,
    this.rating2,
    this.rating1,
  });

  RatingsModel.fromJson(Map<String, dynamic> json) {
    totalRatings = json['total_ratings'].toString();
    averageRating = json['average_rating'].toString();
    rating5 = json['rating_5'].toString();
    rating4 = json['rating_4'].toString();
    rating3 = json['rating_3'].toString();
    rating2 = json['rating_2'].toString();
    rating1 = json['rating_1'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_ratings'] = totalRatings.toString();
    data['average_rating'] = averageRating.toString();
    data['rating_5'] = rating5.toString();
    data['rating_4'] = rating4.toString();
    data['rating_3'] = rating3.toString();
    data['rating_2'] = rating2.toString();
    data['rating_1'] = rating1.toString();
    return data;
  }

  @override
  String toString() {
    return 'RatingsModel(totalRatings: $totalRatings, averageRating: $averageRating, rating5: $rating5, rating4: $rating4, rating3: $rating3, rating2: $rating2, rating1: $rating1)';
  }
}
