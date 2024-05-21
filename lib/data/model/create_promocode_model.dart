class CreatePromocodeModel {

  CreatePromocodeModel(
      {this.promoCode,
      this.partnerId,
      this.promo_id,
      this.startDate,
      this.endDate,
      this.minimumOrderAmount,
      this.discount,
      this.discountType,
      this.maxDiscountAmount,
      this.status,
      this.image,
      this.repeat_usage,
      this.no_of_users,
      this.no_of_repeat_usage,
      this.message,});

  CreatePromocodeModel.fromJson(Map<String, dynamic> json) {
    promoCode = json['promo_code'];
    partnerId = json['partner_id'];
    startDate = json['start_date'];
    promo_id = json['promo_id'];
    endDate = json['end_date'];
    minimumOrderAmount = json['minimum_order_amount'];
    discount = json['discount'];
    discountType = json['discount_type'];
    maxDiscountAmount = json['max_discount_amount'];
    status = json['status'];
    message = json['message'];
    image = json['image'];
    no_of_users = json['no_of_users'];
    no_of_repeat_usage = json['no_of_repeat_usage'];
    repeat_usage = json['repeat_usage'];
  }
  String? promoCode;
  String? promo_id;
  String? partnerId;
  String? startDate;
  String? endDate;
  String? minimumOrderAmount;
  String? discount;
  String? discountType;
  String? maxDiscountAmount;
  String? status;
  String? message;
  String? no_of_users;
  dynamic image;
  String? repeat_usage;
  String? no_of_repeat_usage;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['promo_code'] = promoCode;
    data['partner_id'] = partnerId;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['minimum_order_amount'] = minimumOrderAmount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['max_discount_amount'] = maxDiscountAmount;
    data['status'] = status;
    data['message'] = message;
    data['no_of_users'] = no_of_users;
    data['image'] = image;
    data['promo_id'] = promo_id;
    data['repeat_usage'] = repeat_usage;

    data['no_of_repeat_usage'] = no_of_repeat_usage;
    return data;
  }
}
