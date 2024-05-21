// ignore_for_file: public_member_api_docs, sort_constructors_first
class ServiceModel {
  String? id;
  String? userId;
  String? categoryId;
  String? parentId;
  String? categoryName;
  String? partnerName;
  String? tax;
  String? taxType;
  String? title;
  String? slug;
  String? description;
  String? tags;
  String? imageOfTheService;
  String? price;
  String? discountedPrice;
  String? numberOfMembersRequired;
  String? duration;
  String? rating;
  String? numberOfRatings;
  String? onSiteAllowed;
  String? maxQuantityAllowed;
  String? isPayLaterAllowed;
  String? isDoorStepAllowed;
  String? isStoreAllowed;
  String? status;
  String? createdAt;
  String? cancelableTill;
  String? cancelable;
  String? isCancelable;
  String? inCartQuantity;
  String? taxId;
  String? taxTitle;
  String? taxPercentage;
  List<String>? otherImages;
  List<String>? files;
  String? longDescription;
  List<ServiceFaQs>? faqs;

  ServiceModel({
    this.id,
    this.userId,
    this.categoryId,
    this.parentId,
    this.categoryName,
    this.partnerName,
    this.tax,
    this.taxType,
    this.title,
    this.slug,
    this.description,
    this.tags,
    this.imageOfTheService,
    this.price,
    this.discountedPrice,
    this.numberOfMembersRequired,
    this.duration,
    this.rating,
    this.numberOfRatings,
    this.onSiteAllowed,
    this.maxQuantityAllowed,
    this.isPayLaterAllowed,
    this.isDoorStepAllowed,
    this.isStoreAllowed,
    this.status,
    this.createdAt,
    this.cancelableTill,
    this.cancelable,
    this.isCancelable,
    this.taxId,
    this.taxPercentage,
    this.taxTitle,
    this.inCartQuantity,
    this.otherImages,
    this.files,
    this.longDescription,
    this.faqs,
  });

  ServiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '0';
    userId = json['user_id'].toString();
    categoryId = json['category_id'].toString();
    parentId = json['parent_id'].toString();
    categoryName = json['category_name'].toString();
    partnerName = json['partner_name'].toString();
    tax = json['tax'].toString();
    taxType = json['tax_type'].toString();
    title = json['title'].toString();
    slug = json['slug'].toString();
    description = json['description'].toString();
    tags = json['tags'].toString();
    imageOfTheService = json['image_of_the_service'].toString();
    price = json['price'].toString();
    discountedPrice = json['discounted_price'].toString();
    numberOfMembersRequired = json['number_of_members_required'].toString();
    duration = json['duration'].toString();
    rating = json['rating'] ?? '0';
    numberOfRatings = json['number_of_ratings'].toString();
    onSiteAllowed = json['on_site_allowed'].toString();
    maxQuantityAllowed = json['max_quantity_allowed'].toString();
    isPayLaterAllowed = json['is_pay_later_allowed'].toString();
    isStoreAllowed = json['at_store'].toString();
    isDoorStepAllowed = json['at_doorstep'].toString();
    status = json['status'].toString();
    createdAt = json['created_at'].toString();
    cancelableTill = json['cancelable_till'].toString();
    cancelable = json['cancelable'].toString();
    isCancelable = json['is_cancelable'].toString();
    inCartQuantity = json['in_cart_quantity'].toString();
    taxId = json['tax_id'].toString();
    taxTitle = json['tax_title'].toString();
    taxPercentage = json['tax_percentage'].toString();
    otherImages = json.containsKey("other_images")
        ? json["other_images"].map<String>((e) => e.toString()).toList()
        : [];
    files = json.containsKey("files")
        ? json["files"].map<String>((e) => e.toString()).toList()
        : [];
    longDescription = json["long_description"].toString();
    faqs = json.containsKey("faqs")
        ? json["faqs"] != ""
            ? json["faqs"]
                .map<ServiceFaQs>(
                  (e) => ServiceFaQs.fromJson(e),
                )
                .toList()
            : []
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['category_id'] = categoryId;
    data['parent_id'] = parentId;
    data['category_name'] = categoryName;
    data['partner_name'] = partnerName;
    data['tax'] = tax;
    data['tax_type'] = taxType;
    data['title'] = title;
    data['slug'] = slug;
    data['description'] = description;
    data['tags'] = tags;
    data['image_of_the_service'] = imageOfTheService;
    data['price'] = price;
    data['discounted_price'] = discountedPrice;
    data['number_of_members_required'] = numberOfMembersRequired;
    data['duration'] = duration;
    data['rating'] = rating;
    data['number_of_ratings'] = numberOfRatings;
    data['on_site_allowed'] = onSiteAllowed;
    data['max_quantity_allowed'] = maxQuantityAllowed;
    data['is_pay_later_allowed'] = isPayLaterAllowed;
    data['at_doorstep'] = isDoorStepAllowed;
    data['at_store'] = isStoreAllowed;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['cancelable_till'] = cancelableTill;
    data['cancelable'] = cancelable;
    data['is_cancelable'] = isCancelable;
    data['in_cart_quantity'] = inCartQuantity;
    data['other_images'] = otherImages;
    data['files'] = files;
    data['long_description'] = longDescription;
    data["faqs"] = faqs?.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, userId: $userId, categoryId: $categoryId, parentId: $parentId, categoryName: $categoryName, partnerName: $partnerName, tax: $tax, taxType: $taxType, title: $title, slug: $slug, description: $description, tags: $tags, imageOfTheService: $imageOfTheService, price: $price, discountedPrice: $discountedPrice, numberOfMembersRequired: $numberOfMembersRequired, duration: $duration, rating: $rating, numberOfRatings: $numberOfRatings, onSiteAllowed: $onSiteAllowed, maxQuantityAllowed: $maxQuantityAllowed, isPayLaterAllowed: $isPayLaterAllowed, status: $status, createdAt: $createdAt, cancelableTill: $cancelableTill, cancelable: $cancelable, isCancelable: $isCancelable, inCartQuantity: $inCartQuantity)';
  }
}

class ServiceFaQs {
  String? question;
  String? answer;

  ServiceFaQs({
    this.question,
    this.answer,
  });

  factory ServiceFaQs.fromJson(Map<String, dynamic> json) => ServiceFaQs(
        question: json["question"].toString(),
        answer: json["answer"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "question": question.toString(),
        "answer": answer.toString(),
      };
}
