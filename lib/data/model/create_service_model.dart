import 'package:edemand_partner/app/generalImports.dart';

class CreateServiceModel {
  CreateServiceModel({
    this.title,
    this.serviceId,
    this.description,
    this.price,
    this.duration,
    this.maxQty,
    this.image,
    this.tags,
    this.members,
    this.categories,
    this.iscancelable,
    this.is_pay_later_allowed,
    this.isDoorStepAllowed,
    this.isStoreAllowed,
    this.discounted_price,
    this.tax_type,
    this.tax,
    this.cancelableTill,
    this.taxId,
    this.other_images,
    this.files,
    this.long_description,
    this.faqs,
    this.status
  });
  String? serviceId;
  String? title;
  String? description;
  String? price;
  int? duration;
  String? maxQty;
  String? tags;
  String? members;
  String? categories;
  String? cancelableTill;
  int? iscancelable;
  int? is_pay_later_allowed;
  int? isStoreAllowed;
  int? isDoorStepAllowed;
  int? discounted_price;
  String? tax_type;
  String? status;
  String? taxId;
  int? tax;
  dynamic image;
  List<String>? other_images;
  List<String>? files;
  String? long_description;
  List<ServiceFaQs>? faqs;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (serviceId != '' && serviceId != null) {
      data['service_id'] = serviceId;
    }

    data['title'] = title;
    data['description'] = description;
    data['price'] = price;
    data['duration'] = duration;
    data['max_qty'] = maxQty;
    data['tags'] = tags;
    data['members'] = members;
    data['categories'] = categories;
    data['cancelable_till'] = cancelableTill;
    data['is_cancelable'] = iscancelable;
    data['is_pay_later_allowed'] = is_pay_later_allowed;
    data['at_store'] = isStoreAllowed;
    data['at_doorstep'] = isDoorStepAllowed;
    data['discounted_price'] = discounted_price;
    data['tax_type'] = tax_type;
    data['image'] = image;
    data['tax'] = tax;
    data['tax_id'] = taxId;
    data['status'] = status;

    if (long_description != null) {
      data['long_description'] = long_description;
    }

    if (faqs != null) {
      for (int i = 0; i < faqs!.length; i++) {
        data['faqs[$i][question]'] = faqs![i].question;
        data['faqs[$i][answer]'] = faqs![i].answer;
      }
    }
    final List<String> tagList = tags!.split(',');
    for (int i = 0; i < tagList.length; i++) {
      data['tags[$i]'] = tagList[i];
    }

    if (other_images != null && other_images!.isNotEmpty) {
      data['other_images'] = other_images;
    }
    if (files != null && files!.isNotEmpty) {
      data['files'] = files;
    }
    data['files'] = files;
    return data;
  }
}
