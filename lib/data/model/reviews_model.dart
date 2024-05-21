class ReviewsModel {
  ReviewsModel({
    this.id,
    this.partnerId,
    this.partnerName,
    this.userName,
    this.profileImage,
    this.userId,
    this.serviceId,
    this.rating,
    this.comment,
    this.ratedOn,
    this.rateUpdatedOn,
    this.service_name,
    this.images,
  });

  ReviewsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    partnerId = json['partner_id'];
    partnerName = json['partner_name'];
    userName = json['user_name'];
    profileImage = json['profile_image'];
    userId = json['user_id'];
    serviceId = json['service_id'];
    rating = json['rating'];
    comment = json['comment'];
    ratedOn = json['rated_on'];
    rateUpdatedOn = json['rate_updated_on'];
    service_name = json['service_name'];
    images = json['images'].cast<String>();
  }
  String? id;
  String? partnerId;
  String? partnerName;
  String? userName;
  String? profileImage;
  String? userId;
  String? serviceId;
  String? rating;
  String? comment;
  String? ratedOn;
  String? rateUpdatedOn;
  String? service_name;
  List<String>? images;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['partner_id'] = partnerId;
    data['partner_name'] = partnerName;
    data['user_name'] = userName;
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['service_id'] = serviceId;
    data['rating'] = rating;
    data['comment'] = comment;
    data['rated_on'] = ratedOn;
    data['rate_updated_on'] = rateUpdatedOn;
    data['images'] = images;
    data['service_name'] = service_name;
    return data;
  }
}
