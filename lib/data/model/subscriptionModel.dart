class SubscriptionInformation {
  final String? subscriptionId;
  final String? isSubscriptionActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? isPayment;
  final String? id;
  final String? partnerId;
  final String? purchaseDate;
  final String? expiryDate;
  final String? name;
  final String? description;
  final String? duration;
  final String? price;
  final String? priceWithTax;
  final String? discountPrice;
  final String? discountPriceWithTax;
  final String? orderType;
  final String? maxOrderLimit;
  final String? isCommision;
  final String? commissionThreshold;
  final String? commissionPercentage;
  final String? publish;
  final String? taxId;
  final String? taxType;
  final String? taxPercenrage;

  SubscriptionInformation(
      {this.priceWithTax,
      this.discountPriceWithTax,
      this.subscriptionId,
      this.isSubscriptionActive,
      this.createdAt,
      this.updatedAt,
      this.isPayment,
      this.id,
      this.partnerId,
      this.purchaseDate,
      this.expiryDate,
      this.name,
      this.description,
      this.duration,
      this.price,
      this.discountPrice,
      this.orderType,
      this.maxOrderLimit,
      this.isCommision,
      this.commissionThreshold,
      this.commissionPercentage,
      this.publish,
      this.taxId,
      this.taxType,
      this.taxPercenrage});

  factory SubscriptionInformation.fromJson(Map<String, dynamic> json) {
    return SubscriptionInformation(
      subscriptionId: json["subscription_id"] ?? "0",
      isSubscriptionActive: json["isSubscriptionActive"] ?? "",
      //0-pending 1-success 2-failed
      isPayment: json["is_payment"] ?? "2",
      id: json["id"] ?? "0",
      partnerId: json["partner_id"] ?? "0",
      purchaseDate: json["purchase_date"].toString(),
      expiryDate: json["expiry_date"].toString(),
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      duration: json["duration"] ?? "",
      price: json["price"] ?? "",
      discountPrice: json["discount_price"] ?? "",
      orderType: json["order_type"] ?? "",
      maxOrderLimit: json["max_order_limit"] ?? "",
      isCommision: json["is_commision"] ?? "",
      commissionThreshold: json["commission_threshold"] ?? "",
      commissionPercentage: json["commission_percentage"] ?? "",
      publish: json["publish"] ?? "",
      taxId: json["tax_id"] ?? "",
      taxType: json["tax_type"] ?? "",
      discountPriceWithTax: json["price_with_tax"] ?? "0",
      priceWithTax: json["original_price_with_tax"] ?? "0",
      taxPercenrage: json["tax_percentage"] != ""
          ? double.parse((json["tax_percentage"] ?? "0").toString()).round().toString()
          : "0",
    );
  }

  Map<String, dynamic> toJson() => {
        "subscription_id": subscriptionId,
        "isSubscriptionActive": isSubscriptionActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_payment": isPayment,
        "id": id,
        "partner_id": partnerId,
        "name": name,
        "description": description,
        "duration": duration,
        "price": price,
        "discount_price": discountPrice,
        "order_type": orderType,
        "max_order_limit": maxOrderLimit,
        "is_commision": isCommision,
        "commission_threshold": commissionThreshold,
        "commission_percentage": commissionPercentage,
        "publish": publish,
        "tax_id": taxId,
        "tax_type": taxType,
        "purchase_date": purchaseDate,
        "expiry_date": expiryDate,
        "price_with_tax": discountPriceWithTax,
        "original_price_with_tax": priceWithTax,
        "tax_percentage": taxPercenrage,
      };
}
